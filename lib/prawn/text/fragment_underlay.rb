module Prawn
  module Text
    class PositionBox
      attr_accessor :at, :width, :height
      
      def initialize(fragment)
        set_fragment(fragment)
      end
      
      def set_fragment(fragment)
        @at = fragment.bounding_box.at 
        at[1] += fragment.height
        @width = fragment.bounding_box.width
        @height = fragment.bounding_box.height
      end
    end    
    
    module FragmentUnderlay  

      attr_accessor :fragment, :position_box

      def draw_fragment_underlay_box 
        pdf.with :join_style => :miter, :line_width => fragment.border_width, :stroke_color => fragment.border_color do          
          pdf.with_dash_style fragment.border_style do          
            if fragment_underlay?
              fill_area
            else
              border_rectangle if draw_fragment_border?
            end  
          end
        end
      end

      def fragment_underlay?
        @fragment_underlay ||= fragment.fill_color && !fragment.fill_color.empty?
      end


      def draw_fragment_border?
        @draw_fragment_border ||= fragment.border_width && fragment.border_width > 0 && !([:none, :hidden].include?(fragment.border_style))
      end

      def fill_area
        pdf.with_fill_color fragment.fill_color do 
          if draw_fragment_border?
            pdf.fill_and_stroke_rectangle(position_box.at, position_box.width, position_box.height)
          else
            pdf.fill_rectangle(position_box.at, position_box.width, position_box.height)
          end                                
        end
      end

      def border_rectangle        
        pdf.stroke_rectangle(position_box.at, position_box.width, position_box.height)
      end
      
      def with_fragment(fragment, &block)
        @fragment = fragment
        @position_box = PositionBox.new fragment
        yield
      end

      def draw_fragment_underlays
        # background/underlay for each fragment
        box.fragments.each do |fragment|   
          with_fragment(fragment) do          
            draw_fragment_underlay_box
          end
        end    
      end
    end
  end
end