Utilities for deploying rails applications at Gilt Groupe
=========================================================

To install:
  git submodule init
  git submodule update

  # Setup your access token for yammer:
  rake yammer_configure

To add a new task

  Create a library file in the subdir named tasks
  Add your rake task to the main Rakefile

Primary tasks
=========================================================
rake tag
