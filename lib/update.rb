module Update

  def Update.update_to_latest
    Util.system_or_fail("cd /web/svc-software-install && git checkout master && git reset --hard origin/master && git pull --rebase")
  end

end
