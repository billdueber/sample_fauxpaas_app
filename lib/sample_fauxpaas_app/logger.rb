require 'semantic_logger'
require 'pathname'
require_relative 'config'

module SampleFauxpaasApp


  module Logger

    class LocalFormatter < SemanticLogger::Formatters::Color
      def process_info
        nil
      end
    end


    FORMATTER = LocalFormatter.new(time_format: "%Y-%m-%d:%H:%M:%S")
    SemanticLogger.add_appender(io: STDERR, level: :info, formatter: FORMATTER)
    SemanticLogger.add_appender(io: File.open(SampleFauxpaasApp::Config.app_root + 'log' + 'commands.log', 'a:utf-8'), level: :info, formatter: FORMATTER)
    LOGGER = SemanticLogger['SampleFauxpaasApp']

    def logger
      if defined? Rails
        Rails.application.config.rails_semantic_logger
      else
        LOGGER
      end
    end
  end
end
