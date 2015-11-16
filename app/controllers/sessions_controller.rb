class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      if user.activated?
        sign_in user
        params[:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or_to user
      else
        message = "Account not activated. Check your email for activation link."
        flash[:warning] = message
        redirect_to root_url
      end
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
