require_relative 'piece'

class InvalidMoveError < StandardError
end

class Board

  def self.setup
    board = Board.new
    [:black, :white].each_with_index do |color, i|
      piece_rank = 7 * i
      pawn_rank = 5 * i + 1
      [Rook, Knight, Bishop].each_with_index do |klass, j|
        klass.new(board, color, [piece_rank, j])
        klass.new(board, color, [piece_rank, 7 - j])
      end
      King.new(board, color, [piece_rank, 4])
      Queen.new(board, color, [piece_rank, 3])
      0.upto(7) do |file|
        Pawn.new(board, color, [pawn_rank, file])
      end
    end
    board
  end

  def initialize
    @grid = Array.new(8){ Array.new(8) { NullPiece.instance } }
  end

  def [](pos)
    x, y = pos
    grid[x][y]
  end

  def []=(pos, value)
    x, y = pos
    grid[x][y] = value
  end

  def move(color, start, end_pos)
    piece = self[start] #piece
    if piece.color == color && piece.valid_moves.include?(end_pos)
      move!(start, end_pos)
    else
      raise InvalidMoveError
    end
  end

  def move!(start, end_pos)
    # piece = self[start] #piece
    #
    # if piece.empty? || !piece.moves.include?(end_pos)
    #   raise InvalidMoveError
    # end

    self[end_pos] = self[start]
    self[end_pos].pos = end_pos
    self[start] = NullPiece.instance
    self
  end

  def in_bounds?(pos)
    pos.all? { |x| x.between?(0, 7) }
  end


  def in_check?(color)
    enemy_color = (color == :white ? :black : :white)
    king_pos = find_king(color)
    grid.flatten.each do |piece|
      next unless piece.color == enemy_color
      return true if piece.moves.include?(king_pos)
    end
    false
  end

  def debug_board
    debugger
  end

  def checkmate?(color)
    own_pieces = grid.flatten.select { |piece| piece.color == color }
    in_check?(color) && own_pieces.all? { |piece| piece.valid_moves.empty? }
  end

  def dup
    dup_board = Board.new
    # take all pieces, duplicate them onto new board
    grid.flatten.each do |piece|
      next if piece.is_a?(NullPiece)
      piece.class.new(dup_board, piece.color, piece.pos)
    end

    dup_board
  end

  private
  attr_reader :grid

  def find_king(color)
    grid.flatten.find{ |piece| piece.is_a?(King) && piece.color == color }.pos
  end
end
