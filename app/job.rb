import 'org.bukkit.Effect'

module Job
  Util.silence_warnings do
    JOBS = [
      :novice, :killerqueen, :archer, :bulldozer, :archtect,
      :grimreaper, :barrage, :enderman]

    JOB_DESCRIPTIONS = {
      novice: 'Default; no pros/cons',
      killerqueen: '(supermomonga will write here)',
      archer: 'Arrows goes very fast and straight. Other attacks you can give get weaker.',
      bulldozer: 'Fast/efficient dig to flat terrains easily',
      archtect: 'Good at building. You can fill an area with using tripwires!',
      grimreaper: '(supermomonga will write here)',
      barrage: '(supermomonga will write here)',
      enderman: 'teleport to somebody secretly',
    }
  end

  extend self

  @job_player ||= {}
  @job_exp ||= {}
  @job_recipes ||= {}

  def reload
    EventHandler.later 0 do
      load "#{APP_DIR_PATH}/job.rb" # TODO
    end
    set_recipe(
      :enderman,
      {
        masteries: {novice: 0},
        votive: [ItemStack.new(Material::ENDER_PEARL, 1)]
      })
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
      return false if Job.exp(player, name) < exp
    end
    # votive check
    EventHandler.inventory_match?(inv, recipe[:votive])
  end

  def change_event(player, blocks)
    enchantment_table = blocks.find {|b| Material::ENCHANTMENT_TABLE === b.type }
    chest = blocks.find {|b| Material::CHEST === b.type }
    return unless enchantment_table && chest
    inv = chest.state.inventory
    name, recipe = @job_recipes.find {|name, recipe|
      player_job_changable?(player, inv, name)
    }
    if name
      inv.clear
      Job.become(player, name)
    else
      player.send_message "Job change failed!"
    end
  end

  def of(player)
    @job_player[player] || :novice
  end

  def become(player, new_job)
    unless JOBS.include? new_job
      warn "job #{new_job.inspect} isn't available"
      return
    end

    @job_player[player] = new_job

    Util.play_effect(player.location, Effect::ENDER_SIGNAL, nil)
    player.send_message "Job change! Now your job is #{new_job}"
    player.send_message('  ' + JOB_DESCRIPTIONS[new_job] || '(No description available yet)')
  end
end
