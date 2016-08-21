module EntityClassMethods

  def entity_drivers
    @@entity_drivers ||= Dir.entries(Home::Engine.root.join('app','models','drivers')).inject([]){|a,f| s=f[-10..-1]; a+if s=='_driver.rb' then [f[0..-11]] else [] end}
  end
  
  def entity_types
    @@entity_types ||= descendants.map{ |d| d.name.to_s }
  end

  def entity_types_downcase
    entity_types.map{|t| t.downcase }
  end
  
  def [](ind)
    if ind.is_a? Fixnum || ind.is_number? 
      find ind
    else
      find_by name: ind.to_s
    end
  end
  
  def menu_entities
    where(parent: nil).order(:location_x)
  end

  def ancestors_and_self(class_limit = Entity, recurs_class = nil)
    klass = recurs_class || self
    is_limit = klass.superclass.nil? || (klass==class_limit)
    a = (is_limit ? [] : self.ancestors_and_self(class_limit, klass.superclass) ) << klass
    recurs_class ? a : a.reverse 
  end
  
  def types 
    ancestors_and_self.map{|c| c.name.downcase}.reverse
  end  
  
  def require_entity_classes
    Dir["#{Home::Engine.root}/app/models/entities/*.rb"].each {|file| require_dependency file}
  end

  def register_events *args
    args.each do |sym|
      define_method sym do |&block|
        events.add_with_replace sym, block
      end
    end
  end

  def execute_sql(*sql_array)     
    connection.execute(send(:sanitize_sql_array, sql_array))
  end
  
  protected

  def register_attributes *args
    if args.length==1 && args.first.is_a?(Hash)
      iterator = args.first
    else
      iterator = args
    end    
    iterator.each {|key,value| register_attribute key, value}
  end  

  private
  
  def register_attribute attr_name, default_value = nil
    attr_writer attr_name
    
    define_method attr_name do
      instance_variable_get('@'+attr_name.to_s) || default_value
    end
  end
end

