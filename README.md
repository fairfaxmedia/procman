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
        -p, --port PORT                  Port to use as the base for this application. (default: 5000)
        -f, --file PROCFILE              Specify an alternate Procfile to load.
        -r, --root ROOT                  Specify an alternate application root. (default: Procfile directory)
        -t, --template TEMPLATES         Specify an alternate template to use for creating export files. (default: upstart_rvm)
        -u, --user USER                  Specify the user the application should be run as. (default: www-data)

Example usage.

    sudo -i procman export --file /var/www/example/Procfile --app example --user www-data

On some systems you may need to start the service.

    sudo start example

It is important to note that Procman writes files to /etc/init which requires root access. An interactive shell is required so the RVM environment is available.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/fairfaxmedia/procman/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
