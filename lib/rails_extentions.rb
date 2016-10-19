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
    from = Time.parse(from)
    to = Time.parse(to)
    if from > to
      if self > from
        to += 1.day
      else
        from -= 1.day
      end
    end
    super(from ,to)
  end
end