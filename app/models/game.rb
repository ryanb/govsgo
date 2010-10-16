class Game < ActiveRecord::Base
  attr_accessible :komi, :handicap, :board_size, :chosen_color
  attr_accessor :chosen_color, :creator
end
