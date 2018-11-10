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
  
  def self.buttons(options_hash)
    starting_line = options_hash[:y]

    all.map.with_index do |object_type, index|
      Button.new(
                  window: options_hash[:window], 
                  x: options_hash[:x], 
                  y: starting_line + (options_hash[:height] * index), 
                  id: object_type.id, 
                  text: object_type.name
                )
    end
  end
end