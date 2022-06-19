# frozen_string_literal: true

require 'rack'
require 'addressable/uri'
require 'net/http'

module ReverseProxy
  class Client
    @@callback_methods = %i[
      on_response
      on_set_cookies
      on_connect
      on_success
      on_redirect
      on_missing
      on_error
      on_complete
    ]

    # Define callback setters
    @@callback_methods.each do |method|
      define_method(method) do |&block|
        callbacks[method] = block
      end
    end

    attr_accessor :url, :callbacks
    attr_reader :target_request, :target_response, :status_code, :payload

    def initialize(url)
      self.url = url
      self.callbacks = {}

      @@callback_methods.each do |method|
        callbacks[method] = proc {}
      end

      yield(self) if block_given?
    end

    def define_headers(source_request, options)
      extract_http_request_headers(source_request.env).merge(options[:headers])
    end

    def has_body?(target_request, source_request)
      target_request.request_body_permitted? && source_request.body
    end

    def request(env, options = {})
      options.reverse_merge!(
        headers: {},
        http: {},
        path: nil,
        username: nil,
        password: nil,
        verify_ssl: true,
        reset_accept_encoding: false
      )

      source_request = Rack::Request.new(env)

      uri = Addressable::URI.parse("#{url}#{options[:path] || env['ORIGINAL_FULLPATH']}")

      target_request_headers = define_headers(source_request, options)

      create_request(uri, source_request, target_request_headers, options)

      callbacks[:on_response].call(payload)

      define_cookies(target_response, payload)
      define_callback(status_code, payload, target_response)

      payload
    end

    def define_cookies(target_response, payload)
      if set_cookie_headers = target_response.to_hash['set-cookie']
        set_cookies_hash = {}

        set_cookie_headers.each do |set_cookie_header|
          set_cookie_hash = parse_cookie(set_cookie_header)
          name = set_cookie_hash[:name]
          set_cookies_hash[name] = set_cookie_hash
        end

        callbacks[:on_set_cookies].call(payload | [set_cookies_hash])
      end
    end

    def create_request(uri, source_request, target_request_headers, options)
      request_method = source_request.request_method.capitalize
      @target_request = Net::HTTP.const_get(request_method).new(uri.request_uri, target_request_headers)

      if options[:username] && options[:password]
        @target_request.basic_auth(options[:username], options[:password])
      end

      if has_body?(@target_request, source_request)
        source_request.body.rewind
        @target_request.body_stream = source_request.body
      end

      @target_request.content_length = source_request.content_length || 0
      @target_request.content_type   = source_request.content_type if source_request.content_type

      @target_response = nil
      @target_request['Accept-Encoding'] = nil if options[:reset_accept_encoding]

      http_options = {}
      http_options[:use_ssl] = (uri.scheme == 'https')
      http_options[:verify_mode] = OpenSSL::SSL::VERIFY_NONE unless options[:verify_ssl]
      http_options.merge!(options[:http]) if options[:http]

      http_options.merge!(options[:http]) if options[:http]

      Net::HTTP.start(uri.hostname, uri.port, http_options) do |http|
        callbacks[:on_connect].call(http)
        @target_response = http.request(@target_request)
      end

      @status_code = @target_response.code.to_i
      @payload = [status_code, @target_response]
    end

    def define_callback(status_code, payload, target_response, redirect_url = nil)
      case status_code
      when 200..299
        callbacks[:on_success].call(payload)
      when 300..399
        callbacks[:on_redirect].call(payload | [redirect_url]) if redirect_url = target_response['Location']
      when 400..499
        callbacks[:on_missing].call(payload)
      when 500..599
        callbacks[:on_error].call(payload)
      end

      callbacks[:on_complete].call(payload)
    end

    private

    def extract_http_request_headers(env)
      env.reject do |k, v|
        !(/^HTTP_[A-Z_]+$/ === k) || k == 'HTTP_VERSION' || v.nil?
      end.map do |k, v|
        [reconstruct_header_name(k), v]
      end.each_with_object(Rack::Utils::HeaderHash.new) do |k_v, hash|
        k, v = k_v
        hash[k] = v
      end
    end

    def reconstruct_header_name(name)
      name.sub(/^HTTP_/, '').gsub('_', '-')
    end

    COOKIE_PARAM_PATTERN = %r{\A([^(),/<>@;:\\"\[\]?={}\s]+)(?:=([^;]*))?\Z}.freeze
    COOKIE_SPLIT_PATTERN = /;\s*/.freeze

    def parse_cookie(cookie_str)
      params = cookie_str.split(COOKIE_SPLIT_PATTERN)
      info = params.shift.match(COOKIE_PARAM_PATTERN)
      return {} unless info

      cookie = {
        name: info[1],
        value: CGI.unescape(info[2])
      }

      params.each do |param|
        result = param.match(COOKIE_PARAM_PATTERN)
        next unless result

        key = result[1].downcase.to_sym
        value = result[2]

        case key
        when :expires
          begin
            cookie[:expires] = Time.parse(value)
          rescue ArgumentError
          end
        when :httponly, :secure
          cookie[key] = true
        else
          cookie[key] = value
        end
      end

      cookie
    end
  end
end
