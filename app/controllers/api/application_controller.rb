module Api
  class ApplicationController < ActionController::Base
    include ReverseProxy::Controller

    protected

    def gateway(api_path)
      log_event_request(request)
      reverse_proxy api_path  do |config|
        config.on_missing do |code, response|
          redirect_to root_path, allow_other_host: true and return
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
