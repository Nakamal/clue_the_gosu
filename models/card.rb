require 'gosu'

class Card
  attr_accessor :id, :name
  def initialize(input_options)
    @id = input_options["id"]
    @name = input_options["subject"]["name"]
  end
end