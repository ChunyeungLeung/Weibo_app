class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit,:update]
  before_action :valid_user, only:[:edit, :update]
  before_action :check_expiration, only: [:edit, :update]   #第一种情况，密码重设请求已过期
  def new
  end
  
  def create
	  @user = User.find_by(email: params[:password_reset][:email].downcase)
	  if @user
		  @user.create_reset_digest
		  @user.send_password_reset_email
		  flash[:info] = "邮件已发送。请到注册邮箱激活用户。"
		  redirect_to root_url
	  else
		  flash.now[:danger] = "找不到此邮箱地址。"
		  render 'new'
	  end
  end

  def edit
  end

  def update
	  if params[:user][:password].empty?        #第三种情况，没有填写密码和密码确认，更新失败（看起来像是成功了）
		  @user.errors.add(:password,"不能为空")
		  render 'edit'
	  elsif @user.update_attributes(user_params)  #第四种情况，成功更新密码
		  log_in @user
		  flash[:success] = "密码修改成功！"
		  redirect_to @user
	  else
		  render 'edit'         #第二种情况，填写的新密码无效，更新失败
	  end
  end

  private
   def user_params
	   params.require(:user).permit(:password, :password_confirmation)
   end

   #前置过滤器
   #
   def get_user
	   @user = User.find_by(email:params[:email])
   end

   #确保是有效用户
   def valid_user
	   unless (@user && @user.activated? && @user.authenticated?(:reset,params[:id]))
		   redirect_to root_url
	   end
   end
   #检查重设令牌是否过期

   def check_expiration
	   if @user.password_reset_expired?
		   flash[:danger] = "此链接已过期。"
		   redirect_to new_password_reset_url
	   end
   end

end
