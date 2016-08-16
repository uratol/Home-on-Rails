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
     yield self
     startup
  end  
  
  private
  
  def self.startup
    Indication.where('created_at < ?', DateTime.now - 1.week).delete_all
    Entity.all.each do |e| 
      e.startup
      e.watch if e.respond_to? :watch
    end  
  end
  
end

