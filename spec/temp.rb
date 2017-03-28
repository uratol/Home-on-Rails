Actor.find_or_create_by(name: :fb_up, driver: :dummy, caption: 'fb_up')
Actor.find_or_create_by(name: :fb_down, driver: :dummy, caption: 'fb_down')

fb = FacadeBlind.find_or_create_by(name: :fb, driver: :bidirectional_motor, caption: 'test facade blind')
fb.behavior_script = <<-eos
      def up_full_time
        10.second
      end

      def down_full_time
        10.second
      end

      self.position_range = 0..100
eos

#fb.send :behavior_script_eval
fb.save!


fb.position_range = 0..100
fb.tilt_range = -80..80
fb.tilt_up_full_time = 3.second
fb.tilt_down_full_time = 3.second
fb.set_position!(50)
#fb.set_tilt!(80)


30.times do |i|
  sleep(0.5)

  puts "step: #{ 0.5 * i }; position: #{ fb.position }; tilt: #{ fb.tilt };"
  #puts "relay_thread[:start_time]: #{ Time.now - fb.send(:relay_thread)[:start_time] }; relay_thread[:start_tilt]: #{ fb.send(:relay_thread)[:start_tilt] }"
end

# load '../home/spec/temp.rb'