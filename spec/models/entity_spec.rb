require 'spec_helper'

describe Entity, type: :model do
  
#  let(:user) { mock_model User, name: 'Lucas', email: 'lucas@email.com' }
  
  before do
    #puts "Tables: #{ActiveRecord::Base.connection.tables};"
    @e = Entity.find_or_create_by(name: 'test', caption: 'test', type: 'Widget')
  end
  
  it 'Data memory store' do
    @e.data.stored_float = 3.15
    expect(@e.data.stored_float).to eq(3.15)
  end
  
  it 'Data time store' do
    t = Time.now
    @e.data.time_field = t
    @e.save!
    @e = Entity[@e.id] # reload
    expect(@e.data.time_field).to eq(t)
  end
  
  def mail(to, expected_count)
    mail = nil
    expect { mail = @e.mail("test", to: to) }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
    expect(mail.to.size).to eq(expected_count)   
  end
  
  it('#mail to admins') { mail :admins, User.admins.count }
  it('#mail to all') { mail nil, User.count }
  it('#mail to array'){ mail ['test@example.com', 'test2 <test2@example.com>', 't@example.com'], 3 }
  
end