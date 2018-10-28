require 'paint'

class Square
  attr_accessor :role, :icon

  def initialize
    @role = :playable
    @icon = '■'
  end

  def colored_icon
    color_key = {
      playable: '#008800',
      nope: 'red',
      possible: '#008800',
      start: 'purple',
      stop: 'orange'
    }
    background_key = {
      playable: 'green',
      nope: 'red',
      possible: 'green',
      start: 'purple',
      stop: 'orange'
    }
    Paint[printable_icon , color_key[role], "green"]
  end

  def printable_icon
    if icon == '■'
      icon
    else
      icon.to_s(24)
    end
  end

  def label_path(step)
    if (icon == '■' || icon > step) && (role == :playable || role == :possible || role == :stop)
      self.role = :possible unless role == :stop
      self.icon = step
    else
      nil
    end
  end
end

class Grid < Array

  def self.build(x_size=7,y_size=15)
    count = 0
    new_grid = Grid.new
    x_size.times do |x|
      x_array = []
      y_size.times do |y|
        count += 1
        x_array << Square.new
      end
      new_grid << x_array
    end
    new_grid
  end

  def coor(x,y)
    self[x][y]
  end

  def start_square_coors
    self.each_with_index do |x_array, x_coor|
      x_array.each_with_index do |square, y_coor|
        return [x_coor, y_coor] if square.role == :start
      end
    end

    nil
  end

  def mark_nonplayable(x,y)
    coor(x,y).role = :nope
  end

  def print
    self.each do |x_array|
      puts x_array.map {|space| space.colored_icon }.join
    end
  end

  def find_path(roll=6, location_coor=start_square_coors, count=0)
    count += 1
    if count > roll
      return
    end 

    x_coor = location_coor[0]
    y_coor = location_coor[1]

    if x_coor > 0
      if self[x_coor - 1][y_coor].label_path(count) 
        find_path(roll, [x_coor - 1, y_coor], count)
      end
    end

    if x_coor < self.length - 1
      if self[x_coor + 1][y_coor].label_path(count) 
        find_path(roll, [x_coor + 1, y_coor], count)
      end
    end

    if y_coor > 0
      if self[x_coor][y_coor - 1].label_path(count) 
        find_path(roll, [x_coor, y_coor - 1], count)
      end
    end

    if y_coor < self[0].length - 1
      if self[x_coor][y_coor + 1].label_path(count) 
        find_path(roll, [x_coor, y_coor + 1], count)
      end
    end
  end
end


system 'clear'

grid = Grid.build

grid.mark_nonplayable(2,3)
grid.mark_nonplayable(3,3)
grid.mark_nonplayable(4,3)
grid.mark_nonplayable(5,3)
grid.mark_nonplayable(2,4)
grid.mark_nonplayable(3,4)
grid.mark_nonplayable(4,4)
grid.mark_nonplayable(2,7)
grid.mark_nonplayable(3,7)
grid.mark_nonplayable(4,7)
grid.mark_nonplayable(5,7)

grid.coor(5,1).role = :start
grid.coor(1,8).role = :stop
grid.find_path(11) if grid.start_square_coors

grid.print