require 'timed_schedule/version'
require 'ice_cube'

module TimedSchedule

  class Schedule

    class DailySchedule < IceCube::Schedule
      Rule = IceCube::Rule
    end

    class HourlySchedule

      attr_accessor :duration, :times, :start_time

      def initialize(recurrence = '00:00', start_time = '00:00')
        self.start_time =  start_time.in_time_zone
        if recurrence.is_a?(ActiveSupport::Duration) || recurrence.is_a?(Numeric)
          self.duration = recurrence
        else
          self.times = recurrence
        end
      end

      def times=(times)
        @duration = nil
        @raw_times = times
        @times = [*times].map(&:in_time_zone).sort
      end

      def next_occurrence(from_time)
        start_time = @start_time
        from_time = from_time.in_time_zone
        if @duration
          while start_time < from_time do
            start_time += @duration
          end
          start_time if start_time.day == @start_time.day
        else
          @times.detect{|t| t >= from_time}
        end
      end

      def to_hash
        result = {start_time: start_time}
        if @duration
          result[:duration] = @duration
        else
          result[:times] = @raw_times
        end
        result
      end

      def self.from_hash(hash)
        self.new(hash[:duration] || hash[:times], hash[:start_time])
      end

      def ==(other)
        other.is_a?(self.class) && other.duration == duration && other.times == times && other.start_time == start_time
      end

      def to_s
        if duration
          "every #{ duration_to_s(duration) }"
        else
          "at #{ @raw_times }"
        end
      end

      private

      def duration_to_s(duration)
        seconds = duration.to_i
        hours = seconds / 3600
        seconds -= hours * 3600
        minutes = seconds / 60
        seconds -= minutes * 60

        ("#{ hours.to_s + ' hours' if hours > 0}" +
            " #{ minutes.to_s + ' minutes' if minutes > 0}" +
            " #{ seconds.to_s + ' seconds' if seconds > 0}"
        ).strip
      end
    end

    attr_reader :daily, :hourly

    def initialize(daily_schedule, hourly_schedule = nil)
      @daily = daily_schedule
      @hourly = hourly_schedule || HourlySchedule.new
      @hourly.start_time = @dayly.start_time unless @hourly.start_time
    end

    def next_occurrence(from_time)
      time = @hourly.next_occurrence(from_time)
      if time
        day = @daily.next_occurrence(from_time.beginning_of_day)
      else
        day = @daily.next_occurrence(from_time.beginning_of_day + 1.day)
        time = @hourly.next_occurrence('00:00')
      end
      time.change(year: day.year, month: day.month, day: day.day)
    end

    def to_hash
      {daily: @daily.to_hash, hourly: @hourly.to_hash}
    end

    def self.from_hash(hash)
      self.new(DailySchedule.from_hash(hash[:daily]), HourlySchedule.from_hash(hash[:hourly]))
    end

    def ==(other)
      other.is_a?(self.class) && other.daily == daily && other.hourly && hourly
    end

    def to_s
      "#{ daily } #{ hourly }"
    end

    end
end
