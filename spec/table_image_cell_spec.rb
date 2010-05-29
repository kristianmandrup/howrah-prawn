# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  
require 'set'

describe "Prawn::Table" do

  describe "image cell" do
    before(:each) do
      @pdf = Prawn::Document.new
      @img_file_name = "#{Prawn::BASEDIR}/data/images/stef.jpg"
      @img_file = File.new(@img_file_name)      
    end

    it "should generate an image cell based on a File" do
      t = @pdf.table([[@img_file]])
      t.cells[0,0].should.be.a.kind_of(Prawn::Table::Cell::Image)
    end 

    it "should generate an image cell based on a File" do
      stef = "#{Prawn::BASEDIR}/data/images/stef.jpg"
      img_file = File.new(stef)
    
      cell = @pdf.image_cell(:content => img_file, :dry_run => true)
      cell.should.be.a.kind_of(Prawn::Table::Cell::Image)
    end 
    
  end
end