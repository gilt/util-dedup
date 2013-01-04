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

Primary tasks
=========================================================
rake tag


Tasks we want to write
=========================================================
rake merge[integration,master]

  Basically wrapper for cd /web/gilt
    git checkout integration
    git pull --rebase
    git checkout master
    git pull --rebase
    git merge integration
    git commit -a -m "Merge integration into master"
    git push origin master
    Announce on yammer

rake deploy_production[r20130112.1]

  Wrapper for cd /web/gilt
    TAG=r20130112.1 cap iad:deploy
    Announce on yammer
