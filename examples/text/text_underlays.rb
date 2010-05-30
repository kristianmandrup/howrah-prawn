require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("text_underlays.pdf") do
  world = { :text => "world", :size => 24, :styles => [:bold, :italic], :fill_color => 'aaaaaa', :border_width => 1, :underlays => true } 

  options = { 
              :fill_color => 'ff0000', :underlays => true, :border_style => :solid, :border_width => 2, 
              :margin => {:left => 20, :top => 30, :bottom => 10}              
            }

  formatted_text_box [{ :text => "goodbye", :fill_color => '0000aa', :border_width => 2, :underlays => true, :border_style => :none }, world], options
   
  text_box ["Hello", "World"], options
end