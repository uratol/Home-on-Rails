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
  end
end
