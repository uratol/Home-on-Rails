module EntityBehavior
  extend ActiveSupport::Concern
  
  included do
    # relations, callbacks, validations, scopes and others...
    attr_accessor :behavior_script
    validate :behavior_script_valid?, :required_method_defined?
    before_save :behavior_script_write
    after_initialize :behavior_script_read
    after_initialize :behavior_script_eval
    after_destroy :behavior_script_delete
  
    include ::BinaryBehavior
    include ::EntityBehaviorHelpers
  end

  private

  def required_method_defined?
    required_methods.each do |required_method|
      errors.add :behavior_script, "Method \"#{ required_method }\" is not defined" if !methods.include? required_method
    end
  end
  

  # instance methods
  def behavior_script_read
    bf = behavior_file_name
    @old_behavior_script = @behavior_script = if bf && File.exist?(bf) then File.read(bf) end
    @old_name = name
  end

  def behavior_script_valid?
    behavior_script_eval
    errors.any?
  end

  def behavior_file_name(nm = name)
    Home.custom_behavior_path.join(nm+'.rb') if nm
  end  


  def behavior_script_eval
    return if !@behavior_script || state.include?(:behavior_script_eval)
    state.push :behavior_script_eval
    begin
      instance_eval @behavior_script, behavior_file_name.to_s, 1
    rescue Exception => e 
      msg = e.to_s
      line = backtrace_error_line e
      msg += "\n #{ line }" if line
      errors.add(:behavior_script, msg)
    end
    state.pop    
  end

  def behavior_script_write
    old_file_name = behavior_file_name(@old_name)
    new_file_name = behavior_file_name
    
    File.delete(old_file_name) if old_file_name && old_file_name!=new_file_name && File.exist?(old_file_name)
    
    if @old_behavior_script != behavior_script
      if @behavior_script.to_s.strip.blank?
        behavior_script_delete
        return
      end
      File.write behavior_file_name, @behavior_script.gsub("\r\n","\n") #fix windows linebreaks
      behavior_script_eval
    end  
  end

  def behavior_script_delete
    File.delete behavior_file_name if File.exist? behavior_file_name
  end

  def backtrace_error_line(e)
    line = nil
    e.backtrace.find do |b|
      /#{ Regexp.escape(behavior_file_name.to_s) }:(\d+):/.match(b).tap{|m| line = "Line #: #{ m[1] }" if m}
    end
    line
  end
  
  

  #module ClassMethods  end  
end

