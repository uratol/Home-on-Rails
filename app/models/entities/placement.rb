class Placement < Entity
  def all_off klass = nil
    descendants.each{|e| e.off if e.respond_to?(:off) && (klass.nil? || (e.is_a? klass)) }
  end
  
  def light_off
    all_off Light
  end

end
