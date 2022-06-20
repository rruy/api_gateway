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

      def per_hours
        requests = Request.where('created_at BETWEEN ? AND ?', Time.now.beginning_of_hour, Time.now.end_of_hour).size

        render json: { requestes_by_hour: requests.to_json }
      end

      def per_day
        requests = Request.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_day, DateTime.now.end_of_day).size
        render json: { requests_today: requests }
      end
    end
  end
end
