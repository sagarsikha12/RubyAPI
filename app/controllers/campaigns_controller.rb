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
        content: campaign.content.body.to_html

      }

      if campaign.cover_image.attached?
        campaign_data[:cover_image_url] = rails_blob_url(campaign.cover_image)
      end

      campaign_data
    end
    respond_to do |format|
      format.html
      format.json { render json: campaigns_json }
    end
  end
  def index
    render json: { message: "Hello, World!" }
  end




  def new
    @campaign = Campaign.new
  end

  # In your controller action
# In your controller action
def create
  # Create the campaign
  @campaign = current_user.campaigns.build(campaign_params)

  if @campaign.save
    # Create notifications for all users who should receive it
    User.all.each do |user|
      Notification.create(
        user: user,
        campaign: @campaign,
        status: "unread"
      )
    end



    redirect_to @campaign, notice: 'Campaign created successfully.'
  else
    render :new
  end
end



  def edit
  end

  def update
    if @campaign.update(campaign_params)

      redirect_to my_campaigns_campaigns_path, notice: 'Campaign updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @campaign = current_user.campaigns.find(params[:id])
    if @campaign.destroy
      redirect_to my_campaigns_campaigns_path, notice: 'Campaign deleted successfully.'
    else
      redirect_to my_campaigns_campaigns_path, alert: 'Error deleting campaign.'
    end
  end




  def campaign_params
    params.require(:campaign).permit(:title, :cover_image, :content, :category_id)
  end

  def find_campaign
    @campaign = Campaign.find(params[:id])
  end


  def show
    @campaign = Campaign.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: campaign_to_json(@campaign) }
    end
  end



private

def campaign_to_json(campaign)
  campaign_data = {
    id: campaign.id,
    title: campaign.title,
    content: campaign.content.body.to_html,
    created_at: campaign.created_at.strftime('%Y-%m-%d %H:%M:%S')
  }

  if campaign.cover_image.attached?
    campaign_data[:cover_image_url] = rails_blob_url(campaign.cover_image)
  end

  campaign_data
end












end
