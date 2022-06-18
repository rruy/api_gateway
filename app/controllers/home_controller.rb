class HomeController  < ApplicationController
  def index
    render json: { entry_point: '/api/v1/' }
  end
end
