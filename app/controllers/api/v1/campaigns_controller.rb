include ActionView::Helpers::SanitizeHelper

class Api::V1::CampaignsController < ApplicationController
  before_action :authenticate_jwt!, only: [:create, :update, :destroy]
  before_action :find_campaign, only: [:show, :edit, :update, :destroy]


  def index

    @campaigns = Campaign.where(approved: 1)
    campaigns_json = @campaigns.map { |campaign| campaign_to_json(campaign) }
    render json: campaigns_json
  end

  def listall
    decoded_data = decode_token
    if decoded_data.present?
      user_id = decoded_data[0]['user_id']
      puts "Current User: #{@current_user}"
      @current_user = User.find_by(id: user_id)
      if @current_user.admin
        @campaigns = Campaign.all
        campaigns_json = @campaigns.map do |campaign|
          campaign_data = {
            id: campaign.id,
            title: campaign.title,
            content: strip_tags(campaign.content.body.to_html),
            created_at: campaign.created_at.iso8601,
            approved:campaign.approved

          }
          if campaign.cover_image.attached?
            campaign_data[:cover_image_url] = rails_blob_url(campaign.cover_image)
          elsif campaign.cover_image_url.present?
            campaign_data[:cover_image_url] = campaign.cover_image_url
          end
          if campaign.images.attached?
            campaign_data[:images] = campaign.images.map { |image| rails_blob_url(image) }
          else
            campaign_data[:images] = []
          end

          campaign_data
        end

        render json: campaigns_json
      end
    end
  end


  def create
    # Create the campaign
    @campaign = current_user.campaigns.build(campaign_params)

    if @campaign.save
      # Create notifications for all admin who should receive it
      User.where(admin: true).each do |user|
        Notification.create(
          user: user,
          campaign: @campaign,
          status: "unapproved",
        )
      end

      render json: { message: 'Campaign created successfully. Waiting for Admin Approval', campaign: campaign_to_json(@campaign) }, status: :created
    else
      render json: { errors: @campaign.errors.full_messages }, status: :unprocessable_entity
    end

  end

  def current_user
    @current_user ||= begin
      decoded_data = decode_token
      User.find_by(id: decoded_data[0]['user_id']) if decoded_data.present?
    end
  end


  def my_campaigns
    @campaigns = current_user.campaigns
    campaigns_json = @campaigns.map do |campaign|
      campaign_data = {
        id: campaign.id,
        title: campaign.title,
        content: strip_tags(campaign.content.body.to_html),
        created_at: campaign.created_at.iso8601,
        approved:campaign.approved
      }

      if campaign.cover_image.attached?
        campaign_data[:cover_image_url] = rails_blob_url(campaign.cover_image)
      elsif campaign.cover_image_url.present?
        campaign_data[:cover_image_url] = campaign.cover_image_url
      end
      if campaign.images.attached?
        campaign_data[:images] = campaign.images.map { |image| rails_blob_url(image) }
      else
        campaign_data[:images] = []
      end

      campaign_data
    end
    render json: campaigns_json
  end

  def destroy
    @campaign = Campaign.find(params[:id])

    if @campaign.destroy
      if @campaign.notification
        @campaign.notification.destroy
      end
      render json: { message: 'Campaign deleted successfully' }, status: :no_content
    else
      render json: { errors: @campaign.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    # Decode the token to get user information
    decoded_data = decode_token

    # Check if decoded data is present and valid
    if decoded_data.blank?
      return render json: { error: 'You are not authorized to perform this action' }, status: 401
    end

    user = User.find_by(id: decoded_data[0]['user_id'])

    # Check if the user is authorized (either admin or the author of the campaign)
    unless user&.admin? || user&.id == @campaign.user_id
      return render json: { error: 'You are not authorized to perform this action' }, status: 401
    end

    # Begin updating the campaign
    ActiveRecord::Base.transaction do
      # Check if cover_image is being updated
      if params[:cover_image].present?
        @campaign.cover_image.purge if @campaign.cover_image.attached?
        @campaign.cover_image.attach(params[:cover_image])
      end

      # Check if cover_image_url is being updated and is different from the current one
      if params[:cover_image_url].present? && params[:cover_image_url] != @campaign.cover_image_url
        @campaign.cover_image.purge if @campaign.cover_image.attached?
        @campaign.cover_image_url = params[:cover_image_url]
      end

      # Save the changes
      if @campaign.save
        render json: { message: 'Campaign updated successfully.', campaign: campaign_to_json(@campaign) }, status: :ok
      else
        raise ActiveRecord::RecordInvalid, @campaign
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end





  private



  # def campaign_params
  #   params.permit(:title,:cover_image, :content, :category_id,images: [])
  # end
  def campaign_params
    params.permit(:title, :cover_image, :content, :category_id, :cover_image_url, images: [])
  end





  def find_campaign
    @campaign = Campaign.find(params[:id])
  end

  def campaign_to_json(campaign)
    campaign_data = {
      id: campaign.id,
      title: campaign.title,
      content: campaign.content.body.to_html
    }
    if campaign.cover_image.attached?
      campaign_data[:cover_image_url] = rails_blob_url(campaign.cover_image)
    elsif campaign.cover_image_url.present?
      campaign_data[:cover_image_url] = campaign.cover_image_url
    end
    # Check if any images are attached and include them
    if campaign.images.attached?
      campaign_data[:images] = campaign.images.map { |image| rails_blob_url(image) }
    end

    campaign_data
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
