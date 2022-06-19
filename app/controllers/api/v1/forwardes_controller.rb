# frozen_string_literal: true

module Api
  module V1
    class ForwardesController < Api::ApplicationController
      def cards
        gateway(ENV['REVERSE_PROXY_SRV_1'])
      end
      def catalog
        gateway(ENV['REVERSE_PROXY_SRV_2'])
      end
      def cart
        gateway(ENV['REVERSE_PROXY_SRV_3'])
      end
      def products
        gateway(ENV['REVERSE_PROXY_SRV_4'])
      end
      def not_found
        render json: { error: "Url not found!" }
      end
    end
  end
end
