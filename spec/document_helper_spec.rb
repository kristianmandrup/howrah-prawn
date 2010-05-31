# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  
require 'set'

describe "Prawn::Table" do

  describe "#document helpers" do
    before(:each) { create_pdf }

    describe "#indent_and_pad" do
      it "should temporarily shift the x coordinate and width (indent) and also increase the box height 2 times pad amount" do
        box = @pdf.bounding_box([100,100], :width => 200) do
          old_cursor = @pdf.cursor
          @pdf.indent_and_pad(20) do
            @pdf.bounds.absolute_left.should == 120
            @pdf.bounds.width.should == 180
          end        
        end
        box.height.should == 40                     
      end                   
    end

    describe "#with" do          
      it "should do nothing if no arguments" do      
        @pdf.with do
        end                
      end

      it "should temporarily set an attribute of the document" do      
        @pdf.with :stroke_color => 'ff0000' do
          @pdf.stroke_color.should == 'ff0000'
        end                
      end
      
      it "should temporarily set certain attributes of the document" do      
        @pdf.with :stroke_color => 'ff0000', :font_size => 10 do
          @pdf.stroke_color.should == 'ff0000'
          @pdf.font_size.should == 10
        end                
      end      
    end  

    describe "#with_dash_style" do              
      it "should temporarily dash_width according to style identifier" do      
        [:solid, :dotted, :dashed].each_with_index do |style, index|
          @pdf.with_dash_style style do          
            @pdf.dashed?.should == true
          end                
          @pdf.undash
          @pdf.dashed?.should == false          
        end        
      end
    end    
    
    describe "#with_join_style" do              
      it "should temporarily set join_style" do      
        prev_join_style = @pdf.join_style
        @pdf.with_join_style :round do
          @pdf.join_style.should == :round          
        end
        @pdf.join_style.should == prev_join_style      
      end
    end    

    describe "#with_line_width" do              
      it "should temporarily set line_width" do      
        prev_width = @pdf.line_width
        @pdf.with_line_width 2 do
          @pdf.line_width.should == 2          
        end
        @pdf.line_width.should == prev_width
      end      
    end    

    describe "#with_stroke_color" do              
      it "should temporarily set stroke_color" do      
        prev_color = @pdf.stroke_color
        @pdf.with_stroke_color 'ff0000' do
          @pdf.stroke_color.should == 'ff0000'          
        end
        @pdf.stroke_color.should == prev_color
      end
    end    

    describe "#with_fill_color" do              
      it "should temporarily set fill_color" do      
        prev_color = @pdf.fill_color
        @pdf.with_fill_color 'ff0000' do
          @pdf.fill_color.should == 'ff0000'          
        end
        @pdf.fill_color.should == prev_color
      end
    end    
  end   
end



