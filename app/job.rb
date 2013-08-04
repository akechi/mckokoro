module Job
  JOBS = [:novice, :killerqueen, :archer, :muteki, :archtect]

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


  def player_job_changable?(player,inv,job)
    recipe = Job.recipe job
    # masteries check
    recipe[:masteries].each do |name, exp|
      if Job.exp(player, name) < exp
        return false
      end
    end
    # votive check
    return EventHandler.inventory_match?(inv, recipe[:votive])
  end


  def job_change_event(evt)
    enchantment_table, chest = nil
    player = evt.player
    blocks = EventHandler.location_around(evt.right_clicked.location, 1).map(&:block)
    enchantment_table = blocks.find {|b| Material::ENCHANTMENT_TABLE === b.type }
    chest = blocks.find {|b| Material::CHEST === b.type }
    if enchantment_table && chest
      player.send_message "Job change!"
      inv = chest.state.inventory
      @job_recipes.each do |name, recipe|
        if player_job_changable?(player, inv, name)
          inv.clear
          Job.become(player, name)
          player.send_message "Now your job is #{Job.of(player)}"
        end
      end
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

    @job_player[player] = new_job
  end
end
