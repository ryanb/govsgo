class Profile
  attr_accessor :captured, :handicap_or_komi, :user, :color, :score, :last_status

  def initialize(color)
    @color = color
  end

  def name
    if user
      user.guest? ? "Guest" : user.name_with_rank
    else
      "GNU Go"
    end
  end

  def user_id
    user ? user.id : 0
  end
end
