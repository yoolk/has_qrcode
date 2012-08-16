module HasQrcode
  class Storage
    def self.location
      return @location if @location
      assign_default
      @location
    end
    
    def self.location=(location_name)
      case location_name
      when Symbol, String
        assign_location(location_name)
      when NilClass
        assign_default
      else
        raise "Missing storage location: #{location_name}"
      end
    end
    
    def self.create(active_record, options)
      location.new(active_record, options)
    end
    
    private
    def self.assign_location(location_name)
      require File.join(File.dirname(__FILE__), "/storages/#{location_name}")
      @location = HasQrcode::Storage.const_get("#{location_name.to_s.camelize}")
    end
    
    def self.assign_default
      assign_location(:filesystem)
    end
  end
end
