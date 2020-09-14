# Splickit Web II

## Getting Up & Running

### 1. Obtain the Repo

    git clone git@github.com:splickit-inc/Splickit-web-2.git

### 2. Install RVM or similar to use ruby 2.1.2

Install the version of ruby listed in `Gemfile` and `.rbenv`. Currenlty, this version is 2.1.2.

It is recommended to use a ruby version manager. I use [RVM](https://rvm.io). To get started with RVM:

    curl -sSL https://get.rvm.io | bash -s stable
    rvm install 2.1.2

### 3. Bundle

    bundle
    
#### Some words about Nokogiri

If you are running Mac OS X and the installation of Nokogiri fails, try these steps:

    brew unlink gcc-4.2      # you might not need this step
    gem uninstall nokogiri
    xcode-select --install
    gem install nokogiri
    
For more help installing Nokogiri, visit the [Nokogiri installation tutorial](http://www.nokogiri.org/tutorials/installing_nokogiri.html).


### 4. Install Redis

    brew install redis

You can also run it manually with redis-server

*Note: `foreman start` will run redis by default*

### 5. Add necessary files

#### Add Secrets / ENV

Get an up to date copy of `config/secrets.yml` and `.env` from someone around you.

You can use 'config/secrets.yml.example' and '.env.example' as starting points, and get the specific values from another developer or from Tarek.

#### Touch log files

It seems silly, but foreman is going to crash if the log files are not present. Create them by doing something like this:

    touch log/development.log
    touch log/test.log

### 6. Foreman

To start the application, run `foreman`:

    foreman start

the app can be viewed at localhost:3000

## Testing

Ensure that the local server is running:

    foreman start

For rspec and capybara:

    foreman run rspec

For Jasmine:

    localhost:8888

## Deployment

### "Development"

To deploy to <http://splickit-dev.com/>, you will need to: configure your ssh
authorizations by connecting to `10.210.194.192` with the proper login and
password. This information may be obtained by asking someone around you.

Once that is complete, run from the project directory:

    cap staging deploy

      or with optional branch

    cap staging deploy branch=[branch name]
    
### "User Acceptance"

This is used to deploy to one of the skin specific user acceptance servers.
These servers are dynamically created and allocated as customers need.

    cap uat deploy skin=[skin name]

    A skin name of 'all' will deploy to all uat servers

#### Log Location

    /usr/local/ordernow/httpd/htdocs/splickitweb/current/log/staging.log

## Brand Images

### Photo Updater Script

This script pulls data from S3 about the specified brand, and populates the **Photos**
table in SMAW with the correct image URL(s). Default images are inserted where required.

#### Usage

Default ENV is set to update the SMAW test database.

    thor photos:update <skin_name> <env>

## Theme a Brand

### 1. Configure SASS overrides

Add merchant specific styling config in:

    config/themes.yml

### 2. Generate CSS

Via the rake task:

    rake themes:generate

### 3. Deploy CSS to CDN

    rake themes:upload

To upload to a specific ENV:

    rake themes:upload\[staging\]

## Clearing Cache

Basic auth required, ask a dev. The `--insecure` flag is required for ENVs
without a valid SSL certificate chain. If using `curl`, the `--verbose` flag
may be of great assistance.

### Merchant

    /cache/clear_merchant/<merchant-id>

Example:

    curl --user <username>:<password> --insecure -X POST https://pitapit.splickit-dev.com/cache/clear_merchant/1082

### Merchants

    /cache/clear_merchants

Accepts optional skin name:

    /cache/clear_merchants?skin=<skin-name>

Example:

    curl --user <username>:<password> --insecure -X POST https://pitapit.splickit-dev.com/cache/clear_merchants

All merchants are defined in `config/skins.yml`.

### Skin

    /cache/clear_skin?skin=<skin-name>

Example:

    curl --user <username>:<password> --insecure -X POST https://pitapit.splickit-dev.com/cache/clear_skin?skin=<skin-name>

### Warming

Warm all cache (skin, merchant: API & views):

    /cache/warm

Example:

    curl --user <username>:<password> --insecure -X POST https://pitapit.splickit-dev.com/cache/warm

Accepts optional skin name:

    /cache/warm?skin=<skin-name>
