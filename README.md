Utilities for deploying rails applications at Gilt Groupe

This is mostly a wrapper around util-install library, with simpler
rake commands for common tasks.


Common flow
=========================================================
rake create_release_branch[gilt,bizops]
rake merge[gilt,bizops_20121212,master]
rake deploy[production,gilt,r20130103.1]


Adding new code
=========================================================
 1. Add your file in lib/
 2. Update lib/load.rb
