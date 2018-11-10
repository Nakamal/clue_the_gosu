require 'gosu'
require 'http'

require_relative 'game'
require_relative 'models/board'
require_relative 'models/button'
require_relative 'models/card'
require_relative 'models/character'
require_relative 'models/detective_info'
require_relative 'models/detective_sheet'
require_relative 'models/die'
require_relative 'models/hand'
require_relative 'models/player'
require_relative 'models/pop_up_window'
require_relative 'models/room'
require_relative 'models/space'
require_relative 'models/weapon'

BASE_ROOT_URL = "http://localhost:3000"

class Clue < Gosu::Window 
  WIDTH = 2400
  HEIGHT = 1400
  attr_accessor :fullscreen, :id
  
  # MAIN SETUP ************************************************************

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

    @pop_up = PopUpWindow.new(window: self)
    pop_up_offset_x = @pop_up.center_x
    pop_up_offset_y = @pop_up.y + 170
    button_height = 110

    @room_buttons = Room.buttons(window: self, x: pop_up_offset_x, y: pop_up_offset_y, z: @pop_up.z + 1, height: button_height)
    @weapon_buttons = Weapon.buttons(window: self, x: pop_up_offset_x, y: pop_up_offset_y, z: @pop_up.z + 1, height: button_height)
    @character_buttons = Character.buttons(window: self, x: pop_up_offset_x, y: pop_up_offset_y, z: @pop_up.z + 1, height: button_height)
    @suggestion_button = Button.new(window: self, x: pop_up_offset_x, y: pop_up_offset_y, z: @pop_up.z + 1, text: "Suggestion")
    @accusation_button = Button.new(window: self, x: pop_up_offset_x, y: pop_up_offset_y + button_height, z: @pop_up.z + 1, text: "Accusation")
  end

  def update 
    case @scene
    when :start
      update_start
    when :character_selecting
      update_character_selecting
    when :waiting
      update_waiting
    when :game_waiting
      update_game_waiting
    when :game
      update_game
    when :win
      update_win
    when :lose
      update_lose
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
    when :game_waiting
      draw_game_waiting
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

  def button_down(id)
    case @scene
    when :start
      button_down_start(id)
    when :character_selecting
      button_down_character_selecting(id)
    when :waiting
      button_down_waiting(id)
    when :game
      button_down_game(id)
    when :game_waiting
      button_down_game_waiting(id)
    end
  end

  # START ******************************************************************

  def initialize_start   
    @new_game_button = Button.new(window: self, x: 1200, y: 847, text: "New Game")
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

  # CHARACTER SELECTING ******************************************************

  def initialize_character_selecting
    parsed_response = HTTP.get("#{BASE_ROOT_URL}/api/games/#{@current_game_id}").parse
    @available_characters = []
    character_starting_line = 355
    parsed_response["available_characters"].each_with_index do |character, index|
      @available_characters << Button.new(window: self, x: 1200, y: character_starting_line + (130 * index), text: character["name"], id: character["id"])
    end
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

  def button_down_character_selecting(id)
    if (id == Gosu::MsLeft) 
      if [1,2,3,4,5,6,7].include?(self.text_input.text.to_i)
        @available_characters.each do |character_button|
          if (mouse_x - character_button.x).abs < (character_button.width / 2) && (mouse_y - character_button.y).abs < (character_button.height / 2)
            puts character_button.text
            parsed_response = HTTP.post("#{BASE_ROOT_URL}/api/games/#{@current_game_id}/participations?character_id=#{character_button.id}&player_id=#{self.text_input.text}").parse

            if parsed_response["move_forward"]
              @player_name = parsed_response["player"]["username"]
              @character_name = parsed_response["character"]["name"]
              @my_player_id = parsed_response["player"]["id"]
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

  # WAITING *******************************************************************

  def initialize_waiting
    @start_game_button = Button.new(window: self, x: 1200, y: 847, text: "Start Game")
    @players = []
    @last_time = Gosu::milliseconds
  end

  def update_waiting
    if (Gosu::milliseconds - @last_time) / 1000 == 1
      response = HTTP.get("#{BASE_ROOT_URL}/api/participations/#{@participation_id}/turn_check")
      @players = response.parse["participations"].map {|participation_hash| Player.new(participation_hash) }
      if response.parse["game_started"]
        @scene = :game_waiting
        initialize_game_waiting
      end
      @last_time = Gosu::milliseconds
    end
  end

  def draw_waiting
    @font.draw_text("waiting", 1050, 100, 1)
    @font.draw_text("Player Name: #{@player_name}", 1050, 250, 1)
    @font.draw_text("Character Name: #{@character_name}", 1050, 400, 1)
    @font.draw_text(@message, 1050, 400, 1)
    @font.draw_text("Game Id: #{@current_game_id}", 70, 70, 1)
    @start_game_button.draw if @game_organizer == true
  end 

  def button_down_waiting(id)
    if @game_organizer && (id == Gosu::MsLeft) && (mouse_x - @start_game_button.x).abs < (@start_game_button.width / 2) && (mouse_y - @start_game_button.y).abs < (@start_game_button.height / 2)
      response = HTTP.patch("#{BASE_ROOT_URL}/api/games/#{@current_game_id}/start")

      if response.parse["start_game"] == "true"
        @scene = :game_waiting
        initialize_game_waiting
      end
    end  
  end

  # GAME WAITING ***************************************************************

  def initialize_game_waiting
    @last_time = Gosu::milliseconds
  end

  def update_game_waiting
    if (Gosu::milliseconds - @last_time) / 1000 == 1
      response = HTTP.get("#{BASE_ROOT_URL}/api/participations/#{@participation_id}/turn_check")
      @players = response.parse["participations"].map { |participation_hash| Player.new(participation_hash) }
      if response.parse["my_turn"]
        @scene = :game 
        initialize_game
      end
      @last_time = Gosu::milliseconds()
    end
  end

  def draw_game_waiting
    @background.draw(100,80,0)
    @board.draw
    @font.draw_text("And now you play, the waiting game...", 400, 180, 30)
    @font.draw_text("Detective Sheet", 1600, 100, 50)
    background_c = Gosu::Color.argb(0x88_000000)
    self.draw_quad(0, 0, background_c, WIDTH, 0, background_c, WIDTH, HEIGHT, background_c, 0, HEIGHT, background_c, 20, mode = :default)
  end

  def button_down_game_waiting(id)
    
  end

  # GAME ************************************************************************

  def initialize_game
    @choosen_room = nil
    @choosen_weapon = nil
    @choosen_character = nil
    @game_button_set = :none
    detective_sheet_info = HTTP.get("#{BASE_ROOT_URL}/api/participations/#{@participation_id}/sheet").parse
    @detective_sheet = DetectiveSheet.new(detective_sheet_info, window: self, x: 1589, y: 190)
     
  end

  def update_game

  end

  def draw_game 
    @background.draw(100,80,0)
    @board.draw
    @font.draw_text("Detective Sheet", 1600, 100, 50)
    @detective_sheet.draw
    z = 10

    case @game_button_set

    when :room_buttons
      @pop_up.draw
      header_message = "What room would you like to go to?"
      header_width = @font.text_width(header_message)
      @font.draw_text(header_message, @pop_up.center_x - (header_width / 2), @pop_up.y + 50, z + 1)
      @room_buttons.each { |room_button| room_button.draw }

    when :character_buttons
      @pop_up.draw
      header_message = "Which shifty suspect do you think committed this heinous act?"
      header_width = @font.text_width(header_message)
      @font.draw_text(header_message, @pop_up.center_x - (header_width / 2), @pop_up.y + 50, z + 1)
      @character_buttons.each { |character_button| character_button.draw }

    when :weapon_buttons
      @pop_up.draw
      header_message = "And how do you think said shifty suspect accomplished this vile feat?"
      header_width = @font.text_width(header_message)
      @font.draw_text(header_message, @pop_up.center_x - (header_width / 2), @pop_up.y + 50, z + 1)
      @weapon_buttons.each { |weapon_button| weapon_button.draw }

    when :decision_buttons
      @pop_up.draw
      header_message = "Are you making a suggestion or an accusation?"
      header_width = @font.text_width(header_message)
      @font.draw_text(header_message, @pop_up.center_x - (header_width / 2), @pop_up.y + 50, z + 1)
      @suggestion_button.draw
      @accusation_button.draw
    end 
  end 

  def button_down_game(id)
    case @game_button_set
    when :none
      if id == 40
        @game_button_set = :room_buttons
      end
    when :room_buttons
      @room_buttons.each do |room_button|
        if (mouse_x - room_button.x).abs < (room_button.width / 2) && (mouse_y - room_button.y).abs < (room_button.height / 2)
          puts room_button.text
          @choosen_room = room_button.text
          @game_button_set = :character_buttons
        end
      end
    when :character_buttons
      @character_buttons.each do |character_button|
        if (mouse_x - character_button.x).abs < (character_button.width / 2) && (mouse_y - character_button.y).abs < (character_button.height / 2)
          puts character_button.text
          @choosen_character = character_button.text
          @game_button_set = :weapon_buttons
        end
      end
    when :weapon_buttons
      @weapon_buttons.each do |weapon_button|
        if (mouse_x - weapon_button.x).abs < (weapon_button.width / 2) && (mouse_y - weapon_button.y).abs < (weapon_button.height / 2)
          puts weapon_button.text
          @choosen_weapon = weapon_button.text
          @game_button_set = :decision_buttons
        end
      end
    when :decision_buttons
      
      if (mouse_x - @suggestion_button.x).abs < (@suggestion_button.width / 2) && (mouse_y - @suggestion_button.y).abs < (@suggestion_button.height / 2)
        params = {
          new_location: @choosen_room,
          weapon: @choosen_weapon,
          character: @choosen_character
        }
        print "*" * 15
        print " suggestion "
        print "*" * 15
        p params
        puts "-" * 50
        parsed_response = HTTP.patch("#{BASE_ROOT_URL}/api/participations/#{@participation_id}/turn", form: params).parse
        p parsed_response
        puts "=" * 50
        if parsed_response["move_forward"]
          @scene = :game_waiting
          initialize_game_waiting
          @choosen_room = nil
          @choosen_weapon = nil
          @choosen_character = nil
        else
          initialize_game
        end
      end

      if (mouse_x - @accusation_button.x).abs < (@accusation_button.width / 2) && (mouse_y - @accusation_button.y).abs < (@accusation_button.height / 2)
        params = {
          new_location: @choosen_room,
          weapon: @choosen_weapon,
          character: @choosen_character
        }
        print "*" * 15
        print " accusation "
        print "*" * 15
        p params
        puts "-" * 50
        parsed_response = HTTP.patch("#{BASE_ROOT_URL}/api/participations/#{@participation_id}/turn?accusation=true", form: params).parse
        p parsed_response
        puts "=" * 50
        if parsed_response["accusation"]
          @scene = :win
          initialize_win
        else
          @scene = :lose
          initialize_lose
        end
      end       
    end
  end  

  # WIN SETUP *******************************************************************

  def initialize_win
    
  end

  def update_win
    
  end

  def draw_win
    @pop_up.draw
    header_message = "You win, brag about it."
    header_width = @font.text_width(header_message)
    @font.draw_text(header_message, @pop_up.center_x - (header_width / 2), @pop_up.y + 50, @pop_up.z + 1)
  end 

  # LOSE SETUP ******************************************************************

  def initialize_lose
    
  end

  def update_lose
    
  end

  def draw_lose
    @pop_up.draw
    header_message = "You lose, good day sir...I said good day!"
    header_width = @font.text_width(header_message)
    @font.draw_text(header_message, @pop_up.center_x - (header_width / 2), @pop_up.y + 50, @pop_up.z + 1)
  end

  # LONE METHODS ****************************************************************

  def needs_cursor?
    true
  end

  def fullscreen? 
    @fullscreen = [true, false]
  end

  def my_player
    @players.select {|player| player.id == @my_player_id }.first
  end
end

window = Clue.new
window.show
