Utilities for deploying rails applications at Gilt Groupe


Common flow
=========================================================
rake create_release_branch[bizops]
rake merge_and_deploy_to_production[bizops_20121212]
rake deploy_to_production[r20130103.1]


Adding new code
=========================================================
 1. Add your file in lib/
 2. Update lib/load.rb
