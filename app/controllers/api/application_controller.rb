module Api
  class ApplicationController < ActionController::Base
    include ReverseProxy::Controller

    protected

    def gateway
      log_event_request(request)
      reverse_proxy ENV['REVERSE_PROXY'] do |config|
        config.on_missing do |code, response|
          redirect_to root_url, allow_other_host: true and return
        end
      end
    end

    private

    def log_event_request(request)
      origin = request.headers['origin']
      remote_ip = request.remote_ip
      url = request.url
      payload = request.body.to_json

      RegisterRequestJob.perform_now(remote_ip, origin, url, payload)
    end
  end
end
