class ButlerController < ApplicationController
  def command
    @butler = Butler.find(params[:id])
    session[:commandOptions] = @butler.run_command(params[:commandText], session[:commandOptions])
    message = session[:commandOptions][:message]
    if !session[:commandOptions][:waiting_param]
      session[:commandOptions] = nil
    end
    
    render json: {response: message, sc: session[:commandOptions]}
  end

  def speak
    queryString = params[:s] #.gsub(. . ., '')
    lang = params[:lang] #Language code; see https://sites.google.com/site/tomihasa/google-language-codes
    require 'net/http'
    url = URI.parse('http://translate.google.com/translate_tts?ie=UTF-8&tl=' + lang + '&q=' + URI::encode(queryString))
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    send_data(res.body, :disposition => "inline", :filename => "sound.mp3", :type => "audio/mpeg");
  end
end
