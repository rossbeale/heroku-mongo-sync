# Heroku - Mongo Sync

This is a plugin for the Heroku command line, adding commands to sync your
local and production mongo databases.

It was tested and should just work with Mongolab or Mongo HQ. If you host your mongo db
somewhere else, just make sure you have access from your local machine.

## About this fork

Thanks to pedro for creating the plugin, and for bitzesty for improving it. This fork fixes all the deprecated warnings.

## Installation

    $ heroku plugins:install http://github.com/rossbeale/heroku-mongo-sync.git

## Usage

Get a copy of your production database with:

    $ heroku mongo:pull
	Please input local mongodb name: db
    Replacing the myapp db at localhost with genesis.mongohq.com
    Syncing users (4)... done
    Syncing permissions (4)... done
    Syncing plans (17)... done

Update your production database with:

    $ heroku mongo:push
	Please input local mongodb name: db
    THIS WILL REPLACE ALL DATA for app ON mongodb://blahblah WITH mongodb://localhost:27017/db
    Are you sure? (y/n) y
    Syncing users (4)... done
    Syncing permissions (4)... done
    Syncing plans (17)... done

As usual, in case you're not inside the app checkout you can specify the app
you want to pull/push to:

    $ heroku mongo:pull --app myapp-staging

If you're inside a checkout with multiple apps deployed, you can also specify
the one to pull/push to by the git remote:

    $ heroku mongo:pull --remote staging


## Notes

Created by Pedro Belo. 
Support for indexes, users and more added by Ben Wyrosdick.
Fixed up by Ross Beale.

Use at your own risk.
