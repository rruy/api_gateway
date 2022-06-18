module Api
  module V1
    class EntryPointController < Api::ApplicationController
      def index
        render json: { entry_point: [] }
      end
    end
  end
end
