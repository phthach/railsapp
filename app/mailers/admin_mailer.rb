class AdminMailer < ActionMailer::Base
  default from: "admin@example.com"

  def send_email(email, pass, link)
  	mail(:to => email, :subject => "Welcome to exam online", :body => "Your password: "+pass+"\nLink: <a>"+link+"</a>")
  end
end
