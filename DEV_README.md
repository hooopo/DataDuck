# Helpful things to remember when developing

## Publishing to Rubygems

Ensure the version number is updated.

gem build dataduck.gemspec

gem push dataduck-VERSION.gem

## Requiring the local version of the Gem

Use something like this:

gem 'dataduck', '0.3.0', path: '/Users/jrp/projects/dataduck'