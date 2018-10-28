require 'gosu'
require_relative 'game'
require_relative 'models/board'
require_relative 'models/space'
require_relative 'models/room'

class Clue < Gosu::Window 
  WIDTH = 2200
  HEIGHT = 1200
  attr_accessor :height, :width, :fullscreen
  
  def initialize
    super(WIDTH, HEIGHT)
    @spaces = []  #
    @start_scene = :start #
    self.caption = 'Clue' #
    # @image = Gosu::Image.new("board_picture.png")
    # @game = Game.new(self)
  end

  def update #
    case @start_scene #
    when @game #
      update_game # 
    end
  end

  def needs_cursor?
    true
  end

  def fullscreen?
    @return = [true, false]
  end

  def draw
    @spaces.each do |space|
      space.draw
    end
  end
end

window = Clue.new
window.show