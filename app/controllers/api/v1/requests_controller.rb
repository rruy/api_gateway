# frozen_string_literal: true

module Api
  module V1
    class RequestsController < Api::ApplicationController
      def index
        render json: Request.all.order(id: :desc).to_json
      end

      def errors
        render json: Request.where('status_code BETWEEN ? AND ?', 400, 599).to_json
      end

      def requests_per_hours
        render json: {}
      end

      def requests_per_day
        render json: {}
      end
    end
  end
end
