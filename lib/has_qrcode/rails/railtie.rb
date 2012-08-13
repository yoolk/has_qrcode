module HasQrcode
  class Railtie < Rails::Railtie
    initializer do
      ActiverecordQrcode::Hooks.init
      AWS.config(:logger => Rails.logger) if defined?(AWS)
    end
    
    rake_tasks do
      load "has_qrcode/rails/qrcode.rake"
    end
  end
end
