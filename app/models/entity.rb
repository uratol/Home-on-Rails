class Entity < ActiveRecord::Base
  
  extend EntityClassMethods 

  belongs_to :parent, class_name: Entity
  has_many :indications, dependent: :destroy
  has_many :jobs, class_name: :EntityJob, dependent: :destroy
  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-z][a-z0-9_]+\Z/ }
  validates :caption, presence: true
  validates :type, presence: true
  validate :name_valid?
  # has_closure_tree
  acts_as_nested_set dependent: :restrict, counter_cache: :children_count, depth_column: :depth
  has_many :children, class_name: Entity, foreign_key: :parent_id, dependent: :restrict_with_error
  attr_accessor :state, :image_name, :width, :height, :driver_address, :binary
  alias_method :binary?, :binary
  attr_reader :events
  
  after_initialize :init
  
  include ::EntityVisualization
  include ::EntityData
  include ::EntityBehavior
  
  register_events :at_click, :at_touchstart, :at_touchend, :at_startup, :at_schedule
  register_attributes min: 0, max: 1, schedule: nil
  register_attributes invert_driver_value: false
  
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
  
  def do_event event_name, params = nil
    events.call event_name, params: params
  end

  def write_value v
    v = max if v > max
    v = min if v < min
    transaction do
      store_value v
      tw = twins 
      twins.where.not(id: id).update_all value: v if tw
    end  
    return v
  end

  def invert_driver_value?
    return invert_driver_value
  end

  def transform_driver_value(v)
    invert_driver_value? ? 1-v : v
  end
  
  def startup
    cancel :do_schedule
    log {"Startup #{ self }"}
    if schedule
      log {"Schedule #{ self } : #{ schedule }"}
      every(schedule).do_schedule 
    end
    do_event :at_startup
  end
  
  def do_schedule
    super rescue NoMethodError
    do_event :at_schedule
  end
  
  def at_schedule sched = nil, &block
    self.schedule = sched if sched
    events.add_with_replace :at_schedule, block
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
    result = self.class.required_methods 
    result += driver_module.required_methods if driver_module.respond_to? :required_methods
    return result
  end
  
  protected
  
  def store_value v, dt = Time.now
    
    if binary? && !(v==0 || v==1)
      raise ArgumentError, "Value #{ v } is not binary"
    end
    
    old_value = self.value

    set_driver_value(v) if respond_to? :set_driver_value 

    if (dbl_change_assigned = events.assigned?(:at_dbl_change) )
      last_time = last_indication_time
      dbl_change_assigned = last_time && ((Time.now - last_time) < 1.second)
    end

    self.value = v
    update_columns value: v
#    update_attribute(:value, v) 
    
    if old_value != v
      do_event :at_on if on?
      do_event :at_off if off?
      do_event :at_change, old_value
      do_event :at_dbl_change if dbl_change_assigned
    end  
    indications.create! value: v, dt: dt

  end

  def self.method_missing method_sym, *arguments, &block
    Entity[method_sym] || super
  end

  def method_missing method_sym, *arguments, &block
    Entity[method_sym] || super
  end
  
  def self.register_required_methods *args
    #required_methods |= args.flatten
    @required_methods = [] unless @required_methods
    @required_methods |= args.flatten
  end
  
  def driver_module
    @driver_module ||= nil
    if !@driver_module || driver_changed?
      @driver_module = "#{ driver }_driver".camelcase.constantize unless driver.blank?
    else  
      @driver_module
    end  
  end
  
  private

  def init
    @events = EntityEvents.new
    self.state = []
    return if name.to_s.blank?
    extend driver_module if driver_module
  end
  

  def name_valid?
    errors.add :name, "\"#{name}\" is reserved" if Entity.instance_methods.include? name.to_sym if name?
  end

  self.require_entity_classes
end

 

