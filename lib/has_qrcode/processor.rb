module HasQrcode
  module Processor
    extend self
    # write to template
    
    def backend
      return @backend if @backend
      self.backend = :qr_server
      @backend
    end
    
    def backend=(backend_name)
      case backend_name
      when Symbol, String
        require File.join(File.dirname(__FILE__), "/processors/#{backend_name}")
        @backend = HasQrcode::Processor.const_get("#{backend_name.to_s.camelize}")
      else
        raise "Missing processor backend: #{backend_name}"
      end
    end
    
    def write_temp_file(options)
      backend.write_temp_file(options)
    end
  end
end
