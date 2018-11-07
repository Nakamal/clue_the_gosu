require 'gosu'

class Room
  attr_accessor :id, :name
  def initialize(options_hash)
    @id = options_hash["id"] 
    @name = options_hash["name"]
  end
end