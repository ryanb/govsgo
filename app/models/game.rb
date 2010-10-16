class Game < ActiveRecord::Base
  attr_accessible :komi, :handicap, :board_size
end
