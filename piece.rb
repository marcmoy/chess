require 'singleton'
require 'byebug'

require_relative 'slidable'
require_relative 'stepable'

class Piece

  attr_reader :board, :color
  attr_accessor :pos

  def initialize(board, color, pos)
    @board = board
    @color = color
    @pos = pos
    @board[pos] = self
  end

  def to_s
    symbol.colorize(:color => color)
  end

  def empty?
    false
  end

  def valid_moves
    moves.reject{|move| move_into_check?(move)}
  end

  def enemy_color
    color == :white ? :black : :white
  end

  private

  def move_into_check?(to_pos)
    board_after_move = board.dup.move!(pos, to_pos)
    board_after_move.in_check?(color)
  end

end

class NullPiece
  include Singleton

  def color
    nil
  end

  def to_s
    " "
  end

  def moves
    []
  end

  def valid_moves
    []
  end

  def empty?
    true
  end
end

class King < Piece
  include Stepable

  def symbol
    "♔"
  end

  def moves
    step_moves + castle_moves
  end

  def castle_moves
    king_side_castle_pos = (color == :white ? [7,6] : [0,6])
    queen_side_castle_pos = (color == :white ? [7,2] : [0,2])
    moves = []
    moves << king_side_castle_pos if can_castle_king_side?
    moves << queen_side_castle_pos if can_castle_queen_side?
    moves
  end

  def can_castle_king_side?

    return false unless board.options[:castle_kingside].include?(color)
    return false if board.in_check?(color)

    castle_squares = []
    castle_squares << [7,5] << [7,6] if color == :white
    castle_squares << [0,5] << [0,6] if color == :black

    # check if squares between king and rook are safe to castle through
    castle_squares.all? do |sq|
      board[sq].empty? &&
        board.pieces(enemy_color).none? do |piece|
          piece.moves.include?(sq)
        end
    end


  end

  def can_castle_queen_side?
    return false unless board.options[:castle_queenside].include?(color)
    return false if board.in_check?(color)
    castle_squares = []
    castle_squares << [7,1] << [7,2] << [7,3] if color == :white
    castle_squares << [0,1] << [0,2] << [0,3] if color == :black

    return false unless board[castle_squares.first].empty?
    castle_squares.drop(1).all? do |sq|
      board[sq].empty? &&
        board.pieces(enemy_color).none? do |piece|
          piece.moves.include?(sq)
        end
    end
  end

  protected
  def move_diffs
    [[-1, -1], [-1, 0], [-1, 1],
     [0, -1],           [0, 1],
     [1, -1],  [1, 0],  [1, 1]]
  end



end

class Knight < Piece
  include Stepable

  def symbol
   "♘"
  end

  def moves
    step_moves
  end

  protected
  def move_diffs
    [[-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1]]
  end

end

class Bishop < Piece
  include Slidable

  def symbol
    "♗"
  end

  protected
  def move_dirs
    [:nw, :ne, :sw, :se]
  end
end

class Rook < Piece
  include Slidable

  # def initialize
  #   @moved_already = false
  #   super
  # end

  def symbol
    "♖"
  end

  protected
  def move_dirs
    [:n, :s, :e, :w]
  end
end

class Queen < Piece
  include Slidable

  def symbol
    "♕"
  end

  protected
  def move_dirs
    [:n, :s, :e, :w, :nw, :ne, :sw, :se]
  end
end


class Pawn < Piece
  def symbol
    "♙"
  end

  def moves
    forward_steps + side_attacks
  end

  protected
  def at_start_row?
    forward_dir > 0 ? pos[0] == 1 : pos[0] == 6
  end

  def forward_dir
    color == :white ? -1 : 1
  end

  def forward_steps
    row, col = pos
    one_fwd = [row + forward_dir, col]
    two_fwd = [row + 2 * forward_dir, col]
    return [] unless board.in_bounds?(one_fwd) && board[one_fwd].empty?
    return [one_fwd] unless at_start_row? && board[two_fwd].empty?
    [one_fwd, two_fwd]

  end

  def side_attacks
    row, col = pos
    result = [[row + forward_dir, col + 1], [row + forward_dir, col - 1]]
    result.select do |pos|
      board.in_bounds?(pos) && board[pos].color == enemy_color
    end
  end
end
