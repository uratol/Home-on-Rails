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
    if TimeRangeComparable.args_is_time_str(from ,to)
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
    super
  end

  def holiday?
    sunday? || saturday?
  end

  protected

  def self.args_is_time_str(first, last)
    first.is_a?(String) && last.is_a?(String) && first.size.between?(3,5) && last.size.between?(3,5)
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
    if other.is_a?(TimeRangeComparable) && TimeRangeComparable.args_is_time_str(first, last)
      other.between?(first, last)
    else
      super
    end
  end
end