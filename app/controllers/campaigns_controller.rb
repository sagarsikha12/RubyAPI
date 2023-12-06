class CampaignsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  before_action :find_campaign, only: [:show, :edit, :update, :destroy]


  # This will list only the campaigns of the currently logged-in user

  def index
    @campaigns = Campaign.where(reviewed: true)
    campaigns_json = @campaigns.map do |campaign|
      campaign_data = {
        id: campaign.id,
        title: campaign.title,
        content: campaign.content.body.to_html,
        ownerId:campaign.user_id

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
    respond_to do |format|
      format.html
      format.json { render json: campaigns_json }
    end
  end



  def campaign_params
    params.require(:campaign).permit(:title, :cover_image,:cover_image_url, :content, :category_id,images: [])
  end

  def find_campaign
    @campaign = Campaign.find(params[:id])
  end


  def show
    @campaign = Campaign.find(params[:id])

    render json: campaign_to_json(@campaign)

  end



private

def campaign_to_json(campaign)
  campaign_data = {
    id: campaign.id,
    title: campaign.title,
    content: campaign.content.body.to_html,
    created_at: campaign.created_at.strftime('%Y-%m-%d %H:%M:%S'),
    ownerId: campaign.user_id
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





end
