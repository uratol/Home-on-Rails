module DriverModuleMethods

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
                ent = Entity.where(driver: d.name[0..-7].downcase, address: address).first
                ent.write_value(ent.transform_driver_value(value))
              rescue RuntimeError => e
                Rails.logger.error e.message
                Rails.logger.error e.backtrace.join("\n")
              end
            end
          end
        end
      end
    end
  end
end