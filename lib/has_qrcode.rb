require "active_record"

module HasQrcode
  autoload :VERSION,            'has_qrcode/version'
  autoload :Model,              'has_qrcode/model'
  autoload :Hooks,              'has_qrcode/hooks'
  autoload :Processor,          'has_qrcode/processor'
  autoload :Storage,            'has_qrcode/storage'
  autoload :Configuration,      'has_qrcode/configuration'
end

require 'has_qrcode/rails/railtie' if defined?(Rails::Railtie)
