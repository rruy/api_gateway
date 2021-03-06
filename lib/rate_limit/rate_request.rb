# frozen_string_literal: true

require 'json'
require_relative './rule'

class RateRequest
  def initialize(app, &block)
    @app = app
    @logger = nil
    @rules = []
    @cache = {}
    block.call(self)
  end

  def call(env)
    request = Rack::Request.new(env)
    @logger = env['rack.logger']
    (limit_header = allowed?(request)) ? respond(env, limit_header) : rate_limit_exceeded(env['HTTP_ACCEPT'])
  end

  def respond(env, limit_header)
    status, header, response = @app.call(env)
    limit_header.instance_of?(Hash) ? [status, header.merge(limit_header), response] : [status, header, response]
  end

  def rate_limit_exceeded(accept)
    case accept.gsub(/;.*/, '').split(',')[0]
    when 'application/json' then message = ['Rate Limit Exceeded'].to_json
                                 type = 'application/json'
    else
      message = ['Rate Limit Exceeded']
      type = 'text/html'
    end
    [403, { 'Content-Type' => type }, message]
  end

  def define_rule(options)
    @rules << Rule.new(options)
  end

  def set_cache(cache)
    @cache = cache
  end

  def cache
    case @cache
    when Proc then @cache.call
    else @cache
    end
  end

  def cache_has?(key)
    return cache.key?(key) if cache.respond_to?(:has_key?)
    return cache.get(key) if cache.respond_to?(:get)
    return cache.exist?(key) if cache.respond_to?(:exist?)

    false
  end

  def cache_get(key)
    return cache[key] if cache.respond_to?(:[])
    return cache.get(key) || nil if cache.respond_to?(:get)
    return cache.fetch(key) if cache.respond_to?(:fetch)
  end

  def cache_set(key, value)
    return cache[key] = value if cache.respond_to?(:[])
    return cache.set(key, value) if cache.respond_to?(:set)
    return cache.write(key, value) if cache.respond_to?(:write)
  end

  def logger
    @logger || Rack::NullLogger.new(nil)
  end

  def allowed?(request)
    if rule = find_matching_rule(request)
      logger.debug "[#{self}] #{request.ip}:#{request.path}: Rate limiting rule matched."
      apply_rule(request, rule)
    else
      true
    end
  end

  def find_matching_rule(request)
    @rules.each do |rule|
      return rule if request.path =~ rule.match
    end
    nil
  end

  def apply_rule(request, rule)
    key = rule.get_key(request)
    if cache_has?(key)
      record = cache_get(key)
      logger.debug "[#{self}] #{request.ip}:#{request.path}: Rate limiting entry: '#{key}' => #{record}"

      if (reset = Time.at(record.split(':')[1].to_i)) > Time.now
        # rule hasn't been reset yet
        times = record.split(':')[0].to_i
        cache_set(key, "#{times + 1}:#{reset.to_i}")
        if (times) < rule.limit
          # within rate limit
          response = get_header(times + 1, reset, rule.limit)
        else
          logger.debug "[#{self}] #{request.ip}:#{request.path}: Rate limited; request rejected."
          return false
        end
      else
        response = get_header(1, rule.get_expiration, rule.limit)
        cache_set(key, "1:#{rule.get_expiration.to_i}")
      end
    else
      response = get_header(1, rule.get_expiration, rule.limit)
      cache_set(key, "1:#{rule.get_expiration.to_i}")
    end
    response
  end

  def get_header(times, reset, limit)
    { 'x-RateLimit-Limit' => limit.to_s, 'x-RateLimit-Remaining' => (limit - times).to_s,
      'x-RateLimit-Reset' => reset.strftime('%d%m%y%H%M%S') }
  end
end
