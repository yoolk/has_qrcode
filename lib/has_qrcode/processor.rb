module HasQrcode
  module Processor
    extend self
    
    def backend
      return @backend if @backend
      assign_default
      
      @backend
    end
    
    def backend=(backend_name)
      case backend_name
      when Symbol, String
        assign_backend(backend_name)
      when NilClass
        assign_default
      else
        raise "Missing processor backend: #{backend_name}"
      end
    end
    
    def write_temp_file(options)
      backend.write_temp_file(options)
    end
    
    private
    def assign_backend(backend_name)
      require File.join(File.dirname(__FILE__), "/processors/#{backend_name}")
      @backend = HasQrcode::Processor.const_get("#{backend_name.to_s.camelize}")
    end
    
    def assign_default
      assign_backend(:qr_server)
    end
  end
end
