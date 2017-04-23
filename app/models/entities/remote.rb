# Удалённое устройство, с идентичным web-сервером.
# Взаимодействие осуществляется по протоколу HTTP, при помощи GET-запроса.
# В поле address должен быть прописан DNS или IP-адрес удалённого устройства
# либо в виде 192.168.0.55 либо subdomain.subdomain.domain
# Для аутентификации будет использован email и зашифрованный пароль первого администратора (с наименьшим id)
# т.е. на удалённом сервере должен быть пользователь с таким же email-ом и с таким же паролем (не обязательно администратор)
# Если зашифрованный пароль не совпадает (а такое может быть из-за различного шифрования), при первом вызове на удалённом
# сервере будет создан пользователь remote.email_администратора с идентичным зашифрованным паролем.
# Если пароль администратора в дальнейшем будет изменён, на удалённом сервере нежно просто удалить этот логин и
# обратиться один раз к удалённому серверу, вызвав любой метод. Таким образом remote. логин будет пересоздан.
#
# Примеры использования:
# 1. Включить удалённое реле:
#   remote_device_name.remote_entity_name.on!
# где
#   "remote_device_name" - имя объекта Remote,
#   "remote_entity_name" - имя устройства на удалённой машине
#
# 2. Прочитать значение температуры на удалённом устройстве:
#   remote_temperature = remote_device_name.remote_entity_name.value
#
# 3. Установить положение и угол удалённой рафшторы:
#   remote_device_name.hall_facade_blind_1.set_position_and_tilt!(50, 45)



class Remote < Device
  require 'net/http'
  require 'yaml'

  PROTOCOL_PREFIX = 'http://'

  validates :address, presence: true

  def execute_remote_method(remote_entity_name, method_name, *arguments)
    uri = address
    uri = PROTOCOL_PREFIX + uri unless address.start_with?(PROTOCOL_PREFIX)
    uri += '/' unless uri.end_with?('/')
    uri += 'remote/'
    uri = URI(uri)

    admin = User.where(isadmin: true).first

    uri.query = URI.encode_www_form(entity: remote_entity_name, method: method_name, params: arguments.to_yaml, email: admin.email, pwd: admin.encrypted_password)
    request = Net::HTTP::Get.new(uri)

#    request = Net::HTTP::Post.new(uri)
#    request.set_form_data(entity: remote_entity_name, method: method_name, params: params.to_yaml)

    response = Net::HTTP.start(uri.hostname, uri.port, read_timeout: 10) do |http|
      http.request(request)
    end

    case response
      when Net::HTTPSuccess
        YAML::load(response.value)
      else
        raise "#{ response.body }. Invalid response from remote server(#{ response.value }). Address: #{ uri.host }, entity: #{ remote_entity_name }, method: #{ method_name }, arguments: #{ arguments.to_s }"
    end
  end

  protected

  class MethodProxy
    attr_accessor :owner, :remote_entity_name

    def initialize(owner, remote_entity_name)
      self.owner, self.remote_entity_name = owner, remote_entity_name
    end

    def method_missing(method_sym, *arguments, &block)
      owner.execute_remote_method(remote_entity_name, method_sym, *arguments)
    end

  end

  def method_missing(method_sym, *arguments, &block)
    if block || arguments.any?
      super
    else
      MethodProxy.new(self, method_sym)
    end
  end

end