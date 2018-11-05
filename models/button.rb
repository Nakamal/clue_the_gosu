 require 'gosu'

 BUTTON_PADDING = 30

 class Button
  attr_accessor :window, :x, :y, :height, :width, :color, :text, :id
  def initialize(options_hash)
    @window = options_hash[:window]
    @x = options_hash[:x]
    @y = options_hash[:y]
    @color = options_hash[:color]
    @text = options_hash[:text]
    @id = options_hash[:id]
    @text_height = 40
    @font = Gosu::Font.new(window, "Nimbus Mono L", @text_height)
    @height = @text_height + BUTTON_PADDING * 2
    @width = @font.text_width(text) + BUTTON_PADDING * 2
  end

  def starting_x
    x - (width / 2)
  end

  def starting_y
    y - (height / 2)
  end

  def font_x
    x - (@font.text_width(text) / 2)
  end

  def font_y
    y - (@text_height / 2)
  end

  def draw
    border = 2
    x_1 = starting_x
    y_1 = starting_y
    x_2 = x_1 + width
    y_2 = y_1
    x_3 = x_2
    y_3 = y_2 + height
    x_4 = x_1
    y_4 = y_3
    c = Gosu::Color.argb(0xAA_650F0B)
    window.draw_quad(x_1, y_1, c, x_2, y_2, c, x_3, y_3, c, x_4, y_4, c, z = 0, mode = :default)

    @font.draw_text(text, font_x, font_y, 3)
  end


 end