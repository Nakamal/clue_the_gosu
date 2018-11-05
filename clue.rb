require 'gosu'
require 'http'
require_relative 'game'
require_relative 'models/board'
require_relative 'models/space'
require_relative 'models/room'
require_relative 'models/button'

BASE_ROOT_URL = "http://localhost:3000"

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
    @characters = []
    @message = ""
    initialize_start
    @game_organizer = false
  end
    
  def initialize_start   
    @new_game_button = Button.new(window: self, x: 1200, y: 847, text: "New Game")
  end

  def initialize_character_selecting
    parsed_response = HTTP.get("#{BASE_ROOT_URL}/api/games/#{@current_game_id}").parse
    @available_characters = []
    character_starting_line = 355
    parsed_response["available_characters"].each_with_index do |character, index|
      @available_characters << Button.new(window: self, x: 1200, y: character_starting_line + (130 * index), text: character["name"], id: character["id"])
    end
  end

  def initialize_waiting
    @start_game_button = Button.new(window: self, x: 1200, y: 847, text: "Start Game")
  end

  def update 
    case @scene
    when :start
      update_start
    when :character_selecting
      update_character_selecting
    when :waiting
      update_waiting
    when :game
      update_game
    end
  end

  def draw
    case @scene
    when :start
      draw_start
    when :character_selecting
      draw_character_selecting
    when :waiting
      draw_waiting
    when :game
      draw_game
    when :win
      draw_win
    when :lose
      draw_lose
    end 

    @font.draw_text("X: #{mouse_x.round(0)}", 2000, 50, 1) # remove once you have the visuals in place
    @font.draw_text("Y: #{mouse_y.round(0)}", 2200, 50, 1) # remove once you have the visuals in place
  end

  def update_start
    if self.text_input.text == ""
      @new_game_button.text = "New Game"
    else
      @new_game_button.text = "Join Game"
    end
  end

  def draw_start
    @font_2.draw_text("Clue", 900, 100, 1)
    @font.draw_text("Welcome to Hill House", 950, 400, 1)
    @font.draw_text("Press Enter to begin", 970, 1300, 1)

    @font.draw_text(self.text_input.text, 1155, 700, 1)
    @new_game_button.draw
  end 

  def update_character_selecting

  end

  def draw_character_selecting
    @font.draw_text("Choose your Character", 950, 200, 1)
    @available_characters.each {|character_button| character_button.draw }
    @font.draw_text("Player ID: #{self.text_input.text}", 70, 200, 1)
    @font.draw_text("Game Id: #{@current_game_id}", 70, 70, 1)
    
    @font.draw_text(@message, 1800, 250, 1)
  end

  def update_waiting
    if (Gosu::milliseconds - @last_time) / 10000 == 1
      response = HTTP.get("#{BASE_ROOT_URL}/api/participations/#{@participation_id}/turn_check")
      @scene = :game if response.parse["my_turn"]
        
      @last_time = Gosu::milliseconds()
    end
  end

  def draw_waiting
    @font.draw_text("waiting", 1050, 100, 1)
    @font.draw_text("Player Name: #{@player_name}", 1050, 250, 1)
    @font.draw_text("Character Name: #{@character_name}", 1050, 400, 1)
    @font.draw_text(@message, 1050, 400, 1)
    @font.draw_text("Game Id: #{@current_game_id}", 70, 70, 1)

    if @game_organizer == true
      @start_game_button.draw
    end
  end 

  def update_game
    
  end

  def draw_game 
    @background.draw(100,80,0)
    @board.draw
    @font.draw_text("Detective Sheet", 1800, 100, 1)
  end 

  def draw_game_waiting
    
  end

  def draw_win(fate)
  
  end 

  def draw_lose(fate)
    
  end

  def button_down(id)
    case @scene
    when :start
      button_down_start(id)
    when :character_selecting
      character_selecting(id)
    when :waiting
      button_down_waiting(id)
    when :game
      button_down_game(id)
    end
  end

  def button_down_start(id) 
    if (id == Gosu::MsLeft) && (mouse_x - @new_game_button.x).abs < (@new_game_button.width / 2) && (mouse_y - @new_game_button.y).abs < (@new_game_button.height / 2)
      if self.text_input.text == ""
        @current_game_id = HTTP.post("#{BASE_ROOT_URL}/api/games").parse["id"]
        @game_organizer = true
      else
        @current_game_id = self.text_input.text.to_i
        self.text_input.text = ""
      end

      puts "You are now playing game number: #{@current_game_id}"
      @scene = :character_selecting
      initialize_character_selecting
    end
  end  

  def character_selecting(id)
    if (id == Gosu::MsLeft) 
      if [1,2,3,4,5,6,7].include?(self.text_input.text.to_i)
        @available_characters.each do |character_button|
          if (mouse_x - character_button.x).abs < (character_button.width / 2) && (mouse_y - character_button.y).abs < (character_button.height / 2)
            puts character_button.text
            parsed_response = HTTP.post("#{BASE_ROOT_URL}/api/games/#{@current_game_id}/participations?character_id=#{character_button.id}&player_id=#{self.text_input.text}").parse

            if parsed_response["move_forward"]
              @player_name = parsed_response["player"]["username"]
              @character_name = parsed_response["character"]["name"] #change to gosu logic, may need to make player/character objects on all computers
              @participation_id = parsed_response["id"]
              self.text_input.text = ""
              initialize_waiting
              @scene = :waiting
            else
              initialize_character_selecting
            end
          end
        end
      end
    end
  end

  def button_down_waiting(id)
    id = Gosu::MsLeft
    if (id == Gosu::MsLeft) && (mouse_x - @start_game_button.x).abs < (@start_game_button.width / 2) && (mouse_y - @start_game_button.y).abs < (@start_game_button.height / 2)
     @scene = :game
    end  
  end

  def button_down_game(id)
      
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

