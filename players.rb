require_relative 'display'

class HumanPlayer

  attr_reader :display, :color

  def initialize(name, display, color)
    @name = name
    @display = display
    @color = color
  end

  def play_turn
    start_pos, end_pos = nil, nil
    until start_pos
      display.render
      start_pos = display.get_input
    end
    until end_pos
      display.render
      end_pos = display.get_input
    end

    [start_pos, end_pos]
  end
end
