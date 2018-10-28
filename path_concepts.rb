require 'paint'

class Square
  attr_accessor :role, :icon

  def initialize
    @role = :playable
    @icon = '■'
  end

  def colored_icon
    color_key = {
      playable: 'green',
      nope: 'blue',
      possible: 'green',
      start: 'purple',
      stop: 'orange',
      path: 'red'
    }
    Paint[printable_icon , color_key[role], "green"]
  end

  def printable_icon
    icon == '■' ? icon : icon.to_s(34)
  end

  def label_path(step)
    if (icon == '■' || icon > step) && (playable? || possible? || stop?)
      possible! unless stop?
      self.icon = step
    else
      nil
    end
  end

  def playable!
    self.role = :playable
  end

  def nope!
    self.role = :nope
  end

  def possible!
    self.role = :possible
  end

  def start!
    self.role = :start
  end

  def stop!
    self.role = :stop
  end

  def path!
    self.role = :path
  end

  def playable?
    role == :playable
  end

  def nope?
    role == :nope
  end

  def possible?
    role == :possible
  end

  def start?
    role == :start
  end

  def stop?
    role == :stop
  end

  def path?
    role == :path
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

  def print
    system 'clear'

    find_path if start_square_coords
    backpath = find_backpath

    self.each do |x_array|
      puts x_array.map {|space| space.colored_icon }.join
    end

    backpath
  end

  # Finding squares ================================

  def start_square_coords
    self.each_with_index do |x_array, x_coor|
      x_array.each_with_index do |square, y_coor|
        return [x_coor, y_coor] if square.start?
      end
    end

    nil
  end

  def stop_square_coords
    self.each_with_index do |x_array, x_coor|
      x_array.each_with_index do |square, y_coor|
        return [x_coor, y_coor] if square.stop?
      end
    end

    nil
  end

  def square_at(coords)
    self[coords[0]][coords[1]]
  end

  def square_to(direction, coords)
    case direction
    when :top
      self[coords[0] - 1][coords[1]]
    when :bottom
      self[coords[0] + 1][coords[1]]
    when :left
      self[coords[0]][coords[1] - 1]
    when :right
      self[coords[0]][coords[1] + 1]
    end
  end

  # Marking methods ================================

  def mark_nonplayable(x,y)
    square_at([x,y]).nope!
  end

  # Checking methods ================================

  def check_to(direction, coords)
    case direction
    when :top
      coords[0] > 0
    when :bottom
      coords[0] < self.length - 1
    when :left
      coords[1] > 0
    when :right
      coords[1] < self[0].length - 1
    end
  end

  # Coords methods ================================

  def coords_to(direction, original_coords)
    case direction
    when :top
      [original_coords[0] - 1, original_coords[1]]
    when :bottom
      [original_coords[0] + 1, original_coords[1]]
    when :left
      [original_coords[0], original_coords[1] - 1]
    when :right
      [original_coords[0], original_coords[1] + 1]
    end
  end

  # Possible Path methods ================================

  def check_and_label_path(direction, coords, count)
    check_to(direction, coords) && square_to(direction, coords).label_path(count)
  end

  def find_path(coords=start_square_coords, count=0)
    count += 1

    [:top, :bottom, :left, :right].each do |direction|
      find_path(coords_to(direction, coords), count) if check_and_label_path(direction, coords, count) 
    end
  end

  # Back Path methods ================================

  def start_check(direction, coords)
    check_to(direction, coords) && square_to(direction, coords).start? 
  end

  def icon_check(direction, coords)
    check_to(direction, coords) && 
    square_to(direction, coords).icon.is_a?(Integer) && 
    square_to(direction, coords).icon < square_at(coords).icon
  end

  def find_backpath
    backpath_coords = [stop_square_coords]

    while true
      location_coords = backpath_coords.last

      if start_check(:top, location_coords)
        square_to(:top, location_coords).path!
        backpath_coords << coords_to(:top, location_coords)
        return backpath_coords

      elsif start_check(:bottom, location_coords) 
        square_to(:bottom, location_coords).path!
        backpath_coords << coords_to(:bottom, location_coords)
        return backpath_coords

      elsif start_check(:left, location_coords)
        square_to(:left, location_coords).path!
        backpath_coords << coords_to(:left, location_coords)
        return backpath_coords

      elsif start_check(:right, location_coords)
        square_to(:right, location_coords).path!
        backpath_coords << coords_to(:right, location_coords)
        return backpath_coords

      elsif icon_check(:top, location_coords)
        square_to(:top, location_coords).path!
        backpath_coords << coords_to(:top, location_coords)

      elsif icon_check(:bottom, location_coords)
        square_to(:bottom, location_coords).path!
        backpath_coords << coords_to(:bottom, location_coords)

      elsif icon_check(:left, location_coords)
        square_to(:left, location_coords).path!
        backpath_coords << coords_to(:left, location_coords)

      elsif icon_check(:right, location_coords)
        square_to(:right, location_coords).path!
        backpath_coords << coords_to(:right, location_coords)

      end
    end
  end
end



grid = Grid.build

grid.mark_nonplayable(5,0)

grid.mark_nonplayable(4,1)
grid.mark_nonplayable(5,1)

grid.mark_nonplayable(5,2)

grid.mark_nonplayable(2,3)
grid.mark_nonplayable(2,2)
grid.mark_nonplayable(3,3)
grid.mark_nonplayable(5,3)

grid.mark_nonplayable(2,4)
grid.mark_nonplayable(3,4)
grid.mark_nonplayable(4,0)

grid.mark_nonplayable(3,5)
grid.mark_nonplayable(3,6)

grid.mark_nonplayable(2,7)
grid.mark_nonplayable(3,7)
grid.mark_nonplayable(4,7)
grid.mark_nonplayable(5,7) #
grid.mark_nonplayable(6,7)

grid.square_at([6,1]).start!
grid.square_at([1,8]).stop!

p grid.print