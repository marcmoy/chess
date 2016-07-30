require_relative 'board'
require_relative 'display'
require_relative 'players'
require_relative 'computer'

class ChessGame

  def initialize(player1, player2)
    @board = Board.setup
    @display = Display.new(board)
    @player1 = player1
    @player2 = player2
    player1.display = @display
    player2.display = @display
    player1.color = :white
    player2.color = :black

    @players = [@player1, @player2]
  end

  def current_player
    players[0]
  end

  def play
    until board.checkmate?(current_player.color)
      begin
        move = current_player.play_turn
        board.move(current_player.color, *move)
      rescue InvalidMoveError
        puts "Invalid move."
        sleep(1)
        retry
      end

      players.rotate!
    end
    puts "Checkmate!"
  end

  attr_reader :board, :display
  attr_accessor :players
end

if __FILE__ == $PROGRAM_NAME
  player1 = HumanPlayer.new("Sam")
  player2 = ComputerAI.new("Marc")
  game = ChessGame.new(player1, player2)
  game.play
end

# SET UP FOR PRY TESTING

# def reload!
#    load 'board.rb'
#    load 'computer.rb'
#    load 'display.rb'
#    load 'board_tree_node'
# end
# reload!
# def render(board)
#   d = Display.new(board)
#   d.render
# end
# b = Board.setup
# qb.move!([7,1],[5,2])
# qrender(b)
# node = BoardTreeNode.new(b, :black)
