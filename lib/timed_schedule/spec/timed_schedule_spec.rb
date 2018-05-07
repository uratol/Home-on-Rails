require 'spec_helper'
require 'active_support/all'



describe TimedSchedule do
  it 'has a version number' do
    expect(TimedSchedule::VERSION).not_to be nil
  end
end


describe TimedSchedule::Schedule::HourlySchedule do
  it 'by duration' do
    h = TimedSchedule::Schedule::HourlySchedule.new(1.minute)
    expect(h.next_occurrence('00:00')).to eq('00:00'.in_time_zone)

    h = TimedSchedule::Schedule::HourlySchedule.new(2.hours + 10.minutes)
    expect(h.next_occurrence('03:00')).to eq('04:20'.in_time_zone)
    expect(h.next_occurrence('23:59')).to eq(nil)
  end

  it 'by times' do
    h = TimedSchedule::Schedule::HourlySchedule.new('13:00')
    expect(h.next_occurrence('03:00')).to eq('13:00'.in_time_zone)
    expect(h.next_occurrence('13:00')).to eq('13:00'.in_time_zone)
  end

  it 'by array of times' do
    h = TimedSchedule::Schedule::HourlySchedule.new(['10:15:35', '15:00'])
    expect(h.next_occurrence('01:00')).to eq('10:15:35'.in_time_zone)
    expect(h.next_occurrence('14:00')).to eq('15:00'.in_time_zone)
    expect(h.next_occurrence('15:01')).to eq(nil)
  end

  it 'to_hash & from_hash' do
    h = TimedSchedule::Schedule::HourlySchedule.new(1.hour)
    hash = h.to_hash
    expect(hash).to include(duration: 1.hour)

    h = TimedSchedule::Schedule::HourlySchedule.from_hash(hash)
    expect(h.duration).to eq(1.hour)
    expect(h.times).to eq(nil)

    times = ['10:15:35', '15:00'].map(&:in_time_zone)
    h = TimedSchedule::Schedule::HourlySchedule.new(times)
    hash = h.to_hash
    expect(hash).to include(times: times)

    h = TimedSchedule::Schedule::HourlySchedule.from_hash(hash)
    expect(h.duration).to eq(nil)
    expect(h.times).to eq(times)

  end

end

describe TimedSchedule::Schedule do

  before do
    daily =  TimedSchedule::Schedule::DailySchedule.new((now = Time.now))
    daily.add_recurrence_rule TimedSchedule::Schedule::DailySchedule::Rule.daily
    hourly = TimedSchedule::Schedule::HourlySchedule.new(2.hours)
    @daily_every_2_hours = TimedSchedule::Schedule.new(daily, hourly)
  end

  it 'Recurrence' do
    expect(@daily_every_2_hours.next_occurrence('00:15'.in_time_zone)).to eq('02:00'.in_time_zone)
  end

  it 'Persistence' do
    hash = @daily_every_2_hours.to_hash
    expect(hash).to include(daily: be_an(Hash), hourly: be_an(Hash))
    schedule = TimedSchedule::Schedule.from_hash(hash)
    expect(schedule).to eq(@daily_every_2_hours)
  end

  it 'to_s' do
    expect(@daily_every_2_hours.to_s).to eq('Daily every 2 hours')
  end

end

