require "ettin"

module SampleFauxpaasApp
  class ConfigSetup

    attr_reader :loaded_config
    def initialize(env)
      return @config unless @config.nil?
      env     ||= if defined? Rails
                  Rails.env
                elsif %w[production development test].include? ENV['RAILS_ENV']
                  ENV['RAILS_ENV']
                else
                  "development"
                end
      @loaded_config = load_config(env)
      @loaded_config['app_root'] = Pathname.new(__dir__).parent.parent
    end

    def load_config(env)
      config_dir = Pathname.new(__dir__).parent.parent + 'config'
      Ettin.for(Ettin.settings_files(config_dir, env))
    end

    def reload_config(env)
      @loaded_config = load_config(env)
    end

    def self.config(env = nil)
      @instance ||= self.new(env)
      @instance.loaded_config
    end
  end

  def self.reload_config!(env = nil)
    const_set(:Config, ConfigSetup.new(env).loaded_config)
  end

  # eager load
  self.reload_config!
end
