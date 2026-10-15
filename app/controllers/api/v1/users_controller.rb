class Api::V1::UsersController < ApplicationController
  before_action :load_user, only: [ :show, :update, :destroy ]

  def create
    @user = User.new(user_params)

    if user.save
      render json: { id: @user.id, name: @user.name, email: @user.email }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    if @user
      render json: { name: @user.name, message: "Welcome #{@user.name}" }, status: :ok
    else
      render json: { message: "User not found" }
    end
  end

  private
    def load_user
      @user = User.find_by(id: params[:id])
    end

    def user_params
      params.expect(user: [ :name, :email, :password ])
    end
end
