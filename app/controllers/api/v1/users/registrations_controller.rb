class Api::V1::Users::RegistrationsController < Devise::RegistrationsController
  # Your custom actions and methods
  before_action :configure_sign_up_params, only: [:create]


  def create
    build_resource(sign_up_params)

    if resource.save
      sign_up(resource_name, resource)
      render json: { message: 'Registration successful' }, status: :created
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end


private

def configure_sign_up_params
  devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :username])
end


end
