require 'gosu'

class Die
  attr_accessor :sides, :value

  def initialize(input_die)
    @sides = input_die[:sides]
    @value = 1
  end

  def roll
    @value = rand(1..sides)
    @total = @value
  end
end

d6 = Die.new(sides: 6)

p d6.roll