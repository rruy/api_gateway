module Api
  class ApplicationController < ActionController::Base
    include ReverseProxy::Controller

    protected

    def gateway
      reverse_proxy ENV['REVERSE_PROXY'] do |config|
        config.on_missing do |code, response|
          redirect_to root_url, allow_other_host: true and return
        end
      end
    end
  end
end
