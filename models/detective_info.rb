require 'gosu'

class DetectiveInfo
  attr_accessor :status, :name, :window, :x, :y, :width, :height, :header_message
  def initialize(info, options_hash)

    @status = info["printed_status"]
    @name = info["card"] && info["card"]["subject"]["name"]
    @window = options_hash[:window]
    @x = options_hash[:x]
    @y = options_hash[:y]
    @width = options_hash[:width]
    @height = options_hash[:height]
    @font = options_hash[:font]
    @header_message = options_hash[:header_message]
  end

  def draw
    z = 50
    border = 2
    x_1 = x
    y_1 = y + border
    x_2 = x_1 + width
    y_2 = y_1
    x_3 = x_2
    y_3 = y_2 + height - (border * 2)
    x_4 = x_1
    y_4 = y_3

    if status == "?"
      c = Gosu::Color.argb(0xaa_333300)
    elsif status == "X"
      c = Gosu::Color.argb(0xaa_880000)
    else
      c = Gosu::Color.argb(0xaa_883300)
    end
    window.draw_quad(x_1, y_1, c, x_2, y_2, c, x_3, y_3, c, x_4, y_4, c, z, mode = :default)

    if header_message
      @font.draw_text(@header_message, x + 30, y + 13, z + 1)
    else
      @font.draw_text(status, x + 30, y + 13, z + 1)
      @font.draw_text(name, x + 70, y + 13, z + 1)
      window.draw_line(x + 50, y, Gosu::Color.argb(0xff_000000), x + 50, y + height, Gosu::Color.argb(0xff_000000), z + 1, mode = :default)
    end
  end
end