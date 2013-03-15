class AdminMailer < ActionMailer::Base
  default from: "admin@example.com"

  def send_email(email, pass, link)
  	#@email=email
  	mail(:to => email, :subject => "Welcome to exam online", :body => pass+"-"+link)
  end
end
