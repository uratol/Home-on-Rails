module EntityData
  extend ActiveSupport::Concern
  
  class DataEntity
    def initialize entity
      @entity = entity
      if entity.attrs
        @hash = Marshal.load(entity.attrs).with_indifferent_access
      else   
        @hash = {}.with_indifferent_access
      end  
    end
    
    def method_missing method_sym, *arguments, &block
      is_assignment = method_sym.to_s.last == '='
      
      if (need_args = is_assignment ? 1 : 0) != arguments.size
        raise ArgumentError.new("Wrong arguments number. #{ arguments.size } of #{ need_args }")
      end
      
      if is_assignment
        method_sym = method_sym.to_s[0..-2].to_sym
        if arguments.first.nil?
          @hash.except! method_sym 
        else  
          @hash[method_sym] = arguments.first
        end  
        store_hash
      else
        @hash[method_sym]
      end  
    end

    private
    
    def store_hash
      @entity.attrs = @hash.empty? ? nil : Marshal.dump(@hash)
      @entity.update_columns attrs: @entity.attrs unless @entity.new_record?
    end    
    
  end
  
  def data
    @data ||= DataEntity.new(self)
  end
  
  private
  

end
