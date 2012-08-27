class ListingDefault < ActiveRecord::Base
  self.table_name = "listings"
  has_qrcode :data => :vcard_4_0
             
  def vcard_4_0
    VCARD_DATA
  end
end

class ListingSetting < ActiveRecord::Base
  self.table_name = "listings"
  has_qrcode :data => :vcard_4_0,
             :logo => :logo_url,
             :size => "300x300",
             :format  => ["png", "pdf", "eps"],
             :margin  => "10",
             :bgcolor => "ff0",
             :color   => "aaa",
             :backend => :qr_server,
             :storage => Proc.new { |listing| listing.qr_storage }
             
  def vcard_4_0
    VCARD_DATA
  end
  
  def logo_url
    "http://www.google.com/images/srpr/logo3w.png"
  end
  
  def qr_storage
    { :filesystem => { :path => "/tmp/:table_name/:id.:format" }}
  end
end

class Listing < ActiveRecord::Base
end