class HasQrcode::Configuration
  
  attr_reader :backend, :storage_name, :storage_options, :qrcode_options
  def initialize(options = {})
    @qrcode_options  = merge_with_defaults(options)
    
    storage          = qrcode_options.delete(:storage)
    @backend         = qrcode_options.delete(:backend)
    @storage_name    = storage.try(:keys).try(:first)
    @storage_options = storage.try(:values).try(:first) || {}
  end
  
  def with(options)
    new_options = options.merge(self.qrcode_options)
    self.class.new(new_options)
  end
  
  def method_missing(*args, &block)
    qrcode_options.send(:[], *args, &block)
  end
  
  private
  def merge_with_defaults(options = {})
    defaults = {
      :size     => "250x250",
      :margin   => 0,
      :ecc      => "L",
      :color    => "000",
      :bgcolor  => "fff",
      :format   => "png",
      :backend  => :qr_server,
      :storage  => { :filesystem => { :path => ":rails_root/public/system/:table_name/:id/:qrcode_filename.:format" } }
    }
    defaults.merge(options)
  end
end
