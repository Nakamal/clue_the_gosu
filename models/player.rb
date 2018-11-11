require 'gosu'
require_relative 'character'

class Player
  attr_accessor :window, :current_player, :id, :username, :character, :participation_id, :my_turn, :current_location_x, :current_location_y
  def initialize(json_hash, options_hash)
    @window = options_hash[:window]
    @board = options_hash[:board]
    @current_player = false
    @id = json_hash["player"]["id"]
    @username = json_hash["player"]["username"]
    @character = Character.new(json_hash["character"])
    @participation_id = json_hash["id"]
    @my_turn = json_hash["my_turn"]
    @current_location_x = json_hash["current_location_x"].to_i
    @current_location_y = json_hash["current_location_y"].to_i
    @piece = Gosu::Image.new(window, "media/character_pieces/#{@character.image}")
  end

  def draw
    space = @board.space_at(row: @current_location_y, column: @current_location_x)
    space_middle_x = space.middle_x
    space_middle_y = space.middle_y
    image_height = @piece.height
    image_width = @piece.width
    @piece.draw(space_middle_x - (image_width / 2), space_middle_y - (image_height / 2), 5)
  end
end