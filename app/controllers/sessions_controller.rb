class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      sign_in user
      params[:remember_me] == '1' ? remember(user) : forget(user)
      redirect_back_or_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out if signed_in?
    redirect_to root_url
  end
end
