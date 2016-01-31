module Procman
  # Procman::App
  class App
    class InvalidTemplate < StandardError; end

    include Procman::Logger

    SHELL   = '/bin/bash --login -c'
    PROGRAM = 'foreman'
    ACTION  = 'export'

    def initialize(config)
      @config = config
      log.debug "Procman options = #{@config.inspect}"
     end

    def help(cli)
      puts 'Usage: procman [action] [options]'
      puts
      puts 'Actions:'
      puts '    help                             Show this message.'
      puts '    version                          Show version.'
      puts '    export                           Export the Procfile.'
      puts
      puts 'Options:'
      puts cli.opt_parser.to_a[1..-1].join
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

      log.debug "Foreman options = #{options.inspect}"

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
      log.debug "Running #{command.inspect}"
      system(command)
    end
  end
end
