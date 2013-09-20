# coding: utf-8
import 'java.util.HashSet'
import 'org.bukkit.Bukkit'
import 'org.bukkit.Material'
import 'org.bukkit.Effect'
import 'org.bukkit.Sound'
import 'org.bukkit.Location'
import 'org.bukkit.SkullType'
import 'org.bukkit.util.Vector'
import 'org.bukkit.event.entity.EntityDamageEvent'
import 'org.bukkit.event.entity.CreatureSpawnEvent'
import 'org.bukkit.metadata.FixedMetadataValue'
import 'org.bukkit.inventory.ItemStack'
import 'org.bukkit.inventory.FurnaceRecipe'
import 'org.bukkit.inventory.ShapelessRecipe'
import 'org.bukkit.inventory.ShapedRecipe'
import 'org.bukkit.material.MaterialData'
import 'org.bukkit.material.SpawnEgg'
import 'org.bukkit.entity.EntityType'
import 'org.bukkit.event.block.Action'
import 'org.bukkit.enchantments.Enchantment'
import 'org.bukkit.potion.PotionEffectType'
import 'org.bukkit.potion.Potion'
import 'org.bukkit.potion.PotionType'
import 'org.bukkit.block.BlockFace'
import 'com.github.ujihisa.Mckokoro.JavaWrapper'

require 'set'
require 'digest/sha1'
require 'erb'
require 'open-uri'
require 'json'

module Util
  extend self

  def let(x)
    yield x
  end

  def play_effect(loc, eff, data)
    loc.world.play_effect(loc, eff, data)
  end

  def smoke_effect(loc)
    (0...8).each do |byte|
      loc.world.play_effect(loc, Effect::SMOKE, byte)
    end
  end

  def play_sound(loc, sound, volume, pitch)
    loc.world.play_sound(loc, sound, jfloat(volume), jfloat(pitch))
  end

  def sec(n)
    (n * 20).to_i
  end

  def jfloat(rubyfloat)
    rubyfloat.to_java Java.float
  end

  def jchar(rubystring)
    rubystring[0].ord
  end

  def post_lingr(text)
    post_lingr_to('mcujm', text)
  end

  def post_lingr_to(room, text)
    Thread.start do
      # Send chat for lingr room
      # TODO: move lingr room-id to config.yml to change.
      # TODO: moge following codes to lingr module.
      param = {
        room: room,
        bot: 'mcsakura',
        text: text,
        bot_verifier: '5uiqiPoYaReoNljXUNgVHX25NUg'
      }.tap {|p| p[:bot_verifier] = Digest::SHA1.hexdigest(p[:bot] + p[:bot_verifier]) }

      query_string = param.map {|e|
        e.map {|s| ERB::Util.url_encode s.to_s }.join '='
      }.join '&'
      #broadcast "http://lingr.com/api/room/say?#{query_string}"
      open "http://lingr.com/api/room/say?#{query_string}"
    end
  end

  def spawn(loc, etype)
    loc.world.spawn_entity(loc, etype)
  end

  def strike_lightning(loc)
    loc.world.strike_lightning_effect(loc)
  end

  def haveitem(pname, iname, num)
    Bukkit.get_player(pname).item_in_hand =
      ItemStack.new(eval("Material::#{iname.to_s.upcase}"), num)
  end

  def add_loc(loc, x, y, z)
    loc.clone.tap {|l| l.add(x, y, z) }
  end

  def loc_above(loc) add_loc(loc, 0, 1, 0) end
  def loc_below(loc) add_loc(loc, 0, -1, 0) end

  def block2loc(block)
    add_loc(block.location, 0.5, 0.0, 0.5)
  end

  def face2pitchyaw(face)
    x, z = face.mod_x, face.mod_z
    phi = Math.atan2(-x, z) * 180 / Math::PI
    [0.0, phi]
  end

  def stochastically(percentage)
    yield if rand(100) < percentage
  end

  # dummy
  def sleep(*x)
    warn "Don't use it"
  end

  # location_around(loc_centre, 2).each {|loc| ... }
  # will do something around the centre (loc_centre) with width 2
  def location_around(loc, size)
    location_list = ([*-size..size] * 3).combination(3).to_a.uniq - [0, 0, 0]
    location_list.map {|x, y, z|
      loc.clone.add(x, y, z)
    }
  end

  def location_around_flat(loc, size)
    location_list = ([*-size..size] * 2).combination(2).to_a.uniq - [0, 0]
    location_list.map {|x, z|
      loc.clone.add(x, 0, z)
    }
  end

  def location_distance_xy(loc1, loc2)
    loc1 = loc1.clone.tap {|l| l.set_y 0.0 }
    loc2 = loc2.clone.tap {|l| l.set_y 0.0 }
    loc1.distance(loc2)
  end

  def break_naturally_by_dpickaxe(block)
    block.break_naturally(ItemStack.new(Material::DIAMOND_PICKAXE))
  end

  def break_naturally_by_daxe(block)
    block.break_naturally(ItemStack.new(Material::DIAMOND_AXE))
  end

  def break_naturally_by_dspade(block)
    block.break_naturally(ItemStack.new(Material::DIAMOND_SPADE))
  end

  def night?(world)
    13500 < world.time
  end

  def phi_yaw(location)
    (location.yaw + 90 + 360) % 360
  end

  def phi_pitch(location)
    # test
    (location.pitch + 90 + 360) % 360
  end

  def fall_block(block)
    loc = block.location
    loc.world.spawn_falling_block(loc, block.type, block.data)
    block.type = Material::AIR
  end

  def broadcast(*msgs)
    Bukkit.getServer.broadcastMessage(msgs.join ' ')
  end

  def broadlingr(msg)
    broadcast(msg.to_s)
    post_lingr(msg.to_s)
  end

  def explode(loc, power, fire_p)
    loc.getWorld.createExplosion(loc, power.to_f, fire_p)
  end

  def drop_item(loc, istack)
    loc.getWorld.dropItemNaturally(loc, istack)
  end

  def consume_item_durability(player, d_damage)
    if player.item_in_hand.durability >= player.item_in_hand.type.max_durability
      player.item_in_hand = ItemStack.new(Material::AIR)
    else
      player.item_in_hand.durability += d_damage
    end
  end

  def consume_item(player)
    if player.item_in_hand.amount == 1
      player.item_in_hand = ItemStack.new(Material::AIR)
    else
      player.item_in_hand.amount -= 1
    end
  end

  # clojure's loop/recur
  def cloop(*params, &block)
    r = ->(*xs){ block.(r, *xs) }
    r.(*params)
  end

  def serialize_location(loc)
    [loc.world.name, loc.x, loc.y, loc.z, loc.yaw, loc.pitch]
  end

  def deserialize_location(sloc)
    world_name, loc_x, loc_y, loc_z, loc_yaw, loc_pitch = sloc
    Location.new(
      Bukkit.get_world(world_name), loc_x, loc_y, loc_z, jfloat(loc_yaw), jfloat(loc_pitch))
  end

  def facing_next(facing)
    all_facings = [
      BlockFace::EAST_SOUTH_EAST, BlockFace::EAST, BlockFace::EAST_NORTH_EAST,
      BlockFace::NORTH_EAST, BlockFace::NORTH_NORTH_EAST, BlockFace::NORTH,
      BlockFace::NORTH_NORTH_WEST, BlockFace::NORTH_WEST,
      BlockFace::WEST_NORTH_WEST, BlockFace::WEST, BlockFace::WEST_SOUTH_WEST,
      BlockFace::SOUTH_WEST, BlockFace::SOUTH_SOUTH_WEST, BlockFace::SOUTH,
      BlockFace::SOUTH_SOUTH_EAST, BlockFace::SOUTH_EAST]
    all_facings[(all_facings.find_index(facing) - 1) % all_facings.size]
  end

  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end

  silence_warnings do
    RECORDS =
      [Material::GOLD_RECORD, Material::GREEN_RECORD, Material::RECORD_10,
       Material::RECORD_11, Material::RECORD_3, Material::RECORD_4, Material::RECORD_5,
       Material::RECORD_6, Material::RECORD_7, Material::RECORD_8, Material::RECORD_9]
  end
end

