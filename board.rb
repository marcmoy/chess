require_relative 'piece'

class InvalidMoveError < StandardError
end

class Board

  def self.setup
    board_data = {castle_kingside: [:black, :white],
              castle_queenside: [:black, :white],
              en_passant_pawn: []}
    board = Board.new(board_data)
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

  attr_reader :board_data

  def initialize(board_data = nil)
    @grid = Array.new(8){ Array.new(8) { NullPiece.instance } }
    @board_data = board_data || {castle_kingside: [],
                          castle_queenside: [],
                          en_passant_pawn: []}
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
    moved_piece = self[start]
    self[end_pos] = moved_piece
    moved_piece.pos = end_pos
    self[start] = NullPiece.instance

    handle_special_moves(moved_piece, start, end_pos)

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
      piece_moves = (piece.is_a?(King) ? piece.step_moves : piece.moves)
      return true if piece_moves.include?(king_pos)
    end
    false
  end

  def debug_board
    debugger
  end

  def checkmate?(color)
    in_check?(color) && pieces(color).all? { |piece| piece.valid_moves.empty? }
  end

  def pieces(color)
    grid.flatten.select { |piece| piece.color == color }
  end

  def dup
    dup_board = Board.new(dup_options)
    # take all pieces, duplicate them onto new board
    grid.flatten.each do |piece|
      next if piece.is_a?(NullPiece)
      piece.class.new(dup_board, piece.color, piece.pos)
    end

    dup_board
  end

  private
  attr_reader :grid

  def handle_special_moves(moved_piece, start, end_pos)
    handle_castling(moved_piece, start, end_pos)
    handle_en_passant(moved_piece, start, end_pos)
    handle_promotion(moved_piece, end_pos)
  end

  def handle_promotion(moved_piece, end_pos)
    moved_piece.promote if moved_piece.is_a?(Pawn) && [0,7].include?(end_pos[0])
  end

  def handle_en_passant(moved_piece, start, end_pos)
    ep_pos = board_data[:en_passant_pawn]
    square_moved_through = nil

    unless ep_pos.empty?
      fwd_dir = self[ep_pos].forward_dir
      square_moved_through = [ep_pos[0] - fwd_dir, ep_pos[1]]
    end

    board_data[:en_passant_pawn] = []
    return false unless moved_piece.is_a?(Pawn)
    board_data[:en_passant_pawn] = moved_piece.pos if (start[0] - end_pos[0]).abs == 2

    if square_moved_through && end_pos == square_moved_through
      self[ep_pos] = NullPiece.instance
    end
  end

  def handle_castling(moved_piece, start, end_pos)
    if castle_move?(moved_piece, start, end_pos)
      move_rook_for_castle!(start, end_pos)
    end

    remove_castling_privilege(start, moved_piece.color)
  end

  def dup_options
    duped = {}
    board_data.each { |k, v| duped[k] = v.dup }
    duped
  end

  def castle_move?(piece, start, end_pos)
    piece.is_a?(King) && (start[1] - end_pos[1]).abs == 2
  end

  def move_rook_for_castle!(start, end_pos)
    rook_start_file = end_pos[1] > 4 ? 7 : 0
    rook_start_rank = start[0]
    rook_start = [rook_start_rank, rook_start_file]
    rook = self[rook_start]

    rook_end_file = end_pos[1] > 4 ? 5 : 3
    rook_end = [rook_start_rank, rook_end_file]
    self[rook_end] = rook
    rook.pos = rook_end
    self[rook_start] = NullPiece.instance

    self
  end

  def remove_castling_privilege(start, color)
    rank, file = start
    color_matches_rank = (color == :black && rank == 0) ||
                            (color == :white && rank == 7)

    return unless color_matches_rank
    case file
    when 0
      @board_data[:castle_queenside].delete(color)
    when 4
      @board_data[:castle_queenside].delete(color)
      @board_data[:castle_kingside].delete(color)
    when 7
      @board_data[:castle_kingside].delete(color)
    end
  end

  def find_king(color)
    grid.flatten.find{ |piece| piece.is_a?(King) && piece.color == color }.pos
  end
end
