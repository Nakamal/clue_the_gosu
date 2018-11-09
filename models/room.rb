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

  def self.buttons(options_hash)
    starting_line = options_hash[:y]
    # break into multiple lines
    all.map.with_index {|object_type, index| Button.new(window: options_hash[:window], x: options_hash[:x], y: starting_line + (options_hash[:height] * index), id: object_type.id, text: options_hash[:text])}
  end
end