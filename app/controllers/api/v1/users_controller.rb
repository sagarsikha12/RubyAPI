
module Api
  module V1
    class UsersController < ApplicationController

      def index
        decoded_data = decode_token
        if decoded_data.present?
        # Check if the current user is an admin
          user_id = decoded_data[0]['user_id']

          @current_user = User.find_by(id: user_id)
          if @current_user.admin == true # Assuming the 'admin' column is a boolean
          # Return all user details in JSON format
            users = User.all
            render json: { success: true, users: users.map { |user| user_details(user) } }
          else
            render json: { success: false, message: "You are not authorized to access this resource" }, status: :forbidden
          end
        end

      end
      # Method to delete a user by ID
      def destroy
        user = User.find_by(id: params[:id])
        if user
          decoded_data = decode_token
          if decoded_data.present?
          # Check if the current user is an admin
            user_id = decoded_data[0]['user_id']

            @current_user = User.find_by(id: user_id)
            # Check if the current user is an admin or if they are trying to delete their own account
            if @current_user.admin || user != @current_user
              user.destroy
              render json: { success: true, message: "User deleted successfully" }
            else
              render json: { success: false, message: "You are not authorized to delete this user" }, status: :forbidden
            end
          end
        else
          render json: { success: false, message: "User not found" }, status: :not_found
        end
      end

      def update_password
        decoded_data = decode_token
        if decoded_data.present?
          user_id = decoded_data[0]['user_id']
          user =User.find_by(id: user_id)

          if user.valid_password?(params[:current_password])
            if user.update(password: params[:new_password])
              render json: { message: 'Password updated successfully' }, status: :ok
            else
              render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
            end
          else
            render json: { errors: ['Current password is incorrect'] }, status: 401
          end
        else
          render json: { errors: ['Not Authorized'] }, status: :unprocessable_entity
        end
      end


      # Method to make a user admin by ID
      def make_admin
        user = User.find_by(id: params[:id])
        if user
          decoded_data = decode_token
          if decoded_data.present?
            # Check if the current user is an admin
            user_id = decoded_data[0]['user_id']

            @current_user = User.find_by(id: user_id)
            # Check if the current user is an admin
            if @current_user.admin
              user.update(admin: true)
              render json: { success: true, message: "User is now an admin" }
            else
              render json: { success: false, message: "You are not authorized to make this user an admin" }, status: :forbidden
            end
          end
        else
          render json: { success: false, message: "User not found" }, status: :not_found
        end
      end


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
      def user_details(user)
        { id: user.id, email: user.email, firstname: user.first_name, lastname:user.last_name, admin: user.admin, created_at: user.created_at, updated_at: user.updated_at }
        # Add more user attributes as needed
      end

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
