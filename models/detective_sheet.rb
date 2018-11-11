require 'gosu'
require_relative 'card'
require_relative 'hand'
require_relative 'detective_info'

class DetectiveSheet
  attr_accessor :characters, :weapons, :rooms, :x, :y, :window, :font
  
  def initialize(sections_hash, options_hash)
    @characters = sections_hash["sheet_infos"]["characters"]
    @weapons = sections_hash["sheet_infos"]["weapons"]
    @rooms = sections_hash["sheet_infos"]["rooms"]

    @x = options_hash[:x]
    @y = options_hash[:y]
    @window = options_hash[:window]
    @font = Gosu::Font.new(window, "Nimbus Mono L", 20)

    @lines = []

    height = 40
    width = 350
    line = 0
    @lines << DetectiveInfo.new({}, window: window, x: x , y: y + (line * height), width: width, height: height, font: font, header_message: "Characters")

    characters.each do |character|
      line += 1
      @lines << DetectiveInfo.new(character, window: window, x: x , y: y + (line * height), width: width, height: height, font: font)
    end

    line += 1
    @lines << DetectiveInfo.new({}, window: window, x: x , y: y + (line * height), width: width, height: height, font: font, header_message: "Weapons")

    weapons.each do |weapon|
      line += 1
      @lines << DetectiveInfo.new(weapon, window: window, x: x , y: y + (line * height), width: width, height: height, font: font)
    end

    line += 1
    @lines << DetectiveInfo.new({}, window: window, x: x , y: y + (line * height), width: width, height: height, font: font, header_message: "Rooms")

    rooms.each do |room|
      line += 1
      @lines << DetectiveInfo.new(room, window: window, x: x , y: y + (line * height), width: width, height: height, font: font)
    end
  end

  def draw
    @lines.each { |line| line.draw }
  end
end








