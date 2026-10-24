class Api::V1::SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create

  def create
    user = User.find_by(email: session_params[:email])

    if user&.authenticate(session_params[:password])
      render json: { token: user.generate_token_for(:api_auth), user: { id: user.id, name: user.name, email: user.email } }, status: :ok
    else
      render json: { message: "Invalid email or password" }, status: :unauthorized
    end
  end

  private
    def session_params
      params.expect(session: [ :email, :password ])
    end
end
