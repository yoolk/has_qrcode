require 'spec_helper'
describe "Model with has_qrcode" do
  before(:all) do
    @listing = ListingDefault.new
    @listing.id = 100
  end
  let(:qrcode_path) { "/tmp/public" + @listing.qrcode_url("png") }
  
  after(:each) do
    FileUtils.rm_rf("/tmp/public/system/listings/*")
    FileUtils.rm_rf("/tmp/100.*")
  end
  
  it "should generate image based on pre-configuration" do
    @listing.generate_qrcode
    
    File.exist?(qrcode_path).should eq(true)
    ZXing.decode(qrcode_path).should eq(@listing.vcard_4_0)
  end
  
  it "should remove archived files before it generates news" do
    @listing.generate_qrcode
    old_qrcode_filename = qrcode_path
    File.exist?(old_qrcode_filename).should eq(true)
    
    @listing.generate_qrcode
    File.exist?(old_qrcode_filename).should eq(false)
    File.exist?("/tmp/public" + @listing.qrcode_url("png")).should eq(true)
  end
  
  it "should generate image based on data" do
    @listing.generate_qrcode(:data => "http://yoolk.com/")
    
    Dir.glob("/tmp/public/system/listings/100/*.png").count.should > 0
    ZXing.decode(qrcode_path).should eq("http://yoolk.com/")
  end
  
  it "should generate image based on the overwrite format" do
    @listing.generate_qrcode(:format => "jpeg")
    
    Dir.glob("/tmp/public/system/listings/100/*.jpeg").count.should > 0
  end
  
  it "should generate image with multiple formats" do
    @listing.generate_qrcode(:format => ["eps", "png", "pdf"])
    
    Dir.glob("/tmp/public/system/listings/100/*").count.should eq(3) 
  end
  
  it "should generate image to a specified location" do
    @listing.generate_qrcode(:storage => { :filesystem => { :path => "/tmp/:id.:format" }})
    
    File.exist?("/tmp/100.png").should eq(true)
  end
  
  it "should generate image based on size" do
    @listing.generate_qrcode(:size => "300x300")
    
    image_path = Dir.glob("/tmp/public/system/listings/100/*.png")[0]
    MiniMagick::Image.open(image_path)[:width].should eq(300)
  end
  
  it "should generate image based on backend" do
    @listing.generate_qrcode(:backend => :qr_server)
    
    HasQrcode::Processor.backend.should eq(HasQrcode::Processor::QrServer)
  end
  
  it "should generate image based on storage", :pending do
  end
  
  it "should generate image with logo" do
    @listing.generate_qrcode(:logo => "http://www.google.com/images/srpr/logo3w.png")
    
    ZXing.decode(qrcode_path).should eq(@listing.vcard_4_0)
  end
end

describe "Hook after_save" do
  before(:each) do
    FileUtils.rm_rf("/tmp/public/system/listings/*")
  end
  
  it "should generate image when save" do
    @listing = ListingDefault.new(:name => "Hello Word")
    @listing.id = 100
    @listing.save
    
    Dir.glob("/tmp/public/system/listings/100/*.png").count.should > 0
  end
end

describe "Model with instance-level config" do
  before(:all) do
    @listing = ListingSetting.new(:name => "Hello Word")
    @listing.id = 100
    @listing.generate_qrcode
  end
  
  it "should process logo per instance" do
    @listing.qrcode_config.logo.should eq(@listing.logo_url)
  end
  
  it "should process data per instance" do
    @listing.qrcode_config.data.should eq(@listing.vcard_4_0)
  end
  
  it "should process storage per instance" do
    @listing.qrcode_config.storage_name.should eq(@listing.qr_storage.keys.first)
    @listing.qrcode_config.storage_options.should eq(@listing.qr_storage.values.first)
  end
end
