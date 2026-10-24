class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  private
    def authenticate!
      token = authenticate_with_http_token { |t, _options| t }
      @current_user = User.find_by_token_for(:api_auth, token) if token

      render json: { message: "Unauthorized" }, status: :unauthorized unless @current_user
    end
end
