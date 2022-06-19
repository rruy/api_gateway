require 'benchmark'

module Api
  class ApplicationController < ActionController::Base
    include ReverseProxy::Controller

    protected

    def process_request(api_path)
      time = Benchmark.measure do
        gateway(api_path)
      end
      log_event_request(request, response.status, time.real)
    end

    private

    def gateway(api_path)
      reverse_proxy api_path  do |config|
        config.on_missing do |code, response|
          redirect_to root_path, allow_other_host: true and return
        end
      end
    end

    def log_event_request(request, status_code, time_total)
      origin = request.headers['origin']
      remote_ip = request.remote_ip
      url = request.url
      payload = request.body.to_json

      RegisterRequestJob.perform_now(remote_ip, origin, url, payload, status_code, time_total)
    end
  end
end
