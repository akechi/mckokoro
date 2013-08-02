module Job
  JOBS = [:neet, :killerqueen, :muteki]

  module_function

  @job_player = {}

  def reload
    EventHandler.later 0 do
      load "#{APP_DIR_PATH}/job.rb" # TODO
    end
  end

  def of(player)
    @job_player[player] || :neet
  end

  def become(player, new_job)
    unless JOBS.include? new_job
      warn "job #{new_job.inspect} isn't available"
      return
    end

    @job_player[player] = new_job
  end
end
