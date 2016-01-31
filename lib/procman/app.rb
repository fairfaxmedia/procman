require 'yaml'

module Procman
  # Procman::App
  class App
    class InvalidTemplate < StandardError; end

    include Procman::Logger

    SHELL   = '/bin/bash --login -c'
    PROGRAM = 'foreman'
    ACTION  = 'export'

    def initialize(config)
      log.debug "Procman options = #{config.inspect}"

      @config = config
      @target_dir = @monitoring_facter_file = @monitoring_subst = nil

      @config.delete(:target_dir).tap {|v| @target_dir = v if v && !v.empty? }
      @config.delete(:monitoring_facter_file).tap {|v| @monitoring_facter_file = v if v && !v.empty? }
      @config.delete(:monitoring_subst).tap {|v| @monitoring_subst = Regexp.new(v) if v && !v.empty? }

      fail(ArgumentError, "No $TARGET_DIR provided") unless @target_dir
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

      export_monitoring
    end

    private

    def management
      case @config[:template]
      when 'upstart_rvm'
        "upstart #{@target_dir}"
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

    # Build a YAML file suitable for updating Icinga monitoring from
    # E.g. Facter facts --> Icinga monitors
    def export_monitoring
      procfile = @config[:procfile]
      return unless @monitoring_file && procfile

      procs = export_monitoring_subst(YAML.load_file(procfile), @monitoring_subst)
      open(@monitoring_file, 'w') {|f| YAML.dump(procs, f) }
    end

    # Some types of commands can't be monitored, as they spawn the "real" command (e.g. `bundle exec`)
    # We need to clean these out of our command list:
    def export_monitoring_subst(procs, subst)
      procs.each.with_object({}) do |(name, command), obj|
        # TODO: Does Facter let me use `-` in a name?
        obj.merge!("procman-#{name}" => command.gsub(subst, ''))
      end
    end
  end
end
