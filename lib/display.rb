require 'colorize'

require_relative 'board'
require_relative 'cursorable'

class Display
  include Cursorable
  CURSOR_COLOR = :blue
  SELECTED_COLOR = :red

  attr_reader :board, :cursor_pos, :selected_pos

  def initialize(board)
    @board = board
    @cursor_pos = [7,4]
    @selected_pos = nil
  end

  def move(new_pos)
    @cursor_pos = new_pos
  end

  def render
    system('clear')
    puts board.captured_pieces(:white).join(" ")
    puts "   a  b  c  d  e  f  g  h"
    0.upto(7) do |row|
      str_row = ""
      0.upto(7) do |col|
        color = ((row + col).odd? ? :light_white : :light_black)
        color = CURSOR_COLOR if cursor_pos == [row, col]
        color = SELECTED_COLOR if selected_pos == [row, col]
        piece_symbol = board[[row,col]].to_s
        str_row << " #{piece_symbol} ".colorize(:background => color)
      end
      puts "#{8 - row} #{str_row} "
    end
    puts board.captured_pieces(:black).join(" ")

  end

end
