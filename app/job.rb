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

  def set_recipe(job, recipe)
    @job_recipes[job] = recipe
  end

  def recipe(job)
    @job_recipes[job]
  end

  def exp(player,job)
    @job_exp[player] ||= {}
    @job_exp[player][job] ||= 0
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

    @job_player[player] = new_job
  end
end
