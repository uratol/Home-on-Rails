module ChangeBehavior
  
  def self.included base
    base.register_events :at_change, :at_on, :at_off, :at_dbl_change
  end  
  
end