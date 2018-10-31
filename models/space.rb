require 'paint'
require 'gosu'

SQUARE_WIDTH = 60

Y_OFFSET = 10
X_OFFSET = 10

class Space

  attr_accessor :row, :column, :step, :role, :window

  def initialize(input_hash)
    @window = input_hash[:window]
    @row = input_hash[:row]
    @column = input_hash[:column]
    @role = input_hash[:role] || :playable
    @step = 0
  end

  def starting_x
    row * SQUARE_WIDTH
  end

  def starting_y
    (column * SQUARE_WIDTH) + Y_OFFSET
  end

  def middle_x
    starting_x + (SQUARE_WIDTH / 2)
  end

  def middle_y
    starting_y + (SQUARE_WIDTH / 2)
  end

  def label_path(current_step)
    if (step > current_step) && (!start? || !wall? || !room?)
      this.step = current_step
      possible_path! unless stop?
    else
      nil
    end
  end

  def color_print
    color_key = {
      home: '#000088',
      room: '#008800',
      playable: '#880088',
      non_playable: '#000000',
      door: '#888800'
    }

    Paint["██", color_key[role]]
  end

  def possible_path!
    this.role = :possible_path
  end

  def start?
    role == :start
  end

  def stop?
    role == :stop
  end

  def wall?
    role == :wall
  end

  def room?
    role == :room
  end

  def draw
    border = 2
    x_1 = starting_x + border
    y_1 = starting_y + border
    x_2 = x_1 + SQUARE_WIDTH - (border * 2)
    y_2 = y_1
    x_3 = x_2
    y_3 = y_2 + SQUARE_WIDTH - (border * 2)
    x_4 = x_1
    y_4 = y_3
    c = Gosu::Color.argb(0xff_0000ff)

    window.draw_quad(x_1, y_1, c, x_2, y_2, c, x_3, y_3, c, x_4, y_4, c, z = 0, mode = :default)
  end

end