class Tag

  def initialize(dir)
    Preconditions.check_state(File.directory?(dir), "Dir[%s] does not exist" % [dir])
    @dir = dir
    @all_tags = get_all_tags
  end

  def current
    @all_tags.last
  end

  def next
    date = Time.now.strftime("%Y%m%d")
    todays_tags = @all_tags.select { |tag| tag.match(/^r#{date}\./) }
    index = todays_tags.sort.size

    100.times do
      index += 1
      new_tag = "r#{date}.#{index}"
      if !todays_tags.include?(new_tag)
        return new_tag
      end
    end

    raise "Failed to create a tag"
  end

  def exists?(tag)
    @all_tags.include?(tag)
  end

  private
  def get_all_tags
    command = "git tag -l 'r*'"
    tags = Dir.chdir(@dir) do
      `#{command}`.strip.split.select { |tag| is_valid_tag?(tag) }
    end
    tags.sort
  end

  def is_valid_tag?(tag)
    if md = tag.match(/^r(\d\d\d\d+)(\d\d)(\d\d)\.(\d+)$/)
      year = md[1].to_i
      month = md[2].to_i
      day = md[3].to_i
      count = md[4].to_i

      year >= 2007 && month >= 1 && month <= 12 && day >= 1 && day <= 31 && count >= 1
    else
      false
    end
  end
end
