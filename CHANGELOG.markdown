# Changelog

All notable changes to this project (at least, from v0.4.0 onwards) are documented in this file.

## 2.0.0 - 2018-04-10

### Added

* Add support for Manticore (via `engine` setting in config/thinking_sphinx.yml).
* Using Thinking Sphinx v4's new task/command architecture, and so all the ts rake tasks perform the appropriate behaviour on Flying Sphinx.

### Changed

* Dropped support for Thinking Sphinx 3.x or older.
* Dropped support for ActiveRecord/Rails 3.1 or older.
* Dropped support for Ruby 2.1 or older.

### Deprecated

* The fs tasks and the flying-sphinx CLI tool are deprecated and will be removed in a future release. Please use the standard Thinking Sphinx ts rake tasks instead.

## 1.3.1 - 2017-12-04

### Fixed

* Fix call to generate real-time data for thinking-sphinx v3.4+.

## 1.3.0 - 2017-12-04

### Changed

* Using v5 of the flying-sphinx.com API.
* Dropping support for Ruby 1.8.7 and REE.
* Be clear about the reliance on thinking-sphinx v1.5 or better.

## 1.2.1 - 2017-09-29

### Changed

* Remove post-install message.
* Relax Faraday requirement to allow for v0.7.
* Improved behaviour with Ruby 1.8.7.

### Fixed

* Fix population of real-time indices for thinking-sphinx v3.4+.

## 1.2.0 - 2014-03-30

### Changed

* All configuration files (Sphinx, wordforms, exceptions, etc) are now gzipped when sent to the API.

## 1.1.0 - 2014-03-15

### Added

* Added remote rotate support via custom controller.
* Added regenerate command (for when real-time indices are being used).

### Changed

* Updated Faraday dependency to require 0.9 or newer (and removed faraday_middleware dependency).
* Removed the requirement of Rashie.

## 1.0.0 - 2013-05-07

### Changed

* Updating Riddle dependency to >= 1.5.6.
* Support for Thinking Sphinx v1/2/3.
* Delayed Job support pushed back to ts-delayed-delta.
* Updating MultiJson dependency to ensure MultiJson.load is always available.
* All actions are now tracked through Pusher, instead of polling or using slow HTTP requests.

## 0.8.5 - 2012-12-10

### Changed

* Daemon actions (start/stop) are now asynchronous.
* More forgiving when environment variables aren't around. Particularly helpful for Padrino and Sinatra.
* Make delta indexing jobs asynchronous - no need to wait for the result. Also, with the different URL, flying-sphinx.com will not queue up duplicate delta jobs within the last 20 minutes if there's a indexing job still pending.

## 0.8.4 - 2012-09-22

### Fixed

* Load the Delta class when loading Rails.

## 0.8.3 - 2012-09-17

### Changed

