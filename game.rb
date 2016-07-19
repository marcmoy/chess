require_relative 'board'
require_relative 'display'
require_relative 'players'

class ChessGame

  def initialize(player1, player2)
    @board = Board.setup
    @display = Display.new(board)
    @player1 = HumanPlayer.new(player1, display, :white)
    @player2 = HumanPlayer.new(player2, display, :black)
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
  end

  private

  attr_reader :board, :display
  attr_accessor :players
end

if __FILE__ == $PROGRAM_NAME
  game = ChessGame.new("Sam", "Marc")
  game.play
end
