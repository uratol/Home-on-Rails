Home.setup do |config|
  config.title = 'Sweet Home On Rails'
  config.latitude, config.longitude = 50.433022, 30.331020
  config.time_zone = 'Kyiv'
  config.mqtt_username = 'demo@example.com'
  config.mqtt_password = 'demo12345'
end

Rails.application.configure do
  config.action_mailer.smtp_settings = {
      address: "smtp.gmail.com",
      port: 587,
      user_name: 'home.on.rails@gmail.com',
      password: 'password',
      authentication: "plain",
      enable_starttls_auto: true
  }
end
