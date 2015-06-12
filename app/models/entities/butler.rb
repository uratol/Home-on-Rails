#encoding: utf-8
class Butler < Widget

  require 'nokogiri'
  require 'open-uri'
  require 'parse_time'
  require 'alarm_clock'
  
  class Command
    
    @match_params = {}
    
    def phrases
      []
    end

    def detect_command(command)
      result = phrases.any?{|phrase| phrase=~command}
      if result
        @match_params = Hash[ Regexp.last_match.names.zip( Regexp.last_match.captures ) ].with_indifferent_access
      end
      result
    end
    
    def run_command(command, options = {})
    end  
  end
  
  class CommandNotFound < Command
    def detect_command command
      true
    end
    
    def run_command(command, options = {})
      "Неизвестная команда: #{ command }"
    end  
  end
  
  class CommandCancel < Command
    def phrases
      [/отмена/,/отставить/,/я передумал/,/отбой/]
    end

    def run_command(command, options = {})
      ['Ok','Ладно','Отбой'].sample
    end  

  end
  
  class CommandTime < Command
    def phrases
      [/время/,/который (сейчас )?час/,/сколько (сейчас )?време(ни|я)/]
    end

    def run_command(command, options = {})
      Time.now.strftime("%H:%M")
    end  
  end
  
  class CommandWeather < Command
    def phrases
      [/.*^погод(а|у|е).*/]
    end

    def run_command(command, options = {})
      file_handle = open('http://informer.gismeteo.ua/xml/33345_1.xml')
      xml = Nokogiri::XML(file_handle).xpath("//FORECAST[1]")
      t = xml.xpath('TEMPERATURE')
      p = xml.xpath('PHENOMENA')
      
      result = "Температура: #{ t.xpath("@min").first.value }..#{ t.xpath("@max").first.value }"
      result+="\n"+case p.xpath("@cloudiness").first.value.to_i when 0 then 'ясно' when 1 then 'малооблачно' when 2 then 'облачно' when 3 then 'пасмурно' end

      # вероятность осадков, если они есть
      rpower_str=case p.xpath("@rpower").first.value.to_i when 0 then ' '+'возможен' end
      spower_str=case p.xpath("@spower").first.value.to_i when 0 then ' '+'возможна' end

      result+="\n"+case p.xpath("@precipitation").first.value.to_i when 4 then rpower_str+'дождь' when 5 then rpower_str+'ливень' when 6 then rpower_str+'снег' when 7 then rpower_str+'снег' when 8 then spower_str+'гроза' when 10 then 'без осадков' end
      
    end  
    
  end
  
  def CommandCalculator
    def phrases
      [/сколько будет .+/]
    end

    def run_command(command, options = {})
      result = ["Не знаю","Без понятия"].sample
    end
    
  end
  
  class CommandAlarmClock < Command

    include ParseTime

    include AlarmClock


    
    def phrases
      [/((постав(ит)?ь|установи(ть)?|(?<delete>удали(ть)?)|(?<check>провер(ит)?ь)) )?(?<type>будильник|таймер)( на)?(?<time> .*)?/]
    end

    def run_command(command, options = {})
      options ||= Hash.new 
      options = options.with_indifferent_access
      options.merge! @match_params if @match_params
      
      
      time_string = options[:time].to_s
      if time_string.blank?
        if options[:waiting_param]=='time'
          time_string = command
        else 
          if options[:check] || options[:delete]
            old_alarm = get_alarm
            msg = "#{ options[:type] } #{ old_alarm ? '' : 'не'  } #{ options[:delete] && old_alarm ? 'удален' : 'установлен' } #{ old_alarm ? 'на '+time_words(old_alarm.run_at) : '' }".mb_chars.capitalize
            delete_alarm if options[:delete]
            return options.merge({message: msg})
          else  
            return options.merge({message: 'На который час?', waiting_param: 'time'})
          end
        end
      end
      
      time = parse_time(time_string)
      
      
      if time.nil?
        return {message: 'Непонятно... На который час?', waiting_param: 'time'}
      else      
        set_alarm(time)
        options.merge({message: "Установлен на #{ time_words time }", waiting_param: nil})
      end
    end 
    
  end
  
  @@commands = [CommandTime.new,CommandWeather.new,CommandAlarmClock.new,CommandNotFound.new]
  
  def run_command(command_string, options = {})
    command_string = clean_command_string command_string

    options = {} if options.nil? 
    options = options.with_indifferent_access

    # timeout    
    options = {} if options[:timestamp].nil? || (Time.now - options[:timestamp].to_time).seconds>30.seconds 
    
    if options.any?

      command = CommandCancel.new
      if !command.detect_command(command_string)
        command = @@commands.find{|cmd| cmd.class.name.demodulize==options[:commandClassName]}
      end
      
    else
      command = @@commands.find{|cmd| cmd.detect_command(command_string)};
    end
    result = command.run_command(command_string, options)
    if !result.is_a?(Hash)
      result = {message: result}.with_indifferent_access
    end
    result.merge!({commandClassName: command.class.name.demodulize, timestamp: Time.now})
    
  end

  private
  
  def clean_command_string s
    #s.mb_chars.downcase.gsub(/[^[[:word:]]\s]/,'').squeeze(' ')
    #Rails.logger.debug '++++'+s.mb_chars.downcase.squeeze(' ')
    
    s.to_s.mb_chars.downcase.squeeze(' ')
  end 
end