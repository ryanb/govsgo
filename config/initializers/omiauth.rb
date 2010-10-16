require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, PRIVATE_CONFIG["twitter_key"], PRIVATE_CONFIG["twitter_secret"]
  provider :open_id, OpenID::Store::Filesystem.new('/tmp')
end
