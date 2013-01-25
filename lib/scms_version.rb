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
