# 101companies-wiki

[![](https://codeclimate.com/github/101companies/101rails.png)](https://codeclimate.com/github/101companies/101rails) [![Dependency Status](http://www.versioneye.com/user/projects/51b5a94f83548c000200dda1/badge.png)](http://www.versioneye.com/user/projects/51b5a94f83548c000200dda1)

101wiki web app written using Ruby on Rails and Backbone.js

## Software dependencies

Before starting work with the application, you need to install such dependencies, if you are using Ubuntu:

    apt-get install curl nodejs build-essential libxslt-dev libxml2-dev mongodb zlib1g-dev libreadline-dev libssl-dev libcurl4-openssl-dev

For OSX there are such dependencies, that can be installed via [homebrew](http://brew.sh/):

    brew install mongodb node

apt:

    apt-get install mongodb mongodb-tools

## Ruby

With OSX you already have Ruby (e.g. 2.0.0p247 for Mavericks).

If you are using Ubuntu you can install ruby via [rvm](http://rvm.io) or [rbenv](https://github.com/sstephenson/rbenv/).

This app was tested with ruby 2.2.1.

## Installing the app

At first you need to install **bundler** gem.

    gem install bundler

Now you need go to the project folder und install app:

    bundle install

You need a mongodb dump which must be acquired from the 101companies admins.
If you have a dump load it like this:

    mongorestore --directoryperdb dump/wiki_development --drop

If you have troubles with installing gem on OSX and have error:

     clang: error: unknown argument: '-multiply_definedsuppress' [-Wunused-command-line-argument-hard-error-in-future]

After installing mongodb you need to start it and then launch application with:

    bundle exec rails s

## Admin rights

To be signed in you need to have GitHub account with **name** and **public email** in GitHub profile.

![](app/assets/images/readme_profile.png)

If you have been successfully signed in, you can set another role to your user:

    bundle exec rake change_role

You will be asked for your email and new role. Just type email from your GitHub account and role **admin**.

## Keys

You need some keys of 101companies before you can start to work.
You can ask [@avaranovich](https://github.com/avaranovich), [@rlaemmel](https://github.com/rlaemmel) or
[@tschmorleiz](https://github.com/tschmorleiz) for this password.

For successful work with project in development mode you need to define next ENV variables in your .bashrc/.zshrc

    export SLIDESHARE_API_KEY=""
    export SLIDESHARE_API_SECRET=""
    export GMAIL_PASSWORD=""
    export GITHUB_KEY_DEV=""
    export GITHUB_SECRET_DEV=""
    export MONGODB_USER=""
    export MONGODB_PWD=""

## Populating db

You need to execute this task:

    bundle exec rake import_production_db_to_local_dev_db

## Contributing

If you make improvements to this application, please share with others.

*   Fork the project on GitHub.
*   Make your feature addition or bug fix.
*   Commit with Git.
*   Send a pull request.

If you add functionality to this application, create an alternative implementation, or build an application that is similar, please contact me and I’ll add a note to the README so that others can find your work.
