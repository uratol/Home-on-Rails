require "home/engine"

module Home
  LINUX_PLATFORM = RUBY_PLATFORM.match(/linux/)
  
  mattr_writer :title
  mattr_accessor :latitude, :longitude
  
  def self.title
    @@title ||= Rails.root.basename.to_s.capitalize
  end
  
  def self.time_zone= t
    Rails.application.config.time_zone = t
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
    
    startup if program_name == :jobs
  end  
  
  private
  
  def self.startup
    ActiveRecord::Base.transaction do
      delete_old_indications
      Entity.all.each{|e| e.startup}
    end
    drivers_watch
  end
  
  def self.delete_old_indications(leave_interval = 1.week)
    Indication.where('created_at < ?', DateTime.now - leave_interval).delete_all
  end
  
  def self.drivers_watch
    
    @threads.each(&:kill) if (@threads ||= []).any? 
        
    Entity.drivers.each do |d|
      if d.respond_to? :watch
        @threads << Thread.new do
          loop do
            puts "Driver #{ d }: watching"
            d.watch do |address, value|
              for e in devices.where(address: address)
                e.write_value e.transform_driver_value(value)
              end
            end  
          end  
        end
      end      
    end  
  end
  
  def self.program_name
    @program_name ||= (
      if %w(thin unicorn nginx apache lighttpd webrick).any?{|s| $PROGRAM_NAME.include? s}
        :web
      else
        :jobs  
      end  
      )
  end
  
  
end

