# Базовый класс для всех объектов.
# От него наследуются все остальные объекты: помещения, устройства, виджеты и т.д.

class Entity < ActiveRecord::Base

  extend EntityClassMethods

  belongs_to :parent, class_name: Entity
  has_many :indications, dependent: :delete_all 
  has_many :jobs, class_name: :EntityJob, dependent: :destroy
  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-z][a-z0-9_]+\Z/ }
  validates :caption, presence: true
  validates :type, presence: true
  validate :name_valid?
  validate :driver_valid?
  # has_closure_tree
  acts_as_nested_set dependent: :restrict, counter_cache: :children_count, depth_column: :depth
  has_many :children, class_name: Entity, foreign_key: :parent_id, dependent: :restrict_with_error

  attr_accessor :state # @!visibility private

  # Имя изображения.
  # Вызывается каждый раз при обновлении страницы для каждого объекта (как правило раз в пять секунд).
  # Файл с этим именем должен присутствовать в папке app/assets/image/entities
  # По умолчанию берёт первый файл из этой папки в следующем порядке:
  #   ИмяОбъекта.Значение
  #   ИмяОбъекта
  #   ИмяКласса.Значение
  #   ИмяКласса
  #   ИмяКлассаПредка.Значение
  #   ИмяКлассаПредка
  #   ... и т.д. для каждого класса-предка
  # Перегрузив этот метод, можно задать индивидуальное изображение для каждого объекта.
  # @return [String] Имя изображения (без расширения)
  # @example
  #   def image_name
  #     "custom_image_#{ value.round(0) }"
  #   end
  attr_accessor :image_name

  # Ширина объекта в пикселах
  attr_accessor :width

  # Высота объекта в пикселах
  attr_accessor :height


  attr_accessor :driver_address # @!visibility private

  attr_accessor :binary # @!visibility private

  alias_method :binary?, :binary # @!visibility private
  attr_reader :events # @!visibility private

  after_commit do
    driver_module(previous_changes[:driver].first).do_watch if previous_changes[:driver]
    driver_module.do_watch if previous_changes[:driver] || previous_changes[:address]
    delay.startup
  end

  # @!method name
  #   Имя объекта
  #   @return [String]

  # @!method parent
  #   Возвращает имя родительского объекта в иерархии
  #   @return [Entity]

  after_initialize :init
  
  include ::EntityVisualization
  include ::EntityData
  include ::EntityBehavior
  include ::ChangeBehavior


  # @!method at_click
  # Вызывается при клике на объект в вэб-интерфейсе
  # @yield скрипт, котрый будет выполнен на сервере при клике на объекте
  # @example
  #   at_click do
  #     light1.on!
  #     redirect_to page1
  #   end

  # @!method at_touchstart
  # Вызывается при нажатии левой кнопки мыши или тачпада  в вэб-интерфейсе
  # @yield скрипт
  # @example
  #   at_touchstart do
  #     light1.on!
  #   end

  # @!method at_touchend
  # Вызывается при отпускании левой кнопки мыши или тачпада в вэб-интерфейсе
  # @yield скрипт
  # @example
  #   at_touchend do
  #     light1.off!
  #   end

  # @!method at_startup
  # Вызывается каждый раз при старте сервера
  # @yield скрипт
  # @example
  #   at_startup do
  #     log 'started'
  #   end



  register_events :at_click, :at_touchstart, :at_touchend, :at_startup, :at_schedule, :at_show
  register_attributes min: 0, max: 1, schedule: nil
  register_attributes invert_driver_value: false
  alias_method :invert=, :invert_driver_value=
  alias_method :invert?, :invert_driver_value

  # переводит режим в инверсный режим
  # т.е. при вызове on! драйверу будет отправлен ноль, при вызове off!  - единица
  def invert
    self.invert = true
  end

  # возвращает значение на заданное время
  # @param dt [Date, Time]
  # @return [Float]
  def value_at(dt)
    (indication_at(dt) || self).value
  end

  def indication_at(dt) # @!visibility private
    Indication.indication_at self, dt
  end
  
  def types # @!visibility private
    self.class.types
  end
  
  def behavior_methods # @!visibility private
    self.class.instance_methods.grep(/^at_/)
  end

  def to_f # @!visibility private
    value || 0
  end
  
  def to_s # @!visibility private
    name ? "#{ name } (#{ caption })" : super
  end
  
  def inspect # @!visibility private
    "#<#{self.class.name}: #{name}>"
  end
  
  def do_event(event_name, params = nil) # @!visibility private
    events.call event_name, params: params
  end

  # Устанавливает и записывает значение (атрибут value) и отправляет это значение драйверу
  # @param new_value [Float, Fixnum] - новое значение объекта
  # @param do_set_driver [Boolean] -  отправлять значение драйверу, по умолчанию true
  def write_value(new_value, do_set_driver = true)
    store_value(new_value ? new_value.to_f.restrict_by_range(min, max) : new_value, Time.now, do_set_driver)
  end

  def invert_driver_value? # @!visibility private
    invert_driver_value
  end

  # преобразовывает значение, полученное от драйвера, в число, сохраняемое в атрибуте value
  # @param driver_value [Object] - значение, полученное от драйвера
  # @return [Float]
  def driver_value_to_value(driver_value)
    invert? ? 1 - driver_value : driver_value if driver_value
  end

  # преобразовывает значение объекта (числовое) в объект, который будет передан драйверу
  # @param value [Float] - значение объекта
  # @return [Object] - объект, который будет передан драйверу
  def value_to_driver_value(value)
    invert? ? 1 - value : value if value
  end

  def startup # @!visibility private
    transaction do
      cancel [:do_schedule, :startup]
      log {"Startup #{ self }"}
      if schedule && enabled?
        log {"Schedule #{ self } : #{ schedule }"}
        every(schedule).do_schedule
      end
      do_event(:at_startup)
    end
  end
  
  def do_schedule # @!visibility private
    super rescue NoMethodError
    do_event(:at_schedule)
  end

  # задаёт обработчик, вызываемый по расписанию
  # @param options [Hash] Хеш, задающий распимание
  # @option options [ActiveSupport::Duration] :every интервал. например 1.hour, 30.minutes, 10.seconds
  # @option options [String, Time] :at время в формате 'HH:MM'. Можно также указывать массив, например ['10:00', '13:10']
  # @yield код, который будет выполняться по расписанию
  # @example Включать свет на пять минут каждый день в 10:00 и 13:00
  #   at_schedule(every: 1.day, at: ['10:00', '13:00']) do
  #     light1.on! delay: 5.minutes
  #   end
  def at_schedule(options = nil, &block)
    self.schedule = options if options
    events.add_with_replace(:at_schedule, block)
  end

  # возвращает последнее значение - обект Indication
  # @param value [Float, Fixnum] значение, если не указано, возвращается время любого изменения значения
  def last_indication(value = nil)
    query = indications.limit(1).order('created_at DESC')
    query = query.where(value: value) if value
    query.first
  end

  # возвращает время последнего изменения значения
  # если значение не менялось, возвращается 0000 год 01 мес 01 день
  # @param value [Float, Fixnum] - значение, если не указано, возвращается время любого изменения значения
  def last_indication_time(value = nil)
    indication = last_indication(value)
    indication ? indication.created_at : Time.new(0)
  end  

  # возвращает время, прошедшее с последнего изменения значения
  # @return [ActiveSupport::Duration]
  def last_indication_interval(value = nil)
    v = last_indication_time(value)
    Time.now - v if v
  end

  def self.required_methods # @!visibility private
    @required_methods ||= []
  end

  def required_methods # @!visibility private
    result = self.class.required_methods 
    result += driver_module.required_methods if driver_module.respond_to? :required_methods
    result
  end

  def enabled?
    !disabled?
  end

  def enabled=(enabled)
    self.disabled = !enabled
    save!
  end

  def disabled?
    disabled if respond_to? :disabled
  end

  def save_and_copy_descendants(source_entity) # @!visibility private
    transaction do
      unless save
        return false
      end
      return true unless source_entity
      source_entity.children.each do |child|
        attribs = child.attributes_for_copy
        attribs['parent_id'] = nil
        attribs['name'] = self.class.generate_new_name(source_entity.name, self.name, child.name)

        e = Entity.new(attribs)
        e.parent = self
        e.behavior_script = child.behavior_script.to_s.gsub(source_entity.name, self.name)
        saved = e.save_and_copy_descendants(child)
        unless saved
          e.errors.full_messages.each do |msg|
            # you can customize the error message here:
            self.errors[child.name] << msg
            raise ActiveRecord::Rollback, msg
          end

          return false
        end
      end
    end
  end

  def destroy_with_descendants
    transaction do
      children.each{|c| c.destroy_with_descendants}
      if (!destroy) && parent
        errors.full_messages.each do |msg|
          # you can customize the error message here:
          parent.errors[name] << msg
          raise ActiveRecord::Rollback, msg
        end
      end
      return true
    end
    false
  end

  def attributes_for_copy # @!visibility private
    attributes.reject{|k,v| %w(lft rgt depth id children_count).include? k.to_s }
  end

  # проверяет, является ли текущий контекст вызова метода удалённым,
  # т.е. вызванным на другом сервере с помощью объекта класса *Server*
  def remote_call?
    state.include?(:remote_execute)
  end

  protected

  # @!visibility private
  def store_value(v, dt = Time.now, do_set_driver = true)
    if binary? && v && !(v==0 || v==1)
      raise ArgumentError, "Value #{ v } is not binary"
    end

    old_value = self.value

    set_driver_value(value_to_driver_value(v)) if respond_to?(:set_driver_value) && do_set_driver

    dbl_change_assigned = events.assigned?(:at_dbl_change)

    if dbl_change_assigned
      last_time = last_indication_time
      dbl_change_assigned = last_time && ((Time.now - last_time) < 1.second)
    end

    update_columns(value: v)

    if old_value != v
      do_event :at_on if on?
      do_event :at_off if off?
      do_event :at_change, old_value
      do_event :at_dbl_change if dbl_change_assigned
    end
    begin
    indications.create!(value: v, dt: dt) unless v.nil?
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
    v
  end

  # @!visibility private
  def self.method_missing(method_sym, *arguments, &block)
    Entity[method_sym] || super
  end

  def method_missing(method_sym, *arguments, &block)
    Entity[method_sym] || super
  end

  # @!visibility private
  def self.register_required_methods(*args)
    #required_methods |= args.flatten
    @required_methods = [] unless @required_methods
    @required_methods |= args.flatten
  end

  # @!visibility private
  def driver_module(driver_name = driver)
    @driver_module ||= nil
    if !@driver_module || driver_changed?
      @driver_module = "#{ driver_name }_driver".camelcase.constantize unless driver.blank?
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

  def driver_valid?
    self.driver = nil if driver==''
    if driver && !Entity.drivers_names.include?(driver.to_s)
      errors.add(:driver, "Driver \"#{ driver }\" is not valid")
    end
  end

  self.require_entity_classes
end

 

