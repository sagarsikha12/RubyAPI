class Users::SessionsController < Devise::SessionsController
  respond_to :json # Ensure the controller responds to JSON

  def create
    puts "I am inside the create method!"
    user = User.find_by(email: params[:user][:email])

    if user && user.valid_password?(params[:user][:password])
      sign_in(user)
      render json: { message: 'Login successful', user: user } # Return a JSON response
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
end

