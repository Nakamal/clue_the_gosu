require 'gosu'

class Room
  attr_accessor :id, :name
  def initialize(options_hash)
    @id = options_hash["id"] 
    @name = options_hash["name"]
    @location_x = options_hash["location_x"]
    @location_y = options_hash["location_y"]
  end

  def self.all
    rooms_response = HTTP.get("#{BASE_ROOT_URL}/api/rooms").parse
    rooms_response.map { |room_hash| Room.new(room_hash) }
  end

  def self.buttons(options_hash)
    starting_line = options_hash[:y]

    all.map.with_index do |object_type, index|
      Button.new(
                  window: options_hash[:window], 
                  x: options_hash[:x], 
                  y: starting_line + (options_hash[:height] * index), 
                  z: options_hash[:z],
                  id: object_type.id, 
                  text: object_type.name
                )
    end
  end
end