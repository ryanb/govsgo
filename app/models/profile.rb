class Profile
  attr_accessor :captured, :handicap_or_komi, :user, :color, :score, :last_status, :current

  def initialize(color)
    @color = color
  end

  def user_id
    user ? user.id : 0
  end
end
