class Entity < ActiveRecord::Base
  
  extend EntityClassMethods 

  belongs_to :parent, class: Entity
  has_many :indications, dependent: :destroy
  has_many :jobs, class_name: :EntityJob, dependent: :destroy
  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-z][a-z0-9_]+\Z/ }
  validates :caption, presence: true
  validates :type, presence: true
  validate :name_valid?
  # has_closure_tree
  acts_as_nested_set dependent: :restrict, counter_cache: :children_count, depth_column: :depth
  has_many :children, class: Entity, foreign_key: :parent_id, dependent: :restrict_with_error
  attr_accessor :state, :image_name, :width, :height, :driver_address, :binary
  alias_method :binary?, :binary
  attr_reader :events
  
  after_initialize :init
  after_save :startup
  
  include ::EntityVisualization
  include ::EntityBehavior
  include ::EntityData
  
  register_events :at_click, :at_startup, :at_shedule
  register_attributes shedule: nil
  
  def value_at dt
    (indication_at(dt) || self).value
  end

  def indication_at dt
    Indication.indication_at self, dt
  end
  
  def types
    self.class.types
  end
  
  def behavior_methods
    self.class.instance_methods.grep(/^at_/)
  end
  
  def twins
    Entity.where(driver: driver, address: address) unless address.to_s.blank? || driver.to_s.blank?
  end
  
  def twin_id
    tw = twins
    tw.minimum(:id) if tw
  end
  
  def original?
    tw_id = twin_id
    tw_id.nil? || tw_id==id
  end
  
  def to_s
    name ? "#{ name } (#{ caption })" : super
  end
  
  def inspect
    "#<#{self.class.name}: #{name}>"
  end
  
  def do_event event_name
    events.call event_name 
  end

  def write_value v
    transaction do
      store_value v
      tw = twins 
      twins.where.not(id: id).update_all value: v if tw
    end  
    return v
  end

  def invert_driver_value?
    return false
  end

  def transform_driver_value(v)
    invert_driver_value? ? 1-v : v
  end
  
  def send_mail options = {}
    HomeMailer.send_mail options
  end
  
  def startup
    cancel :do_shedule
    log {"Startup #{ self }"}
    if shedule
      log {"Shedule #{ self } : #{ shedule }"}
      every(shedule).do_shedule 
    end
    do_event :at_startup
  end
  
  def do_shedule
    do_event :at_shedule
  end

  def last_indication value = nil
    query = indications.limit(1).order('created_at DESC')
    query = query.where(value: value) if value
    return query.first
  end

  def last_indication_time value = nil
    indication = last_indication(value)
    return indication.created_at if indication
  end  
  
  def last_indication_interval value = nil
    v = last_indication_time(value)
    DateTime.now - v if v
  end

  def self.required_methods
    @required_methods ||= []
  end

  def required_methods
    self.class.required_methods
  end
  
  protected
  
  def store_value v, dt = Time.now
    
    if binary? && !(v==0 || v==1)
      raise ArgumentError, "Value #{ v } is not binary"
    end
    
    old_value = self.value

    set_driver_value v if is_a?(Actor) && !driver.blank?

    if (dbl_change_assigned = events.assigned?(:at_dbl_change) )
      last_time = last_indication_time
      dbl_change_assigned = last_time && ((Time.now - last_time) < 1.second)
    end

    self.value = v
    Entity.where(id: id).update_all(value: v)
#    update_attribute(:value, v) 
    
    if old_value != v
      do_event(if on? then :at_on else :at_off end)
      do_event :at_change
      do_event :at_dbl_change if dbl_change_assigned
    end  
    indications.create! value: v, dt: dt

  end

  def self.method_missing method_sym, *arguments, &block
    Entity[method_sym] || super
  end

  def method_missing method_sym, *arguments, &block
    Entity[method_sym] || data_method(method_sym, *arguments)  || super
  end
  
  def self.register_required_methods *args
    #required_methods |= args.flatten
    @required_methods = [] unless @required_methods
    @required_methods |= args.flatten
  end
  
  private

  def init
    @events = EntityEvents.new
    self.state = []
    return if name.to_s.blank?
    extend "#{ driver }_driver".camelcase.constantize unless driver.blank?
  end
  

  def name_valid?
    errors.add :name, "\"#{name}\" is reserved" if Entity.instance_methods.include? name.to_sym if name?
  end

  self.require_entity_classes
end

 

