require_relative 'display'

class HumanPlayer

  attr_reader :name
  attr_accessor :display, :color

  def initialize(name)
    @name = name
  end

  def play_turn
    start_pos, end_pos = nil, nil
    until start_pos
      display.render
      puts "Check!" if display.board.in_check?(color)
      start_pos = display.get_input
    end
    until end_pos
      display.render
      puts "Check!" if display.board.in_check?(color)
      end_pos = display.get_input
    end

    [start_pos, end_pos]
  end
end

class ComputerPlayer

  attr_reader :name, :display
  attr_accessor :color, :board

  def initialize(name)
    @name = name
  end

  def display=(display)
    @display = display
    @board = display.board
  end

  def play_turn
    display.render
    puts "Computer player #{name} is thinking..."
    sleep(1)
    pieces_with_valid_moves = board.pieces(color).reject do |piece|
      piece.valid_moves.empty?
    end
    random_piece = pieces_with_valid_moves.sample
    start_pos = random_piece.pos
    end_pos = random_piece.valid_moves.sample

    [start_pos, end_pos]
  end
end
