# encoding: utf-8
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"
                
Prawn::Document.generate("img_table.pdf") do 

  stef = "#{Prawn::BASEDIR}/data/images/stef.jpg"
  img_file = File.new(stef)

  image_cells = []
  3.times do
    image_cells << image_cell(:content => img_file, :dry_run => true)
  end

  move_down 12

  table([%w[foo bar bazbaz], image_cells], :cell_style => { :padding => 12 }, :width => bounds.width, :row_colors => ["ff0000", "00ff00"])  

end
