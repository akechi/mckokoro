require 'json'
require 'stringio'
$LOAD_PATH.concat(Dir.glob File.expand_path("#{File.dirname __FILE__}/ruby/*/gems/**/lib/")[5..-1])
require 'sinatra/base'
import 'org.bukkit.Bukkit'
import 'org.bukkit.Material'
import 'org.bukkit.util.Vector'
import 'org.bukkit.event.entity.EntityDamageEvent'

class LingrBot < Sinatra::Base
  get '/' do
    {RUBY_DESCRIPTION: RUBY_DESCRIPTION, bukkit_version: Bukkit.getBukkitVersion}.inspect
  end

  post '/' do
    begin
      JSON.parse(request.body.string)['events'].map {|event|
        msg = event['message']
        next unless %w[computer_science mcujm].include? msg['room']
        EventHandler.on_lingr(msg)
        case event['message']['text']
        when '/list'
          p 'list!'
          Bukkit.getOnlinePlayers.map(&:getName).inspect
        else
          ''
        end
      }.join
    rescue => e
      p e
      ''
    end
  end
end

Thread.start do
  Rack::Handler::WEBrick.run LingrBot, Port: 8126, AccessLog: [], Logger: WEBrick::Log.new("/dev/null")
end

module EventHandler
  module_function
  def on_load(plugin)
    @plugin = plugin
    p :on_load, plugin
  end

  def on_lingr(message)
    return if Bukkit.getOnlinePlayers.empty?
    later 0 do
      broadcast "#{message['nickname']}: #{message['text']}"
    end
  end

  def on_async_player_chat(evt)
    #p :chat, evt.getPlayer
  end

  def on_player_login(evt)
    p :login, evt
    p evt.getPlayer
  end

  def on_block_break(evt)
    #evt.setCancelled true
    later 0 do
      evt.getBlock.setType(Material::LAVA)
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
