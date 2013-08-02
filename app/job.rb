module Job
  module_function

  @job_player = {}

  def reload
    later 0 do
      load "#{APP_DIR_PATH}/job.rb" # TODO
    end
  end

  def of(player)
    @job_player[player] || :neet
  end

  def become(player, new_job)
    unless %s[killerqueen].include? new_jo
      warn "job #{new_job.inspect} isn't available"
      return
    end

    @job_player[player] = new_job
  end
end
