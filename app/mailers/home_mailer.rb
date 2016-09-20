class HomeMailer < ::ActionMailer::Base
  #default from: "uratol@gmail.com"
  
  def mail body, options = {}
    options[:from] ||= ::ActionMailer::Base.smtp_settings[:user_name]
    options[:to] ||= User.where(isadmin: true).where.not(email: nil).pluck(:email)
    options[:body] ||= body
    options[:subject] ||= Home.title
    ::ActionMailer::Base.mail(options).deliver_now
=begin
    mail(to: user.email,
         body: email_body,
         content_type: "text/html",
         subject: "Already rendered!")
=end         
  end 

   
  
end