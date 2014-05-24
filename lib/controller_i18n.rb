module ControllerI18n
  def self.included(controller)
    controller.send :before_filter, :set_locale
  end
  
  private
  def set_locale
    I18n.locale = cookies[:locale] || setup_cookies_locale
  end

  def change_locale
    cookies[:locale] = current_user.locale if logged_in? && current_user.locale.present?
  end

  def setup_cookies_locale
    if logged_in?
      current_user.update_attribute(:locale, extract_locale_from_accept_language_header) if current_user.locale.blank?
      cookies[:locale] = current_user.locale
    else
      cookies[:locale] = extract_locale_from_accept_language_header
    end
  end

  def extract_locale_from_accept_language_header
    if lang = request.accept_language
      locale = lang.split(",").first.downcase.to_sym
    else
      locale = nil
    end
    I18n.available_locales.include?(locale) ? locale : I18n.default_locale
  end
end
