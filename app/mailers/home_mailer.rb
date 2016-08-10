class HomeMailer < ActionMailer::Base
  default from: "from@example.com"
  
  def send_mail(options = {})
    mail(options).deliver_now
=begin
    mail(to: user.email,
         body: email_body,
         content_type: "text/html",
         subject: "Already rendered!")
=end         
  end 

   
  
end