module EventHandler
  include_package 'org.bukkit.entity'
  include Util
  extend self

  def on_load(plugin)
    @plugin = plugin
    Bukkit.scheduler.schedule_sync_repeating_task(
      @plugin, -> { self.periodically_sec }, 0, sec(1))
    Bukkit.scheduler.schedule_sync_repeating_task(
      @plugin, -> { self.periodically_tick }, 0, 2)
    p :on_load, plugin
    p "#{APP_DIR_PATH}/event_handler.rb"
    update_recipes()
    @food_poisoning_player = Set.new

    @db_path = "#{@plugin.data_folder.absolute_path}/db.json"
    @db = File.readable?(@db_path) ? JSON.load(File.read @db_path) : {'achievement' => {'block-place' => {}}}
  end

  def on_lingr(message)
    return if Bukkit.getOnlinePlayers.empty?
    return unless message['room'] == 'mcujm'
    later 0 do
      broadcast "[lingr] #{message['nickname']}: #{message['text']}"
    end

    case message['text']
    when /^!mck (\w+) (cow|chicken|pig|minecart|arrow|zombie|ocelot)/
      pname = $1
      ename = $2
      player = Bukkit.get_player(pname)
      return unless player
      etype =
        begin
          eval("EntityType::#{ename.upcase}")
        rescue
          nil
        end
      return unless etype
      player.send_message "test #{etype}"
      entity = spawn(player.location, etype)
      player.set_passenger entity
    end
  end

  def reload
    p :reload
    later 0 do
      load "#{APP_DIR_PATH}/event_handler.rb" # TODO
      update_recipes
    end
  end

  def on_async_player_chat(evt)
    @last_chat_message ||= []
    #p :chat, evt.getPlayer

    last_pname, last_message = @last_chat_message
    @last_chat_message = [evt.player.name, evt.message]
    if evt.player.op? && evt.message == "reload"
      evt.cancelled = true
      reload
      broadcast '(reloading event handler)'
    elsif last_pname && /\|$/ =~ evt.message
      message = evt.message.sub(/\|$/, '')
      post_lingr("#{evt.player.name}: #{message}")
      post_lingr_to('computer_science', "#{last_pname}: #{last_message}")
      post_lingr_to('computer_science', "#{evt.player.name}: #{message}")
    elsif evt.message == 'benri'
      post_lingr("#{evt.player.name}: 便利")
      evt.message = '便利'
    else
      post_lingr("#{evt.player.name}: #{evt.message}")
      if /optifine/ =~ evt.message
        Bukkit.dispatch_command(Bukkit.get_console_sender, "toggledownfall")
      end
    end
  end

  def on_player_join(evt)
    player = evt.player
    name = player.name

    evt.join_message = [
      '%sさんが温野菜食べ放題です。',
      'ujmさんではなく%sさんがログインしました',
      '<%s> おはようございます',
      '%s.vim',
      '<%s> イカカワイイデス',
    ].sample % name
    if name == 'ujm' # TODO temp
      #evt.join_message = ''
      post_lingr "#{name} logged in."
      another_player = (Bukkit.online_players.to_a - [player]).sample
      player.teleport(another_player.location) if another_player
    else
      post_lingr "#{name} logged in."
    end

    #later 0 do
      player_first_time_p =
        player.inventory.contents.to_a.compact.empty? &&
        player.health == player.max_health
      if player_first_time_p
        player.send_message 'You are first time to visit here right?'
        player.send_message 'Check your inventory. You already have good stuff.'
        [ItemStack.new(Material::COBBLESTONE, rand(64) + 1),
         ItemStack.new(Material::MUSHROOM_SOUP, 1),
         ItemStack.new(Material::WHEAT, rand(64) + 1),
         ItemStack.new(Material::WOOD, 10),
         ItemStack.new(Material::LEATHER_HELMET, 1),
         ItemStack.new(Material::PUMPKIN_PIE, 1)].each do |istack|
          player.inventory.add_item istack
         end
        later sec(20) do
          player.send_message "Note that you can't place any blocks at first..."
          player.send_message "You need to unlock that by making a Workbench."
        end

        later sec(120) do
          player.send_message 'You may want to check browser map as well.'
          player.send_message 'http://mck.supermomonga.com'
        end
      else
        #player.send_message 'There will be a CTF this weekend!'
        #player.send_message '  (今週末にCTFやりたいなあ)'
        #player.send_message 'It will be at 8pm PDT on the Saturday.'
        #player.send_message '  (日本時間でいうと日曜の正午(12pm)とかどうかな?)'
        #player.send_message 'By the way there will be a downtown during 12am~4am on Friday'
        #player.send_message '  (ちなみに計画停電のため日本時間の金曜の4pm~8pmの間,鯖とまるかも)'
      end
    #end
  end

  def on_player_login(evt)
  end

  def on_player_quit(evt)
    player = evt.player
    loc = player.location
    strike_lightning(loc)
    later sec(1) do
      strike_lightning(loc)
    end
    later sec(2) do
      strike_lightning(loc)
    end
    # e.g. "ujm left the game."
    post_lingr "#{evt.player.name} #{evt.quit_message.sub(/^.*?#{evt.player.name}\s*/, '')}"
  end

  def on_entity_explode(evt)
    entity, block_list, yieldf =
      [evt.entity, evt.block_list, evt.yield]

    # to see if projectile_on_hopper() is earlier or not
    Bukkit.get_player('ujm').send_message "on_entity_explode #{entity.type} #{loc_below(entity.location).block.type}"

    case entity
    when TNTPrimed
      evt.yield = 1.0
      Bukkit.get_player('ujm').send_message "tnt explosion: #{entity.source}"
      loc = entity.location
      later sec(0.5) do
        orbs = (block_list.size / 10).times.map {
          spawn(loc, EntityType::EXPERIENCE_ORB).tap {|orb|
            orb.experience = 1
          }
        }
        later 0 do
          orbs.each do |o|
            o.velocity = Vector.new(
              (rand - 0.5) / 3.0,
              rand,
              (rand - 0.5) / 3.0)
          end
        end
        later sec(1) do
          orbs.select(&:valid?).each do |o|
            play_effect(o.location, Effect::MOBSPAWNER_FLAMES , nil)
            o.remove
          end
        end
      end
    end
  end

  def on_item_spawn(evt)
    case evt.entity.item_stack.type
    when Material::SUGAR_CANE, Material::SAPLING
      evt.cancelled = true
    #when Material::EGG
    #  evt.cancelled = true
    end
  end

  def on_player_portal(evt)
    name = evt.player.name
    if evt.player.world.name == 'mc68'
      evt.cancelled = true
      return
    end
    loc = evt.player.location.block.location # to align
    broadlingr("#{name} is using a portal at #{loc}!")
  end

  def on_entity_portal_enter(evt)
    #name = evt.entity.type.downcase.to_s
    #loc = evt.player.location.block.location # to align
    #broadlingr("#{name} is using a portal at #{loc}.")
  end

  def on_entity_death(evt)
    drop_replace = ->(remove_types, new_istacks) {
      drops = evt.drops.to_a
      drops.reject! {|d| remove_types.include? d.type}
      drops += new_istacks
      evt.drops.clear
      evt.drops.add_all drops
    }
    case evt.entity
    when Creeper
      head = MaterialData.new(Material::SKULL_ITEM, 4).to_item_stack(1)
      drop_replace.([], rand(10) == 0 ? [head] : [])
    when PigZombie
      opt_golden_apple =
        (rand(10) == 0 ? [ItemStack.new(Material::GOLDEN_APPLE, 1)] : [])
      drop_replace.(
        [Material::ROTTEN_FLESH],
        [ItemStack.new(Material::GLOWSTONE_DUST , 1)] + opt_golden_apple)
    when Zombie
      if evt.entity.baby?
        drop_replace.(
          [Material::ROTTEN_FLESH],
          [ItemStack.new(Material::IRON_INGOT, 1),
           ItemStack.new(Material::GOLD_INGOT, 1)])
      else
        head = MaterialData.new(Material::SKULL_ITEM, 2).to_item_stack(1)
        drop_replace.(
          [Material::ROTTEN_FLESH],
          [ItemStack.new(Material::TORCH, rand(9) + 1)] + (rand(20) == 0 ? [head] : []))
      end
    when Horse
      opt_beef =
        (rand(5) == 0 ? [ItemStack.new(Material::RAW_BEEF, rand(3) + 1)] : [])
      drop_replace.(
        [],
        [SpawnEgg.new(EntityType::HORSE).toItemStack(1)] + opt_beef)
    when Sheep
      drop_replace.([Material::WOOL], [ItemStack.new(Material::STRING)])
    when MagmaCube
      # nop to avoid Slime's
    when Slime
      #case evt.entity.last_damage_cause.cause
      #when EntityDamageEvent::DamageCause::FIRE
      #  block = evt.entity.location.block
      #  unless block.type.solid?
      #    block.type = Material::WATER
      #    evt.clicked_block.data = 0
      #  end
      #end
    end
    entity = evt.entity
    if entity.killer && Player === entity.killer
      @player_last_killed_mob ||= {}

      player = entity.killer
      killed_at = Time.now
      last_killed = @player_last_killed_mob[player.name]

      cond =
        last_killed &&
        last_killed[:mob] == entity.type &&
        (killed_at - last_killed[:time]) < 10
      unless cond
        post_lingr "#{player.name} killed a #{entity.type.name.downcase}"
      end

      @player_last_killed_mob[player.name] = {
        mob: entity.type,
        time: killed_at
      }
    end
  end

  def on_player_death(evt)
    player = evt.entity
    @logout_countdown_table.delete(player)
    @food_poisoning_player.delete player
    post_lingr "#{player.name} died: #{evt.death_message.sub(/^#{player.name}/, '')} at (#{player.location.x.to_i}, #{player.location.z.to_i}) in #{player.location.world.name}."
  end

  def fill_two_blocks(player, block1, block2)
    return false if !block1 or !block2
    cond =
      block1.type == Material::TRIPWIRE_HOOK &&
      block2.type == Material::TRIPWIRE_HOOK
    return false unless cond
    block1 = contacting_block(block1)
    block2 = contacting_block(block2)
    return false if !block1 || !block2
    if block1.type != block2.type
      player.send_message "Failed! #{block1.type} isn't #{block2.type}."
      false
    else
      vec = block2.location.clone.subtract(block1.location)
      case [vec.x, vec.y, vec.z].count(&:zero?)
      when 0
        player.send_message 'Failed! give 2 points on same face.'
        false
      when 1
        # projection from (x, y, z) to (v, w)
        v, w = [:x, :y, :z].reject {|s| vec.send(s).zero? }
        v1, v2 = [block1, block2].map(&v).sort
        w1, w2 = [block1, block2].map(&w).sort
        fill_two_blocks2(v, w, v1, v2, w1, w2, player, block1)
      when 2
        v = !vec.x.zero? ? :x : !vec.y.zero? ? :y : :z
        w = [:x, :y, :z].find {|s| vec.send(s).zero? }
        v1, v2 = [block1, block2].map(&v).sort
        w1 = w2 = block1.send(w)
        fill_two_blocks2(v, w, v1, v2, w1, w2, player, block1)
      else # == 3
        player.send_message 'Failed! same places.'
        false
      end
    end
  end

  def fill_two_blocks2(v, w, v1, v2, w1, w2, player, block1)
    sizev = v2 - v1 + 1
    sizew = w2 - w1 + 1
    itemstacks = player.inventory.all(block1.type)
    cost_amount = sizev * sizew - 2
    your_amount = itemstacks.map {|k, v| v.amount }.inject(0, :+)
    if cost_amount > 1000
      player.send_message "Failed! the size, #{cost_amount}, is bigger than 1,000!"
      false
    elsif cost_amount > your_amount
      player.send_message "Failed! the size is too big #{sizev}x#{sizew}-2 > #{cost_amount}"
      false
    else
      player.send_message 'Success!!!'
      player.send_message "cost: #{cost_amount}"
      itemstacks.each do |idx, is|
        if cost_amount == 0
          break
        elsif cost_amount > is.amount
          #player.send_message "reduce #{is} to 0"
          cost_amount -= is.amount
          is.type = Material::AIR
        else # cost_amount <= is.amount
          #player.send_message "reduce #{is} a little bit"
          is.amount -= cost_amount
        end
        player.inventory.set_item(idx, is)
      end
      player.update_inventory
      basetype = block1.type
      basestatedata = block1.data
      later 0 do
        (0...sizew).each do |wdiff|
          baseloc = block1.location.tap {|l|
            l.send(:"set#{v.to_s.upcase}", v1)
            l.send(:"set#{w.to_s.upcase}", w1 + wdiff)
          }
          fill_two_blocks3(player, basetype, basestatedata, baseloc, sizev, v)
        end
      end
      true
    end
  end
  private :fill_two_blocks2

  def fill_two_blocks3(player, basetype, basestatedata, baseloc, size, base_axis)
    set_base_axis = :"set#{base_axis.to_s.upcase}"
    (0...size).each do |diff|
      loc = baseloc.clone.tap {|l|
        l.send(set_base_axis, l.send(base_axis) + diff)
      }
      #player.send_message loc.to_s
      unless loc.block.type.solid?
        #player.send_message [:before, loc.block.type.to_s, loc.block.state.data.to_s].to_s
        loc.block.type = basetype
        loc.block.data = basestatedata
        #player.send_message [:after, loc.block.type.to_s, loc.block.state.data.to_s].to_s
      end
    end
  end
  private :fill_two_blocks3

  # assuming the block has BlockFace
  def contacting_block(block)
    face = block.state.data.facing
    unless face
      warn "block #{block}'s face is nil"
      nil
    end
    block.location.clone.tap {|loc|
      loc.subtract(face.mod_x, face.mod_y, face.mod_z)
    }.block
  end

  @player_block_place_lasttime ||= {}
  def on_block_place(evt)
    return unless evt.canBuild

    player = evt.player

    if Job.of(player) == :archtect
      result = fill_two_blocks(
        player, @player_block_place_lasttime[player], evt.block_placed)
        if result
          # remove the tripwires
          break_naturally_by_dpickaxe(evt.block_placed)
          break_naturally_by_dpickaxe(@player_block_place_lasttime[player])
          @player_block_place_lasttime[player] = nil
          return
        end
    end

    @player_block_place_lasttime[player] = evt.block_placed

    unless @db['achievement']['block-place'][player.name]
      if evt.block_placed.type == Material::WORKBENCH
        player.send_message "[ACHIEVEMENT UNLOCKED]"
        player.send_message "Congrats! Now you can place any blocks."
        post_lingr "#{player.name} unlocked block-place."
        @db['achievement']['block-place'][player.name] = true
        db_save
      else
        player.send_message "You didn't unlock block-place."
        evt.cancelled = true
        return
      end
    end

    case evt.block_placed.type
    when Material::DIRT
      b = evt.block_placed
      unless b.location.clone.add(0, -1, 0).block.type.solid?
        later 0 do
          fall_block(b)
        end
      end
    when Material::PUMPKIN, Material::JACK_O_LANTERN
      base_loc = evt.block_placed.location
      later 0 do
        mod_x, mod_z =
          let(evt.block_placed.state.data.facing) {|f| [f.mod_z, -f.mod_x] }
        diamond_blocks = [
          add_loc(base_loc, 0, -1, 0).block,
          add_loc(base_loc, mod_x, -1, mod_z).block,
          add_loc(base_loc, -mod_x, -1, -mod_z).block,
          add_loc(base_loc, 0, -2, 0).block]
        if diamond_blocks.map(&:type).all? {|t| t == Material::DIAMOND_BLOCK }
          player.send_message "Success! Diamond golem! #{mod_x} #{mod_z}"
          (diamond_blocks + [base_loc.block]).each do |b|
            b.type = Material::AIR
          end
          golem = spawn(base_loc, EntityType::IRON_GOLEM)
          golem.player_created = true
          golem.max_health = 500
          golem.health = golem.max_health
        end
      end
    end
  end

  def inventory_match?(inv, item_stacks)
    amounts = let({}) do |a|
      item_stacks.each do |s|
        a[s.type] ||= 0
        a[s.type] += s.amount
      end
      a
    end
    inv.contents.to_a.compact.each do |s|
      amounts[s.type] ||= 0
      amounts[s.type] -= s.amount
    end
    amounts.all? {|k, v| v == 0 }
  end

  def on_player_interact_entity(evt)
    player = evt.player
    case evt.right_clicked
    when PigZombie
    when Zombie
      # TODO this is dead-copy from Player clause
      if player.item_in_hand.type == Material::AIR
        target = evt.right_clicked
        vec = target.location.clone.subtract(player.location).to_vector
          vec.set_y jfloat(0.0)
        vec = vec.normalize.multiply(jfloat(0.5))
        vec.set_y jfloat(0.1)
        target.velocity = vec
        later sec(0.1) do
          target.velocity.set_x jfloat(0.0)
          target.velocity.set_z jfloat(0.0)
        end
      end
    when Player
      target = evt.right_clicked

      case player.item_in_hand.type
      when Material::AIR
        vec = target.location.clone.subtract(player.location).to_vector
        x, y, z = [
          (vec.get_x * 0.3) / Math.sqrt(vec.get_x ** 2 + vec.get_z ** 2),
          0.2,
          (vec.get_z * 0.3) / Math.sqrt(vec.get_x ** 2 + vec.get_z ** 2)]
        target.velocity = Vector.new(jfloat(x), jfloat(y), jfloat(z))
        #later sec(0.1) do
        #  target.velocity.set_x jfloat(0.0)
        #  target.velocity.set_z jfloat(0.0)
        #end
      when Material::WHEAT
        consume_item(player)
        broadcast("<#{target.name}> %s♡" % [
          'ムフフ',
          'うふふ',
          'いやーん',
          'Gentooインストールしたい',
          "#{player.name}様",
        ].sample)
      end
    when Chicken
      if player.item_in_hand.type == Material::SHEARS
        stochastically(40) do
          target = evt.right_clicked
          loc = target.location

          @chicken_feather_durability ||= {}
          @chicken_feather_durability[target] ||= 0
          @chicken_feather_durability[target] += 1
          if @chicken_feather_durability[target] > 5
            target.damage(target.max_health, player)
          end
          later sec(30) do
            if target.valid?
              smoke_effect(target.location)
              @chicken_feather_durability[target] -= 1
            else
              @chicken_feather_durability.delete(target)
            end
          end

          play_sound(loc, Sound::SHEEP_SHEAR, 0.8, 1.5)
          drop_item(loc, ItemStack.new(Material::FEATHER, 1))
          consume_item_durability(player, 1)
        end
      end
    when Squid
      squid = evt.right_clicked
      if @earthwork_squids[squid]
        earthwork_squids_work(squid)
      end
    when Villager
      # job change by villager
      location = evt.right_clicked.location
      Job.change_event(
        evt.player,
        location_around(location, 1).map(&:block))
    else
      #evt.player.send_message "you right clicked something!"
    end
  end

  def feather_freedom_move(player, action)
    return unless player.item_in_hand.type == Material::FEATHER
    if player.sneaking?
      case action
      when Action::RIGHT_CLICK_BLOCK, Action::RIGHT_CLICK_AIR
        player.velocity = player.velocity.tap{|v| v.setY jfloat(1.4) }
        stochastically(50) do
          consume_item(player)
        end
        player.fall_distance = 0.0
        play_sound(player.location, Sound::BAT_LOOP, 1.0, 2.0)
      end
    else
      case action
      when Action::RIGHT_CLICK_BLOCK, Action::RIGHT_CLICK_AIR
        phi = (player.location.yaw + 90) % 360
        x, z =
          Math.cos(phi / 180.0 * Math::PI),
          Math.sin(phi / 180.0 * Math::PI)
        vehicle = player.vehicle
        if vehicle && Pig === vehicle
          vehicle.eject
          vehicle.fall_distance = 0.0
          later 0 do
            #vehicle.teleport(player.location)
            vehicle.velocity = Vector.new(1.2 * x, 0.40, 1.2 * z)
            player.velocity = Vector.new(1.2 * x, 0.40, 1.2 * z)
            vehicle.set_passenger player
          end
          play_sound(player.location, Sound::BAT_LOOP, 0.8, 1.0)
          play_sound(player.location, Sound::PIG_IDLE, 1.0, 1.0)
        else
          player.velocity = Vector.new(1.5 * x, 0.5, 1.5 * z)
          stochastically(50) do
            consume_item(player)
          end
          play_sound(player.location, Sound::BAT_LOOP, 1.0, 2.0)
        end
        player.fall_distance = 0.0
      when Action::LEFT_CLICK_BLOCK, Action::LEFT_CLICK_AIR
        player.velocity = player.velocity.tap do |v|
          v.setX jfloat(0)
          v.setY jfloat(0)
          v.setZ jfloat(0)
        end
        stochastically(50) do
          consume_item(player)
        end
        player.fall_distance = 0.0
        play_sound(player.location, Sound::BAT_LOOP, 1.0, 2.0)
      end
    end
  end
  private :feather_freedom_move

  # returns bool
  def projectile_on_hopper(projectile)
    return false if projectile.dead?
    loc = projectile.location
    block = loc_below(loc).block
    Bukkit.get_player('ujm').send_message "projectile_on_hopper #{projectile.type} #{block.type}"
    return false unless block.type == Material::HOPPER
    table = {
      EntityType::ARROW => ItemStack.new(Material::ARROW, 1),
      EntityType::EGG => ItemStack.new(Material::EGG, 1),
      EntityType::ENDER_PEARL => ItemStack.new(Material::ENDER_PEARL, 1),
      EntityType::FIREBALL => ItemStack.new(Material::FIREBALL, 1),
      EntityType::FISHING_HOOK => ItemStack.new(Material::RAW_FISH, 1), # I know it's different
      EntityType::FIREBALL => ItemStack.new(Material::FIREBALL, 1),
      EntityType::SMALL_FIREBALL => ItemStack.new(Material::FIREBALL, 1),
      EntityType::SNOWBALL => ItemStack.new(Material::SNOW_BALL, 1),
      EntityType::THROWN_EXP_BOTTLE => ItemStack.new(Material::EXP_BOTTLE, 1),
      EntityType::SPLASH_POTION => projectile.item,
      EntityType::WITHER_SKULL => ItemStack.new(Material::PUMPKIN_PIE, 1), # hehehe
    }
    hopper = block.state
    hopper.inventory.add_item(ItemStack.new(table[projectile.type], 1))
    projectile.remove
    true
  end
  private :projectile_on_hopper

  def on_potion_splash(evt)
    potion = evt.entity
    projectile_on_hopper(potion) && evt.cancelled = true
  end

  def on_projectile_hit(evt)
    projectile_on_hopper(evt.entity)

    case evt.entity
    when Snowball
      # this is for Job bulldozer vvvvv
      # cond =
      #   Player === evt.entity.shooter &&
      #   evt.entity.shooter.item_in_hand &&
      #   evt.entity.shooter.item_in_hand.type == Material::GOLD_HOE
      # if cond
      #   soft_blocks =
      #     [Material::GRASS, Material::DIRT, Material::GRAVEL,
      #      Material::SAND]
      #   location_around(evt.entity.location, 1).each do |loc|
      #     b = loc.block
      #     cond =
      #       soft_blocks.include?(b.type) &&
      #       loc.y >= evt.entity.shooter.location.y
      #     if cond
      #       break_naturally_by_dpickaxe(b)
      #       evt.entity.remove
      #       break
      #     end
      #   end
      # end
      # this is for Job bulldozer ^^^^^
    when Arrow
      loc0 = evt.entity.location
      loc1 = loc0.tap {|l| l.add evt.entity.velocity.normalize }
      loc = [loc0, loc1].find {|loc| loc.block.type == Material::SKULL }
      shooter = evt.entity.shooter
      if loc && shooter
        strike_lightning(loc)
        if Player === shooter
          distance = location_distance_xy(shooter.location, loc).to_i
          bonus = (distance ** 3) / 400
          bonus /= 10 if Job.of(shooter) == :archer
          broadlingr "#{shooter.name} hit! distance: #{distance}, bonus: #{bonus}"
          loc.chunk.load()
          later 0 do
            bonus.times do
              case rand(500)
              when 0...1
                drop_item(loc, ItemStack.new(Material::DIAMOND, 1))
              when 1...6
                drop_item(loc, ItemStack.new(Material::GOLD_INGOT, 1))
              when 6...18
                drop_item(loc, ItemStack.new(Material::IRON_INGOT, 1))
              when 18...50
                drop_item(loc, ItemStack.new(Material::GRAVEL, 1))
              when 50...100
                drop_item(loc, ItemStack.new(Material::SMOOTH_BRICK, 1))
              when 100...200
                drop_item(loc, ItemStack.new(Material::WOOD, 1))
              when 200...300
                drop_item(loc, ItemStack.new(Material::STONE, 1))
              when 300...400
                drop_item(loc, ItemStack.new(Material::LEAVES, 1))
              else
                drop_item(loc, ItemStack.new(Material::STICK, 1))
              end
            end
          end
        end
        stochastically(50) do
          break_naturally_by_dpickaxe(loc.block)
        end
      end
    end
  end

  def bulldozer_hoe(player, action)
    return false unless player.item_in_hand.type == Material::GOLD_HOE
    case action
    when Action::RIGHT_CLICK_BLOCK, Action::RIGHT_CLICK_AIR
      3.times do
        loc = player.location
        loc_above = add_loc(loc, 0, 1, 0)
        snowball = spawn(loc_above, EntityType:: SNOWBALL)
        snowball.shooter = player

        phi = (player.location.yaw + 90 + 360) % 360
        x, z =
          Math.cos((phi + rand(40) - 15) / 180.0 * Math::PI),
          Math.sin((phi + rand(40) - 15) / 180.0 * Math::PI)

        snowball.velocity = Vector.new(x, 0.1, z)
      end
      true
    else
      false
    end
  end
  private :bulldozer_hoe

  def killerqueen_explode(evt)
    # JOB::KILLERQUEEN
    player = evt.player
    if Job.of(player) == :killerqueen
      killerqueen_explodable_blocks = [
        Material::SAND,
        Material::WOOL,
        Material::WOOD,
        Material::FENCE,
        Material::DIRT,
        Material::GRASS,
        Material::WHEAT,
        Material::LEAVES,
        Material::COBBLESTONE,
        Material::STONE,
        Material::COAL_ORE,
        Material::WEB
      ]
      case [ player.item_in_hand.type, evt.action ]
      when [ Material::SULPHUR, Action::LEFT_CLICK_BLOCK ], [ Material::SULPHUR, Action::LEFT_CLICK_AIR ]
        player.send_message "KILLERQUEEN...!!"

        # 20 if cat on player head and have uekibachi
        explodable_distance = 8

        _, target = player.get_last_two_target_blocks(nil, 100).to_a
        return if target.type == Material::AIR
        target_distance = target.location.distance(player.location)

        # effect
        if target_distance <= explodable_distance
          explode(target.location, 0, false)
          location_around(target.location, 1).each do |loc|
            explode(loc, 0, false) if rand(9) < 2
          end
        end
        # explode
        case target.type
        when *killerqueen_explodable_blocks
          if target_distance <= explodable_distance
            target.type = Material::AIR
            stochastically(33) do
              consume_item(player)
            end
          end
        when Material::TNT
          # explode TNT (can be long distance)
          target.type = Material::AIR
          explode(target.location, 3, false)
          stochastically(33) do
            consume_item(player)
          end
        end
      end
    end
  end

  @clock_timechange_counter ||= 0
  def clock_timechange(player)
    return unless player.item_in_hand.type == Material::WATCH
    to_time = night?(player.world) ? 0 : 16000
    player.world.time = to_time
    play_effect(player.location, Effect::RECORD_PLAY, RECORDS.sample)
    if @clock_timechange_counter % 4 == 0
      consume_item(player)
    end
    @clock_timechange_counter += 1
  end
  private :clock_timechange

  def trapdoor_openclose(door)
    # the below condition is buggy with RS input
    cond =
      !door.state.data.inverted? && door.state.data.open? or
      door.state.data.inverted? && !door.state.data.open?
    return if cond

    facing = door.state.data.facing
    entities_on_the_door =
      door.chunk.entities.select {|e| e.location.block == door }

    later 0 do
      entities_on_the_door.each do |p|
        p.velocity = p.velocity.tap {|v|
          v.add Vector.new(facing.mod_x * 5.0, 1.5, facing.mod_z * 5.0)
        }
      end
    end
  end


  def barrage_visual_orb(player, name, distance, visual_orb_amount, rotation_amount_by_tick)
    return unless Job.of(player) == :barrage
    @barrage_visual_tick ||= {}
    @barrage_visual_tick[name] ||= 0
    @barrage_visual_orbs ||= {}
    @barrage_visual_orbs[name] ||= {}
    @barrage_visual_orbs[name][player.name] ||= []
    v_orbs = @barrage_visual_orbs[name][player.name]
    base_loc = player.location.clone.add(0, 1, 0)

    @barrage_visual_tick[name] += rotation_amount_by_tick
    rotation_phi = @barrage_visual_tick[name] % 360.0
    # rotation_phi = 0

    # phi_pitch = phi_pitch(base_loc)
    # player.send_message "pitch:#{ base_loc.pitch } phi:#{ phi_pitch }"


    visual_orb_amount.times.each do |n|
      phi_add = ( 360.0 / visual_orb_amount ) * n
      phi_yaw = phi_yaw(base_loc) + phi_add + rotation_phi
      rad = phi_yaw / 180.0 * Math::PI
      x, z =
        Math.cos(rad) * distance,
        Math.sin(rad) * distance
      # TODO use util
      orb_loc = base_loc.clone
      orb_loc.add(x, 0, z)

      if v_orbs[n] && v_orbs[n].valid?
        orb = v_orbs[n]
        orb.teleport orb_loc
        orb.velocity = orb.velocity.set_x jfloat(0.0)
        orb.velocity = orb.velocity.set_y jfloat(0.0)
        orb.velocity = orb.velocity.set_z jfloat(0.0)
      else
        orb = spawn(orb_loc, EntityType::SNOWBALL)
        # TODO find the best entity to use visual orbs

        # orb = drop_item(orb_loc, ItemStack.new(Material::ENDER_PEARL, 1))
        # orb = player.launch_projectile(EnderPearl.new)
        # orb = spawn(orb_loc, EntityType::ENDER_PEARL)


        # Exp orb is move to user in client side vision.
        # orb = spawn(orb_loc, EntityType::EXPERIENCE_ORB)
        # orb.experience = 0

        v_orbs[n] = orb
      end
    end
  end

  def on_vehicle_exit(evt)
    vehicle = evt.vehicle
    if Player === evt.exited
      player = evt.exited
      case vehicle
      when Horse
        if vehicle.location.block.liquid?
          evt.cancelled = true
          return
        end
        unless vehicle.on_ground?
          play_sound(player.location, Sound::PIG_IDLE, 0.8, 0.0)
          play_sound(player.location, Sound::PIG_IDLE, 0.8, 2.0)
          later 0 do
            player.velocity = vehicle.velocity.tap {|v|
              v.multiply(10.0)
              v.set_y(1.5)
            }
          end
        end
      end
    end
  end

  @horse_sword_swing_flag ||= {}
  def horse_sword_swing(action, player)
    return if @horse_sword_swing_flag[player.name]
    return unless player.item_in_hand
    return unless SWORDS.include?(player.item_in_hand.type)
    return unless [Action::LEFT_CLICK_BLOCK, Action::LEFT_CLICK_AIR].include?(action)
    vehicle = player.vehicle
    return unless vehicle
    return if add_loc(vehicle.location, 0, 1, 0).block.type.solid?
    return unless Horse === vehicle
    return if vehicle.velocity.get_x == 0.0 && vehicle.velocity.get_z == 0.0
    return unless vehicle.on_ground?
    play_sound(vehicle.location, Sound::FALL_BIG, 0.8, 1.5)
    stochastically(70) do
      consume_item_durability(player, 1)
    end

    vehicle.eject
    player_loc = player.location
    later 0 do
      vehicle.teleport(add_loc(vehicle.location, 0, 0.8, 0))
      player.teleport(player_loc)
      vehicle.set_passenger player

      vehicle.velocity = vehicle.velocity.tap {|v|
        v.set_x(jfloat(v.get_x * 10.0))
        v.set_z(jfloat(v.get_z * 10.0))
      }
    end

    @horse_sword_swing_flag[player.name] = true
    later sec(0.8) do
      @horse_sword_swing_flag[player.name] = false
    end
  end
  private :horse_sword_swing

  def use_enderpearl(action, player)
    return unless Job.of(player) == :enderman
    #return unless action == Action::RIGHT_CLICK_AIR || action == Action::LEFT_CLICK_BLOCK
    return unless action == Action::LEFT_CLICK_AIR || action == Action::LEFT_CLICK_BLOCK
    return unless player.item_in_hand.type == Material::ENDER_PEARL
    friends = Bukkit.online_players.to_a - [player]
    friends = friends.select {|p| p.world == player.world }
    friend = friends.sample
    return unless friend

    friend_loc = friend.location
    locs_nearby = location_around_flat(friend_loc, 3) - [friend_loc]
    available_locs = locs_nearby.select {|l|
      loc_above(l).block.type == Material::AIR &&
        (l.block.type == Material::AIR && loc_below(l).block.type.solid?) ||
        (add_loc(l, 0, 2, 0).block.type == Material::AIR && l.block.type.solid?)
    }
    loc_to = available_locs.max_by {|l| l.distance(friend_loc) }
    return unless loc_to

    play_effect(player.location, Effect::ENDER_SIGNAL, nil)
    play_sound(player.location, Sound::ENDERMAN_TELEPORT , 1.0, 1.5)

    new_loc = (player.location.tap {|l|
      l.set_x loc_to.get_x
      l.set_y loc_to.get_y
      l.set_z loc_to.get_z
    })
    player.teleport(new_loc)
    play_effect(new_loc, Effect::ENDER_SIGNAL, nil)
    play_sound(new_loc, Sound::ENDERMAN_TELEPORT , 1.0, 1.5)
    stochastically(10) do
      consume_item(player)
    end
  end
  private :use_enderpearl

  def on_player_interact(evt)
    feather_freedom_move(evt.player, evt.action)

    # seeded_p = bulldozer_hoe(evt.player, evt.action)
    # if seeded_p
    #   evt.cancelled = true
    #   return
    # end

    killerqueen_explode(evt)
    clock_timechange(evt.player)
    horse_sword_swing(evt.action, evt.player)
    use_enderpearl(evt.action, evt.player)

    if evt.clicked_block
      if evt.action == Action::RIGHT_CLICK_BLOCK && [Material::SIGN, Material::SIGN_POST, Material::WALL_SIGN].include?(evt.clicked_block.type)
        sign_command(evt.player, evt.clicked_block.state, evt)
      end

      case [evt.clicked_block.type, evt.action]
      #when [Material::STONE_PLATE, Action::PHYSICAL]
      #  plate = evt.clicked_block
      #  below = loc_below(plate.location)
      #  cond =
      #    below.block.type == Material::SMOOTH_BRICK &&
      when [Material::TRAP_DOOR, Action::RIGHT_CLICK_BLOCK]
        trapdoor_openclose(evt.clicked_block)
      when [Material::ENDER_CHEST, Action::RIGHT_CLICK_BLOCK]
        evt.cancelled = true if evt.player.world.name == 'mc68'
      when [Material::GRASS, Action::LEFT_CLICK_BLOCK]
        # SPADE can remove grass from dirt
        if SPADES.include? evt.player.item_in_hand.type && !evt.player.item_in_hand.enchantments[Enchantment::SILK_TOUCH]
          evt.clicked_block.type = Material::DIRT
          stochastically(33) do
            drop_item(evt.clicked_block.location, ItemStack.new(Material::SEEDS))
          end
        end
      end

      case [evt.action, evt.player.item_in_hand.type]
      when [Action::RIGHT_CLICK_BLOCK, Material::AIR]
        if evt.block_face == BlockFace::UP
          evt.player.velocity = evt.player.velocity.tap {|v|
            v.set_y 0.4
          }
        end
      end

      # seeding
      case [evt.clicked_block.type, evt.action, evt.player.item_in_hand.type]
      when [Material::DIRT, Action::RIGHT_CLICK_BLOCK, Material::SEEDS]
        consume_item(evt.player)
        evt.clicked_block.type = Material::GRASS
      # rum (not working...?) TODO
      when [Material::SUGAR_CANE_BLOCK, Action::RIGHT_CLICK_BLOCK, Material::POTION]
        potion = evt.player.item_in_hand
        if potion.item_meta.custom_effects.empty?
          break_naturally_by_daxe(evt.clicked_block)
          new_p = Potion.new(48).to_item_stack(1)
          new_p.set_item_meta(new_p.item_meta.tap {|m|
            # 10sec
            m.add_custom_effect(
              PotionEffectType::SLOW_DIGGING.create_effect(sec(10)*2, 3), true)
          })
          evt.player.item_in_hand = new_p
          evt.player.send_message "Rum! #{new_p}"
        end
      # tree -> paper
      when [Material::LOG, Action::RIGHT_CLICK_BLOCK, Material::SHEARS]
        consume_item_durability(evt.player, 1)
        if rand(5) == 0
          stochastically(10) do # 1/(5*10) possibility
            evt.clicked_block.type = Material::WOOD
            evt.clicked_block.data = evt.clicked_block.state.data.species.data
          end
          loc = add_loc(
            evt.clicked_block.location,
            evt.block_face.mod_x, evt.block_face.mod_y, evt.block_face.mod_z)
          play_sound(loc, Sound::SHEEP_SHEAR, 1.0, 1.0)
          drop_item(loc, ItemStack.new(Material::PAPER, 1))
        end
      # grim reaper
      when *( HOES.map { |hoe| [ [ Material::DIRT, Action::RIGHT_CLICK_BLOCK, hoe ], [ Material::GRASS, Action::RIGHT_CLICK_BLOCK, hoe ] ] }.flatten 1 )
        if Job.of(evt.player) == :grimreaper
          location_around_flat(evt.clicked_block.location, 10).each do |loc|
            if [ Material::DIRT, Material::GRASS ].include? loc.block.type
              upper = add_loc(loc, 0, 1, 0).block
              if [ Material::LONG_GRASS, Material::AIR ].include? upper.type
                upper.type = Material::AIR 
                loc.block.type = Material::SOIL
                play_effect(upper.location, Effect::ENDER_SIGNAL, nil) if rand(4) == 0
              end
            end
          end
          # Inochi wo karitoru katachi wo shiteru darou?
          broadcast "The shape looks like--"
          broadcast "                the DEATH."
        end
      end

      case [ evt.player.item_in_hand.type, evt.action ]
      # when [ Material::SPECKLED_MELON, Action::RIGHT_CLICK_BLOCK ], [ Material::SPECKLED_MELON, Action::RIGHT_CLICK_AIR ]
      when [ Material::SPECKLED_MELON, Action::LEFT_CLICK_BLOCK ], [ Material::SPECKLED_MELON, Action::LEFT_CLICK_AIR ]
        evt.player.send_message "lalala..."
        # TODO: play that melody and give player a horse
      when [Material::PAPER, Action::LEFT_CLICK_BLOCK]
        vehicle = evt.player.vehicle
        if vehicle && Minecart === vehicle
          evt.cancelled = true
          loc_rails = vehicle.location
          facing = loc_rails.block.state.data.direction
          #next_locs = [
          #  add_loc(loc_rails, facing.mod_x, facing.mod_y, facing.mod_z),
          #  add_loc(loc_rails, -facing.mod_x, -facing.mod_y, -facing.mod_z)]
          #next_loc = next_locs.find {|l| l.block.type == Material::RAILS }
          next_loc = add_loc(loc_rails, -facing.mod_x, -facing.mod_y, -facing.mod_z)
          if next_loc.block.type == Material::RAILS
            evt.player.send_message next_loc.to_s
            evt.player.send_message next_loc.block.type.to_s
            next_loc_vehicle = add_loc(
              vehicle.location, -facing.mod_x, -facing.mod_y, -facing.mod_z)
            vehicle.teleport(next_loc_vehicle)
            evt.player.teleport(next_loc_vehicle)
          end
        end
      end
    end
  end

  @logout_countdown_table ||= {}
  def sign_command(player, sign_state, evt)
    return if player.world.name == 'mc68'
    @db['sign_location_list'] ||= {}

    location_name = ->(lines){ lines.map(&:downcase).join(" ").gsub(/\s{2,}/, ' ').sub(/\s$/, '') }

    raw_command = sign_state.get_line(0).downcase
    args = 1.upto(3).map {|n| sign_state.get_line n }

    if /<(.+)>/ =~ raw_command
      command = $1.to_sym
      evt.cancelled = true
      case command
      when :login
        player.send_message "You already logged in (already)"
      when :logout
        unless @logout_countdown_table[player]
          @logout_countdown_table[player] = 10
          player.send_message "Logout countdown started!"
        end
      when :warp
        name = location_name.call args
        if @db['sign_location_list'][name]
          loc = deserialize_location @db['sign_location_list'][name]
          # safety_loc = location_around_flat(loc, 2).find{ |loc| loc.block.type == Material::AIR }
          face = loc.block.state.data.facing
          safety_loc = add_loc(loc, face.mod_x, face.mod_y, face.mod_z)
          if safety_loc
            pitch, yaw = face2pitchyaw(face)
            safety_loc.set_yaw(yaw + 180)
            play_effect(safety_loc, Effect::ENDER_SIGNAL, nil)
            player.teleport safety_loc
            broadlingr "#{player.name} teleported to #{name}"
          else
            player.send_message "No such location or there aren't safety place around the sign."
          end
        else
          player.send_message "Not found the location named '#{ name }'"
        end
      when :location
        name = location_name.call args
        loc = sign_state.location.clone

        @db['sign_location_list'][name] = serialize_location loc
        db_save
        broadlingr "#{player.name} added: [#{name}] loc(#{[loc.x, loc.y, loc.z].join ","})"
      #when :direction
      #  player.teleport(player.location.tap {|l|
      #    pitch, yaw = face2pitchyaw(sign_state.data.facing)
      #    #l.set_pitch(pitch)
      #    l.set_yaw(yaw)
      #  })
      when :locationlist
        @db['sign_location_list'].each do |name, sloc|
          loc = deserialize_location sloc
          player.send_message "#{name}: loc(#{[loc.x, loc.y, loc.z].join ","})"
        end
      end
    end
  end

  def on_block_damage(evt)
    player = evt.player
    damaged_block = evt.block

    player.damage 1 if player.item_in_hand.type == Material::AIR

    # player.send_message "#{ damaged_block.type }"

    case damaged_block.type
    when Material::SAND
      if !player.sneaking? && !loc_above(damaged_block.location).block.liquid?
        break_naturally_by_dpickaxe(damaged_block)
        # TODO use something like location_around
        diffs = [[-1, 0, 0], [1, 0, 0], [0, -1, 0], [0, 1, 0], [0, 0, -1], [0, 0, 1]]
        diffs.each do |x, y, z|
          block = damaged_block.location.clone.add(x, y, z).block
          if block.type == Material::SAND
            break_naturally_by_dpickaxe(block)
          end
        end
      end
    end
  end

  silence_warnings do
    AXES = [Material::STONE_AXE, Material::WOOD_AXE, Material::DIAMOND_AXE,
            Material::IRON_AXE,  Material::GOLD_AXE]
    SPADES = [Material::STONE_SPADE, Material::WOOD_SPADE, Material::DIAMOND_SPADE,
            Material::IRON_SPADE,  Material::GOLD_SPADE]
    HOES = [Material::STONE_HOE, Material::WOOD_HOE, Material::DIAMOND_HOE,
            Material::IRON_HOE,  Material::GOLD_HOE]
    PICKAXES = [Material::STONE_PICKAXE, Material::WOOD_PICKAXE, Material::DIAMOND_PICKAXE,
            Material::IRON_PICKAXE,  Material::GOLD_PICKAXE]
    SWORDS = [Material::STONE_SWORD, Material::WOOD_SWORD, Material::DIAMOND_SWORD,
            Material::IRON_SWORD,  Material::GOLD_SWORD]

    ZOMBIES = [EntityType::PIG_ZOMBIE, EntityType::ZOMBIE]
  end

  def on_inventory_open(evt)
    #p evt.inventory.holder
  end

  def on_player_chat_tab_complete(evt)
    #p evt.chat_message
    player = evt.player
    loc = player.location

    play_sound(loc, Sound::SWIM, 0.8, 1.0)
  end

  def on_player_command_preprocess(evt)
    player, message = [evt.player, evt.message]

    Bukkit.get_player('ujm').send_message "[DEBUG] #{player.name} #{message}"
    case message
    when '/gamemode 1'
      strike_lightning(player.location)
      play_sound(player.location, Sound::EXPLODE, 1.0, 0.0)
    when '/gamemode 0'
      play_sound(player.location, Sound::EAT, 1.0, 1.0)
    end
  end

  def bulldozer_break(broken_block, player)
    return unless Job.of(player) == :bulldozer
    return if player.sneaking?
    tool_block_type_table = {
      SPADES => [Material::DIRT, Material::GRASS, Material::SAND, Material::GRAVEL],
      PICKAXES => [Material::NETHERRACK, Material::STONE, Material::COAL_ORE, Material::COBBLESTONE]}
    _, block_group = tool_block_type_table.find {|tools, block_group|
      block_group.include?(broken_block.type) && tools.include?(player.item_in_hand.type)
    }
    return unless block_group
    blocks = location_around(broken_block.location, 1).
      select {|loc| loc.y >= player.location.y }.
      map(&:block).
      select {|block| block_group.include? block.type }
    return if blocks.empty?
    later 0 do
      blocks.each do |block|
        break if player.item_in_hand.type == Material::AIR
        break_naturally_by_dpickaxe(block)
        consume_item_durability(player, 1) if 7 > rand(10) # 70%
      end
    end
  end
  private :bulldozer_break

  def on_block_break(evt)
    broken_block = evt.block
    player = evt.player

    bulldozer_break(broken_block, player)

    case evt.block.type
    #when Material::SUGAR_CANE_BLOCK
    #  evt.cancelled = true
    #  evt.block.type = Material::AIR
    when Material::LOG
      if AXES.include? evt.player.item_in_hand.type
        kickory(evt.block, evt.player)
      else
        evt.player.send_message "(you can't cut tree without an axe!)"
        evt.player.send_message "(cut tree leaves that may have wood sticks.)"
        evt.cancelled = true
      end

      if rand(10) == 0
        drop_item(evt.block.location, ItemStack.new(Material::EGG, 1))
      end
    when Material::LEAVES
      if rand(3) == 0
        drop_item(evt.block.location, ItemStack.new(Material::STICK, 1))
      end
    when Material::GRASS
      unless evt.player.item_in_hand.enchantments[Enchantment::SILK_TOUCH]
        evt.cancelled = true
        evt.block.type = Material::DIRT
      end
    when Material::LONG_GRASS
      drop_item(evt.block.location, ItemStack.new(Material::SEEDS, 1))
    when Material::STONE
      case rand(5)
      when 0
        evt.cancelled = true
        evt.block.type = Material::THIN_GLASS
        evt.block.setMetadata("salt", FixedMetadataValue.new(@plugin, true))
      when 1
        # nop
      else
        evt.cancelled = true
        evt.block.type = Material::COBBLESTONE
      end
    end
    if !evt.cancelled && evt.block.hasMetadata("salt")
      drop_item(evt.block.location, ItemStack.new(Material::SUGAR))
      evt.block.removeMetadata("salt", @plugin)
    end

    unless evt.cancelled
      fall_chain_above = ->(base_block) {
        later sec(0.1) do
          unless base_block.type.solid?
            block_above = add_loc(base_block.location, 0, 1, 0).block
            case block_above.type
            when Material::DIRT, Material::LEAVES
              fall_block(block_above)
              fall_chain_above.(block_above)
            end
          end
        end
      }
      fall_chain_above.(evt.block)
    end
  end

  def on_food_level_change(evt)
    #evt.getEntity.setVelocity(Vector.new(0.0, 2.0, 0.0))
    player = evt.entity
    eating_p = player.food_level < evt.food_level
    if eating_p
      if @logout_countdown_table[player]
        @logout_countdown_table[player] += 10
        player.send_message "You got 10 more second until logout! (#{@logout_countdown_table[player]})"
      end

      case player.item_in_hand.type
      when Material::RAW_BEEF, Material::RAW_CHICKEN, Material::PORK
        player.send_message "(food poisoning!)"
        @food_poisoning_player << player
        later sec(60) do
          if Bukkit.online_players.include? player and @food_poisoning_player.include? player
            # TODO supermomonga
            # food poisoning. the player may die in the worst case.
            @food_poisoning_player.delete player
          end
        end
      when Material::POTATO_ITEM
        player.send_message "(raw potato doesn't satisfy you!)"
        evt.cancelled = true
      end
    end
  end

  def on_creature_spawn(evt)
    case evt.spawn_reason
    # when CreatureSpawnEvent::SpawnReason::SPAWNER_EGG
    when CreatureSpawnEvent::SpawnReason::EGG
      evt.cancelled = true
    when CreatureSpawnEvent::SpawnReason::REINFORCEMENTS
      strike_lightning(evt.location)
    when CreatureSpawnEvent::SpawnReason::NATURAL
      if evt.location.block.light_level >= 8
        case evt.entity
        when Ghast, MagmaCube, PigZombie
          evt.cancelled = true
        end
      end
      case evt.entity
      #when Zombie
      #  spawn(evt.location, EntityType::SPIDER)
      #  evt.cancelled = true
      when CaveSpider
      when Spider
        loc = evt.location
        stochastically(80) do
          later sec(5) do
            spawn(loc, EntityType::SPIDER)
          end
          later sec(10) do
            spawn(loc, EntityType::SPIDER)
          end
        end
      end
    end
  end

  def on_block_piston_extend(evt)
    if evt.direction.mod_y == 1
      final_block_loc =
        if evt.blocks.to_a.empty?
          evt.block.location
        else
          evt.blocks.to_a.last.location
        end
      entities = final_block_loc.chunk.entities.select {|e|
        loc = e.location.block.location
        final_block_loc == add_loc(loc, 0, 2, 0) ||
          final_block_loc == add_loc(loc, 0, 1, 0) ||
          final_block_loc == add_loc(loc, 0, 0, 0)
      }
      later 0 do
        entities.each do |e|
          e.teleport(add_loc(e.location, 0, 1, 0))
          e.fall_distance = 0.0
        end
      end
    end
  end

  def on_block_piston_retract(evt)
    retract_block = evt.retract_location.block
    if evt.sticky? && retract_block.type == Material::FENCE
      face = evt.direction
      tuples = cloop(20, retract_block, []) {|recur, num, cur_block, acc|
        if num == 0 || !cur_block.type.solid?
          [[cur_block, Material::AIR, nil]] + acc
        else
          b = add_loc(
            cur_block.location, face.mod_x, face.mod_y, face.mod_z).block
          recur.(num - 1, b, [[cur_block, b.type, b.state.data]] + acc)
        end
      }
      later 0 do
        tuples.each do |goes_to, btype, bdata|
          goes_to.type = btype
          if bdata
            let(goes_to.state) do |state|
              state.data = bdata
              state.update()
            end
          end
        end
      end
    end
  end

  def on_block_physics(evt)
    case evt.block.type
    when Material::TRAP_DOOR
      trapdoor_openclose(evt.block)
    when Material::STONE_BUTTON
      button = evt.block
      if button.state.data.powered?
        face = button.state.data.attached_face
        attached = add_loc(button.location, face.mod_x, face.mod_y, face.mod_z)
        if attached.block.type == Material::JUKEBOX
          on_juke = loc_above(attached)
          items = on_juke.chunk.entities.select {|e|
            Item === e &&
              e.location.block.location == on_juke
          }
          papers = items.select {|e|
            e.item_stack.type == Material::PAPER
          }
          map_idx = items.find {|e|
            e.item_stack.type == Material::MAP
          }
          map_idx = map_idx.item_stack.data.data if map_idx
          Bukkit.get_player('ujm').send_message map_idx.to_s if map_idx
          smoke_effect(on_juke)
          play_sound(on_juke, Sound::PIG_IDLE, 1.0, 2.0)
          play_sound(on_juke, Sound::PIG_IDLE, 1.0, 0.0)
          papers.each do |paper|
            map = paper.world.drop_item(paper.location, ItemStack.new(Material::MAP, paper.item_stack.amount))
            paper.remove
          end
        end
      end
    when Material::JACK_O_LANTERN
      #lantern_piston(evt.block)
    end
  end

  def lantern_piston(block)
    @last_lantern_piston ||= {}
    loc = block.location
    return if @last_lantern_piston[loc]

    later 0 do # for getting facing
      facing = block.state.data.facing
      loc_next = add_loc(block.location, facing.mod_x, facing.mod_y, facing.mod_z)
      strike_lightning(loc_next)
      Bukkit.get_player('ujm').send_message facing.to_s
      @last_lantern_piston[loc] = true
      later sec(1) do
        @last_lantern_piston[loc] = false
      end
    end
  end
  private :lantern_piston

  @earthwork_squids ||= {}
  def on_block_dispense(evt)
    item = evt.item
    case item.type
    when Material::MONSTER_EGG
      if item.data.spawned_type == EntityType::SQUID
        evt.item = ItemStack.new(Material::DIRT, 1) # dirty hack
        dispenser = evt.block
        face = dispenser.state.data.facing
        loc = add_loc(block2loc(dispenser), face.mod_x, face.mod_y, face.mod_z)
        squid = spawn(loc, EntityType::SQUID)
        players = squid.get_nearby_entities(2, 2, 2).
          select {|e| Player === e }.
          map(&:name)
        unless players.empty?
          squid.max_health = 30
          @earthwork_squids[squid] = [loc, face.mod_x, face.mod_y, face.mod_z]
          broadlingr "An earthwork squid started working near #{players.join ' and '}."
        end
      end
    end
  end

  def on_entity_damage_by_entity(evt)
    defender = evt.entity
    case evt.damager
    when Arrow
      arrow = evt.damager
      if Player === defender && defender.blocking?
        play_sound(defender.location, Sound::ANVIL_LAND, 0.5, rand * 2)
        evt.damage = 0
      else
        case arrow.shooter
        when Player
          player = arrow.shooter
          if Job.of(player) == :archer
            # because it's fast
            evt.damage *= 0.85
          else
            evt.damage *= 2.0
          end

          # zombie pigman guards all arrows
          if PigZombie === defender
            evt.cancelled = true
            defender.damage(0, player)
            vel = arrow.velocity.multiply(jfloat(-1.0))
            later 0 do
              arrow.velocity = vel
            end
          end
        when Skeleton
          evt.damage *= 2.0
        end
      end
    when Snowball
      if Player === defender && evt.damager.shooter == defender
        evt.cancelled = true
      end
    when Egg
      case defender
      when Player
        defender.food_level = [defender.food_level + 2, 20].min
        defender.exhaustion = jfloat(0)
      when Villager
        if Player === evt.damager.shooter
          villager = defender
          player = evt.damager.shooter

          evt.cancelled = true
          evt.damager.remove
          villager.set_leash_holder player
        end
      end
    when Player
      player = evt.damager

      case defender
      when Player
        sword_blocking_counter_attack(evt, defender, player)
        if @ctf_players.member?(player) && @ctf_players.member?(defender)
          if defender.passenger && Squid === defender.passenger
            squid = defender.passenger
            defender.eject
            later 0 do
              squid.teleport(squid.location.tap {|l|
                l.set_x((-535 + -606) / 2)
                l.set_y(65)
                l.set_z((81 + 153) / 2)
              })
            end
          else
            evt.damage = 0
            strike_lightning(defender.location)
            helmet = defender.inventory.helmet
            defender.teleport(defender.location.tap {|l|
              cond = helmet && helmet.type == Material::SKULL_ITEM
              cond ? l.set_z(81) : l.set_z(153)
              cond ? l.set_x(-535) : l.set_x(-606)
            })
          end
          return
        end
      when Squid
        evt.cancelled = true
      end

      if Player === defender && @logout_countdown_table[player]
        @logout_countdown_table[defender] = @logout_countdown_table[player]
        @logout_countdown_table.delete(player)
        broadcast "#{player.name}'s logout countdown went to #{defender.name}! (#{@logout_countdown_table[defender]})"
      end

      if Job.of(player) == :archer && evt.damage > 0.0
        new_damage = [(evt.damage * 0.7).to_i, 1].max
        player.send_message "You are archer; the damage isn't #{evt.damage} but #{new_damage}"
        evt.damage = new_damage
      end

      item = player.item_in_hand
      if item && item.type == Material::PAPER
        case defender
        when Zombie
          evt.damage = 9
          defender.no_damage_ticks = 0
          later 0 do
            if defender.valid?
              defender.velocity = defender.velocity.zero
            else
              player.send_message 'Paper cut!'
            end
          end
          if rand(10) == 0
            consume_item(player)
          end
        when Squid
          play_sound(defender.location, Sound::CAT_MEOW , 0.8, 1.0)
        end
      end
    when LivingEntity
      case defender
      when Player
        sword_blocking_counter_attack(evt, defender, evt.damager)
      end
    end
  end

  def sword_blocking_counter_attack(evt, player, damager)
    if player.blocking?
      play_sound(player.location, Sound::ANVIL_LAND, 0.3, rand * 2)
      if PigZombie === damager
        evt.cancelled = true
      else
        damager.damage(evt.damage, player)
        evt.cancelled = true
      end
    end
  end
  private :sword_blocking_counter_attack

  def on_player_drop_item(evt)
    item_suplied_turn = {
      Material::SUGAR => {
        EntityType::ZOMBIE => EntityType::VILLAGER,
        EntityType::PIG_ZOMBIE => EntityType::PIG,
        EntityType::MUSHROOM_COW => EntityType::COW
      },
      Material::ROTTEN_FLESH => {
        EntityType::VILLAGER => EntityType::ZOMBIE,
        EntityType::PIG => EntityType::PIG_ZOMBIE
      }
    }
    item = evt.item_drop
    later sec(0.7) do
      if item.valid? && item_suplied_turn[item.item_stack.type]
        item_stack = item.item_stack
        entity = item.get_nearby_entities(2, 2, 2).select {|e|
          item_suplied_turn[item_stack.type][e.type]
        }.sample
        if entity
          transform_to = item_suplied_turn[item_stack.type][entity.type]
          if transform_to && rand(2) == 0
            newbie = spawn(entity.location, transform_to)
            # bukkit is terrible
            if entity.respond_to?(:baby?) && entity.baby? && newbie.respond_to?(:baby=)
              newbie.baby = true
            end
            play_effect(entity.location, Effect::ENDER_SIGNAL, nil) # TODO: smoke
            entity.remove
          end
        end
        item.remove
      end
    end
  end

  def on_entity_damage_by_block(evt)
    #broadcast "[test] on entity damage by block: #{ evt.damager.type }"
  end

  def damage_by_falling(evt)
    falld = evt.entity.fall_distance
    entity = evt.entity
    if entity.vehicle
      evt.cancelled = true
      return
    end
    loc_below = add_loc(entity.location, 0, -1, 0)
    block_below = loc_below.block
    case block_below.type
    when Material::GRASS
      evt.cancelled = true
      block_below.type = Material::DIRT
      entity.velocity = entity.velocity.tap{|v|
        v.add Vector.new(jfloat(0.0), jfloat(0.4), jfloat(0.0))
      }
    when Material::LEAVES
      evt.damage = 1
      entity.teleport(add_loc(entity.location, 0, -0.1, 0))
      if add_loc(entity.location, 0, -1.9, 0).block.type == Material::LEAVES
        later 0 do
          entity.fall_distance = falld
        end
      end
    when Material::WOOL
      evt.cancelled = true
      later 0 do
        entity.velocity = entity.velocity.tap {|v|
          v.set_y([Math.log(falld) * 0.4, 5.0].min)
        }
      end
    end
  end

  def generate_item_from_falling(evt)
    falld = evt.entity.fall_distance
    entity = evt.entity
    loc_below = add_loc(entity.location, 0, -1, 0)
    block_below = loc_below.block
    case block_below.type
    when Material::COAL_BLOCK
      if Player === evt.entity
        evt.entity.send_message "fall distance: #{falld.to_i}"
        if falld >= 18 && rand(5) > 1
          surround = location_around_flat(loc_below, 1) - [loc_below]
          num_lava = surround.map(&:block).count {|b|
            [Material::LAVA, Material::STATIONARY_LAVA].include? b.type
          }
          if num_lava > 5
            block_below.type = Material::AIR
            drop_item(
              evt.entity.location, ItemStack.new(Material::DIAMOND, [*1..4].sample))
          end
        end
      end
    end
  end

  def on_entity_damage(evt)
    entity = evt.entity
    case evt.cause
    when EntityDamageEvent::DamageCause::FALL
      damage_by_falling evt
      generate_item_from_falling evt
      #evt.cancelled = true
      #explode(evt.getEntity.getLocation, 1, false)
    when EntityDamageEvent::DamageCause::DROWNING
      case entity
      when Squid
        if ctf_in_area?(entity.location)
          evt.cancelled = true
        end
      end
    end

  end

  def on_player_toggle_sprint(evt)
    #player_update_speed(evt.player, spp: evt.sprinting?)
    return if evt.player.passenger && Squid === evt.player.passenger
    if evt.sprinting? && !evt.player.passenger
      if evt.player.location.clone.add(0, -1, 0).block.type == Material::SAND
        evt.cancelled = true
      else
        if @ctf_players.member?(evt.player)
          evt.player.walk_speed = 0.3
        else
          evt.player.walk_speed = 0.4
        end
      end
    else
      evt.player.walk_speed = 0.2
    end
  end

  def ctf_sneaking(player)
    passenger = player.passenger
    if passenger && Squid === passenger
      msg = "#{player.name} put a flag on #{player.location.block.type.to_s.downcase}."
      broadlingr msg
      player.eject
      later 0 do
        vel = player.velocity
        player.send_message [vel.get_x, vel.get_z].map(&:to_s).to_s
        passenger.velocity = vel.tap {|v|
          v.set_x(v.get_x * 1.5)
          v.set_y(v.get_y + 0.8)
          v.set_z(v.get_z * 1.5)
        }
      end
    else
      squid = player.get_nearby_entities(0.8, 0.8, 0.8).find {|e| Squid === e }
      if squid
        smoke_effect(squid.location)
        play_sound(player.location, Sound::EAT, 1.0, 2.0)
        play_sound(player.location, Sound::EAT, 1.0, 0.0)
        player.set_passenger squid
        player.walk_speed = 0.1
      end
    end
  end
  private :ctf_sneaking

  #HARD_BOOTS = [Material::CHAINMAIL_BOOTS, Material::IRON_BOOTS,
  #              Material::DIAMOND_BOOTS, Material::GOLD_BOOTS]
  def on_player_toggle_sneak(evt)
    player = evt.player

    # Superjump
    name = player.name
    @crouching_counter ||= {}
    @crouching_counter[name] ||= 0
    @crouching_countingdown ||= false
    if evt.sneaking?
      # counting up
      @crouching_counter[name] += 1
      later sec(2.5) do
        @crouching_counter[name] -= 1
      end
      if @crouching_counter[name] == 5
        play_sound(add_loc(player.location, 0, 5, 0), Sound::BAT_TAKEOFF, 1.0, 0.0)
        # evt.player.send_message "superjump!"
        player.fall_distance = 0.0
        player.velocity = player.velocity.tap {|v| v.set_y jfloat(1.4) }
      end

      # map teleport
      if player.location.pitch == 90.0 && player.world.name != 'mc68'
        item = player.item_in_hand
        if item && item.type == Material::MAP
          map = Bukkit.get_map(item.data.data)
          loc = block2loc(map.world.get_highest_block_at(map.center_x, map.center_z))
          loc = add_loc(loc, 0, 3, 0)
          loc.pitch = 90.0
          loc.yaw = player.location.yaw
          loc.chunk.load

          animals = player.get_nearby_entities(2, 2, 2).select {|e|
            Animals === e || Player === e || Villager === e
          }
          ([player] + animals).each do |e|
            play_effect(player.location, Effect::ENDER_SIGNAL, nil)
            play_sound(player.location, Sound::ENDERMAN_TELEPORT , 1.0, 0.5)
            e.teleport(loc)
            e.fall_distance = 0.0
            play_effect(player.location, Effect::ENDER_SIGNAL, nil)
            play_sound(loc, Sound::ENDERMAN_TELEPORT , 1.0, 0.5)
          end
        end
      end

      ctf_sneaking(player) if @ctf_players.member?(player)
    end

    #player_update_speed(evt.player, snp: evt.sneaking?)

    #player = evt.player
    #if player.equipment.boots && HARD_BOOTS.include?(player.equipment.boots.type)
    #  if !evt.player.on_ground? && evt.sneaking?
    #    later 0 do
    #      newloc = player.location
    #      newloc.x = newloc.x.to_i.to_f - 0.5
    #      newloc.z = newloc.z.to_i.to_f - 0.5
    #      player.teleport newloc
    #      play_effect(newloc, Effect::ENDER_SIGNAL)
    #      player.velocity = Vector.new(0.0, -1.0, 0.0)
    #    end
    #    loc = (1..4).lazy.
    #      map {|y| evt.player.location.clone.add(0, -y, 0) }.
    #      find {|l| l.block.type != Material::AIR }
    #    later sec(0.2) do
    #      if loc && loc.block.type == Material::STONE
    #        loc.block.break_naturally(ItemStack.new(Material::DIAMOND_PICKAXE))
    #      end
    #    end
    #  end
    #end
  end

  def on_projectile_launch(evt)
    projectile = evt.entity
    shooter = projectile.shooter
    case shooter
    when Player
      case projectile
      when Arrow
        # enchant book infinite
        item0 = shooter.inventory.get_item(0)
        if item0 && item0.type == Material::ENCHANTED_BOOK && item0.item_meta.stored_enchants[Enchantment::ARROW_INFINITE]
          drop_item(shooter.location, ItemStack.new(Material::ARROW, 1))
        end

        if !shooter.on_ground? && shooter.fall_distance > 0
          projectile.velocity = projectile.velocity.multiply(jfloat(2.0))
          play_sound(shooter.location, Sound::SILVERFISH_HIT, 1.0, 0.5)
        end
        # bumeran
        if shooter.sneaking? && !shooter.item_in_hand.enchantments[Enchantment::ARROW_INFINITE]
          later sec(0.7) do
            if projectile.valid?
              #projectile.velocity = projectile.velocity.multiply(jfloat(-1.1))
              vel = projectile.velocity.multiply(jfloat(-0.9))
              projectile.remove
              item = drop_item(projectile.location, ItemStack.new(Material::ARROW, 1))
              later 0 do
                item.velocity = vel
              end
            end
          end
        end

        if Job.of(shooter) == :archer
          projectile.velocity = projectile.velocity.multiply(jfloat(1.9))
        else
          projectile.velocity = projectile.velocity.multiply(jfloat(0.5))
        end
      end
    when Skeleton
      case projectile
      when Arrow
        projectile.velocity = projectile.velocity.tap {|v|
          v.multiply(jfloat(0.4))
          v.add(Vector.new(0.0, 0.3, 0.0))
        }
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

  def kickory(block, player)
    break_naturally_by_dpickaxe(block)
    unless player.sneaking?
      [[0, 1, 0], [1, 1, 0], [0, 1, 1], [-1, 1, 0], [0, 1, -1]].each do |x, y, z|
        loc = block.location.clone.add(x, y, z)
        kickory(loc.block, player) if loc.block.type == Material::LOG
      end
    end
  end

  def update_recipes
    Bukkit.reset_recipes
    recipes = Bukkit.recipe_iterator.to_a
    Bukkit.clear_recipes
    recipes.
      reject {|r| r.result.type == Material::BREAD }.
      each {|r| Bukkit.add_recipe r }
    # bread furnace
    bread_furnace = FurnaceRecipe.new(
      ItemStack.new(Material::BREAD),
      Material::WHEAT)
    Bukkit.add_recipe bread_furnace
    # Eggs
    egg_recipes = [
      # { egg_id: 50, ingredient: Material::SULPHUR },      # Creeper
      { egg_id: 51, ingredient: Material::BONE },         # Skeleton
      { egg_id: 54, ingredient: Material::ROTTEN_FLESH }, # Zombie
      { egg_id: 55, ingredient: Material::SLIME_BALL },   # Slime
      { egg_id: 94, ingredient: Material::INK_SACK }      # Squid
    ]
    egg_recipes.each do |r|
      egg = ShapedRecipe.new(ItemStack.new(Material::MONSTER_EGG, 1, r[:egg_id]))
      egg.shape "aaa", "aba", "aaa"
      egg.set_ingredient(jchar('a'), r[:ingredient])
      egg.set_ingredient(jchar('b'), Material::EGG)
      Bukkit.add_recipe egg
    end
    # torch to coal
    torch_coal = ShapelessRecipe.new(ItemStack.new(Material::COAL, 1))
    torch_coal.add_ingredient(2, Material::TORCH)
    Bukkit.add_recipe torch_coal

    # job recipes
    # TODO: move to each Job class
    Job.set_recipe(:novice, {
      masteries: {novice: 0},
      votive: [
        ItemStack.new(Material::SUGAR, 1),
        ItemStack.new(Material::COBBLESTONE, 1)
      ]
    })
    Job.set_recipe(:killerqueen, {
      masteries: {novice: 0},
      votive: [
        ItemStack.new(Material::SULPHUR, 64),
        ItemStack.new(Material::SUGAR, 64),
        ItemStack.new(Material::DIAMOND, 32)
      ]
    })
  end

  def on_command(sender, cmd, label, args)
    args = args.to_a
    case label
    when 'lingr'
      case sender
      when Player
        false
      else
        post_lingr args.join ' '
        true
      end
    when "mck"
      case sender
      when Player
        mck_cmd = args[0]
        if mck_cmd
          case mck_cmd
          when "job"
            sender.send_message "This feature will not be available tomorrow."
            Job.become(sender, args[1].to_sym) if args[1]
          when "update-recipe"
            update_recipes
            broadcast "Recipe updated!"
          when "what-time"
            broadcast Time.now.to_s
          when "list-enchant"
            names = Enchantment.values.to_a.
              map(&:name).map(&:downcase)
            names.each_slice(3) do |names2|
              sender.send_message names2.join ', '
            end
          when "countdown"
            5.times do |i|
              later sec(i) do
                broadcast "[COUNTDOWN] <#{sender.name}> #{4 - i}"
              end
            end
          when "another-world"
            current_world = sender.world.name
            next_world = {
              "world" => "mc68",
              "mc68" => "world",
            }[current_world]
            if next_world && Bukkit.get_world(next_world)
              sender.fall_distance = 0.0
              broadlingr "#{sender.name} goes to another world! #{current_world} -> #{next_world}"
              combined_contents =
                [sender.inventory.contents.to_a, sender.inventory.armor_contents.to_a]
              serialized_inv = combined_contents.map {|contents|
                contents.map {|is| is && is.serialize }
              }
              @db['item_backup'] ||= {}
              @db['item_backup'][sender.name] ||= {}
              @db['item_backup'][sender.name][current_world] = serialized_inv
              if @db['item_backup'][sender.name][next_world]
                contents, (boots, leggings, chestplate, helmet) =
                  @db['item_backup'][sender.name][next_world]
                contents.each_with_index do |is_str, idx|
                  if is_str
                    is = ItemStack.deserialize(is_str)
                    sender.inventory.set_item(idx, is)
                  else
                    sender.inventory.set_item(idx, nil)
                  end
                end
                sender.inventory.set_boots ItemStack.deserialize(boots)
                sender.inventory.set_leggings ItemStack.deserialize(leggings)
                sender.inventory.set_chestplate ItemStack.deserialize(chestplate)
                sender.inventory.set_helmet ItemStack.deserialize(helmet)
              else
                sender.inventory.clear()
                sender.inventory.armor_contents = nil
              end
              db_save()
              strike_lightning(sender.location)
              loc_to = Bukkit.get_world(next_world).spawn_location
              sender.teleport(loc_to)
              strike_lightning(loc_to)
            end
          end
        end
        true
      else
        false
      end
    when "inv"
      case sender
      when Player
        sender.open_workbench sender.location, true
        play_sound(sender.location, Sound::ANVIL_LAND, 1.0, 1.0)
        true
      else
        false
      end
    else
      false
    end
  end

  def ctf_in_area?(loc)
    -610 <= loc.x && loc.x <= -532 &&
      79 <= loc.z && loc.z <= 157
  end

  def ctf_centre_xyz
    [-571, 65.5, 118]
  end

  @ctf_players ||= Set.new
  def on_player_move(evt)
    player = evt.player
    diff_y = evt.to.y - evt.from.y

    if !@ctf_players.member?(player) && ctf_in_area?(evt.to)
      @ctf_players << player
      broadcast "#{player.name} joined CTF!"
    elsif @ctf_players.member?(player) && !ctf_in_area?(evt.to)
      #later 0 do
      #  new_loc = player.location.tap {|l|
      #    x, y, z = ctf_centre_xyz
      #    l.set_x x
      #    l.set_y y
      #    l.set_z z
      #  }
      #  player.teleport(new_loc)
      #  play_effect(new_loc, Effect::ENDER_SIGNAL, nil)
      #end
      @ctf_players.delete(player)
      broadcast "#{player.name} left CTF..."
    end

    # barrage_visual_orb(player)

    # fall damage cancel with sword blocking
    if diff_y < 0 && player.blocking? && player.fall_distance >= 4.0
      player.fall_distance = 4.0
      player.velocity = player.velocity.set_y jfloat(player.velocity.get_y * 0.75)
    end
    # experimental
    #if player.name == 'ujm' && player.item_in_hand.type == Material::SUGAR
    #  below = loc_below(player.location)
    #  if below.block.type == Material::SMOOTH_BRICK
    #    [[1, 0], [0, 1], [1, 1]].each do |x, z|
    #      loc = add_loc(below, x, 0, z)
    #      if loc.block.type == Material::AIR
    #        loc.block.type = Material::SMOOTH_BRICK
    #      end
    #    end
    #  end
    #end

    # fastwater
    cond =
      diff_y > 0 &&
      player.location.pitch == -90.0 &&  # going up, looking above
      !player.sneaking?
    if cond
      block = player.location.block
      if block.type == Material::STATIONARY_WATER && block.data == 8 # flowing downward
        (1..7).each do |i|
          newloc = add_loc(evt.to, 0, i, 0)
          if newloc.block.type == Material::STATIONARY_WATER
            evt.to = newloc
          else
            break
          end
        end
      end
    end

    # if player.sneaking?
    #   @phantom_ladder ||= {}
    #   loc = player.location
    #   unless @phantom_ladder[loc]
    #     @phantom_ladder[loc] = true
    #     player.send_block_change(loc, Material::LADDER, 0)
    #     later sec(5) do
    #       @phantom_ladder[loc] = false
    #       player.send_block_change(loc, loc.block.type, loc.block.data)
    #     end
    #   end
    # end

    # fastladder
    if player.location.block.type == Material::LADDER && !player.sneaking?
      case player.location.pitch
      when -90.0 # up
        if diff_y > 0
          to = evt.to
          (1..7).each do |i|
            newloc = add_loc(evt.to, 0, i, 0)
            if newloc.block.type == Material::LADDER
              to = newloc
            else
              break
            end
          end
          evt.to = to
        end
      when 90.0 #down
        if diff_y < 0
          to = evt.to
          (1..7).each do |i|
            newloc = add_loc(evt.to, 0, -i, 0)
            if newloc.block.type == Material::LADDER
              to = newloc
            else
              break
            end
          end
          evt.to = to
        end
      end
    end
  end

  def on_server_command(evt)
  end

  def db_save
    File.open @db_path, 'w' do |io|
      io.write @db.to_json
    end
  end

  def holy_water(creatures)
    liquid = [
      Material::WATER, Material::STATIONARY_WATER,
      Material::LAVA, Material::STATIONARY_LAVA]
    monsters = creatures.select {|e| Monster === e }
    monsters.select {|m|
      liquid.include?(m.location.block.type) &&
        add_loc(m.location, 0, -1, 0).block.type == Material::LAPIS_BLOCK
    }.each do |m|
      m.damage(4)
    end
  end
  private :holy_water

  def earthwork_squids_work(squid)
    loc, mod_x, mod_y, mod_z = @earthwork_squids[squid]
    unless squid.valid?
      @earthwork_squids.delete(squid)
      return
    end
    if rand(100) == 0
      squid.damage(squid.max_health)
      return
    end

    loc = add_loc(loc, mod_x, mod_y, mod_z)
    soft_blocks = [ # TODO
      Material::GRASS, Material::DIRT, Material::STONE, Material::LONG_GRASS,
      Material::COBBLESTONE, Material::LEAVES, Material::GRAVEL, Material::SAND,
      Material::COAL_ORE]
    cond = soft_blocks.include?(loc.block.type)
    if cond
      break_naturally_by_dpickaxe(loc.block)
      smoke_effect(loc)
      play_sound(loc, Sound::EAT, 0.8, 0.8)
    end
    if cond || !loc.block.type.solid?
      # update!
      @earthwork_squids[squid][0] = loc

      squid.teleport(loc)
      squid.health = squid.max_health

      loc = loc_above(loc)
      if soft_blocks.include?(loc.block.type)
        break_naturally_by_dpickaxe(loc.block)

        loc = loc_above(loc)
        if [Material::LAVA, Material::STATIONARY_LAVA].include?(loc.block.type)
          loc.block.type = Material::GLASS
          loc.block.data = 0
        end
      end
    end
  end


  def periodically_tick
    return # just for now
    online_players = Bukkit.online_players
    online_players.map {|p| p.location.block }.uniq.each {|b|
      rotate_sign(b)
    }

    online_players.each do |player|
      # barrage_visual_orb(player, :inside, 2, 5, 1)
      barrage_visual_orb(player, :outside, 4, 24, 2)
      # barrage_visual_orb(player, :exp1, 3,  6,  1)
      # barrage_visual_orb(player, :exp2, 4, 12, -2)
      # barrage_visual_orb(player, :exp3, 5, 24,  3)
      # barrage_visual_orb(player, :exp4, 6, 36, -4)
    end
  end

  def wild_golem(nearby_creatures, online_players)
    golems = nearby_creatures.select {|c|
      IronGolem === c && !c.player_created?
    }
    #Bukkit.get_player('ujm').send_message golems.map(&:target).join
    golems.each do |g|
      g_loc = g.location
      player = online_players.min_by {|p| g_loc.distance(p.location) }
      g.damage(0, player)
      g.no_damage_ticks = 0
    end
  end
  private :wild_golem

  def logout_countdown_update()
    @logout_countdown_table.each do |player, n|
      next unless Bukkit.get_player(player.name)
      @logout_countdown_table[player] = n - 1
      if n == 0
        @logout_countdown_table.delete(player)
        player.kick_player('logout count is zero!')
      else
        [(10 - n), 0].max.times do
          smoke_effect(
            add_loc(player.eye_location, rand - 0.5, rand, rand - 0.5))
        end
        play_sound(player.location, Sound::EAT, 1.0, 2.0)
      end
    end
  end
  private :logout_countdown_update

  def rotate_sign(block)
    return unless block.type == Material::SIGN_POST
    state = block.state
    state.data = state.data.tap {|d|
      new_facing = facing_next(d.facing)
      d.facing_direction = new_facing
    }
    state.update()
  end
  private :rotate_sign

  def periodically_sec
    online_players = Bukkit.online_players
    # nearby_creatures = online_players.map {|p|
    #   p.get_nearby_entities(2, 2, 2).
    #     select {|e| Creature === e }
    # }.flatten(1).to_set
    nearby_creatures = online_players.map {|p|
      [[0, 0], [0, -16], [0, 16], [-16, 0], [16, 0]].map {|x, z|
        add_loc(p.location, x, 0, z).chunk
      }
    }.flatten(1).uniq.map {|c|
      c.entities.select {|e| Creature === e || Slime === e }
    }.flatten(1).to_set
    holy_water(nearby_creatures)
    #wild_golem(nearby_creatures, online_players)
    logout_countdown_update()

    holder = @ctf_players.find {|p|
      p.passenger && Squid === p.passenger
    }
    if holder
      if @ctf_holder_time
        prev_holder, counter = @ctf_holder_time
        if holder == prev_holder
          @ctf_holder_time = [holder, counter + 1]
          if counter == 20
            broadcast "#{holder.name} won!"
          elsif counter > 20
            # nop
          else
            broadcast "#{holder.name} holds flag for #{counter}sec"
          end
        else
          @ctf_holder_time = [holder, 0]
        end
      else
        @ctf_holder_time = [holder, 0]
      end
    end

    online_players.each do |player|
      # xzs = (-5..4).map {|x| [x, 5 - x.abs] } + (-4..5).map {|x| [x, x.abs - 5] }
      # loc = xzs.
      #   map {|x, z| player.location.clone.add(x, 0, z) }.
      #   select {|loc|
      #   loc.block.light_level <= 7 &&
      #     loc.add(0, -1, 0).block.type != Material::AIR &&
      #     loc.add(0, 1, 0).block.type == Material::AIR &&
      #     loc.add(0, 1, 0).block.type == Material::AIR
      # }.first
      # next unless loc
      # if rand(10) == 0
      #   player.send_message 'monster!'
      # end
    end
  end
end

EventHandler
