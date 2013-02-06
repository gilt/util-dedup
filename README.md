Utilities for deploying rails applications at Gilt Groupe

This is mostly a wrapper around util-install library, with simpler
rake commands for common tasks.

Install
=========================================================
cd /web/
util-eng/bin/gg-gerrit-clone svc-software-install


Common flow
=========================================================
rake release_branch:create[gilt,bizops]
rake merge[gilt,bizops_20121212,master]
rake tag:create[gilt]
rake deploy:production[gilt,r20130103.1]

Integration
=========================================================
rake deploy:integration[gilt,r20130103.1]

Adding new code
=========================================================
 1. Add your file in lib/
 2. Update lib/load.rb
