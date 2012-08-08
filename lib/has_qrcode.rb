require "active_record"

module HasQrcode
  autoload :VERSION,            'has_qrcode/version'
  autoload :Model,              'has_qrcode/model'
  autoload :Hooks,              'has_qrcode/hooks'
end

require 'has_qrcode/railtie' if defined?(Rails::Railtie)
