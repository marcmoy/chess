require 'byebug'

class BoardTreeNode

  attr_reader :board, :color, :parent, :children, :num_of_chidren, :prev_move

  def initialize(board, color, prev_move = nil, parent = nil)
    #color => if :white, it's :white's turn
    #prev_move = [start_pos, end_pos] format
    #parent = BoardTreeNode object
    @board = board
    @color = color
    @prev_move = prev_move
    @parent = parent
  end

  def best_move
    return nil if num_of_chidren == 0
    best_children.sample.prev_move
  end

  def num_of_chidren
    @num_of_chidren ||= children.size
  end

  def children
    @children ||= find_children
  end

  def find_children
    child_nodes = []
      self.board.pieces(color).each do |piece|
        start_pos = piece.pos
        piece.valid_moves.each do |end_pos|
          next_board = board.dup.move!(start_pos, end_pos)
          next_move = [start_pos, end_pos]

          child_nodes << BoardTreeNode.new(next_board, enemy_color, next_move, self)
        end
      end
    child_nodes
  end

  def best_children
    #best children includes children with the 'best' worst_child_score
    return nil if num_of_chidren == 0

    best_worst_child_score = self.children.first.worst_child_score
    self.children[1..-1].each do |child|
      if child.worst_child_score > best_worst_child_score
        best_worst_child_score = child.worst_child_score
      end
    end

    best_childs = []
    self.children.each do |child|
      return [child] if child.winning_node?
        if child.worst_child_score == best_worst_child_score
          best_childs << child
        end
    end
    best_childs
  end

  def winning_node?
    self.board.checkmate?(color)
  end

  def worst_child_score
    return -200 if self.children.empty?
    #if there are no children, then are there are no valid_moves
    #if there are no valid_moves, then the only moves left lead to checkmate
    #checkmates result in a board with -200 or less because king will be gone.
    worst_score = self.children.first.score
    self.children.each do |child|
      if child.score < worst_score
        worst_score = child.score
      end
    end
    worst_score
  end

  def score
    points = board.pieces(color).map(&:value).reduce(:+)
    enemy_points = board.pieces(enemy_color).map(&:value).reduce(:+)

    points - enemy_points
  end

  def enemy_color
    color == :white ? :black : :white
  end

  # def grandchildren
  #   @grandchildren ||= children.map do |child|
  #     child.children
  #   end.flatten
  # end
  #
  # def avg_child_score
  #   return 0 if num_of_chidren.zero?
  #   @avg_child_score ||= children.reduce(0){|sum,child| sum += child.score}/children.size
  # end
  #
  # def best_grandchild
  #   best_grandchildren.sample
  # end
  #
  # def best_grandchildren
  #   return nil if grandchildren.empty?
  #   max = grandchildren.first.avg_child_score
  #   grandchildren.each do |grand_child|
  #     if grand_child.avg_child_score > max
  #       max = grand_child.avg_child_score
  #     end
  #   end
  #
  #   grandchildren.select{|grand_child| grand_child.avg_child_score == max}
  # end

end
