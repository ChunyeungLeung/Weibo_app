class AccountActivationsController < ApplicationController
def edit
	user = User.find_by(email: params[:email])
	if user && !user.activated? && user.authenticated?(:activation, params[:id])
		user.activate
	#	user.update_attribute(:activated, true)
	#	user.update_attribute(:activated_at,Time.zone.now)
		log_in user
		flash[:success] = "激活成功!"
		redirect_to user
	else
		flash[:danger] = "此激活链接无效。"
		redirect_to root_url
	end
end
end
