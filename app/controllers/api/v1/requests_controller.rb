# frozen_string_literal: true

module Api
  module V1
    class RequestsController < Api::ApplicationController
      def index
        render json: Request.all.to_json
      end
    end
  end
end
