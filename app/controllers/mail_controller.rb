class MailController < ApplicationController
	layout false

	def sendMail
		params = request.POST
		@email=params[:e]
		@password=params[:p]
		@link=params[:l]
		AdminMailer.send_email(@email,@password,@link).deliver  
    end

    def insertEmail
		params = request.POST		
		email = params[:email]
		userId = params[:user_id]

		userexams = Userexam.find(userId)
		userexams.email=email
		userexams.save()
	end
end
