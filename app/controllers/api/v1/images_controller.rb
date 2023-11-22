# app/controllers/api/v1images_controller.rb
module Api
  module V1
    class ImagesController < ApplicationController
  before_action :authenticate_jwt!, only: [:create, :update, :destroy]

  def create
    image = ActiveStorage::Blob.create_and_upload!(io: image_params[:file], filename: image_params[:file].original_filename)

    if image
      render json: { url: rails_blob_url(image, only_path: true) }, status: :created
    else
      render json: { errors: 'Image upload failed' }, status: :unprocessable_entity
    end
  end

  private

  def image_params
    params.permit(:file) # Ensure 'file' matches the name used in FormData on the client side
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
  end
end
