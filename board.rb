require_relative 'piece'

class InvalidMoveError < StandardError
end

class Board

  def initialize
    @grid = Array.new(8){ Array.new(8) { NullPiece.instance } }
    populate_grid
  end

  def [](pos)
    x, y = pos
    grid[x][y]
  end

  def []=(pos,value)
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
    grid.flatten.find{|piece| piece.is_a?(King) && piece.color == color}.pos
  end

  def populate_grid
    Rook.new(self, :black, [0,0])
    Knight.new(self, :black, [0,1])
    Bishop.new(self, :black, [0,2])
    Queen.new(self, :black, [0,3])
    King.new(self, :black, [0,4])
    Bishop.new(self, :black, [0,5])
    Knight.new(self, :black, [0,6])
    Rook.new(self, :black, [0,7])

    Rook.new(self, :white, [7,0])
    Knight.new(self, :white, [7,1])
    Bishop.new(self, :white, [7,2])
    Queen.new(self, :white, [7,3])
    King.new(self, :white, [7,4])
    Bishop.new(self, :white, [7,5])
    Knight.new(self, :white, [7,6])
    Rook.new(self, :white, [7,7])

    0.upto(7) do |col|
      Pawn.new(self, :black, [1, col])
      Pawn.new(self, :white, [6, col])
    end
  end
end
