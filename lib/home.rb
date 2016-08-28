require "home/engine"

module Home
  LINUX_PLATFORM = RUBY_PLATFORM.match(/linux/)
  
  mattr_writer :title
  mattr_accessor :latitude, :longitude
  
  def self.title
    @@title ||= Rails.root.basename.to_s.capitalize
  end

  def self.custom_behavior_path
    Rails.root.join('app','behavior')
  end
  
 # this function maps the vars from your app into your engine
  def self.setup
    puts "Starting Home: #{ program_name } (#{ $PROGRAM_NAME })"
    yield self
    
    if ARGV.include? 'startup'
      startup
    end   
  end  
  
  private
  
  def self.startup
    if program_name == :jobs
      ActiveRecord::Base.transaction do
        delete_old_indications
        Entity.all.each{|e| e.startup}
      end
      puts "Watch Home: #{ program_name } (#{ $PROGRAM_NAME })"
      drivers_watch  
    end
  end
  
  def self.delete_old_indications
    Indication.where('created_at < ?', DateTime.now - 1.week).delete_all
  end
  
  def self.drivers_watch
    Entity.drivers.each do |d|
      if d.respond_to? :watch
        puts "Watch: #{ d }"
        d.watch
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

