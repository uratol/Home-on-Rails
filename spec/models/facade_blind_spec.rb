require 'spec_helper'

require 'entity'

describe FacadeBlind, type: :model do

  attr_accessor :fb

  before do
    Actor.find_or_create_by(name: :fb_up, driver: :dummy, caption: 'fb_up')
    Actor.find_or_create_by(name: :fb_down, driver: :dummy, caption: 'fb_down')

    self.fb = FacadeBlind.find_or_create_by(name: :fb, driver: :bidirectional_tilt_motor, caption: 'test facade blind')
    fb.behavior_script = <<-eos
      def up_full_time
        10.second
      end

      def down_full_time
        10.second
      end
    eos

    #fb.send :behavior_script_eval
    fb.save!
  end

=begin
  it "ranges" do
    fb.tilt_range = -80..85
    expect(fb.min_tilt).to eq(-80)
    expect(fb.max_tilt).to eq(85)

    fb.position_range = 0..100
    expect(fb.min).to eq(0)
    expect(fb.max).to eq(100)

  end
=end
=begin

  it "position" do
    puts "from #{ fb.position } to 40, 0, 20"
    fb.set_positions!(40,0,20)
    sleep(1.second)
    expect(fb.position).to be_between(9,11)
    sleep(3.second)
    expect(fb.position).to be_between(39,41)
    sleep(0.5.second)
    expect(fb.position).to be_between(39,41)
    sleep(3.second)
    expect(fb.position).to be_between(9,15)
    sleep(2.second)
    expect(fb.position).to be_between(0,1)
    sleep(1.second)
    expect(fb.position).to be_between(9,15)
    sleep(1.second)
    expect(fb.position).to be_between(19,20)
    sleep(1.second)
    expect(fb.position).to eq(20)
  end
=end

  it "tilt" do
    puts "from #{ fb.position } to 40, 0, 20"
    expect(fb.position).to eq(0)
    expect(fb.tilt).to eq(0)
    fb.min_tilt = -80
    fb.max_tilt = 80
    fb.tilt_up_full_time = 10.second
    fb.tilt_down_full_time = 10.second
    fb.set_tilt!(0)

    puts "set tilt 0"
    10.times do |i|
      sleep(0.5)

      puts "step: #{ 0.5 * i }; position: #{ fb.position }; tilt: #{ fb.tilt }"
    end
    #expect(fb.position).to eq(0)
    #expect(fb.tilt).to eq(0)

    puts "set position 50"
    fb.set_position!(50)
    20.times do |i|
      sleep(0.5)

      puts "step: #{ 0.5 * i }; position: #{ fb.position }; tilt: #{ fb.tilt }"
    end

    #expect(fb.position).to eq(50)
    #expect(fb.tilt).to eq(0)
  end


  end
