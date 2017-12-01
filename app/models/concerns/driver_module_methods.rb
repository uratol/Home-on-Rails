module DriverModuleMethods

  def do_watch
    return unless respond_to? :watch
    @threads.each(&:kill) if (@threads ||= []).any?
    @threads << Thread.new(@driver_module) do |d|
      puts "Driver #{ d }: watching"
      ActiveRecord::Base.connection_pool.with_connection do
        watch do |address, value|
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