class SessionsController < ApplicationController
  def new
  end

  def create
	  user = User.find_by(email: params[:session][:email].downcase)
	  if user && user.authenticate(params[:session][:password])
		  #登入用户，然后重定向到用户的资料页面
		if user.activated?
		  log_in user
		  params[:session][:remember_me] == '1' ? remember(user) : forget(user)
		  redirect_back_or user
		else
			message = "未激活成功 "
			message += "请查看邮箱中的激活链接。"
			flash[:warning] = message
			redirect_to root_url
		end

	  else
		  #创建一个错误消息
		  flash.now[:danger] = '邮箱地址或密码错误'  #不完全正确
		render 'new'
	  end
  end

  def destroy
	  log_out if logged_in?
	  redirect_to root_url
  end
end
