# Procman

Procman installs and configures the Foreman Procfile. It also add support for RVM in the Upstart config files.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'procman'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install procman

## Usage

To use Procman you need to have an application with a Procfile in the applications root directory. Some valid Procfile examples.

    unicorn:   bundle exec unicorn --listen /tmp/unicorn-app.sock
    puma:      bundle exec puma --port 8080
    passenger: bundle exec passenger start --port 8080
    rake:      bundle exec rake task

The commandline structure.

    Usage: procman [action] [options]

    Actions:
        help                             Show this message.
        version                          Show version.
        export                           Export the Procfile.

    Options:
        -a, --app APP                    Name of the application. (default: directory name)
            --debug                      Debug logging (default: false)
            --monitoring_out MONITORING_FILE
                                         Change the file for exporting to a Monitoring YAML (Structure Fact) file.
        -p, --port PORT                  Port to use as the base for this application. (default: 5000)
        -f, --file PROCFILE              Specify an alternate Procfile to load.
        -m PROCFILE_MONITORING,          Specify an alternate Procfile monitoring config to load.
            --monitoring_file
        -r, --root ROOT                  Specify an alternate application root. (default: Procfile directory)
        -d, --dir TARGET_DIR             Target dir for creating upstart scripts. (default: /etc/init)
        -t, --template TEMPLATES         Specify an alternate template to use for creating export files. (default: upstart_rvm)
        -u, --user USER                  Specify the user the application should be run as. (default: www-data)

Example usage.

    sudo -i procman export --file /var/www/example/Procfile --app example --user www-data

    sudo -i procman export --file /var/www/example/Procfile --app example --user www-data --monitoring_file /var/www/example/Procfile.mon

On some systems you may need to start the service.

    sudo start example

It is important to note that Procman writes files to /etc/init which requires root access. An interactive shell is required so the RVM environment is available.

## Procfile Monitoring

It's quite likely that you'll want to add monitoring/alerts for the processes that Foreman creates.
To this end, if a `MONITORING_FILE` is provided, a YAML file will be written to that location with a
list of processes that Foreman will start, e.g `files/Procfile`:

    ---
    delayed-job: bundle exec rake jobs:work
    event-forwarder: /usr/local/bin/beanstalkd -b /var/cache/beanstalkd -u www-data
    dir-watcher: ruby /usr/local/bin/dir-watcher

... will produce in `/etc/facter/facts.d/procman` (by default):

    ---
    procman-monitors:
    - bundle exec rake jobs:work
    - /usr/local/bin/beanstalkd -b /var/cache/beanstalkd -u www-data
    - ruby /usr/local/bin/dir-watcher

The assumption here is that you're using Puppet's Facter (and Structured Data files) to manage your
monitoring.

Since that may not be appropriate -- e.g. `bundle exec` replaces the bundle process with a Ruby/rake
one, so you won't find `bundle` nor `exec` in the process tree -- then you can also provide a monitoring
file that will be used to provide "substituted" processes for any matching keys, e.g. adding
`--monitoring_file files/Procfile.mon` with the following contents:

    ---
    delayed-job: rails rake jobs:work
    event-forwarder: beanstalkd

... will produce in `/etc/facter/facts.d/procman`:

    ---
    procman-monitors:
    - rails rake jobs:work
    - beanstalkd
    - ruby /usr/local/bin/dir-watcher

... which can be read by Puppet modules (et al) to produce valid process-monitoring config's.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/fairfaxmedia/procman/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
