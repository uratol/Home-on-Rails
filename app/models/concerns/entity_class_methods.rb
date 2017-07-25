module EntityClassMethods

  def drivers_names
    @@drivers_names ||= Dir.entries(Home::Engine.root.join('app','models','drivers')).inject([]){|a,f| s=f[-10..-1]; a+if s=='_driver.rb' then [f[0..-11]] else [] end}
  end

  def drivers
    drivers_names.map{|s| "#{ s.camelize }Driver".constantize}
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
  
  def menu_entities(root = nil)
    where('parent_id is null and (disabled=? or id=?)', false, root).order(:location_x)
  end

  def ancestors_and_self(class_limit = Entity, recurs_class = nil)
    klass = recurs_class || self
    is_limit = klass.superclass.nil? || (klass==class_limit)
    a = (is_limit ? [] : self.ancestors_and_self(class_limit, klass.superclass) ) << klass
    recurs_class ? a : a.reverse 
  end
  
  def types 
    ancestors_and_self.map{|c| c.name.underscore}.reverse
  end  
  
  def require_entity_classes
    (Dir["#{Home::Engine.root}/app/models/entities/*.rb"] + Dir["#{Rails.root}/app/models/entities/*.rb"]).each {|file| require_dependency file}
  end

  def register_events(*args)
    args.each do |sym|
      define_method sym do |&block|
        events.add_with_replace sym, block
      end
    end
  end

  def execute_sql(*sql_array)     
    connection.execute(send(:sanitize_sql_array, sql_array))
  end

  def generate_new_name(source_name, target_name, current_name)
    name_diff = parse_name_difference(source_name, target_name)
    new_name = current_name.gsub(name_diff[:source], name_diff[:target])
    while Entity.find_by_name(new_name) != nil
      number_part = new_name.scan(/\d+/).last
      if number_part
        new_name.sub!(number_part, (number_part.to_i + 1).to_s)
      else
        new_name += '_1'
      end
    end
    new_name
  end

  def params
    @params
  end

  def params=(params)
    @params = params
  end

  protected

  def register_attributes(*args)
    if args.length==1 && args.first.is_a?(Hash)
      iterator = args.first
    else
      iterator = args
    end    
    iterator.each {|key,value| register_attribute key, value}
  end

  def parse_name_difference(source, new)
    detect_prefix_length = lambda{|src, dst| src.each_char.with_index{|ch, i| break i if ch != dst[i]}}
    prefix_length = detect_prefix_length.call(source, new)
    suffix_length = detect_prefix_length.call(source.reverse, new.reverse)

    {
        prefix: source[0,prefix_length],
        suffix: suffix_length > 0 ? source[-suffix_length..-1] : '',
        source: source[prefix_length..-suffix_length-1],
        target: new[prefix_length..-suffix_length-1]
    }
  end

  private
  
  def register_attribute(attr_name, default_value = nil)
    attr_writer attr_name
    
    define_method attr_name do
      instance_variable_get('@'+attr_name.to_s) || default_value
    end
  end
end

