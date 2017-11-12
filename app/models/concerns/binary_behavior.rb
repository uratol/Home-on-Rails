module BinaryBehavior

  # @return [Boolean] true если включено, false если выключено
  def on?
    value && value != min
  end

  # @return [Boolean] false если включено, true если выключено
  def off?
    value == min
  end

  def opposite_value # @!visibility private
    min + max - (value || 0)
  end

  # Переключает устройство - включает, если выключено и выключает, если включено
  def switch!
    write_value(opposite_value)
  end

  # Включает устройство
  # @param options [Hash]
  # @option options [ActiveSupport::Duration, nil] :delay (опционально) время, по прошествии которого устройство будет выключено
  def on!(options = {})
    write_value max if value != max 
    wait_for(options[:delay]).off! if options[:delay]  
    value
  end

  # Включить дибо выключить устройство
  # @param v [Boolean] значение, true - включить, false - выключить
  def on=(v)
    v && v != 0 ? on! : off!
  end

  # Выключает устройство
  # @param options [Hash]
  # @option options [ActiveSupport::Duration, nil] :delay (опционально) время, по прошествии которого устройство будет включено
  def off!(options = {})
    write_value min if value != min 
    wait_for(options[:delay]).on! if options[:delay]
    value
  end

  # Выключить дибо включить устройство
  # @param v [Boolean] значение, true - выключить, false - включить
  def off=(v)
    v && v != 0 ? off! : on!
  end

  # Включить/выключить устройство/устройства несколько раз подряд (поморгать). При этом значения в indications не попадают, вызывается только set_driver_value
  # @param args [Hash]
  # @option args [ActiveSupport::Duration, nil] :delay время включения/выключения
  # @option args [Fixnum] :times количество включений/выключений
  # @option args [Entity, Array<Entity>] :devices устройство либо массив устройств, которыми моргаем
  def self.blink(args = {}, &block_after)
    delay = args[:delay] || 0.2
    devices = args[:devices]
     
    Thread.new do
      (args[:times]||1).times do |i|
        2.times do |j|
          [*devices].each{|e| e.set_driver_value(if j==0 then e.opposite_value else e.value end)}
          sleep(delay)
        end
      end
      if block_after
        if args[:sender]
          args[:sender].instance_eval(&block_after) 
        else
          block_after.call  
        end
      end
    end
  end

  # Среднее значение за период
  # @param interval [ActiveSupport::Duration] период, за который возвращается среднее значение, начиная от текущего времени
  # @return [Float]
  def average_value(interval)
    to = Time.now
    from = to - interval
    first_indication = indication_at(from)
    if first_indication
      first_indication.created_at = from
    else
      first_indication = Indication.new(created_at: from, value: 0)
    end
    
    arr = [first_indication] 
    arr += indications.where('created_at between ? and ?', from, to).order(:created_at).to_a 
    arr << Indication.new(created_at: to, value: value)
    
    prev_indication = nil
    sum  = 0
    arr.each_with_index do |ind, i|
      sum += prev_indication.value * (ind.created_at - prev_indication.created_at) if prev_indication
      prev_indication = ind
    end
    sum / (to - from)
  end

  def do_schedule # @!visibility private
    self.on = average_value(schedule * 10) < data.pwm_power if data.pwm_power
    super
  end

  # возвращает мощность ШИМ, при которой с периодичностью, заданой в опции schedule элемент будет включаться/выключаться
  # @return [Float] мощность задаётся в пределах 0..1
  def pwm_power
    data.pwm_power
  end

  def pwm_power=(value)
    raise 'PWM power must be in 0..1 range' unless (0..1).include(value)
    data.pwm_power = value
  end

end