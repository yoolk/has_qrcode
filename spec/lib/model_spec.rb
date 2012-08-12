require 'spec_helper'

describe "Model without configuration" do
  before(:all) do
    @listing = Listing.new
    @listing.id = 100
  end
  
  after(:all) do
    FileUtils.rm_rf("/tmp/public/system/listings/100.png")
    FileUtils.rm_rf("/tmp/100.png")
  end
  
  it "should generate image to default location" do
    qrcode_path = @listing.generate_qrcode(:data => "HelloWorld!")
    
    qrcode_path.should == ["/tmp/public/system/listings/100/100.png"]
    File.exist?(qrcode_path[0]).should eq(true)
  end
  
  it "should generate image to a specified location" do
    qrcode_path = @listing.generate_qrcode(:data => "HelloWorld!", :storage => {:filesystem => { :path => "/tmp/:id.:format" }})
    
    qrcode_path.should == ["/tmp/100.png"]
    File.exist?(qrcode_path[0]).should eq(true)
  end
  
  it "should receive call with value from :data option" do
    qrserver = QrServer.new(:data => "hello")
    QrServer.should_receive(:new).with(hash_including({:data => "hello"})).and_return(qrserver)
    
    @listing.generate_qrcode(:data => "hello")
  end
  
  it "should receive call with value returned from :data option" do
    qrserver = QrServer.new(:data => "hello data")
    QrServer.should_receive(:new).with(hash_including({:data => @listing.vcard_4_0})).and_return(qrserver)
    
    @listing.generate_qrcode(:data => :vcard_4_0)
  end
  
  it "should raise exception when :data is not defined" do
    proc {
      @listing.generate_qrcode(:data => :not_found)
    }.should raise_error RuntimeError, /not_found is undefined/
  end
  
  it "should raise exception when :data is not passed in" do
    proc {
      @listing.generate_qrcode
    }.should raise_error RuntimeError
  end
end

describe "Model with configuration" do
  before(:all) do
    @listing = ListingHasQrcode.new
    @listing.id = 100
  end
  
  after(:all) do
    FileUtils.rm_rf("/tmp/public/system/listings/100.jpeg")
    FileUtils.rm_rf("/tmp/public/system/listings/100.png")
  end
  
  it "should generate image based on pre-configuration" do
    qrcode_path = @listing.generate_qrcode(:data => "HelloWorld!")
    
    qrcode_path.should == ["/tmp/100.png"]
    File.exist?(qrcode_path[0]).should eq(true)
  end
  
  it "should generate image based on the overwrite options" do
    qrcode_path = @listing.generate_qrcode(:data => "HelloWorld!", :format => "jpeg")
    
    qrcode_path.should == ["/tmp/100.jpeg"]
    File.exist?(qrcode_path[0]).should eq(true)
  end
end

describe "Hook after_save" do
  after(:all) do
    FileUtils.rm_rf("/tmp/100.png")
  end
  
  it "should generate image when save" do
    @listing = ListingHasQrcode.new(:name => "Hello Word")
    @listing.id = 100
    @listing.save
    
    File.exist?("/tmp/100.png").should eq(true)
  end
end
