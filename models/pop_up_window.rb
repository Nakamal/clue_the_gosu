require 'gosu'

class PopUpWindow
  attr_accessor :x, :y, :z, :window, :height, :width
  def initialize(options_hash)
    @x = options_hash[:x] || 190
    @y = options_hash[:y] || 110
    @window = options_hash[:window]
    @z = options_hash[:z] || 10
    @height = options_hash[:height] || 1200
    @width = options_hash[:width] || 1100
  end

  def center_x
    x + (width / 2)
  end

  def draw
    border = 0
    x_1 = x + border
    y_1 = y + border
    x_2 = x_1 + width - (border * 2)
    y_2 = y_1
    x_3 = x_2
    y_3 = y_2 + height - (border * 2)
    x_4 = x_1
    y_4 = y_3
    tint = Gosu::Color.argb(0xFE_13133a)
    window.draw_quad(x_1, y_1, tint, x_2, y_2, tint, x_3, y_3, tint, x_4, y_4, tint, z, mode = :default)
  end
end