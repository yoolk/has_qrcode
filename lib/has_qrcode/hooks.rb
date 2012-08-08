module HasQrcode
  class Hooks
    def self.init
      ActiveSupport.on_load(:active_record) do |app|
        ::ActiveRecord::Base.send(:include, HasQrcode::Model)
      end
    end
  end
end
