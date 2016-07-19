module Stepable
  def step_moves
    next_squares = move_diffs.map do |diff|
      [@pos[0] + diff[0], @pos[1] + diff[1]]
    end
    next_squares.select {|sq| can_move_to_sq?(sq)}
  end

  private

  def can_move_to_sq?(sq)
    board.in_bounds?(sq) && board[sq].color != color
  end
end
