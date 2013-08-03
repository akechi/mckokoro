module Job
  JOBS = [:novice, :killerqueen, :archer, :muteki]

  module_function

  @job_player ||= {}
  @job_exp ||= {}
  @job_recipes ||= {}

  def reload
    EventHandler.later 0 do
      load "#{APP_DIR_PATH}/job.rb" # TODO
    end
  end

  def of(player)
    unless @job_player[player]
      become player, :novice
    end
    @job_player[player]
  end

  def become(player, new_job)
    unless JOBS.include? new_job
      warn "job #{new_job.inspect} isn't available"
      return
    end

    @job_exp[player] ||= {}
    @job_exp[player][new_job] ||= 0
    @job_player[player] = new_job
  end
end
