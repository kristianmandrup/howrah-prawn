require 'prawn/text/fragment_underlay'

module Prawn
  module Text
    module Underlay
      include Prawn::Text::FragmentUnderlay   

      class Drawer
        include Prawn::Text::FragmentUnderlay   
           
        attr_accessor :pdf, :box, :options
        
        def initialize(pdf, box, options) 
          @pdf = pdf
          @box = box
          @options = options
        end

        def draw    
          # collect fragment meta info used for drawing underlays
          box.render(:dry_run => true)
                        
          draw_box_underlay
          # draw fragment underlays
          draw_fragment_underlays
        end
      
      protected
        def draw_box_underlay
          pdf.with_dash_style box.border_style do
            if box_underlay?
              draw_box_underlay_fill
            else
              draw_box_underlay_border
            end
          end
        end

        def box_width
          @box_width ||= [box.width, pdf.bounds.width].min  
        end

        def box_height
          @box_height ||= box.border_width > 0 ? box.box_height + box.border_width : box.box_height
        end

        def box_underlay?
          @box_underlay ||= box.fill_color && !box.fill_color.empty?
        end

        def at_position
          # at ||= options[:at] || [0, pdf.cursor + y]         
          @at ||= options[:at] || [0, pdf.y]         
        end          

        def draw_border?
          box.border_width && box.border_width > 0 && !([:none, :hidden].include?(box.border_style))
        end

        def draw_box_underlay_fill
          pdf.with :fill_color, box.fill_color do
            at = at_position
            if draw_border?
              pdf.fill_and_stroke_rectangle(at, box_width, box.box_height)              
            else
              pdf.fill_rectangle(at, box_width, box.box_height)            
            end            
          end
        end

        def draw_box_underlay_border          
          at = at_position
          if draw_border?
            pdf.stroke_rectangle(at, box_width, box.box_height)
          end
        end
      end
    end
  end
end