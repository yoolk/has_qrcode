require 'spec_helper'
require 'has_qrcode/qr_server'

describe "QrCode Url Generator" do
  context "Without raising exception" do
    it "should generate url for plain text" do
      qr_server = QrServer.new(:data => "HelloWorld", :margin => 10, :size => "20x20")
      
      qr_server.to_s.should == "#{QrServer::BASE_URI}data=HelloWorld&margin=10&size=20x20"
    end
    
    it "should encode data for url" do
      qr_server = QrServer.new(:data => "HelloWorld?", :margin => 10, :size => "20x20")
      
      qr_server.to_s.should == "#{QrServer::BASE_URI}data=HelloWorld%3F&margin=10&size=20x20"
    end
  end

  context "With raising exception" do
    context "data parameter" do
      it "without value" do
        qr_server = QrServer.new(:data => "")
        
        proc {
          qr_server.to_s
        }.should raise_error RuntimeError
      end
    end
    
    context "size parameter" do
      it "value < 10" do
        qr_server = QrServer.new(:data => "HelloWorld", :size => "5x5")
        
        proc {
          qr_server.to_s
        }.should raise_error RuntimeError
      end
      
      it "value > 1000" do
        qr_server = QrServer.new(:data => "HelloWorld", :size => "1020x1020")
        
        proc {
          qr_server.to_s
        }.should raise_error RuntimeError
      end
      
      it "wrong format value '100x200'" do
        qr_server = QrServer.new(:data => "HelloWorld", :size => "100x200")
        
        proc {
          qr_server.to_s
        }.should raise_error RuntimeError
      end
      
      it "wrong format value 'wrongformat900x900'" do
        qr_server = QrServer.new(:data => "HelloWorld", :size => "wrongformat900x900")
        
        proc {
          qr_server.to_s
        }.should raise_error RuntimeError
      end
    end
    
    context "margin parameter" do
      it "value < 0" do
        qr_server = QrServer.new(:data => "HelloWorld?", :margin => -2, :size => "20x20")
      
      proc {
        qr_server.to_s
      }.should raise_error RuntimeError
      end
      
      it "value > 50" do
        qr_server = QrServer.new(:data => "HelloWorld?", :margin => 51, :size => "20x20")
      
      proc {
        qr_server.to_s
      }.should raise_error RuntimeError
      end
    end
    
    context "ecc parameter" do
      it "wrong format 'HG'" do
        qr_server = QrServer.new(:data => "HelloWorld?", :margin => 0, :size => "20x20", :ecc => 'HG')
      
      proc {
        qr_server.to_s
      }.should raise_error RuntimeError
      end
    end
  end
end
