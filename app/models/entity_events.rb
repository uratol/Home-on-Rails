class EntityEvents < Array
  
  class EntityEvent
    attr_accessor :name, :code, :options
    
    def initialize name, code, options = {}
      @name, @code, @options = name, code, options
    end
    
    def call
      @code.call
    end
    
    def to_s
      "#{name}#{ if @options.any? then @options.to_s end }"
    end
  end
  
  def add_with_replace(event_name, prc)
    self.reject!{|e| e.name==event_name }
    add event_name, prc
  end

  def add(event_name, prc, options = {})
    push EntityEvent.new(event_name, prc, options)
  end
  
  def assigned?(event_name)
    self.find{|e| e.name==event_name}
  end
  
  def call event_name, options = {}
#puts "events#call event_name=#{event_name}, options=#{options}, length=#{inspect}"
    
    select{|e| e.name==event_name && e.options[:source_row]==options[:source_row]}.each(&:call)
  end  
  
end
