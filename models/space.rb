require 'gosu'

class Space

  attr_accessor :row, :column, :step, :role

  def initialize(input_hash)
    @window = input_hash[:window]
    @row = input_hash[:row]
    @column = input_hash[:column]
    @role = input_hash[:role] || :playable
    @step = 0
  end

  def label_path(current_step)
    if (step > current_step) && (!start? || !wall? || !room?)
      this.step = current_step
      possible_path! unless stop?
    else
      nil
    end
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

end