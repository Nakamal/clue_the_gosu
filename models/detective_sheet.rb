require 'gosu'
require_relative 'card'
require_relative 'hand'

class DetectiveSheet
  attr_accessor :characters, :weapons, :rooms
  
  def initialize(sections_hash)
    @characters = sections_hash["characters"]
    @weapons = sections_hash["weapons"]
    @rooms = sections_hash["rooms"]
  end
end