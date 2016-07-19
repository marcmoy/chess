require 'colorize'

require_relative 'board'
require_relative 'cursorable'

class Display
  include Cursorable
  CURSOR_COLOR = :blue

  attr_reader :board, :cursor_pos, :selected

  def initialize(board)
    @board = board
    @cursor_pos = [7,4]
    @selected = false
  end

  def move(new_pos)
    @cursor_pos = new_pos
  end

  def render
    system('clear')
    puts "   0  1  2  3  4  5  6  7"
    0.upto(7) do |row|
      str_row = ""
      0.upto(7) do |col|
        color = ((row + col).odd? ? :light_black : :light_blue)
        color = CURSOR_COLOR if cursor_pos == [row, col]
        piece_symbol = board[[row,col]].to_s
        str_row << " #{piece_symbol} ".colorize(:background => color)
      end
      puts "#{row} #{str_row}"
    end
  end

end
