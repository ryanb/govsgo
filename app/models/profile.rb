class Profile
  attr_accessor :captured, :handicap_or_komi, :user, :color, :score

  def initialize(color)
    @color = color
  end
  
  def name
    user ? user.username : "GNU Go"
  end
end
