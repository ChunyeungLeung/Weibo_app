class UsersController < ApplicationController
	before_action :logged_in_user, only: [:index, :edit, :update, :destroy,:following,:followers]
	before_action :correct_user, only: [:edit, :update]
	before_action :admin_user, only: :destroy
	def index
		@users = User.paginate(page: params[:page])
	end

	def show
		@user=User.find(params[:id])
	end

  def new
	  @user = User.new
  end

  def create
	  @user = User.new(user_params)
	  if @user.save
		  @user.send_activation_email
		  flash[:info] = "请查看邮箱里的激活链接"
		  redirect_to root_url
		  #succeed
	#	  log_in @user
	#	  flash[:success] = "欢迎来到微博 APP!"
	#	  redirect_to @user
	  else
		  render 'new'
	  end
  end

  def edit 
	  @user = User.find(params[:id])
  end
  
  def update
	  @user = User.find(params[:id])
	 if @user.update_attributes(user_params)
		  flash[:success] = "上传成功！"
		  redirect_to @user
		  #处理更新成功的情况
	  else
		  render 'edit'
	  end
  end

  def show
	  @user = User.find(params[:id])
	  @microposts = @user.microposts.paginate(page: params[:page])
  end

  
  def destroy
	  User.find(params[:id]).destroy
	  flash[:success] = "用户已删除。"
	  redirect_to users_url
  end

  def following
	  @title = "Following"
	  @user = User.find(params[:id])
	  @users = @user.following.paginate(page: params[:page])
	  render 'show_follow'
  end

  def followers
	  @title = "Followers"
	  @user = User.find(params[:id])
	  @users = @user.followers.paginate(page: params[:page])
	  render 'show_follow'
  end

  private

  def user_params
	  params.require(:user).permit(:name,:email,:password,:password_confirmation)
  end
  #前置过滤器
  #确保用户已登陆
=begin def logged_in_user
	  unless logged_in?
		#  store_location
		  store_location
		  flash[:danger] = "Please log in."
		  redirect_to login_url
	  end
=end end
  #确保是正确的用户
	def correct_user
		@user = User.find(params[:id])
		redirect_to(root_url) unless @user == current_user
	end
  #确保是管理员
	def admin_user
		redirect_to(root_url) unless current_user.admin?
	end
end
