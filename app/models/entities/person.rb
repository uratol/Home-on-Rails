class Person < Entity
  alias_method :at_home?, :on?
  alias_method :at_home=, :on=
  alias_method :at_home!, :on!

  def binary?
    true
  end
end