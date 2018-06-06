module DriverModuleMethods

  def driver_name
    name[0..-7].underscore # cut "Driver" suffix (module names should be "GpioDriver", "MqttDriver" etc)
  end

  def title
    name[0..-7].titleize
  end

  def description
    ''
  end unless respond_to? :description

  def to_s
    driver_name
  end

  def do_startup
    startup if respond_to? :startup
  rescue Exception => e
    puts e.message
    Rails.logger.error(e.message)
  end

  def do_watch
    return unless respond_to? :watch
    @watch_thread.try :kill
    @watch_thread = Thread.new(self) do |d|
      puts "Driver #{ d }: watching"
      ActiveRecord::Base.connection_pool.with_connection do
        d.watch do |address, value|
          Thread.exclusive do
            ActiveRecord::Base.connection_pool.with_connection do
              begin
                ent = Entity.where(driver: d.driver_name, address: address).first
                ent.write_value(ent.driver_value_to_value(value), false)
              rescue RuntimeError => e
                Rails.logger.error e.message
                Rails.logger.error e.backtrace.join("\n")
              end
            end
          end
        end
      end
    end


  rescue Exception => e
    puts e.message
    Rails.logger.error(e.message)
  end
end