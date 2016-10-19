require 'spec_helper'

describe Time do

  it 'between' do
    expect('13:00'.to_time.between? '21:00','08:00').to be false
    expect('09:00'.to_time.between? '21:00','08:00').to be false
    expect('22:00'.to_time.between? '21:00','08:00').to be true
    expect('02:00'.to_time.between? '21:00','08:00').to be true
  end

end