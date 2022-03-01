# Source: https://crystal-lang.org/reference/master/syntax_and_semantics/enum.html
enum Color
  Red
  Green
  Blue

  def red?
    self == Color::Red
  end
end

def paint(color : Color)
  case color
  when .red?
    # ...
  else
    # Unusual, but still can happen.
    raise "Unknown color: #{color}"
  end
end

paint :red
