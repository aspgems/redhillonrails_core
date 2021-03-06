# Information for developers

We need to run it against multiple versions of rails. There are
several tools already available to manage running against multiple versions of
Ruby (e.g. rvm), and there are even some multi-rails tools (e.g. multi-rails)
but we haven't found one that does exactly what we need here, so we've rolled
our own.

This method is the same used in rspec-rails

## The short version

thor gemfile:use 3.0.6
rake

## The long version

### thor gemfile:use

The `thor rails:use` task accepts any released version of rails, or either the
3-0-stable or master branches.

    thor gemfile:use master
    thor gemfile:use 3.1.0.rc1
    thor gemfile:use 3-0-stable
    thor gemfile:use 3.0.9
    thor gemfile:use 3.0.8
    thor gemfile:use 3.0.7

It then does several things:

* generates a .gemfile file with the version listed. This is used internally by
  assorted rake tasks.
* installs the bundle using the appropriate file in the gemfiles directory
** this includes binstubs, which are stored in ./gemfiles/bin
* symlinks the gemfiles/bin directory to ./bin (in the project root) to support
  running bin/rspec from the project root

At any time, if you want to change rails versions, run `thor gemfile:use` with a
new version number. To play it safe, you probably want to also run `rake
clobber` to delete all the code generated by the previous rails version.