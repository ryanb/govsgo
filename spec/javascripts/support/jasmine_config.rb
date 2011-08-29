module Jasmine
  class Config

    # Add your overrides or custom config code here

  end
end


# Note - this is necessary for rspec2, which has removed the backtrace
module Jasmine
  class SpecBuilder
    def declare_spec(parent, spec)
      me = self
      example_name = spec["name"]
      @spec_ids << spec["id"]
      backtrace = @example_locations[parent.description + " " + example_name]
      parent.it example_name, {} do
        me.report_spec(spec["id"])
      end
    end
  end
end

# for CoffeeScript support in specs
# commenting out because it seems jasmine-headless-webkit has better coffeescript support already
# require 'barista'
# require 'logger'
# 
# require File.join(Rails.root, 'config/initializers/barista_config')
# Barista.configure do |c|
#   c.env = 'test'
#   c.logger = Logger.new(STDOUT)
#   c.logger.level = Logger::INFO
#   c.before_compilation do |path|
#     relative_path = Pathname(path).relative_path_from(Rails.root)
#     c.logger.info "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] Barista: Compiling #{relative_path}"
#   end
# end
# Barista.setup_defaults
# 
# module Jasmine
#   def self.app(config)
#     Barista::Framework.register 'jasmine', config.spec_dir
#     Barista::Framework['jasmine'].instance_variable_set('@output_root', Pathname(config.spec_dir).join('compiled'))
# 
#     Rack::Builder.app do
#       use Rack::Head
# 
#       map('/run.html')         { run Jasmine::Redirect.new('/') }
#       map('/__suite__')        { run Barista::Filter.new(Jasmine::FocusedSuite.new(config)) }
# 
#       map('/__JASMINE_ROOT__') { run Rack::File.new(Jasmine.root) }
#       map(config.spec_path)    { run Rack::File.new(config.spec_dir) }
#       map(config.root_path)    { run Rack::File.new(config.project_root) }
# 
#       map('/favicon.ico')      { run Rack::File.new(File.join(Rails.root, 'public')) }
# 
#       map('/') do
#         run Rack::Cascade.new([
#           Rack::URLMap.new('/' => Rack::File.new(config.src_dir)),
#           Barista::Filter.new(Jasmine::RunAdapter.new(config))
#         ])
#       end
#     end
#   end
# end