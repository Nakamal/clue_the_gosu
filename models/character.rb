require 'gosu'

class Character
  attr_accessor :id, :name, :color
  def initialize(options_hash)
    @id = options_hash["id"]
    @name = options_hash["name"]
    @color = options_hash["color"]
  end

  def self.all
    characters_response = HTTP.get("#{BASE_ROOT_URL}/api/characters").parse
    @available_characters = characters_response.map { |character_hash| Character.new(character_hash) }
  end

  def self.buttons(window)
    starting_line = 355
    all.map.with_index {|object_type, index| Button.new(window: window, x: 1200, y: starting_line + (130 * index), id: object_type.id)}
  end
end