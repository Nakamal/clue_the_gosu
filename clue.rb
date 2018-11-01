require 'gosu'
require_relative 'game'
require_relative 'models/board'
require_relative 'models/space'
require_relative 'models/room'

class Clue < Gosu::Window 
  WIDTH = 2400
  HEIGHT = 1400
  attr_accessor :height, :width, :fullscreen
  
  def initialize
    super(WIDTH, HEIGHT, false)
    @board = Board.new(window: self)
    @start_scene = :start 
    self.caption = 'Clue' 
    @background = Gosu::Image.new(self, 'final_board.png')
    @large_font = Gosu::Font.new(self, "Futura", HEIGHT / 20)
  end

  def update 
    
  end

  def needs_cursor?
    true
  end

  def fullscreen? #
    @fullscreen = [true, false]
  end

  def draw
    @background.draw(100,80,0)
    # @large_font.draw_text("Detective Sheet", 50, 170, 1)
    # draw_text(170, 650, "Player Info", @large_font, '#008800')
    @board.draw
  end

end

window = Clue.new
window.show