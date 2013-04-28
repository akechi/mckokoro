import 'org.bukkit.Bukkit'
import 'org.bukkit.Material'
import 'org.bukkit.Effect'
import 'org.bukkit.util.Vector'
import 'org.bukkit.event.entity.EntityDamageEvent'
import 'org.bukkit.metadata.FixedMetadataValue'
import 'org.bukkit.inventory.ItemStack'
import 'org.bukkit.entity.Player'
import 'org.bukkit.entity.Arrow'
import 'org.bukkit.entity.TNTPrimed'
import 'org.bukkit.entity.Zombie'
import 'org.bukkit.entity.PigZombie'

require 'digest/sha1'
require 'erb'
require 'open-uri'


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
    else
      Thread.start do
        # Send chat for lingr room
        # TODO: move lingr room-id to config.yml to change.
        # TODO: moge following codes to lingr module.
        param = {
          room: 'computer_science',
          bot: 'mcsakura',
          text: "#{evt.player.name}: #{evt.message}",
          bot_verifier: '5uiqiPoYaReoNljXUNgVHX25NUg'
        }.tap{|p| p[:bot_verifier] = Digest::SHA1.hexdigest(p[:bot] + p[:bot_verifier]) }

        query_string = param.map{|e| e.map{|s| ERB::Util.url_encode s.to_s }.join '='}.join '&'
        broadcast ['http://lingr.com/api/room/say', query_string] * '?' # test
        open ['http://lingr.com/api/room/say', query_string] * '?'
      end
    end
  end

  def on_player_login(evt)
    Bukkit.online_players.each do |player|
      update_hide_player(player, evt.player)
    end
  end

  def on_entity_explode(evt)
    #case evt.entity
    #when TNTPrimed
    #  evt.cancelled = true
    #  evt.block_list do |b|
    #    case b
    #    when Material::SUGAR_CANE_BLOCK
    #      # nop
    #    else
    #      b.break_naturally(ItemStack.new(Material::DIAMOND_PICKAXE)
    #    end
    #  end
    #end
  end

  def on_item_spawn(evt)
    case evt.entity.item_stack.type
    when Material::SUGAR_CANE, Material::SAPLING
      evt.cancelled = true
    end
  end

  def on_entity_death(evt)
    case evt.entity
    when PigZombie
      # nop
    when Zombie
      drops = evt.drops.to_a
      drops.reject! {|d| d.type == Material::ROTTEN_FLESH }
      drops << ItemStack.new(Material::TORCH, rand(9) + 1)
      evt.drops.clear
      evt.drops.add_all drops
    end
  end

  def on_block_place(evt)
    case evt.block_placed.type
    when Material::DIRT
      b = evt.block_placed
      if b.location.clone.add(0, -1, 0).block.type == Material::AIR
        later 0 do
          fall_block(b)
        end
      end
    end
  end

  def on_player_interact(evt)
    return unless evt.clicked_block
    case evt.clicked_block.type
    when Material::DIRT
      if evt.player.item_in_hand.type == Material::SEEDS
        consume_item(evt.player)
        evt.clicked_block.type = Material::GRASS
      end
    end
  end

  def on_block_damage(evt)
    evt.player.damage 1 if evt.player.item_in_hand.type == Material::AIR
  end

  def on_block_break(evt)
    case evt.block.type
    #when Material::SUGAR_CANE_BLOCK
    #  evt.cancelled = true
    #  evt.block.type = Material::AIR
    when Material::LOG
      kickory(evt.block, evt.player)
    when Material::GRASS
      evt.cancelled = true
      evt.block.type = Material::DIRT
    when Material::LONG_GRASS
      drop_item(evt.block.location, ItemStack.new(Material::SEEDS))
    when Material::STONE
      evt.cancelled = true
      if rand(5) == 0
        evt.block.type = Material::THIN_GLASS
        evt.block.setMetadata("salt", FixedMetadataValue.new(@plugin, true))
      else
        evt.block.type = Material::COBBLESTONE
      end
    end
    if !evt.cancelled && evt.block.hasMetadata("salt")
      drop_item(evt.block.location, ItemStack.new(Material::SUGAR))
      evt.block.removeMetadata("salt", @plugin)
    end
    #later 0 do
    #  evt.getBlock.setType(Material::STONE)
    #end
  end

  def on_food_level_change(evt)
    #evt.getEntity.setVelocity(Vector.new(0.0, 2.0, 0.0))
  end

  def on_entity_damage_by_entity(evt)
    case evt.damager
    when Arrow
      case evt.damager.shooter
      when Player
        evt.damage *= 2
      end
    end
  end

  def on_entity_damage(evt)
    case evt.getCause
    when EntityDamageEvent::DamageCause::FALL
      #evt.cancelled = true
      #explode(evt.getEntity.getLocation, 1, false)
    when EntityDamageEvent::DamageCause::LAVA
      evt.cancelled = true
      evt.entity.food_level -= 1 rescue nil
    end
  end

  def on_player_toggle_sprint(evt)
    #player_update_speed(evt.player, spp: evt.sprinting?)
    if evt.sprinting?
      if evt.player.location.clone.add(0, -1, 0).block.type == Material::SAND
        evt.cancelled = true
      else
        evt.player.walk_speed = 0.5
      end
    else
      evt.player.walk_speed = 0.2
    end
  end

  def on_player_toggle_sneak(evt)
    #player_update_speed(evt.player, snp: evt.sneaking?)
    player = evt.player
    hard_boots = [Material::CHAINMAIL_BOOTS, Material::IRON_BOOTS,
                  Material::DIAMOND_BOOTS, Material::GOLD_BOOTS]
    if hard_boots.include? player.equipment.boots.type
      if !evt.player.on_ground? && evt.sneaking?
        later 0 do
          newloc = player.location
          newloc.x = newloc.x.to_i.to_f - 0.5
          newloc.z = newloc.z.to_i.to_f - 0.5
          player.teleport newloc
          play_effect(newloc, Effect::ENDER_SIGNAL)
          player.velocity = Vector.new(0.0, -1.0, 0.0)
        end
        loc = (1..4).lazy.
          map {|y| evt.player.location.clone.add(0, -y, 0) }.
          find {|l| l.block.type != Material::AIR }
        later sec(0.2) do
          if loc && loc.block.type == Material::STONE
            loc.block.break_naturally(ItemStack.new(Material::DIAMOND_PICKAXE))
          end
        end
      end
    end
  end

  def on_projectile_launch(evt)
    projectile = evt.entity
    shooter = projectile.shooter
    case shooter
    when Player
      case projectile
      when Arrow
        projectile.velocity = projectile.velocity.multiply(0.5.to_java Java.float)
      end
    end
  end

  #def player_update_speed(player, spp: player.sprinting?, snp: player.sneaking?)
  #  if spp or !snp
  #    #if evt.player.location.clone.add(0, -1, 0).block.type == Material::SAND
  #    #  evt.cancelled = true
  #    #else
  #      player.walk_speed = 0.5
  #    #end
  #  else
  #    player.walk_speed = 0.2
  #  end
  #end

  def later(tick, &block)
    Bukkit.getScheduler.scheduleSyncDelayedTask(@plugin, block, tick)
  end

  def broadcast(*msgs)
    Bukkit.getServer.broadcastMessage(msgs.join ' ')
  end

  def explode(loc, power, fire_p)
    loc.getWorld.createExplosion(loc, power.to_f, fire_p)
  end

  def drop_item(loc, istack)
    loc.getWorld.dropItemNaturally(loc, istack)
  end

  def consume_item(player)
    if player.item_in_hand.amount == 0
      player.item_in_hand = ItemStack.new(Material::AIR)
    else
      player.item_in_hand.amount -= 1
    end
  end

  def fall_block(block)
    loc = block.location
    loc.world.spawn_falling_block(loc, block.type, block.data)
    block.type = Material::AIR
  end

  def kickory(block, player)
    block.break_naturally(player.item_in_hand)
    return if rand(30) == 0
    [[0, 1, 0], [1, 1, 0], [0, 1, 1], [-1, 1, 0], [0, 1, -1]].each do |x, y, z|
      loc = block.location.clone.add(x, y, z)
      kickory(loc.block, player) if loc.block.type == Material::LOG
    end
  end

  def play_effect(loc, eff)
    loc.world.playEffect(loc, eff, nil)
  end

  def sec(n)
    (n * 20).to_i
  end

  def update_hide_player(p1, p2)
    p1.hide_player(p2) unless p2.op?
    p2.hide_player(p1) unless p1.op?
  end
end

EventHandler
