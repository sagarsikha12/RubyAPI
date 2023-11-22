require 'jwt'

class Api::V1::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token


  def check_session
    if current_user
      render json: { user: { email: current_user.email } }, status: :ok
    else
      render json: { error: 'Not Authorized' }, status: :unauthorized
    end
  end

  def create
    user = User.find_by(email: login_params[:email])

    if user && user.valid_password?(login_params[:password])
        sign_in user

        # Create JWT token
        payload = { user_id: user.id }
        token = JWT.encode(payload, 'secret', 'HS256') # 'secret' should be a strong secret key

        render json: {
            message: 'Login successful',
            user: { email: user.email },
            jwt: token
        }, status: :ok
    else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    render json: { message: 'Logged out successfully' }, status: :ok if signed_out
  end
  def csrf_token
    render json: { csrf_token: form_authenticity_token }
  end

  private

  def login_params
      params.require(:user).permit(:email, :password)
  end

end
