require 'mixlib/cli'

module Procman
  # Procman::Commandline
  class Commandline
    include Mixlib::CLI

    # rubocop:disable Metrics/LineLength

    option :help,
           short:        '-h',
           long:         '--help',
           description:  'Show this message',
           on:           :tail,
           boolean:      true,
           show_options: true,
           exit:         0

    option :procfile,
           short:       '-f PROCFILE',
           long:        '--file PROCFILE',
           description: 'Specify an alternate Procfile to load.'

    option :app,
           short:       '-a APP',
           long:        '--app APP',
           description: 'Name of the application.'

    option :user,
           short:       '-u USER',
           long:        '--user USER',
           description: 'Specify the user the application should be run as.',
           default:     'www-data'

    option :root,
           short:       '-r ROOT',
           long:        '--root ROOT',
           description: 'Specify an alternate application root.'

    option :port,
           short:       '-p PORT',
           long:        '--port PORT',
           description: 'Port to use as the base for this application.'

    option :template,
           short:       '-t TEMPLATE',
           long:        '--template TEMPLATES',
           description: 'Specify an alternate template to use for creating export files.',
           default:     'upstart_rvm'

    # rubocop:enable Metrics/LineLength

    def run
      parse
    end

    private

    def parse
      cli = Procman::Commandline.new
      cli.parse_options

      procman = Procman::App.new(cli.config)

      case (action = action cli.cli_arguments)
      when 'version'
        procman.version
      when 'export'
        procman.export if validate(action, cli.config)
      else
        puts 'Missing action.'
        puts cli.banner
      end
    rescue ArgumentError, OptionParser::MissingArgument, OptionParser::InvalidOption => e
      puts e.message
    end

    def action(array)
      array.select { |i| %w(version export).include? i }.first
    end

    def validate(action, config)
      send(action, config) ? true : fail(ArgumentError, 'Missing required arguments.')
    end

    def export(config)
      procfile = File.file? config[:procfile]
      procfile ? true :  fail(ArgumentError, 'Invalid procfile.')
    rescue TypeError
      raise(ArgumentError, 'Missing profile argument.')
    end
  end
end
