# frozen_string_literal: true

module Api
  module V1
    class ForwardesController < Api::ApplicationController
      before_action :gateway

      def cart
        render json: { cart: 'Sucesso' }
      end

      def catalog
        render json: { catalog: 'Sucesso' }
      end
    end
  end
end
