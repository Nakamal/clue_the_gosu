# require 'gosu'

# class Die
#   attr_accessor :sides, :value, :finished

#   def initialize(options_hash)
#     @sides = options_hash[:sides]
#     @value = 1
#     @x = options_hash[:x]
#     @y = options_hash[:y]
#     @radius = 30
#     @images = Gosu::Image.load_tiles('images/explosions.png', 60, 60) #
#     @image_index = 0
#     @finished = false
#   end

#   def roll
#     @value = rand(1..sides)
#     @total = @value
#   end
# end

# def draw
#   if @image_index < @images.count
#     @images[@image_index].draw(@x - @radius, @y - @radius, 2)
#     @image_index += 1
#   else
#     @finished = true
#   end
# end

# d6 = Die.new(sides: 6)
