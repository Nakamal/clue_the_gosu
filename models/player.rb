require 'gosu'

class Player
  def initialize(player_options_hash, character_options_hash)
    @current_player = false
    @id = player_options_hash["id"]
    @username = player_options_hash["username"]
    @character = Character.new(character_options_hash)
  end


  # def turn_check
  #   response = HTTP.get("#{BASE_ROOT_URL}/api/participations/#{@participation_id}/turn_check")
  # end
end