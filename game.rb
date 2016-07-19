require_relative 'board'
require_relative 'display'
require_relative 'players'

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

  private

  attr_reader :board, :display
  attr_accessor :players
end

if __FILE__ == $PROGRAM_NAME
  player1 = HumanPlayer.new("Sam")
  player2 = Level3ComputerPlayer.new("Marc")
  game = ChessGame.new(player1, player2)
  game.play
end
