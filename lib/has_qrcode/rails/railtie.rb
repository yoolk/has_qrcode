module HasQrcode
  class Railtie < Rails::Railtie
    initializer "load qrcode modules" do
      HasQrcode::Hooks.init
    end
    
    rake_tasks do
      load "has_qrcode/rails/qrcode.rake"
    end
  end
end
