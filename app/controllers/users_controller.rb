class UsersController < ApplicationController
  before_action :require_user, only: [:show]

  def new
    redirect_to home_path if current_user
    @user = User.new   
  end

  def new_with_invitation_token
    invitation = Invitation.find_by(token: params[:token])
    if invitation
      @user = User.new(email: invitation.recipient_email)
      @invitation_token = invitation.token
      render :new
    else
      redirect_to invalid_token_path
    end
  end

  def create
    @user = User.new(user_params)

    if @user.save
      handle_invitation      
      AppMailer.send_welcome_email(@user).deliver
      flash[:warning] = "You've registered!"
      redirect_to sign_in_path
    else
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :username)
  end

  def handle_invitation
    if params[:invitation_token].present?
    invitation = Invitation.find_by(token: params[:invitation_token]) 
    @user.follow(invitation.inviter)
    invitation.inviter.follow(@user)
    invitation.update_column(:token, nil)
    end   
  end
end