module ApplicationHelper
  def online_status(user)
    content_tag(:span, raw("&bull;"), :class => (user.online? ? "user_online" : "user_offline")) if user
  end

  def div_hidden_if(condition, options, &block)
    options[:style] = "#{options[:style]}display:none;" if condition
    content_tag(:div, options, &block)
  end
end
