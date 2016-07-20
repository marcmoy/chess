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

class Level1ComputerPlayer

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

class Level2ComputerPlayer < Level1ComputerPlayer

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

class Level3ComputerPlayer < Level2ComputerPlayer

  PIECE_RANK = {
    Pawn => 1,
    Knight => 3,
    Bishop => 3,
    Rook => 5,
    Queen => 9,
    King => 100
  }

  def capture_move
    current_rank = 0
    move_result = nil
    pcs = pieces_with_valid_moves
    pcs.each do |piece|
      piece.valid_moves.each do |move|
        if board[move].color == enemy_color && PIECE_RANK[board[move].class] > current_rank
          move_result = [piece.pos, move]
          current_rank = PIECE_RANK[board[move].class]
        end
      end
    end
    move_result
  end

end

class Level4ComputerPlayer < Level3ComputerPlayer

  attr_reader :temp_board

  def play_turn
    display.render
    puts "Computer player #{name} is thinking..."
    sleep(1)
    prevent_capture_move || capture_move || random_move
  end

  def prevent_capture_move
    @temp_board = board.dup
    temp_board.board_data[:en_passant_pawn] = []

    enemy_piece_moves = threatened_squares

    sorted_pieces = pieces_threatened.sort_by{ |piece| PIECE_RANK[piece.class] }.reverse
    moving_piece = sorted_pieces.find do |piece|
      !(piece.valid_moves - enemy_piece_moves).empty?
    end

    return nil unless moving_piece

    start_pos = moving_piece.pos
    end_pos = (moving_piece.valid_moves - enemy_piece_moves).sample

    [start_pos, end_pos]
  end

  def pieces_threatened
    enemy_piece_moves = threatened_squares
    temp_board.pieces(color).select do |piece|
      enemy_piece_moves.include?(piece.pos)
    end
  end

  def threatened_squares
    temp_board.pieces(enemy_color).map do |enemy_piece|
      enemy_piece.valid_moves
    end.flatten(1)
  end

end
