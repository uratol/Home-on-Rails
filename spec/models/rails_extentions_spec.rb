require 'spec_helper'

describe Time do

  it 'between' do
    expect('13:00'.to_time.between? '21:00','08:00').to be false
    expect('09:00'.to_time.between? '21:00','08:00').to be false
    expect('22:00'.to_time.between? '21:00','08:00').to be true
    expect('02:00'.to_time.between? '21:00','08:00').to be true

  end

  it ('case with range') do
    expect(
      case '02:00'.to_time
        when '21:00'..'07:00'
          true
        else
          false
      end
    ).to be(true)
  end

end