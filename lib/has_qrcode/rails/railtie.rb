module HasQrcode
  class Railtie < Rails::Railtie
    initializer do
      ActiverecordQrcode::Hooks.init
    end
    
    rake_tasks do
      load "has_qrcode/rails/qrcode.rake"
    end
  end
end
