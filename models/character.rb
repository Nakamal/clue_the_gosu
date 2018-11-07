require 'gosu'

class Character
  attr_accessor :id, :name, :color
  def initialize(options_hash)
    @id = options_hash["id"]
    @name = options_hash["name"]
    @color = options_hash["color"]
  end
end