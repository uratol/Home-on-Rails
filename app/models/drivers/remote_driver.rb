# Драйвер обеспечивает доступ к устройствам, расположенным на другом сервере
# Поле "address" должно быть следующего формата:  server_name.object_name либо server_name (в последнем случае будет вызван удалённый объект с тем же именем, что и у текущего объекта)
# где server_name - имя объекта класса *Server*, object_name - имя объекта на удалённом сервере

module RemoteDriver

  def self.extended(base)
    base.singleton_class.validates :address, presence: true, format: { with: /\A[a-z][a-z0-9_]+(\.[a-z][a-z0-9_]+)?\Z/ }
    base.singleton_class.validate :remote_server_valid?
  end

  def set_driver_value(v)
    remote_object.set_driver_value(v)
  end

  def get_driver_value
    remote_object.get_driver_value
  end

  def remote_object
    remote_server.public_send(remote_object_name)
  end

  def remote_server
    Entity[remote_server_name]
  end

  def remote_server_name
    address.split('.').first
  end

  def remote_object_name
    address.split('.').second || name
  end

  private


  def remote_server_valid?
      errors.add(:address, "Remote server \"#{ remote_server_name }\" not found") unless remote_server
  end

end