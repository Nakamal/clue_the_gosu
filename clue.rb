require 'gosu'
require 'http'
require_relative 'game'
require_relative 'models/board'
require_relative 'models/space'
require_relative 'models/room'

class Clue < Gosu::Window 
  WIDTH = 2400
  HEIGHT = 1400
  attr_accessor :height, :width, :fullscreen, :id
  
  def initialize
    super(WIDTH, HEIGHT, false)
    @board = Board.new(window: self)
    @scene = :start 
    self.caption = 'Clue' 
    @background = Gosu::Image.new(self, 'media/final_board.png')
  
    @font = Gosu::Font.new(self, "Nimbus Mono L", HEIGHT / 30)
    @font_2 = Gosu::Font.new(self, "Nimbus Mono L", HEIGHT / 5)
    self.text_input = Gosu::TextInput.new
    self.text_input.text = ""
    @last_time = 0
    
    @game_id = 112 #change this in start scene to current game
    @participation_id = 175

    @message = ""
  end

  def draw
    case @scene
    when :start
      draw_start
    when :waiting
      draw_waiting
    when :game
      draw_game
    when :win
      draw_win
    when :lose
      draw_lose
    end 
  end

  def draw_start
    @font_2.draw_text("Clue", 900, 100, 1)
    @font.draw_text("Welcome to Hill House", 950, 400, 1)
    @font.draw_text("Press Enter to begin", 970, 1300, 1)
    @font.draw_text(@message, 1800, 250, 1)
  end 

  def draw_waiting 
    @font.draw_text("waiting", 1800, 200, 1)
    @font.draw_text(self.text_input.text, 1800, 100, 1)
    @font.draw_text(@message, 1800, 250, 1)
  end 

  def draw_game 
    @background.draw(100,80,0)
    @board.draw
    @font.draw_text("Detective Sheet", 1800, 25, 1)
  end 

  def draw_win(fate)
  
  end 

  def draw_lose(fate)
    
  end

  def update 
    case @scene
    when :waiting
      update_waiting
    end
  end

  def update_waiting
    if (Gosu::milliseconds - @last_time) / 10000 == 1
      response = HTTP.get("http://localhost:3000/api/participations/#{@participation_id}/turn_check")
      if response.parse["my_turn"]
        @scene = :game
      end
      @last_time = Gosu::milliseconds()
    end
  end

  def button_down(id)
    case @scene
    when :start
      button_down_start(id)
    when :waiting
      button_down_waiting(id)
    end
  end

  def button_down_start(id) 
    if id == 40
      response = HTTP.get("http://localhost:3000/api/characters")
      @message = response.parse.first["name"]
      @scene = :waiting
    end
  end  


  def button_down_waiting(id)  
    if id == 40
     @scene = :game
    end  
  end  

  def needs_cursor?
    true
  end

  def fullscreen? 
    @fullscreen = [true, false]
  end
end

window = Clue.new
window.show

