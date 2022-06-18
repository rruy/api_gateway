# frozen_string_literal: true

module Api
  module V1
    class ProxiesController < Api::ApplicationController
      def cart
        render json: { cart: 'Sucesso' }
      end

      def catalog
        render json: { catalog: 'Sucesso' }
      end
    end
  end
end
