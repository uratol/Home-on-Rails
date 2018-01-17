class String
  def is_number?
    true if Float(self) rescue false
  end
end

class Numeric
  def sign
    self <=> 0
  end

  def restrict_by_range(min, max = nil)
    max, min = min.last, min.first unless max
    self < min ? min : self > max ? max : self
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

  # fix for Windows - Time#utc returns Time

  alias_method :old_utc, :utc

  def utc
    old_utc.to_datetime
  end

end

class ActiveSupport::TimeWithZone
  include TimeRangeComparable
end

class Range
  alias :original_triple_equals :'==='
  def ===(other)
    if other.is_a?(TimeRangeComparable) && TimeRangeComparable.args_is_time_str(first, last)
      other.between?(first, last)
    else
      original_triple_equals other # super not worked, use alias
    end
  end
end


module PropagateMethodsToMembers
  def method_missing(method_sym, *arguments, &block)
    results = map do |member|
      member.public_send(method_sym, *arguments)
    end
    method_sym.to_s.ends_with?('?') ? results.all? : results
  end
end

class ActiveRecord::Relation
#  include PropagateMethodsToMembers
end

class Array
#  include PropagateMethodsToMembers
end