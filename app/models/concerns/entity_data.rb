module EntityData
  extend ActiveSupport::Concern

  included do
    before_save :save_data
    class_attribute :stored_attributes
  end
  
  private
  
  @data_hash = nil
  
  def data_hash
    return @data_hash if @data_hash 
    if data
      @data_hash = JSON.parse(data).with_indifferent_access
    else
      @data_hash = {}.with_indifferent_access
    end    
    return @data_hash  
  end
  
  
  def data_method method_sym, *arguments
    is_assignment = method_sym.to_s.last == '='
    if is_assignment
      method_sym = method_sym.to_s[0..-2].to_sym
    end
    
    return if stored_attributes.nil? || !(stored_attributes.include? method_sym) 
    
    result = is_assignment ? data_hash[method_sym] = arguments.first : data_hash[method_sym]
    return result || 0
  end
  
  def save_data
    self.data = @data_hash.to_json if @data_hash && @data_hash.any?
  end
  
  module ClassMethods
    def register_stored_attributes *args
      self.stored_attributes = [] unless stored_attributes
      self.stored_attributes |= args.flatten
    end
  end

end
