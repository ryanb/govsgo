# from https://groups.google.com/forum/?fromgroups=#!topic/rubyonrails-security/61bkgvnSGTQ
# and https://groups.google.com/forum/?fromgroups=#!topic/rubyonrails-security/1h2DR63ViGo

ActiveSupport::XmlMini::PARSING.delete("symbol")
ActiveSupport::XmlMini::PARSING.delete("yaml")
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::YAML)
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)
ActiveSupport::JSON.backend = "JSONGem"
