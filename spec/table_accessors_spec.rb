# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  
require 'set'

describe "Prawn::Table" do

  describe "cell accessors" do
    before(:each) do
      @pdf = Prawn::Document.new
      @table = @pdf.table([%w[R0C0 R0C1], %w[R1C0 R1C1]])
    end

    it "should style a cell range using explicit block context" do        
      # style a range (box) of cells        
      @table.cell_select(0..1, 0..1) do |cell|
        cell.style(:height => 100, :background_color => 'ff0000')    
      end
      @table.cells[0,0].height.should == 100
      @table.cells[0,1].height.should == 100
      @table.cells[1,1].background_color.should == 'ff0000'
    end

    it "should select rows by number or range" do
      Set.new(@table.row(0).map { |c| c.content }).should == 
        Set.new(%w[R0C0 R0C1])
      Set.new(@table.rows(0..1).map { |c| c.content }).should == 
        Set.new(%w[R0C0 R0C1 R1C0 R1C1])
    end
    
    it "should select rows by list of numbers" do
      Set.new(@table.rows([0,1]).map { |c| c.content }).should == 
        Set.new(%w[R0C0 R0C1 R1C0 R1C1])
    end
    
    it "should select rows by :even and :odd" do
      Set.new(@table.rows(:even).map { |c| c.content }).should == 
        Set.new(%w[R0C0 R0C1 ])
      Set.new(@table.rows(:odd).map { |c| c.content }).should == 
        Set.new(%w[R1C0 R1C1])
    end
    
    it "should select last row by :last" do
      Set.new(@table.rows(:last).map { |c| c.content }).should == 
        Set.new(%w[R1C0 R1C1 ])
    end
    
    it "should select last column by :last" do
      Set.new(@table.columns(:last).map { |c| c.content }).should == 
        Set.new(%w[R0C1 R1C1 ])
    end
    
    it "should select columns by :even and :odd" do
      Set.new(@table.columns(:even).map { |c| c.content }).should == 
        Set.new(%w[R0C0 R1C0 ])
      Set.new(@table.rows(:odd).map { |c| c.content }).should == 
        Set.new(%w[R1C0 R1C1])
    end
    
    it "should select columns striping hash" do
      @table = @pdf.table([%w[R0C0 R0C1 R0C2 R0C3 R0C4 R0C5 R0C6]])      
      Set.new(@table.columns(:stripes => 3, :thickness => 1, :step => 2, :offset => 0).map { |c| c.content }).should == 
        Set.new(%w[R0C0 R0C2 R0C4])
    
      Set.new(@table.columns(:stripes => 2, :thickness => 2, :step => 3, :offset => 1).map { |c| c.content }).should == 
        Set.new(%w[R0C1 R0C2 R0C4 R0C5])
    end
    
    it "should select rows striping hash" do
      @table = @pdf.table([%w[R0C0], %w[R1C0], %w[R2C0], %w[R3C0], %w[R4C0], %w[R5C0], %w[R6C0]])      
      Set.new(@table.rows(:stripes => 3, :thickness => 1, :step => 2, :offset => 0).map { |c| c.content }).should == 
        Set.new(%w[R0C0 R2C0 R4C0])
    
      Set.new(@table.rows(:stripes => 2, :thickness => 2, :step => 3, :offset => 1).map { |c| c.content }).should == 
        Set.new(%w[R1C0 R2C0 R4C0 R5C0])
    end
    
    
    it "should select columns by number or range" do
      Set.new(@table.column(0).map { |c| c.content }).should == 
        Set.new(%w[R0C0 R1C0])
      Set.new(@table.columns(0..1).map { |c| c.content }).should == 
        Set.new(%w[R0C0 R0C1 R1C0 R1C1])
    end
    
    it "should allow rows and columns to be combined" do
      @table.row(0).column(1).map { |c| c.content }.should == ["R0C1"]
    end
    
    it "should accept a select block, returning a cell proxy" do
      @table.cells.select { |c| c.content =~ /R0/ }.column(1).map{ |c| 
        c.content }.should == ["R0C1"]
    end
    
    it "should accept the [] method, returning a Cell or nil" do
      @table.cells[0, 0].content.should == "R0C0"
      @table.cells[12, 12].should.be.nil
    end
    
    it "should proxy unknown methods to the cells" do
      @table.cells.height = 200
      @table.row(1).height = 100
    
      @table.cells[0, 0].height.should == 200
      @table.cells[1, 0].height.should == 100
    end
    
    it "should accept the style method, proxying its calls to the cells" do
      @table.cells.style(:height => 200, :width => 200)
      @table.column(0).style(:width => 100)
    
      @table.cells[0, 1].width.should == 200
      @table.cells[1, 0].height.should == 200
      @table.cells[1, 0].width.should == 100
    end
    
    it "should return the width of selected columns for #width" do
      c0_width = @table.column(0).map{ |c| c.width }.max
      c1_width = @table.column(1).map{ |c| c.width }.max
    
      @table.column(0).width.should == c0_width
      @table.column(1).width.should == c1_width
    
      @table.columns(0..1).width.should == c0_width + c1_width
      @table.cells.width.should == c0_width + c1_width
    end
    
    it "should return the height of selected rows for #height" do
      r0_height = @table.row(0).map{ |c| c.height }.max
      r1_height = @table.row(1).map{ |c| c.height }.max
    
      @table.row(0).height.should == r0_height
      @table.row(1).height.should == r1_height
    
      @table.rows(0..1).height.should == r0_height + r1_height
      @table.cells.height.should == r0_height + r1_height
    end 
      
    it "should style an individual cell" do    
        # style a particular cell    
        @table.cells[0,0].style(:height => 100)
        @table.cells[0,0].height.should == 100
    end                  

    it "should style a cell range using explicit block context" do        
      # style a range (box) of cells        
      puts "should style a cell range using explicit block context"
      
      @table.rows 0..1 do |rows|
        rows.columns 0..1 do |cell|
          cell.style(:height => 100, :background_color => 'ff0000')    
        end
      end
      @table.cells[0,0].height.should == 100
      @table.cells[0,1].height.should == 100
      @table.cells[1,1].background_color.should == 'ff0000'
    end

    # it "should style a cell range where row is a number" do        
    #   # style a range of cells using explicit block context                       
    #   @table.rows(0).columns(0..1) do |cell|
    #     cell.style(:height => 100, :background_color => 'ff0000')    
    #   end
    #   @table.cells[0,0].height.should == 100
    #   @table.cells[1,0].height.should < 100      
    # end
    # 
    # it "should style a cell range where column is a number" do        
    #   # style a range of cells using explicit block context                       
    #   @table.rows(0..1).columns(1) do |cell|
    #     cell.style(:height => 100, :background_color => 'ff0000')    
    #   end
    #   @table.cells[0,0].height.should < 100
    #   @table.cells[1,1].height.should == 100      
    # end
    # 
    # it "should style a cell range using implicit block context" do        
    #   # style a range of cells using explicit block context                       
    #   @table.rows(0..1).columns(1) do
    #     style(:height => 100, :background_color => 'ff0000')    
    #   end
    #   @table.cells[0,0].height.should < 100
    #   @table.cells[1,1].height.should == 100      
    # end    

    # it "should style a cell range where ranges are expressed as array of numbers" do        
    #   # style a range of cells using explicit block context                       
    #   @table = @pdf.table([%w[R0C0 R0C1 R0C2], %w[R1C0 R1C1 R1C2]])
    # 
    #   @table.rows([0, 1]).columns([0, 1]) do
    #     style(:height => 100, :background_color => 'ff0000')    
    #   end
    #   @table.cells[0,0].height.should == 100
    #   @table.cells[1,1].height.should == 100      
    #   @table.cells[1,2].height.should < 100      
    # end    
  end
end