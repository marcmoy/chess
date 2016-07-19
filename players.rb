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
    random_move
  end

  def pieces_with_valid_moves
    board.pieces(color).reject { |piece| piece.valid_moves.empty? }
  end

  def random_move
    random_piece = pieces_with_valid_moves.sample
    start_pos = random_piece.pos
    end_pos = random_piece.valid_moves.sample

    [start_pos, end_pos]
  end

  def enemy_color
    color == :white ? :black : :white
  end
end

class SlightlySmarterComputerPlayer < ComputerPlayer

  def play_turn
    display.render
    puts "Computer player #{name} is thinking..."
    sleep(1)
    capture_move || random_move
  end

  def capture_move
    pcs = pieces_with_valid_moves.shuffle
    pcs.each do |piece|
      piece.valid_moves.shuffle.each do |move|
        return [piece.pos, move] if board[move].color == enemy_color
      end
    end
    nil
  end

end
