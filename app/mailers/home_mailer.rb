class HomeMailer < ActionMailer::Base
  default from: "from@example.com"
  
  def send_mail_to_admin(header: header, body: body)
    mail(to: user.email,
         body: email_body,
         content_type: "text/html",
         subject: "Already rendered!")
  end  
  
end