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

class Time
  def between?(from, to)
    from = Time.parse(from) if from.is_a? String
    to = Time.parse(to) if to.is_a? String
    if from > to
      if self > from
        to += 1.day
      else
        from -= 1.day
      end
    end
    super(from ,to)
  end

  def holiday?
    sunday? || saturday?
  end

end

class Range
  def ===(other)
    if other.is_a?(Time)
      other.between?(first, last)
    else
      super(other)
    end
  end
end