module Procman
  # Procman::App
  class App
    SHELL   = '/bin/bash --login -c'
    PROGRAM = 'foreman'
    ACTION  = 'export'

    def initialize(config)
      @config = config
    end

    def version
      puts Procman::VERSION
    end

    def export
      options = [PROGRAM, ACTION]
      options << management
      options << (option :procfile)
      options << (option :app) if @config[:app]
      options << (option :user)
      options << (option :root) if @config[:root]
      options << (option :port) if @config[:port]
      options << (option :template)

      execute(command options)
    end

    private

    def management
      case @config[:template]
      when 'upstart_rvm'
        'upstart /etc/init'
      else
        fail InvalidTemplate
      end
    end

    def option(option)
      case option
      when :template
        path = File.expand_path(File.dirname(__FILE__) + '../../..')
        format('--%s %s/templates/%s', option.to_s, path, @config[option])
      else
        format('--%s %s', option.to_s, @config[option])
      end
    end

    def command(options)
      format('%s "%s"', SHELL, options.join(' '))
    end

    def execute(command)
      `#{command}`
    end
  end
end
