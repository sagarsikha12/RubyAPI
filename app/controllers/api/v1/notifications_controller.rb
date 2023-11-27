module Api
  module V1
    class NotificationsController < ApplicationController

      before_action :authenticate_jwt!, only: [:create, :update, :destroy]

      def index
        user_id = decode_token[0]['user_id'] # Get user_id from the decoded token
        status = params[:status] || [:unread, :unapproved]

        # Check if 'status' parameter is set to 'All'
        if status == 'All'
          @notifications = Notification.where(user_id: user_id)
        else
          @notifications = Notification.where(user_id: user_id, status: status)
        end

        render json: @notifications
      end


      def destroy
        user_id = decode_token[0]['user_id'] # Get user_id from the decoded token
        if params[:id]
          # Delete the notification with the specified id
          @notification = Notification.find_by(id: params[:id], user_id: user_id)
          if @notification
            @notification.destroy
            render json: { success: true, message: 'Notification deleted successfully' }
          else
            render json: { success: false, message: 'Notification not found' }, status: :not_found
          end
        else
          # Delete notifications based on user_id and status
          @notifications = Notification.where(user_id: user_id, status: [:unread, :approved]).delete_all
          render json: { success: true, message: 'Notifications deleted successfully' }
        end
      end


      def clearall
        user_id = decode_token[0]['user_id'] # Get user_id from the decoded token
        @notifications = Notification.where(user_id: user_id, status: :unapproved).delete_all
        render json:{success:true }
      end

      def update
        @notification = Notification.find(params[:id])
        if @notification.update(status: "read")
           @notification.destroy
          render json: { success: true }
        else
          render json: { errors: @notification.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def authenticate_jwt!
        decoded_data = decode_token
        if decoded_data.present?
          user_id = decoded_data[0]['user_id']
        else
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
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
