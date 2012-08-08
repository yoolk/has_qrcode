module HasQrcode
  class Railtie < Rails::Railtie
    initializer do
      ActiverecordQrcode::Hooks.init
    end
  end
end
