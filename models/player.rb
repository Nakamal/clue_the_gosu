require 'gosu'
require_relative 'character'

class Player
  attr_accessor :current_player, :id, :username, :character, :participation_id, :my_turn
  def initialize(options_hash)
    @current_player = false
    @id = options_hash["player"]["id"]
    @username = options_hash["player"]["username"]
    @character = Character.new(options_hash["character"])
    @participation_id = options_hash["id"]
    @my_turn = options_hash["my_turn"]
  end


  # def turn_check
  #   response = HTTP.get("#{BASE_ROOT_URL}/api/participations/#{@participation_id}/turn_check")
  # end
end