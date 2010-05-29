# encoding: utf-8

# accessors.rb: Methods for accessing rows, columns, and cells of a
# Prawn::Table.
#
# Copyright December 2009, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
module Prawn
  
  class Table

    # Returns a CellProxy that can be used to select and style cells. See the
    # CellProxy documentation for things you can do with cells.
    #
    def cells
      @cell_proxy ||= CellProxy.new(@cells)
    end

    # Selects the given rows (0-based) for styling. Returns a CellProxy -- see
    # the documentation on CellProxy for things you can do with cells.
    #
    def rows(row_spec, &block)
      cells.rows(row_spec, &block)
    end
    alias_method :row, :rows

    # Selects the given columns (0-based) for styling. Returns a CellProxy --
    # see the documentation on CellProxy for things you can do with cells.
    #
    def columns(col_spec, &block)
      cells.columns(col_spec, &block)
    end
    alias_method :column, :columns

    def cell_select(row_spec, col_spec, &block)
      cells.cell_select(row_spec, col_spec, &block)
    end


    # Represents a selection of cells to be styled. Operations on a CellProxy
    # can be chained, and cell properties can be set one-for-all on the proxy.
    #
    # To set vertical borders only:
    #
    #   table.cells.borders = [:left, :right]
    #
    # To highlight a rectangular area of the table:
    #
    #   table.rows(1..3).columns(2..4).background_color = 'ff0000'
    #
    class CellProxy
      def initialize(cells) #:nodoc:
        @cells = cells
      end

      # Iterates over cells in turn.
      #
      def each(&b)
        @cells.each(&b)
      end

      include Enumerable

      # Limits selection to the given row or rows. +row_spec+ can be anything
      # that responds to the === operator selecting a set of 0-based row
      # numbers; most commonly a number or a range.
      #
      #   table.row(0)     # selects first row
      #   table.rows(3..4) # selects rows four and five
      #   table.rows([2, 4]) # selects rows two and four
      #   table.rows(:even) # selects all even numbered rows
      #   table.rows(:odd) # selects all even numbered rows
      #   table.rows(:last) # selects last row
                                                                               
      #   # selects at most 3 stripes, with a thickness of 2, starting from row 0 and each stripe starting stepping by 2 (2, 4, ...)
      #   table.rows(:stripes => 3, :thickness => 1, :step => 2, :offset => 0) 
      #
      #   # selects rows four and five and makes accesible as rows var in block
      #   table.rows(3..4) do |rows| 
      #
      #   # selects rows four and five and makes accesible as self in block
      #   table.rows(3..4) do             
      #   
      def rows(row_spec, &block)
        c = case row_spec
        when Fixnum, Range
          CellProxy.new(@cells.select { |c| row_spec === c.row })
        when Array
          CellProxy.new(@cells.select { |c| row_spec.include? c.row })          
        when Hash
          list = select_thick_range(row_spec)
          CellProxy.new(@cells.select { |c| list.include? c.row })                    
        when Symbol
          case row_spec
          when :even
            CellProxy.new(@cells.select { |c| c.row % 2 == 0 })            
          when :odd
            CellProxy.new(@cells.select { |c| c.row % 2 == 1 })            
          when :last    
            CellProxy.new(@cells.select { |c| c.row == row_count })
          else
            raise "Unknown Table row selector symbol #{row_spec.inspect}. Must be :even or :odd"
          end
        else
          raise "Unknown Table row selector #{row_spec.inspect}"
        end 

        if block  
          block.arity < 1 ? c.instance_eval(&block) : block.call(c)
        else
          c
        end        
        
      end
      alias_method :row, :rows        

      # Limits selection to the given column or columns. +col_spec+ can be
      # anything that responds to the === operator selecting a set of 0-based
      # column numbers; most commonly a number or a range.
      #
      #   table.column(0)     # selects first column
      #   table.columns(3..4) # selects columns four and five
      #   table.rows([2, 4]) # selects columns two and four
      #   table.rows(:even) # selects all even numbered columns
      #   table.rows(:odd) # selects all even numbered columns
      #   table.rows(:last) # selects last row
                                                                               
      #   # selects at most 3 columns stripes, with a thickness of 2. Stripe at offsets 1, 3, ... (offset + step)
      #   table.rows(:stripes => 3, :thickness => 1, :step => 2, :offset => 1) 
      #
      #   # selects rows four and five and makes accesible as rows var in block
      #   table.rows(3..4) do |rows| 
      #
      #   # selects rows four and five and makes accesible as self in block
      #   table.rows(3..4) do             
      #   


      def columns(col_spec, &block)
        c = case col_spec
        when Fixnum, Range
          CellProxy.new(@cells.select { |c| col_spec === c.column })
        when Array
          CellProxy.new(@cells.select { |c| col_spec.include? c.column })
        when Hash
          list = select_thick_range(col_spec)
          CellProxy.new(@cells.select { |c| list.include? c.column })                    
        when Symbol
          case col_spec
          when :even
            CellProxy.new(@cells.select { |c| c.column % 2 == 0 })            
          when :odd
            CellProxy.new(@cells.select { |c| c.column % 2 == 1 })            
          when :last    
            CellProxy.new(@cells.select { |c| c.column == column_count })
          else
            raise "Unknown Table column selector symbol #{col_spec.inspect}. Must be :even or :odd"            
          end
        else
          raise "Unknown Table column selector #{col_spec.inspect}"
        end 
        
        if block
          block.arity < 1 ? c.instance_eval(&block) : block[c]
        else
          c
        end        
        
      end
        
      alias_method :column, :columns

      def row_count
        @rowcount ||= @cells.sort_by{|cell| cell.row}.last.row
      end

      def column_count
        @column_count ||=  @cells.sort_by{|cell| cell.column}.last.column        
      end

      # Select a rectangular space of cells
      #
      # Example:
      # cell_select(0, 0..2) do |cells|
      #  ...
      # end 
      
      # Equivalent to
      # rows(0).columns(0..2) do |cells|
      #  ...
      # end 
      
      #
      def cell_select(row_spec, col_spec, &block)
        rows(row_spec).columns(col_spec) do |cells|       
          if block
            block.arity < 1 ? cells.instance_eval(&block) : block.call(cells)
          end
        end
      end

      # Selects cells based on a block.
      #
      #   table.column(4).select { |cell| cell.content =~ /Yes/ }.
      #     background_color = 'ff0000'
      #
      def select(&b)
        CellProxy.new(@cells.select(&b))
      end

      # Retrieves a cell based on its 0-based row and column. Returns a Cell,
      # not a CellProxy.
      # 
      #   table.cells[0, 0].content # => "First cell content"
      #
      def [](row, col)
        @cells.find { |c| c.row == row && c.column == col }
      end

      # Supports setting multiple properties at once.
      #
      #   table.cells.style(:padding => 0, :border_width => 2)
      #
      # is the same as:
      #
      #   table.cells.padding = 0
      #   table.cells.border_width = 2
      #
      # You can also pass a block, which will be called for each cell in turn.
      # This allows you to set more complicated properties:
      #
      #   table.cells.style { |cell| cell.border_width += 12 }
      #
      def style(options={}, &block)
        @cells.each do |cell| 
          options.each { |k, v| cell.send("#{k}=", v) }
          block.call(cell) if block
        end
      end

      # Returns the total width of all columns in the selected set.
      #
      def width
        column_widths = {}
        @cells.each do |cell| 
          column_widths[cell.column] = 
            [column_widths[cell.column], cell.width].compact.max
        end
        column_widths.values.inject(0) { |sum, width| sum + width }
      end

      # Returns minimum width required to contain cells in the set.
      #
      def min_width
        column_min_widths = {}
        @cells.each do |cell| 
          column_min_widths[cell.column] = 
            [column_min_widths[cell.column], cell.min_width].compact.max
        end
        column_min_widths.values.inject(0) { |sum, width| sum + width }
      end

      # Returns maximum width that can contain cells in the set.
      #
      def max_width
        column_max_widths = {}
        @cells.each do |cell| 
          column_max_widths[cell.column] = 
            [column_max_widths[cell.column], cell.max_width].compact.min
        end
        column_max_widths.values.inject(0) { |sum, width| sum + width }
      end

      # Returns the total height of all rows in the selected set.
      #
      def height
        row_heights = {}
        @cells.each do |cell| 
          row_heights[cell.row] = 
            [row_heights[cell.row], cell.height].compact.max
        end
        row_heights.values.inject(0) { |sum, width| sum + width }
      end

      # Supports setting arbitrary properties on a group of cells.
      #
      #   table.cells.row(3..6).background_color = 'cc0000'
      #
      def method_missing(id, *args, &block)
        @cells.each { |c| c.send(id, *args, &block) }
      end
      
      private

        def select_thick_range(options)
          result = []
          stripes = options[:stripes] || 200
          thickness = options[:thickness] || 1
          step = options[:step] || thickness * 2
          offset = options[:offset] || 0
          stripes.times do |x|
            thickness.times do |t|
              result << offset + x * step + t
            end
          end         
          result
        end

        # TODO: move to ruby extension, perhaps as extension to Fixnum, Range and Array?
        # Converts argument to something enumerable 
        def to_enum(obj)
          case obj                         
          when Fixnum
            return (obj..obj)
          when Range, Array
            return obj
          else
            raise ArgumentError, "Not a valid numeric range: #{obj.inspect}"
          end
        end

            
    end



  end

end


