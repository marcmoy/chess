require_relative 'board_tree_node'

class ComputerAI

  attr_reader :name, :display
  attr_accessor :color, :board

  def initialize(name = "AI")
    @name = name
  end

  def display=(display)
    @display = display
    @board = display.board
  end

  def play_turn
    display.render
    puts "Computer #{name} is thinking..."
    sleep(1)
    best_move
  end

  # def pieces_with_valid_moves
  #   board.pieces(color).reject { |piece| piece.valid_moves.empty? }
  # end
  #
  # def random_move
  #   random_piece = pieces_with_valid_moves.sample
  #   start_pos = random_piece.pos
  #   end_pos = random_piece.valid_moves.sample
  #
  #   [start_pos, end_pos]
  # end

  def enemy_color
    color == :white ? :black : :white
  end

  def best_move
    node = BoardTreeNode.new(board, color)
    node.best_move
  end

end
