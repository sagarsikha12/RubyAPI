# app/controllers/admin/campaigns_controller.rb

class Admin::CampaignsController < ApplicationController
  before_action :ensure_admin


  before_action :authenticate_jwt!, only: [:create, :update, :destroy]




  def index
    @campaigns = Campaign.where(approved: 0)
    campaigns_json = @campaigns.map do |campaign|
      campaign_data = {
        id: campaign.id,
        title: campaign.title,
        content: campaign.content.body.to_html
      }

      if campaign.cover_image.attached?
        campaign_data[:cover_image_url] = rails_blob_url(campaign.cover_image)
      end

      campaign_data
    end
    render json: campaigns_json
  end


  def approve
    campaign = Campaign.find(params[:id])
    campaign.update(approved: 1)
      # Create notifications for all users who should receive it
      User.all.each do |user|
        Notification.create(
          user: user,
          campaign: campaign,
          status: "unread"
        )
      end
    render json: { status: 'success', message: 'Campaign approved.' }
  rescue ActiveRecord::RecordNotFound
    render json: { status: 'error', message: 'Campaign not found.' }, status: 404
  end

  def reject
    campaign = Campaign.find(params[:id])
    campaign.update(approved: 2)

    render json: { status: 'success', message: 'Campaign rejected .' }
  rescue ActiveRecord::RecordNotFound
    render json: { status: 'error', message: 'Campaign not found.' }, status: 404
  end
  private

  def ensure_admin
    user_id = decode_token[0]['user_id']

    puts "User id is: #{@user_id}"

    # Check if a user with the given ID exists and is an admin
    is_admin = User.where(id: user_id, admin: true).exists?

    unless is_admin
      render json: { status: 'error', message: 'Unauthorized' }, status: 401
    end
  end


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





end
