class Device < Entity
  include ChangeBehavior

  def init
    super
    @binary = true
  end  

end
