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

BASE_ROOT_URL = "https://clue-the-heroku.herokuapp.com"

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
    @border = Gosu::Image.new(self, 'media/game_images/win_lose_edited.png') # fix the size for win and lose
    @start_image = Gosu::Image.new(self, 'media/game_images/official_clue_opening_image.png')
    @character_select_image = Gosu::Image.new(self, 'media/game_images/clue_alt_image.png')
    @waiting_image = Gosu::Image.new(self, 'media/game_images/clue_card.png')
    @win_image = Gosu::Image.new(self, 'media/game_images/win_picture.png')
    @lose_image = Gosu::Image.new(self, 'media/game_images/lose_picture.png')

  
    @font = Gosu::Font.new(self, "media/GalliaMTStd.otf", HEIGHT / 30)
    @font_2 = Gosu::Font.new(self, "media/pythago0.ttf", HEIGHT / 5)
    @font_3 = Gosu::Font.new(self, "media/pythago0.ttf", HEIGHT / 12)
    @font_4 = Gosu::Font.new(self, "media/GalliaMTStd.otf", HEIGHT / 25)

    self.text_input = Gosu::TextInput.new
    self.text_input.text = ""
    @last_time = 0
    @game_status = true
    @youre_active = true
    @characters = []
    @message = ""
    initialize_start
    @game_organizer = false 
    @keep_playing = true

    @pop_up = PopUpWindow.new(window: self)
    pop_up_offset_x = @pop_up.center_x
    pop_up_offset_y = @pop_up.y + 240
    button_height = 110

    # @room_buttons = Room.buttons(window: self, x: pop_up_offset_x, y: pop_up_offset_y, z: @pop_up.z + 1, height: button_height)
    @rooms = Room.all
    @weapon_buttons = Weapon.buttons(window: self, x: pop_up_offset_x, y: pop_up_offset_y, z: @pop_up.z + 1, height: button_height)
    @character_buttons = Character.buttons(window: self, x: pop_up_offset_x, y: pop_up_offset_y, z: @pop_up.z + 1, height: button_height)
    @suggestion_button = Button.new(window: self, x: pop_up_offset_x, y: pop_up_offset_y + 50, z: @pop_up.z + 1, text: "Suggestion")
    @accusation_button = Button.new(window: self, x: pop_up_offset_x, y: pop_up_offset_y + 90 + button_height, z: @pop_up.z + 1, text: "Accusation")
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

    # @font.draw_text("X: #{mouse_x.round(0)}", 2000, 50, 1) # remove once you have the visuals in place
    # @font.draw_text("Y: #{mouse_y.round(0)}", 2200, 50, 1) # remove once you have the visuals in place
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
    when :lose
      button_down_lose(id)
    end
  end

  # START ******************************************************************

  def initialize_start
    @start_music = Gosu::Song.new('media/music/01_main_title.mp3')
    @start_music.play(looping = true)   
    @new_game_button = Button.new(window: self, x: 1700, y: 700, text: "New Game")
  end

  def update_start
    if self.text_input.text == ""
      @new_game_button.text = "New Game"
    else
      @new_game_button.text = "Join Game"
    end
  end

  def draw_start
    @start_image.draw(200, 90, 0)
    @font_3.draw_text("Welcome to Hill House", 1180, 200, 1)
    @font_4.draw_text("Press button to begin or type game id", 1130, 1100, 1)

    @font_4.draw_text(self.text_input.text, 1650, 600, 1)
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
    @start_music = Gosu::Song.new('media/music/06_bag_in_hall.mp3')
    @start_music.play(looping = true)
    parsed_response = HTTP.get("#{BASE_ROOT_URL}/api/games/#{@current_game_id}").parse
    @available_characters = []
    character_starting_line = 355
    parsed_response["available_characters"].each_with_index do |character, index|
      @available_characters << Button.new(window: self, x: 1830, y: character_starting_line + (130 * index), text: character["name"], id: character["id"])
    end
  end

  def update_character_selecting

  end

  def draw_character_selecting
    @character_select_image.draw(200, 100, 0) # edit out the name 'clue' and the white border from this picture 
    @font_4.draw_text("Choose your Character", 1470, 200, 1)
    @available_characters.each {|character_button| character_button.draw }
    @font.draw_text("Player ID: #{self.text_input.text}", 1360, 80, 1)
    @font.draw_text("Game Id: #{@current_game_id}", 2030, 80, 1)
    
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
    @start_music = Gosu::Song.new('media/music/04_may_i_present_mr_boddy.mp3')
    @start_music.play(looping = true)
    @start_game_button = Button.new(window: self, x: 440, y: 680, text: "Start Game")
    @players = []
    @last_time = Gosu::milliseconds
  end

  def update_waiting
    if (Gosu::milliseconds - @last_time) / 1000 == 1
      response = HTTP.get("#{BASE_ROOT_URL}/api/participations/#{@participation_id}/turn_check")
      @players = response.parse["participations"].map {|participation_hash| Player.new(participation_hash, window: self, board: @board) }
      @player = @players.select { |player_object| player_object.participation_id == @participation_id }.first
      if response.parse["game_started"]
        @scene = :game_waiting
        initialize_game_waiting
      end
      @last_time = Gosu::milliseconds
    end
  end

  def draw_waiting
    @waiting_image.draw(1400, 100, 0) # clean up image 
    @font.draw_text("Player Name: #{@player_name}", 100, 250, 1)
    @font.draw_text("Character Name: #{@character_name}", 100, 400, 1)
    @font.draw_text("Waiting for players", 160, 980, 1)
    @font.draw_text(@message, 1050, 400, 1)
    @font.draw_text("Game Id: #{@current_game_id}", 100, 100, 1)
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
    @start_music = Gosu::Song.new('media/music/10_ill_search_the_kitchen.mp3')
    @start_music.play(looping = true)
    @last_time = Gosu::milliseconds
    detective_sheet_info = HTTP.get("#{BASE_ROOT_URL}/api/participations/#{@participation_id}/sheet").parse
    @detective_sheet = DetectiveSheet.new(detective_sheet_info, window: self, x: 1589, y: 100)
  end

  def update_game_waiting
    if (Gosu::milliseconds - @last_time) / 1000 == 1
      response = HTTP.get("#{BASE_ROOT_URL}/api/participations/#{@participation_id}/turn_check")
      @players = response.parse["participations"].map { |participation_hash| Player.new(participation_hash, window: self, board: @board) }
      if response.parse["game_completed"]
        @scene = :lose
        initialize_lose
      elsif response.parse["my_turn"]
        @game_status = response.parse["game_status"]
        @scene = :game 
        initialize_game
      end
      @last_time = Gosu::milliseconds()
    end
  end

  def draw_game_waiting
    @background.draw(100,80,0)
    @board.draw
    @font.draw_text("Currently you're playing, Waiting...the game", 130, 150, 30)
    @font.draw_text("Detective Sheet", 1600, 50, 50)
    @detective_sheet.draw
    background_c = Gosu::Color.argb(0xCC_000000)
    self.draw_quad(0, 0, background_c, WIDTH, 0, background_c, WIDTH, HEIGHT, background_c, 0, HEIGHT, background_c, 20, mode = :default)
  end

  def button_down_game_waiting(id)
    
  end

  # GAME ************************************************************************

  def initialize_game
    @start_music = Gosu::Song.new('media/music/08_stranger_at_front_door.mp3')
    @start_music.play(looping = true)
    @choosen_room = nil
    @choosen_weapon = nil
    @choosen_character = nil
    @game_button_set = :room_selection
    detective_sheet_info = HTTP.get("#{BASE_ROOT_URL}/api/participations/#{@participation_id}/sheet").parse
    @detective_sheet = DetectiveSheet.new(detective_sheet_info, window: self, x: 1589, y: 100) 
  end

  def update_game

  end

  def draw_game
    @font.draw_text("What room would you like to investigate?", 180, 40, 0) 
    @background.draw(100,80,0)
    # @board.draw # uncomment to see the colors
    @players.each { |player| player.draw }
    @font.draw_text("Detective Sheet", 1600, 50, 50)
    @detective_sheet.draw
    z = 10

    case @game_button_set

    when :room_selection
      # @pop_up.draw
      # header_message = "What room would you like to go to?"
      # header_width = @font.text_width(header_message)
      # @font.draw_text(header_message, @pop_up.center_x - (header_width / 2), @pop_up.y + 50, z + 1)
      # @room_buttons.each { |room_button| room_button.draw }

    when :character_buttons
      @pop_up.draw
      header_message = "Which shifty suspect do you think"
      header_width = @font.text_width(header_message)
      @font.draw_text(header_message, @pop_up.center_x - (header_width / 2), @pop_up.y + 50, z + 1)
      header_message = "committed this heinous act?"
      header_width = @font.text_width(header_message)
      @font.draw_text(header_message, @pop_up.center_x - (header_width / 2), @pop_up.y + 120, z + 1)
      @character_buttons.each { |character_button| character_button.draw }

    when :weapon_buttons
      @pop_up.draw
      header_message = "And with what do you think said shifty"
      header_width = @font.text_width(header_message)
      @font.draw_text(header_message, @pop_up.center_x - (header_width / 2), @pop_up.y + 50, z + 1)
      header_message = "suspect accomplished this vile feat?"
      header_width = @font.text_width(header_message)
      @font.draw_text(header_message, @pop_up.center_x - (header_width / 2), @pop_up.y + 120, z + 1)
      @weapon_buttons.each { |weapon_button| weapon_button.draw }

    when :decision_buttons
      @pop_up.draw
      header_message = "Are you making a suggestion?"
      header_width = @font.text_width(header_message)
      @font.draw_text(header_message, @pop_up.center_x - (header_width / 2), @pop_up.y + 50, z + 1)
      header_message = "Or is that an accusation?"
      header_width = @font.text_width(header_message)
      @font.draw_text(header_message, @pop_up.center_x - (header_width / 2), @pop_up.y + 120, z + 1)
      @suggestion_button.draw
      @accusation_button.draw
    end 
  end 

  def button_down_game(id)
    if !@keep_playing
      if id == 40
        @scene = :game_waiting
        initialize_game_waiting
      end
    else
      case @game_button_set
      when :room_selection
        @board.rooms.each do |room_space|
          if (mouse_x - room_space.middle_x).abs < (room_space.width / 2) && (mouse_y - room_space.middle_y).abs < (room_space.height / 2)

            #change coordinates on gosu =============================
            @choosen_room = room_space.room
            room = @rooms.select { |room_object| room_object.name == @choosen_room }.first
            @player.current_location_x = room.location_x
            @player.current_location_y = room.location_y
            #========================================================
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
                    character: @choosen_character,
                    current_location_x: @player.current_location_x,
                    current_location_y: @player.current_location_y
                   }

          parsed_response = HTTP.patch("#{BASE_ROOT_URL}/api/participations/#{@participation_id}/turn", form: params).parse
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

          parsed_response = HTTP.patch("#{BASE_ROOT_URL}/api/participations/#{@participation_id}/turn?accusation=true", form: params).parse

          if parsed_response["accusation"]
            @scene = :win
            initialize_win
          else
            @keep_playing = false
            @scene = :lose
            initialize_lose
          end
        end       
      end
    end
  end  

  # WIN SETUP *******************************************************************

  def initialize_win
    @start_music = Gosu::Song.new('media/music/shake_rattle_and_roll.mp3')
    @start_music.play(looping = true)
  end

  def update_win
    
  end

  def draw_win
    @border.draw(30, 10, 0)
    @win_image.draw(500, 450, 0)
    header_message = "You've solved the case,"
    header_width = @font.text_width(header_message)
    @font.draw_text(header_message, (WIDTH / 2) - (header_width / 2), 200, 1)
    header_message = "looks like that phone call from J. Edgar Hoover was for you."
    header_width = @font.text_width(header_message)
    @font.draw_text(header_message, (WIDTH / 2) - (header_width / 2), 350, 1)
  end 

  # LOSE SETUP ******************************************************************

  def initialize_lose
    @start_music = Gosu::Song.new('media/music/14_step_by_step.mp3')
    @start_music.play(looping = true)
  end

  def update_lose
    
  end

  def draw_lose
    @border.draw(30, 10, 0)
    @lose_image.draw(740, 500, 0)
    header_message = "No, communism was just a red herring."
    header_width = @font.text_width(header_message)
    @font.draw_text(header_message, (WIDTH / 2) - (header_width / 2), 200, 1)
    if @game_status 
      loser_message = "You've lost, but you can still move around to mess other players up, what fun"
      loser_width = @font.text_width(loser_message)
      @font.draw_text(loser_message, (WIDTH / 2) - (loser_width / 2), 300, 1)
      loser_command = "Press 'enter' to keep playing...(yes you have to keep playing)"
      loser_command_width = @font.text_width(loser_command)
      @font.draw_text(loser_command, (WIDTH / 2) - (loser_command_width / 2), 400, 1)
    end
  end

  def button_down_lose(id)
    if @game_status && id == 40
      @scene = :game_waiting
      initialize_game_waiting
    end
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
