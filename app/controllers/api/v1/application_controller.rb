module Api
  module V1
    class ApplicationController < ActionController::API
      JWT_SECRET = Rails.application.credentials.jwt_secret || 'fallback_secret'
      JWT_ALGORITHM = 'HS256'

      # You no longer need the "before_action :authenticate_user_from_token!" here,
      # since you're doing the decoding directly in the UsersController#current action.

      protected
      def authenticate_jwt!
        decoded_data = decode_token
        if decoded_data.present?
          user_id = decoded_data[0]['user_id']
          puts "Current User: #{@current_user}"
          @current_user = User.find_by(id: user_id)
        end

        render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
      end

      # This method will now just be used by the UsersController.
      def decode_token
        auth_header = request.headers['Authorization']
        token = auth_header&.split('Bearer ')&.last

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


      # This method is no longer needed because you're setting up @user directly in UsersController#current.
      # But you can leave it here in case you want to use it in other controllers in the future.

      # def authenticate_user_from_token!
      #   bearer_token = request.headers['Authorization']&.split(' ')&.last
      #   Rails.logger.info "Received Token: #{bearer_token}"
      #
      #   return render json: { error: 'Token missing' }, status: :unauthorized unless bearer_token
      #
      #   decoded_data = decode_jwt(bearer_token)
      #   Rails.logger.info "Decoded Data: #{decoded_data}"
      #
      #   return render json: { error: 'Token invalid' }, status: :unauthorized unless decoded_data
      #
      #   @current_user = User.find_by(id: decoded_data['user_id'])
      #   render json: { error: 'User not found' }, status: :not_found unless @current_user
      # end

    end
  end
end
