# app/controllers/notifications_controller.rb

class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.unread
    render json: @notifications
  end

  def update
    @notification = Notification.find(params[:id])
    if @notification.update(status: "read")
        render json: { success: true }
    else
        render json: { errors: @notification.errors.full_messages }, status: :unprocessable_entity
    end
  end

end
