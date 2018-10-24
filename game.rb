require 'gosu'
require_relative 'models/space'

class Game
  def initialize(width, height)
    @window = window
    @spaces = []
    @font = Gosu::Font.new(36)
  end
end