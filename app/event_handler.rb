import 'org.bukkit.Bukkit'
import 'org.bukkit.Material'
import 'org.bukkit.util.Vector'
import 'org.bukkit.event.entity.EntityDamageEvent'

module EventHandler
  module_function
  def on_load(plugin)
    @plugin = plugin
    p :on_load, plugin
    p "#{APP_DIR_PATH}/event_handler.rb"
  end

  def on_lingr(message)
    return if Bukkit.getOnlinePlayers.empty?
    later 0 do
      broadcast "#{message['nickname']}: #{message['text']}"
    end
  end

  def on_async_player_chat(evt)
    #p :chat, evt.getPlayer
    if evt.player.op? && evt.message == "reload"
      evt.cancelled = true
      later 0 do
        load "#{APP_DIR_PATH}/event_handler.rb" # TODO
      end
      broadcast '(reloading event handler)'
    end
  end

  def on_player_login(evt)
    p :login, evt
    p evt.getPlayer
  end

  def on_block_break(evt)
    #evt.setCancelled true
    later 0 do
      evt.getBlock.setType(Material::STONE)
    end
  end

  def on_food_level_change(evt)
    evt.getEntity.setVelocity(Vector.new(0.0, 2.0, 0.0))
  end

  def on_entity_damage(evt)
    if evt.getCause == EntityDamageEvent::DamageCause::FALL
      evt.setCancelled true
      explode(evt.getEntity.getLocation, 1, false)
    elsif evt.getCause == EntityDamageEvent::DamageCause::LAVA
      evt.setCancelled true
      evt.getEntity.setFoodLevel(evt.getEntity.getFoodLevel - 1) rescue nil
    end
  end

  def later(tick, &block)
    Bukkit.getScheduler.scheduleSyncDelayedTask(@plugin, block, tick)
  end

  def broadcast(*msgs)
    Bukkit.getServer.broadcastMessage(msgs.join ' ')
  end

  def explode(loc, power, fire_p)
    loc.getWorld.createExplosion(loc, power.to_f, fire_p)
  end
end

EventHandler
