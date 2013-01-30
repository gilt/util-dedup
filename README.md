Utilities for deploying rails applications at Gilt Groupe

This is mostly a wrapper around util-install library, with simpler
rake commands for common tasks.


Common flow
=========================================================
rake release_owner:create[gilt,bizops]  ## TODO Figure out clearer name
rake merge[gilt,bizops_20121212,master]
rake tag:create[gilt]
rake deploy[production,gilt,r20130103.1]

Adding new code
=========================================================
 1. Add your file in lib/
 2. Update lib/load.rb
