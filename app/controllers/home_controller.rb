class HomeController < ActionController::Base
	before_filter :authorize
	protect_from_forgery
	layout "application"	

	protected

		def authorize
			if session[:user_id] == nil 
				redirect_to login_url, :alert => "Please Log in"
			end
		end
end
