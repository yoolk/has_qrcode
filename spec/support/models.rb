class Listing < ActiveRecord::Base
  def vcard_4_0
%Q{BEGIN:VCARD
VERSION:4.0
N:;CamYP Co., Ltd.;;;
FN:CamYP Co., Ltd.
ADR;TYPE="work":;;Ground Floor, Phnom Penh Center, Building B1;Phnom Penh; ;12301;Cambodia
TEL;TYPE="work,voice":023 218 100
TEL;TYPE="work,fax":023 211 511
EMAIL:info@yp.com.kh
NOTE:erere, re
END:VCARD}
  end
end

class ListingHasQrcode < ActiveRecord::Base
  self.table_name = "listings"
  has_qrcode :format => "png", :data_method => :vcard_4_0,
             :path => '/tmp/:id.:format'
             
  def vcard_4_0
%Q{BEGIN:VCARD
VERSION:4.0
N:;CamYP Co., Ltd.;;;
FN:CamYP Co., Ltd.
ADR;TYPE="work":;;Ground Floor, Phnom Penh Center, Building B1;Phnom Penh; ;12301;Cambodia
TEL;TYPE="work,voice":023 218 100
TEL;TYPE="work,fax":023 211 511
EMAIL:info@yp.com.kh
NOTE:erere, re
END:VCARD}
  end
end
