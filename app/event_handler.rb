import 'org.bukkit.Bukkit'
import 'org.bukkit.Material'
import 'org.bukkit.Effect'
import 'org.bukkit.SkullType'
import 'org.bukkit.util.Vector'
import 'org.bukkit.event.entity.EntityDamageEvent'
import 'org.bukkit.metadata.FixedMetadataValue'
import 'org.bukkit.inventory.ItemStack'
import 'org.bukkit.inventory.FurnaceRecipe'
import 'org.bukkit.material.MaterialData'
import 'org.bukkit.material.SpawnEgg'
import 'org.bukkit.entity.EntityType'
import 'org.bukkit.event.block.Action'

require 'set'
require 'digest/sha1'
require 'erb'
require 'open-uri'
require 'json'

module EventHandler
  include_package 'org.bukkit.entity'

  module_function
  def on_load(plugin)
    @plugin = plugin
    Bukkit.getScheduler.scheduleSyncRepeatingTask(
      @plugin, -> { self.periodically }, 0, sec(1))
    p :on_load, plugin
    p "#{APP_DIR_PATH}/event_handler.rb"
    update_recipes
    @food_poisoning_player = Set.new

    @db_path = "#{@plugin.data_folder.absolute_path}/db.json"
    @db = File.readable?(@db_path) ? JSON.load(File.read @db_path) : {'achievement' => {'block-place' => {}}}
  end

  def let(x)
    yield x
  end

  def on_lingr(message)
    return if Bukkit.getOnlinePlayers.empty?
    later 0 do
      broadcast "[lingr] #{message['nickname']}: #{message['text']}"
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
    #p :chat, evt.getPlayer
    if evt.player.op? && evt.message == "reload"
      evt.cancelled = true
      reload
      broadcast '(reloading event handler)'
    else
      post_lingr("#{evt.player.name}: #{evt.message}")
    end
  end

  def on_player_login(evt)
    post_lingr "#{evt.player.name} logged in."

    Bukkit.online_players.each do |player|
      update_hide_player(player, evt.player)
    end

    later 0 do
      player = evt.player
      player_first_time_p =
        player.inventory.contents.to_a.compact.empty? &&
        player.health == player.max_health
      if player_first_time_p
        player.send_message 'You are first time to visit here right?'
        player.send_message 'Check your inventory. You already have good stuff.'
        [ItemStack.new(Material::COBBLESTONE, 64),
         ItemStack.new(Material::MUSHROOM_SOUP),
         ItemStack.new(Material::WHEAT, 32),
         ItemStack.new(Material::WOOD, 10),
         ItemStack.new(Material::LEATHER_CHESTPLATE)].each do |istack|
          player.inventory.add_item istack
         end
        later sec(20) do
          player.send_message "Note that you can't place any blocks at first..."
          player.send_message "You need to unlock that by making a Workbench."
        end
      end
    end
  end

  def on_player_quit(evt)
    strike_lightning(evt.player.location)
    post_lingr "#{evt.player.name}: #{evt.quit_message.sub(/^#{evt.player.name}/, '')}"
  end

  def on_entity_explode(evt)
    case evt.entity
    when TNTPrimed
      #memo: spawn() doesn't work on jruby...
      #power = 4
      #(power ** 2).to_i.times do
      #  orb = spawn(evt.location, ExperienceOrb)
      #  org.experience = 1
      #end

      #evt.cancelled = true
      #evt.block_list do |b|
      #  case b
      #  when Material::SUGAR_CANE_BLOCK
      #    # nop
      #  else
      #    b.break_naturally(ItemStack.new(Material::DIAMOND_PICKAXE)
      #  end
      #end
    end
  end

  def on_item_spawn(evt)
    case evt.entity.item_stack.type
    when Material::SUGAR_CANE, Material::SAPLING
      evt.cancelled = true
    when Material::EGG
      evt.cancelled = true
    end
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
      # nop
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
      drop_replace.(
        [],
        [SpawnEgg.new(EntityType::HORSE).toItemStack(1)])
    when Sheep
      drop_replace.([Material::WOOL], [ItemStack.new(Material::STRING)])
    end
    entity = evt.entity
    if entity.killer && Player === entity.killer
      post_lingr "#{entity.killer.name} killed a #{entity.type.name.downcase}"
    end
  end

  def on_player_death(evt)
    player = evt.entity
    @food_poisoning_player.delete player
    post_lingr "#{player.name} died: #{evt.death_message.sub(/^#{player.name}/, '')} at (#{player.location.x.to_i}, #{player.location.z.to_i}) in #{player.location.world.name}."
  end

  def on_block_place(evt)
    return unless evt.canBuild

    player = evt.player
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
    end
  end

  def on_player_interact(evt)
    if evt.clicked_block

      if Job.of(evt.player) == :killerqueen
        case [ evt.player.item_in_hand.type, evt.action ]
        when [ Material::SULPHUR, Action::LEFT_CLICK_BLOCK ]
          evt.player.send_message "KILLERQUEEN...!!"
          # effect only
          # TODO: long distance / not only block
          location_around(evt.clicked_block.location, 2) do |loc|
            explode(loc, 0, false) if rand(9) < 2
          end
          # TODO: explode focusing entity (mob or block)
        end
      end

      # SPADE can remove grass from dirt
      case [ evt.clicked_block.type, evt.action ]
      when [ Material::GRASS, Action::LEFT_CLICK_BLOCK ]
        if SPADES.include? evt.player.item_in_hand.type
          evt.clicked_block.type = Material::DIRT
          drop_item(evt.clicked_block.location, ItemStack.new(Material::SEEDS)) if rand(3) == 0
        end
      end

      # seeding
      case [ evt.clicked_block.type, evt.player.item_in_hand.type, evt.action ]
      when [ Material::DIRT, Material::SEEDS, Action::RIGHT_CLICK_BLOCK ]
        consume_item(evt.player)
        evt.clicked_block.type = Material::GRASS
      end

    else
      if evt.player.sprinting?
        loc = evt.player.location
        horse = loc.world.spawn_entity(loc, EntityType::HORSE)
        horse.domestication = horse.max_domestication
        #later 0 do
        #  evt.player.vehicle = horse
        #end
        later sec(60) do
          horse.damage(horse.max_health)
        end
      end
    end
  end

  def on_block_damage(evt)
    evt.player.damage 1 if evt.player.item_in_hand.type == Material::AIR

    case evt.block.type
    when Material::SAND
      the_block = evt.block
      the_block.break_naturally(ItemStack.new(Material::DIAMOND_PICKAXE))
      # TODO use location_around
      diffs = [[-1, 0, 0], [1, 0, 0], [0, -1, 0], [0, 1, 0], [0, 0, -1], [0, 0, 1]]
      diffs.each do |x, y, z|
        block = the_block.location.clone.add(x, y, z).block
        if block.type == Material::SAND
          block.break_naturally(ItemStack.new(Material::DIAMOND_PICKAXE))
        end
      end
    end
  end

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

  def on_inventory_open(evt)
  end

  def on_player_chat_tab_complete(evt)
    #p evt.chat_message
  end

  def on_block_break(evt)
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
    when Material::LEAVES
      if rand(3) == 0
        drop_item(evt.block.location, ItemStack.new(Material::STICK))
      end
    when Material::GRASS
      evt.cancelled = true
      evt.block.type = Material::DIRT
    when Material::LONG_GRASS
      drop_item(evt.block.location, ItemStack.new(Material::SEEDS))
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
    #later 0 do
    #  evt.getBlock.setType(Material::STONE)
    #end
    #

    unless evt.cancelled
      fall_chain_above = ->(base_block) {
        later sec(0.1) do
          unless base_block.type.solid?
            block_above = base_block.location.clone.tap {|l| l.add(0, 1, 0) }.block
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

  def on_entity_damage_by_entity(evt)
    case evt.damager
    when Arrow
      case evt.damager.shooter
      when Player
        player = evt.damager.shooter
        if Job.of(player) == :archer
          # because it's fast
          evt.damage *= 0.85
        else
          evt.damage *= 2
        end
      end
    end
  end

  def on_entity_damage(evt)
    if Player === evt.entity && Job.of(evt.entity) == :muteki
      evt.entity.send_message 'You are muteki'
      evt.cancelled = true
      return
    end

    case evt.getCause
    when EntityDamageEvent::DamageCause::FALL
      # on grass, zenzen itakunai.
      evt.tap do |evt|
        block_below = evt.entity.location.dup.tap {|l| l.add(0, -1, 0)}.block
        if block_below.type == Material::GRASS
          evt.cancelled = true
          # grass will be spread
          block_below.type = Material::DIRT
          # bound
          evt.entity.velocity = evt.entity.velocity.tap{|v| v.add Vector.new(0.0, 0.4, 0.0) }
        end
      end

      #evt.cancelled = true
      #explode(evt.getEntity.getLocation, 1, false)
    when EntityDamageEvent::DamageCause::BLOCK_EXPLOSION
      # killerqueen
      # case evt.entity
      # when Player
      #   player = evt.entity
      #   if @explode_toleranted_players[player.name]
      #     evt.cancelled = true
      #   end
      # end
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
        evt.player.walk_speed = 0.4
      end
    else
      evt.player.walk_speed = 0.2
    end
  end

  #HARD_BOOTS = [Material::CHAINMAIL_BOOTS, Material::IRON_BOOTS,
  #              Material::DIAMOND_BOOTS, Material::GOLD_BOOTS]
  def on_player_toggle_sneak(evt)
    # Lingr
    if evt.sneaking?
      # post_lingr "#{evt.player.name} sneaking..."
    else
      # post_lingr "#{evt.player.name} stood up."
    end

    # Superjump
    jump_counter_notify = ->(player) {
      # Disable instead of delete for debuging
      # player.send_message "jump power : #{ @crouching_counter[player.name] }"
    }
    name = evt.player.name
    @crouching_counter ||= {}
    @crouching_counter[name] ||= 0
    @crouching_countingdown ||= false
    if evt.sneaking?
      # counting up
      @crouching_counter[name] += 1
      jump_counter_notify.call(evt.player)
      if @crouching_counter[name] == 5
        # evt.player.send_message "superjump!"
        evt.player.fall_distance = 0.0
        evt.player.velocity = evt.player.velocity.tap{|v| v.setY jfloat(1.4) }
      end
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
        if Job.of(shooter) == :archer
          projectile.velocity = projectile.velocity.multiply(jfloat(2.0))
        else
          projectile.velocity = projectile.velocity.multiply(jfloat(0.5))
        end
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
    if player.item_in_hand.amount == 1
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
    unless player.sneaking?
      [[0, 1, 0], [1, 1, 0], [0, 1, 1], [-1, 1, 0], [0, 1, -1]].each do |x, y, z|
        loc = block.location.clone.add(x, y, z)
        kickory(loc.block, player) if loc.block.type == Material::LOG
      end
    end
  end

  def update_hide_player(p1, p2)
    p1.hide_player(p2) if p2.op? && !p1.op?
    p2.hide_player(p1) if p1.op? && !p2.op?
  end

  def update_recipes
    Bukkit.reset_recipes
    recipes = Bukkit.recipe_iterator.to_a
    Bukkit.clear_recipes
    recipes.
      reject {|r| r.result.type == Material::BREAD }.
      each {|r| Bukkit.add_recipe r }
    bread_furnace = FurnaceRecipe.new(
      ItemStack.new(Material::BREAD),
      Material::WHEAT)
    Bukkit.add_recipe bread_furnace
  end

  def on_command(sender, cmd, label, args)
    case label
    when 'lingr'
      case sender
      when Player
        false
      else
        post_lingr args.to_a.join ' '
        true
      end
    when "mckokoro"
      # temporary
      case sender
      when Player
        args = args.to_a
        if args[0]
          Job.become(sender, args[0].to_sym)
        end
        sender.send_message "your job is #{Job.of(sender)}"
        true
      else
        false
      end
    when "inv"
      case sender
      when Player
        p [:cmd, sender, cmd, label, args.to_a]
        sender.open_workbench sender.location, true
        true
      else
        false
      end
    else
      false
    end
  end

  def on_server_command(evt)
  end

  def db_save
    File.open @db_path, 'w' do |io|
      io.write @db.to_json
    end
  end

  def periodically
    Bukkit.online_players.each do |player|
      # Superjump counter counting down
      crouching_countdown = -> do
        player.tap do |p|
          if @crouching_counter && @crouching_counter[p.name] && @crouching_counter[p.name] > 0
            @crouching_counter[p.name] -= 1
            # p.send_message "jump power : #{@crouching_counter[p.name]}"
          end
        end
      end
      # count down every 0.5 sec
      crouching_countdown.call
      later sec(0.5) do
        crouching_countdown.call
      end

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

  #
  # Utility functions
  #

  def play_effect(loc, eff)
    loc.world.playEffect(loc, eff, nil)
  end

  def sec(n)
    (n * 20).to_i
  end

  def jfloat(rubyfloat)
    rubyfloat.to_java Java.float
  end

  def post_lingr(text)
    Thread.start do
      # Send chat for lingr room
      # TODO: move lingr room-id to config.yml to change.
      # TODO: moge following codes to lingr module.
      param = {
        room: 'mcujm',
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

  #def spawn(loc, klass)
  #  loc.world.spawnEntity(loc, EntityType::EXPERIENCE_ORB)
  #end

  def strike_lightning(loc)
    loc.world.strike_lightning_effect(loc)
  end

  # dummy
  def sleep(*x)
    warn "Don't use it"
  end

  # location_around(loc_centre, 2) {|loc| ... }
  # will do something around the centre (loc_centre) with width 2
  def location_around(loc, size)
    location_list = ([*-size..size] * 3).combination(3).to_a.uniq - [0,0,0]
    location_list.each do |x,y,z|
      yield loc.clone.add(x, y, z)
    end
  end
end

EventHandler
