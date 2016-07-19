module Stepable
  def moves
    next_squares = move_diffs.map{ |diff| [@pos[0] + diff[0], @pos[1] + diff[1]] }
    next_squares.select { |sq| board.in_bounds?(sq) && board[sq].color != color }
  end
end
