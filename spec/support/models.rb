class Listing < ActiveRecord::Base
  def vcard_4_0
    VCARD_DATA
  end
end

class ListingHasQrcode < ActiveRecord::Base
  self.table_name = "listings"
  has_qrcode :format => "png", :data => :vcard_4_0,
             :storage => 
               { :filesystem => { :path => '/tmp/:id.:format' } }
             
  def vcard_4_0
    VCARD_DATA
  end
end
