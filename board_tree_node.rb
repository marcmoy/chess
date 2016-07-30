class BoardTreeNode

  attr_reader :board, :color, :parent, :children, :grandchildren, :avg_child_score, :prev_move

  def initialize(board, color, prev_move = nil, parent = nil)
    #color => if :white, it's :white's turn
    #prev_move = [start_pos, end_pos] format
    #parent = BoardTreeNode object
    @board = board
    @color = color
    @prev_move = prev_move
    @parent = parent
  end

  def enemy_color
    color == :white ? :black : :white
  end

  def children
    @children ||= find_children
  end

  def grandchildren
    @grandchildren ||= children.map do |child|
      child.children
    end.flatten
  end

  def find_children
    child_nodes = []
      board.pieces(color).each do |piece|
        start_pos = piece.pos
        piece.valid_moves.each do |end_pos|
          next_board = board.dup.move!(start_pos, end_pos)
          next_move = [start_pos, end_pos]

          child_nodes << BoardTreeNode.new(next_board, enemy_color, next_move, self)
        end
      end
    child_nodes
  end

  def score
    points = board.pieces(color).map(&:value).reduce(:+)
    enemy_points = board.pieces(enemy_color).map(&:value).reduce(:+)

    enemy_points - points
  end

  def avg_child_score
    num_of_chidren = children.size
    return 0 if num_of_chidren.zero?
    @avg_child_score ||= children.reduce(0){|sum,child| sum += child.score}/children.size
  end

  def best_child
    best_grandchildren.sample.parent
  end

  def best_move
    best_child.prev_move
  end

  def best_grandchild
    best_grandchildren.sample
  end

  def best_grandchildren
    return nil if grandchildren.empty?
    max = grandchildren.first.avg_child_score
    grandchildren.each do |grand_child|
      if grand_child.avg_child_score > max
        max = grand_child.avg_child_score
      end
    end

    grandchildren.select{|grand_child| grand_child.avg_child_score == max}
  end

end
