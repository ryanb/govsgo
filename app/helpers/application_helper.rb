module ApplicationHelper
  def online_status(user)
    content_tag(:span, raw("&bull;"), :class => (user.online? ? "user_online" : "user_offline")) if user
  end

  def div_hidden_if(condition, options, &block)
    options[:style] = "#{options[:style]}display:none;" if condition
    content_tag(:div, options, &block)
  end

  def avatar_image_tag(user)
    content_tag(:div, :class => "avatar") do
      link_to image_tag(avatar_url(user)), user
    end
  end

  def avatar_url(user)
    if user.nil?
      "avatars/gnugo.png"
    elsif user.avatar_url.present?
      user.avatar_url
    elsif user.email.present?
      default_url = request.protocol + request.host_with_port + "/images/avatars/guest.png"
      "http://gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email.downcase)}.png?s=48&d=#{CGI.escape(default_url)}"
    else
      "avatars/guest.png"
    end
  end

  def link_to_user(user)
    if user
      user.guest? ? "Guest" : link_to(user.name_with_rank, user, :class => "subtle")
    else
      "GNU Go"
    end
  end

  def relative_time(time)
    [relative_date(time.to_date), time.strftime("%I:%M %p")].compact.join(" ")
  end

  def relative_date(date)
    today = Time.zone.now.to_date
    if date == today
      nil
    elsif date == today-1
      "yesterday"
    elsif date.year == today.year
      date.strftime("%b %d")
    else
      date.strftime("%b %d, %Y")
    end
  end
end
