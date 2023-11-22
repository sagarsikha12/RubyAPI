
module Api
  module V1
    class UsersController < ApplicationController

      def show
        render json: { user: { email: @current_user.email } } # Add other user data as needed
      end
      def current
        decoded_data = decode_token
        if decoded_data.present?
          user_id = decoded_data[0]['user_id']
          @user = User.find_by(id: user_id)
          if @user
            render json: { success: true, user: { email: @user.email, admin:@user.admin} }
          else
            render json: { success: false, message: "User not found" }, status: :not_found
          end
        else
          render json: { success: false, message: "Token invalid or expired" }, status: :unauthorized
        end
      end

      private

      def decode_token
        auth_header = request.headers['Authorization']
        token = auth_header.split(' ')[1] if auth_header
        if token
          begin
            JWT.decode(token, 'secret', true, algorithm: 'HS256')
          rescue JWT::DecodeError
            []
          end
        else
          []
        end
      end

    end
  end
end
