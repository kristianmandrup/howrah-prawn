module ArrayExt
  def extract(sym)
    map { |e| e.send(sym) }.extend(ArrayExt)
  end

  def sum
    inject( 0 ) { |sum,x| sum+x }.extend(ArrayExt)
  end  

  # for bounding box calculations
  def width
    return self[2] - self[0] if size == 4
    raise "Can only 'at' a box with 4 co-ordinates"      
  end

  def height
    return self[3] - self[1] if size == 4
    raise "Can only 'at' a box with 4 co-ordinates"      
  end
  
  def at
    return [self[0], self[1]] if size == 4
    raise "Can only 'at' a box with 4 co-ordinates"  
  end
end
