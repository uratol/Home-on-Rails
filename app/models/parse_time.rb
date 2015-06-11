# encoding: utf-8 

module ParseTime 
# require 'rails/all'

  def parse_time (s, options = {})
    options = {} if options.nil?
    
    s.strip!

    {'полпервого' => 0, 'полвторого' => 1, 'полтретьего' => 2 \
      , 'полчетвёртого' => 3, 'полпятого' => 4, 'полшестого' => 5 \
      , 'полседьмого' => 6, 'полвосьмого' => 7, 'полдевятого' => 8 \
      , 'полдесятого' => 9, 'полодинадцатого' => 10, 'полдвенадцатого' => 11
    }.each do |k,v|
      s.gsub!(k,"#{ v.to_s }:30")
      s.gsub!(k[3..-1],(v+1).to_s)
    end
    
    {'полдень' => '12:00', 'полночь' => '00:00' }.each do |k,v|
      s.gsub!(k,v)
    end
    
    
    options[:type]=:interval if s.include?('через')
    
    m = s.match(/(?<num1>\d+).?(?<unit1>час|минут)?\D*(?<num2>\d+)?/)
    
    
    if m
      num1, num2, unit1 = m[:num1], m[:num2], m[:unit1]
    else
      m = s.match(/(?<unit1>час|минуту)/)
      return nil unless m
      num1, num2, unit1 = '1', nil, m[:unit1]
    end
    
    return nil unless num1
    
    hours, minutes = nil
    
    # Rails.logger.debug { "m[:unit1]= #{ m[:unit1] }" }
    
    if unit1=='минут'
      minutes = num1.to_f
      hours = num2.to_f-1 if num2   # 5 минут 7-го = 6:05
    else
      hours, minutes = num1.to_f, num2.to_f
    
    end   
    
    d = Time.now
    if options[:type]==:interval
      hours ||= 0
      minutes ||= 0
      return nil if hours==0 && minutes==0
    else
      d = d.to_date  
      if (s.include?('вечера') && hours <= 12) || (s.include?('дня') && hours <= 4)
        hours += 12
      end

      return nil if hours>24 || minutes>59
    end
    
    
# Rails.logger.debug "num1=#{ num1 } num2=#{ num2 }"
      

    d += hours.hours+minutes.minutes
    d += 1.day if d<Time.now || s.include?('завтра')
    return d
    
  end
  
  def time_words t
    "#{ t.to_s(:time) } #{ case when t.today? then 'сегодня' when (t-1.day).today? then 'завтра' else ", #{ t.day } #{ t.month } #{ t.year }" end }"
  end
  
end

# puts parse_time('в 4 вечера')

