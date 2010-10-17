class Profile
  attr_accessor :captured, :handicap_or_komi, :user, :color, :score

  def initialize(color)
    @color = color
  end
  
  def name
    if user?
      user.guest? ? "Guest" : user.username
    else
      "GNU Go"
    end
  end
end
