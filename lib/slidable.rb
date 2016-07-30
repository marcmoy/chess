require 'byebug'

module Slidable
  DIFFS = {
    n: [-1, 0],
    s: [1, 0],
    e: [0, 1],
    w: [0, -1],
    nw: [-1, -1],
    ne: [-1, 1],
    sw: [1, -1],
    se: [1, 1]
  }


  def moves
    moves = []
    move_dirs.each { |dir| moves.concat(moves_by_dir(dir)) }
    moves
  end

  def moves_by_dir(dir)
    row, col = DIFFS[dir]
    current_pos = [@pos[0] + row, @pos[1] + col]
    moves = []

    while valid_move?(current_pos)
      moves << current_pos
      break if board[current_pos].color == enemy_color
      current_pos = [current_pos[0] + row, current_pos[1] + col]
    end

    moves
  end

  private

  def valid_move?(pos)
    board.in_bounds?(pos) && board[pos].color != color
  end

end
