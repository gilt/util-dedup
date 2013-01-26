Utilities for deploying rails applications at Gilt Groupe
=========================================================

To install:
  git submodule init
  git submodule update

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
#   -- sends email
rake tag


# Deploy a /web/gilt version to production
#   -- sends email
rake deploy_to_production[r20130112.1]


# Change the deploy master
rake set_deploy_master


# Cherry pick ref to a branch
rake cherrypick[ref,integration]
