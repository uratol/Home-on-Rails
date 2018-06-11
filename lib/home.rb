require "home/engine"
require "rails_extentions"

module Home
  LINUX_PLATFORM = RUBY_PLATFORM.match(/linux/)
  
  mattr_writer :title
  mattr_accessor :latitude, :longitude
  mattr_accessor :mqtt_username, :mqtt_password
  
  def self.title
    @title ||= Rails.root.basename.to_s.capitalize
  end
  
  def self.time_zone=(zone_name)
    #Log.e("Invalid time zone #{ zone_name }") unless ActiveSupport::TimeZone.zones_map[zone_name]
    Rails.application.config.time_zone = Time.zone = zone_name
  end

  def self.time_zone
    Rails.application.config.time_zone
  end

  def self.custom_behavior_path
    Rails.root.join('app','behavior')
  end
  
 # this function maps the vars from your app into your engine
  def self.setup
    puts "Starting Home: #{ program_name } (#{ $PROGRAM_NAME })"
    yield self

    puts "setup #{ program_name }: #{ $PROGRAM_NAME }"
    startup
    watch_drivers if program_name == :jobs
  end
  
  private
  
  def self.startup
    Entity.drivers.each do |driver|
      driver.do_startup
    end

    ActiveRecord::Base.transaction do
      delete_old_indications
      Entity.all.each{|e| e.startup}
    end

  end
  
  def self.delete_old_indications(leave_interval = 1.week)
    Indication.where('created_at < ?', DateTime.now - leave_interval).delete_all
  end
  
  def self.watch_drivers
    Entity.drivers.each do |driver|
      driver.do_watch
    end
  end
  
  def self.program_name
    @program_name ||= (
      if %w(thin unicorn nginx apache lighttpd webrick puma).any?{|s| $PROGRAM_NAME.include? s}
        :web
      else
        :jobs  
      end  
      )
  end
  
  
end

