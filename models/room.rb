require 'gosu'

class Room
  attr_accessor :id, :name
  def initialize(options_hash)
    @id = options_hash["id"] 
    @name = options_hash["name"]
  end

  def self.all
    rooms_response = HTTP.get("#{BASE_ROOT_URL}/api/rooms").parse
    @available_rooms = rooms_response.map { |room_hash| Room.new(room_hash) }
  end

  def self.buttons(window)
    starting_line = 355
    all.map.with_index {|object_type, index| Button.new(window: window, x: 1200, y: starting_line + (130 * index), id: object_type.id)}
  end
end