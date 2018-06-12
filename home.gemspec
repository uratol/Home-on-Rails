$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "home/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "home"
  s.version     = Home::VERSION
  s.authors     = ["uratol"]
  s.email       = ["uratol@gmail.com"]
  s.summary     = "Home automation on Ruby On Rails."
  s.description = "Home on Rails is a ruby-on-rails based framework that includes everything needed to create IoT web applications"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib,public}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'rails', '>= 4.2.1'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'jquery-ui-rails'
  s.add_dependency 'jquery_context_menu-rails'
  s.add_dependency 'turbolinks'
#  s.add_dependency 'jquery-turbolinks'

  s.add_dependency 'awesome_nested_set'
  s.add_dependency 'solar'
  s.add_dependency 'delayed_job_active_record'
  
  s.add_dependency 'nokogiri'
  s.add_dependency 'image_size'
  if RUBY_PLATFORM.match(/mingw|mswin|x64_mingw/)
    s.add_dependency 'win32-sound'
    s.add_dependency 'tzinfo-data'
  end

  s.add_dependency 'ace-rails-ap'

  s.add_dependency 'devise'
  
  s.add_dependency 'timedcache'
  
  # drivers

  (gpio_exists = `gpio -v`) rescue Exception

  if gpio_exists # RUBY_PLATFORM.match(/linux/)
    s.add_dependency 'wiringpi' 
#  s.add_dependency 'pi_piper' if RUBY_PLATFORM.match(/linux/)
    s.add_dependency 'dht-sensor-ffi'
    s.add_dependency 'rubyserial'
  end

  s.add_dependency 'net-ping'
  s.add_dependency 'mqtt'
  s.add_dependency 'ice_cube'

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'web-console'

  s.test_files = Dir["spec/**/*"]
  
end
