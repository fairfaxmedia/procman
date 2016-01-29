require 'mixlib/cli'

module Procman
  # Procman::Commandline
  class Commandline
    include Procman::Logger
    include Mixlib::CLI

    MISSING_ACTION    = 'Missing or invalid action.'
    MISSING_ARGUMENTS = 'Missing required arguments.'
    MISSING_PROCFILE  = 'Missing procfile argument.'
    INVALID_PROCFILE  = 'Invalid procfile.'

    # rubocop:disable Metrics/LineLength

    option :debug,
           long:        '--debug',
           description: 'Debug logging (default: false)',
           default: false

    option :procfile,
           short:       '-f PROCFILE',
           long:        '--file PROCFILE',
           description: 'Specify an alternate Procfile to load.'

    option :app,
           short:       '-a APP',
           long:        '--app APP',
           description: 'Name of the application. (default: directory name)'

    option :user,
           short:       '-u USER',
           long:        '--user USER',
           description: 'Specify the user the application should be run as. (default: www-data)',
           default:     'www-data'

    option :root,
           short:       '-r ROOT',
           long:        '--root ROOT',
           description: 'Specify an alternate application root. (default: Procfile directory)'

    option :port,
           short:       '-p PORT',
           long:        '--port PORT',
           description: 'Port to use as the base for this application. (default: 5000)'

    option :template,
           short:       '-t TEMPLATE',
           long:        '--template TEMPLATES',
           description: 'Specify an alternate template to use for creating export files. (default: upstart_rvm)',
           default:     'upstart_rvm'

    option :target_dir,
           short:       '-d TARGET_DIR',
           long:        '--dir TARGET_DIR',
           description: 'Target dir for creating upstart scripts. (default: /etc/init)',
           default:     '/etc/init'

    option :monitoring_file,
           short:       '-m MONITORING_FILE',
           long:        '--monitorout MONITORING_FILE',
           description: 'Change the file for exporting to a Monitoring YAML (Structure Fact) file.  (default: /etc/facter/facts.d/procman)',
           default:     ''
           # default:     '/etc/facter/facts.d/procman'   #TODO: Is this more-appropriate?

    option :monitoring_subst,
           short:       '-S MONITORING_COMMAND_SUBST',
           long:        '--monitoring_subst MONITORING_COMMAND_SUBST',
           description: 'A regexp for removing parts of each command-line for the Monitoring YAML file.  (default: bundle exec)',
           default:     'bundle exec'

    # rubocop:enable Metrics/LineLength

    def run
      parse
    end

    private

    def parse
      cli     = Procman::Commandline.new
      cli.parse_options
      cli.config.delete(:debug).tap do |v|
        ::Logging.logger.root.level = :debug if v
      end

      procman = Procman::App.new(cli.config)
      action = action cli.cli_arguments

      log.debug "Action = #{action.inspect}"
      case action
      when 'help'
        procman.help(cli)
      when 'version'
        procman.version
      when 'export'
        procman.export if validate(action, cli.config)
      else
        fail(ArgumentError, MISSING_ACTION)
      end
    rescue Procman::App::InvalidTemplate,
           ArgumentError,
           OptionParser::MissingArgument,
           OptionParser::InvalidOption => e
      puts procman.help(cli) if procman
      puts "ERROR: #{e.message}"
    end

    def action(array)
      array.select { |i| %w(help version export).include? i }.first
    end

    def validate(action, config)
      send(action, config) ? true : fail(ArgumentError, MISSING_ARGUMENTS)
    end

    def export(config)
      procfile = File.file? config[:procfile]
      procfile ? true :  fail(ArgumentError, INVALID_PROCFILE)
    rescue TypeError
      raise(ArgumentError, MISSING_PROCFILE)
    end
  end
end
