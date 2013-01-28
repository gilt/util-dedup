# Non standard deploy for the gilt repo
module Deploy

  module Gilt

    def Gilt.deploy(env, tag)
      puts "Rails deploy to env[#{env}] starting. You need to manually post into the Skype chat room Gilt US Production"
      puts "   rails %s to %s" % [tag, env]
      if !Util.ask_boolean("Continue?")
        exit(0)
      end

      if env != 'production'
        raise "Not yet implemented for env[%s]" % [env]
      end

      Util.system_or_fail("export TAG=%s && cap production:deploy" % [tag])

      if ScmsVersion.verify_single_scms_version("http://www.gilt.com")
        message = "completed production deploy of rails version %s" % [tag]
        puts message
      end

    end

    module ScmsVersion

      class Instance

        attr_reader :version, :number

        def initialize(version)
          @version = version
          @number = 1
        end

        def increment!
          @number += 1
        end

      end

      def ScmsVersion.verify_single_scms_version(uri)
        versions = ScmsVersion.get_scms_versions(uri)
        if versions.size > 1
          puts ""
          puts "ERROR: Multiple SCMS Versions found"
          puts "-----------------------------------"
          puts "Goto https://admin.gilt.com/admin/dev/monitor for details of hosts to fix"
          puts ""
          versions.each do |scms_version|
            puts "  #{scms_version.version}: #{scms_version.number}"
          end
          puts ""
          false
        else
          true
        end
      end

      # uri ex. http://www.gilt.com
      # Returns an array of Instance objects
      def ScmsVersion.get_scms_versions(uri)
        map = {}
        versions = []
        all = `curl --silent #{uri}/system/active_scms_version_ids`.strip.split.map(&:to_i).sort
        all.each do |version|
          if scms_version = map[version]
            scms_version.increment!
          else
            map[version] = Instance.new(version)
            versions << map[version]
          end
        end
        versions
      end
    end

  end

end
