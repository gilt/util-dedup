Utilities for deploying rails applications at Gilt Groupe
=========================================================

To install:
  git submodule init
  git submodule update

  # Setup your access token for yammer:
  rake yammer_configure

  # If something goes wrong, all this task does is update the file
  #   /web/util-rails-deploy/config/yammer.tokens
  # You can just manually list your token there

To add a new task

  Create a library file in the subdir named tasks
  Add your rake task to the main Rakefile

Common deploy sequence
=========================================================
rake merge_and_deploy_to_production[master]
rake merge_and_deploy_to_production[integration]
rake deploy_to_production[r20130103.1]

Primary tasks
=========================================================

# Merge one branch into another, e.g. merge hotfix into master
rake merge[source,destination]


# Create a new tag on the /web/gilt repo
#   -- sends changelog email
#   -- posts to yammer group
rake tag


# Deploy a /web/gilt version to production
#   -- posts to yammer group when deploy starts/completes
rake deploy_to_production[r20130112.1]


# Change the deploy master
rake set_deploy_master


# Cherry pick ref to a branch
rake cherrypick[ref,integration]
