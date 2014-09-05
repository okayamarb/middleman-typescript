# Middleman::Typescript

middleman-typescript is an extension for the Middleman.

## Installation

Add this line to your application's Gemfile:

    gem 'middleman-typescript'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install middleman-typescript

## Configuration

    activate :typescript,
             typescript_dir: 'ts',  # default: 'typescripts'
             js_lib_dir: 'vendor',  # default: 'lib'
             target: 'ES3',         # default: 'ES5'
             no_implicit_any: false # default: true
    configure :development do
      ignore '.idea/*'              # for Intellij idea user
      ignore 'source/typescripts/*' # *.ts ignore LiveReload
      activate :livereload
    end
    
    configure :build do
      ignore 'typescripts/*'        # ignore copy *.ts to build dir
    end

Create typescripts directory under source directory. 
## Contributing

1. Fork it ( https://github.com/[my-github-username]/middleman-typescript/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
