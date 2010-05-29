# encoding: utf-8   

# image.rb: Image table cells.
#
# May 2010, Kristian Mandrup
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  class Document
    def image_cell(options={})
      cell = Prawn::Table::Cell::Image.new(self, options[:at] || [0, cursor], options)
      cell.draw if !options[:dry_run]
      cell
    end
    
  end
       
  class Table
    class Cell

      # A Cell that contains text. Has some limited options to set font family,
      # size, and style.
      #
      class Image < Cell

        ImageOptions = [:file, :image_info, :dry_run ]

        ImageOptions.each do |option|
          define_method("#{option}=") { |v| @image_options[option] = v }
          define_method(option) { @image_options[option] }
        end


        def initialize(pdf, point, options={})
          @image_options = {}
          super

          file = options.delete(:content)
          
          @image_options[:file] = file # store file pointing to the image resource
                    
          @image_options[:image_info] = pdf.image file.path, options # store image information

          # Sets a reasonable minimum width. If the cell has any content, make
          # sure we have enough width to be at least one character wide. This is
          # a bit of a hack, but it should work well enough.
          min_content_width = natural_content_width
          @min_width = padding_left + padding_right + min_content_width
        end

        # Supports setting multiple image properties at once.
        #
        def style(options={}, &block)
          options.each { |k, v| send("#{k}=", v) }
          block.call(self) if block
        end

        # Returns the natural width of this image, defaulting to the 'real width' of the image
        #
        def natural_content_width
          [@width || image_info.width, @pdf.bounds.width].min
        end

        # Returns the natural height of this image, defaulting to the 'real height' of the image
        #
        def natural_content_height
          [@height || image_info.height, @pdf.bounds.height].min
        end

        # Draws the image
        #
        def draw_content
          @pdf.move_down((@pdf.font.line_gap + @pdf.font.descender)/2) 
          @pdf.image file.path, :at => [0, @pdf.cursor], :width => content_width + FPTolerance, :height => content_height + FPTolerance 
        end

      end
    end
  end
end
