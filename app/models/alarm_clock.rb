module AlarmClock
  
  include Win32 if RUBY_PLATFORM.match(/mingw|mswin/)
  
  def play_sound(file_name)
    if RUBY_PLATFORM.match(/mingw|mswin/)
      Sound.play Home::Engine.root.join('app', 'assets', 'audio', file_name).to_s
    else
      pid = fork{ exec 'mpg123','-q', file_name }
    end
  end
  
  def play_alarm
    10.times{ play_sound('alarm.wav') }
  end

  def set_alarm time
    delete_alarm
    delay(run_at: time, queue: 'alarmclock').play_alarm
  end
  
  def get_alarm
    DelayedJob.find_by queue: 'alarmclock'
  end
  
  def delete_alarm
    DelayedJob.delete_all(queue: 'alarmclock')
  end
  
end