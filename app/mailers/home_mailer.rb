class HomeMailer < ::ActionMailer::Base
  #default from: "uratol@gmail.com"
  
  def send_mail body, options = {}
    options[:from] ||= "#{ Home.title } <#{ ::ActionMailer::Base.smtp_settings[:user_name] }>"
    to = options[:to]
    query = nil
    if (to.nil?)
      query = User.all
    elsif to.is_a?(Symbol) && User.respond_to?(to)
      query = User.send to
    end

    options[:to] = query.pluck(:name,:email).map{|a| "#{ a.first } <#{ a.last }>"} if query
     
    options[:body] ||= body
    options[:subject] ||= Home.title
    #::ActionMailer::Base.
    mail(options)
=begin
    mail(to: user.email,
         body: email_body,
         content_type: "text/html",
         subject: "Already rendered!")
=end         
  end 

   
  
end