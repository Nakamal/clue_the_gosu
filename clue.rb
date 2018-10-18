require 'gosu'
require_relative 'game'

class Clue < Gosu::Window

  def initialize
    @window = window
    @spaces = []
  end

  def needs_cursor?
    true
  end
end

window = Clue.new
window.show