module Prawn
  class Document
    module Helpers 
      def indent_and_pad(number, &block)
        move_down(number)
        indent(number, &block)
        move_down(number)
      end
                 
      def with(configs = {}, &block)
        olds = {}
        configs.each_pair do |k, v| 
          if v
            olds[k] = send k
            send k, v
          end
        end
        yield       
        configs.each_pair do |k, v| 
          if olds[k]
            send k, olds[k] if olds[k]
          end
        end
      end

      def with_dash_style(style, &block)
        dash_width = case style
        when :solid
          0          
        when :dotted          
          1
        when :dashed
          2
        end
        dash dash_width
        yield
        undash
      end

      def with_join_style(value = nil, &block)
        with(:join_style => value, &block)
      end

      def with_line_width(value = nil, &block)
        with(:line_width => value, &block)
      end

      def with_stroke_color(value = nil, &block)
        with(:stroke_color => value, &block)
      end

      def with_fill_color(value = nil, &block)        
        with(:fill_color => value, &block)
      end
    end
  end
end