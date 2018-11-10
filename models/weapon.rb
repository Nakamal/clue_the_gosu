require 'gosu'

class Weapon
 attr_accessor :id, :name
 def initialize(options_hash)
   @id = options_hash["id"]
   @name = options_hash["name"]
  end

  def self.all
    weapons_response = HTTP.get("#{BASE_ROOT_URL}/api/weapons").parse
    @available_weapons = weapons_response.map { |weapon_hash| Weapon.new(weapon_hash) }
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