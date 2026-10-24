class Api::V1::MeController < ApplicationController
  before_action :authenticate!

  def show
    render json: { name: @current_user.name, message: "Welcome #{@current_user.name}" }
  end
end
