require 'gosu'
require_relative 'game'

class Clue < Gosu::Window

  attr_accessor :height, :width, :fullscreen

  def initialize
    super 2650, 1800, :fullscreen => true
    self.caption = 'Clue'
    @image = Gosu::Image.new("board_picture.png")
    # @game = Game.new(self)
  end

  def needs_cursor?
    true
  end

  def fullscreen?
    @return = [true, false]
    
  end

  def draw
    @background_image.draw(0, 0, 1)
  end
end

window = Clue.new
window.show