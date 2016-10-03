class String
  def is_number?
    true if Float(self) rescue false
  end
end

class Numeric
  def sign
    self <=> 0
  end
end