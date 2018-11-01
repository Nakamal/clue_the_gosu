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
    @draw_start = :start 
    self.caption = 'Clue' 
    @background = Gosu::Image.new(self, 'media/final_board.png')
    @font = Gosu::Font.new(self, "Futura", HEIGHT / 20)
    # @input = Gosu::Font.new
    self.text_input = Gosu::TextInput.new
  end

  def update 
    
  end

  def draw_start  #
    
    @message = "Holy Gosu Wadsworth...Clue!"
  end  #

  def draw_waiting  #
    
  end  #

  def draw_game  #
    
  end  #

  def draw_win(fate)  #
  
  end  #

  def draw_lose(fate)  #
    
  end  #

  def button_down_start(id)  #
    if id == Gosu::KbReturn  #
      initialize_game  #
    end  #
  end  #

  def needs_cursor?
    true
  end

  def fullscreen? 
    @fullscreen = [true, false]
  end

  def draw  #
    case @scene  #
    when :start  #
      draw_start  #
    when :waiting  #
      draw_waiting  #
    when :game  #
      draw_game  #
    when :win  #
      draw_win  #
    when :lose  #
      draw_lose  #
    end  #
    @background.draw(100,80,0)
    @board.draw
    @font.draw("Detective Sheet", 1800, 25, 1)
  end
end

window = Clue.new
window.show