=begin
require 'spec_helper'

describe Log, type: :model do

  before do
    #puts "Tables: #{ActiveRecord::Base.connection.tables};"
    @e = Entity.find_or_create_by(name: 'test', caption: 'test', type: 'Widget')
  end
  
  it 'entity raise in thread logged' do
    e.behavior_script = "at_change{ raise 'err'}"
    e.switch!
    Thread.new{
      expect(@e.).to eq(3.15)
    }
    expect(@e.data.stored_float).to eq(3.15)
  end
  
end
=end