* Requires Rails 3 or better (if you're using Rails).
* Load Rails when configuring.
* Don't check whether a document exists before marking it as deleted - Sphinx handles this gracefully anyway.

## 0.8.2 - 2012-08-28

### Changed

* Don't presume there is a Time.zone method (for Rails 2.3).
* Set client key as part of the configuration generation process (for Rails 2.3).

## 0.8.1 - 2012-08-28

### Changed

* Load Thinking Sphinx when sending a generated configuration (as opposed to a hand-written file).
* Rebuild command now sends the new configuration up, as before.

## 0.8.0 - 2012-08-25

### Added

* Adding a 'flying-sphinx' executable to match Python and Node.js clients.

### Removed

* Removing support for accessing Heroku's shared databases through an SSH tunnel.

## 0.7.0 - 2012-07-16

### Changed

* Print the indexing log.
* Distinguish between search server and SSH/indexing server, which allows for load balancers as the former.
* Send the gem version through as a header on API calls.
* Let flying-sphinx.com wrangle the Sphinx configuration.
* Use v3 of the flying-sphinx.com API

## 0.6.6 - 2012-07-14

### Changed

* Don't complain about 201s for starting/stopping Sphinx.
* Relaxing the faraday_middleware dependency to allow 0.8 releases (Matthew Zikherman).

## 0.6.5 - 2012-05-03

### Changed

* Relaxing the multi_json dependency to allow for higher versions.
* Support for staging.flying-sphinx.com.

## 0.6.4 - 2012-03-03

### Fixed

* Fix for Rails 2 with API verbose logging.

## 0.6.3 - 2012-03-01

### Added

* Allow direct database access when FLYING_SPHINX_INGRESS is set.

### Changed

* Slow down polling for direct indexing from every 1 second to every 3 seconds.
* Verbose logging now has timestamps.
* Use dups of ENV variables so the values can be modified.
* Report if Sphinx wasn't able to start.
* Load Flying Sphinx when ENV['FLYING_SPHINX_IDENTIFIER'] exists, instead of for any Rails environment that isn't development or test.

## 0.6.2 - 2012-01-02

### Changed

* Pass Sphinx version through to Flying Sphinx servers.

## 0.6.1 - 2011-11-04

### Changed

* Adding Riddle dependency requirement.
* Updating indexes (index plural) references to indices.
* Updating faraday_middleware version requirement, to play nicely with OmniAuth (Paolo Perrotta)

## 0.6.0 - 2011-07-31

### Added

* Support for all file-based Sphinx settings: stopwords, wordforms, exceptions, and mysql ssl settings for SQL sources.

### Changed

* Version in a separate file.

## 0.5.2 - 2011-07-28

### Added

* This history file now exists (pre-populated).
* An actual README, courtesy of some prodding by Mislav.
* Added support for wordforms (automatically sent through to the server).

### Changed

* Log SSH exceptions during indexing (when we're being verbose).
* Don't presume that ENV['DATABASE_URL'] exists - it won't in non-Heroku environments.

## 0.5.1 - 2011-06-23

### Added

* Adding rake as a development dependency, just for Travis CI.
* Sinatra loader (equivalent of a Railtie).

### Changed

* Have a default database port - Cedar stack doesn't set it by default.
* Allow for newer net-ssh gem versions (including 2.1).

### Fixed

* Fixed bug for handling JSON always as a Hash (sometimes it's an Array).
* Better error checking when index requests don't get created as expected.

## 0.5.0 - 2011-05-12

### Added

* Rake tasks for latest actions and last index log.
* Adding default rake task for Travis CI.
* Allow server to automatically close SSH connections.
* Adding logging on API calls (Josh Kalderimis).
* Allow for non-tunnelled index requests (for RDS).

### Changed

* Switching to version 2 of the API.
* Allow for Rails 2 versions of Delayed Job.
* Set client_key for connections, configuration if supported by Riddle and Thinking Sphinx.
* Don't use custom database adapter if the database is MySQL.
* Fall back to environment variables for connection settings.
* Switching from JSON and HTTParty to MultiJSON and Faraday (Josh Kalderimis).
* Using Bundler as gem driver instead of Jeweler (Josh Kalderimis).
* More flexible JSON dependency.

## 0.4.4 - 2011-02-07

### Changed

* Using ActiveRecord's connection information, as we can't rely on heroku_env.yml to be around.

## 0.4.3 - 2011-02-04

### Changed

* Wait until the SSH session and forward is prepared before making the index request.
* If credentials are invalid, raise an appropriate error instead of letting the JSON parsing fail.

## 0.4.2 - 2011-01-29

### Changed

* Set the Thinking Sphinx database adapter when loaded, instead of requiring the Rails dispatcher to setup.

## 0.4.1 - 2011-01-24

### Changed

* Comparing against response bodies for consistency (and avoiding HTTParty magic).

## 0.4.0 - 2011-01-18

### Changed

* Using HTTPS for API calls.
* Using Flying Sphinx server's account identifier instead of the heroku id from the environment (the latter being unreliable and not part of any official Heroku add-on documentation).

Note: Any releases before this were most definitely experimental and pre-alpha.
