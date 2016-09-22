require 'rubygems'
require 'awesome_nested_set' 

module Home

  class Engine < ::Rails::Engine
    config.autoload_paths += [config.root.join('lib')]
    config.autoload_paths += Dir[config.root.join('app','models','**')]

    require config.root.join('app','helpers','application_helper.rb')
    
    require 'delayed_job_active_record'
    
    require 'jquery-ui-rails'
    require 'jquery_context_menu-rails'

    require 'ace-rails-ap'
        
    require 'devise'
    
    require 'web-console'
    require 'turbolinks'
    
    config.to_prepare do
        app_config = Rails.application.config
        app_config.eager_load_paths -= [Home.custom_behavior_path.to_s]
        app_config.web_console.development_only = false
        app_config.web_console.whitelisted_ips = '192.168.0.0/16'

        app_config.assets.precompile += %w(
          entity/* *.png *.ico *.gif *.jpg *.jpeg jquery.js jquery_ujs.js jquery-ui.js jquery.contextMenu.js jquery-ui.css jquery.contextMenu.css ace/ace.js ace/worker-html.js ace/mode-ruby.js 
        )
    end
    
    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end    
              
  end
end
