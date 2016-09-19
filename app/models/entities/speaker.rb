class Speaker < Widget
  
  module Tts
    def say phrase
      # `espeak "#{phrase}" -a 200 -v ru 2>/dev/null`
      # `echo "#{phrase}" | festival --tts --language english`
      tmp_file = '/tmp/tts.wav'
      `echo "#{phrase}" | text2wave -o #{tmp_file}`
      play tmp_file
    end
    
    alias speak say
    alias tell say
    alias talk say

    def play file
      `aplay -q #{ file } -D plughw:1`
    end
  end  

  extend Tts
  include Tts
end