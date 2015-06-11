# encoding: utf-8 
require 'nokogiri'

class Weather < Widget
  def weather_text
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