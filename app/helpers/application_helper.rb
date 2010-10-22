module ApplicationHelper
  def online_status(user)
    content_tag(:span, raw("&bull;"), :class => (user.online? ? "user_online" : "user_offline")) if user
  end
end
