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

module TimeRangeComparable
  def between?(from, to)
    if from.is_a?(String) || to.is_a?(String)
      from = from.in_time_zone
      to = to.in_time_zone

      if from > to
        if self > from
          to += 1.day
        else
          from -= 1.day
        end
      end
    end
    super(from ,to)
  end

  def holiday?
    sunday? || saturday?
  end
end

class Time
  include TimeRangeComparable
end

class DateTime
  include TimeRangeComparable
end

class ActiveSupport::TimeWithZone
  include TimeRangeComparable
end

class Range
  def ===(other)
    if other.is_a?(TimeRangeComparable)
      other.between?(first, last)
    else
      super(other)
    end
  end
end