require 'logging'

module Procman
  module Logger
    def log
      @log ||= ::Logging.logger[self.class.to_s]
    end
  end
end

::Logging.logger.root.level = :info
::Logging.logger.root.add_appenders(::Logging.appenders.stderr)
