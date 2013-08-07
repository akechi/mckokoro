import 'java.util.HashSet'
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
import 'com.github.ujihisa.Mckokoro.JavaWrapper'

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
    elsif evt.message == last_message
      post_lingr("#{evt.player.name}: #{evt.message}")
      post_lingr_to('computer_science', "#{last_pname}: #{evt.message}")
      post_lingr_to('computer_science', "#{evt.player.name}: #{evt.message}")
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
    case evt.right_clicked
    when Player
      if evt.player.item_in_hand.type == Material::AIR
        vec = evt.right_clicked.location.clone.subtract(evt.player.location).to_vector
        vec.set_y jfloat(0.0)
        vec = vec.normalize.multiply(0.5)
        vec.set_y jfloat(0.1)
        evt.right_clicked.velocity = vec
        later sec(0.1) do
          evt.right_clicked.velocity.set_x jfloat(0.0)
          evt.right_clicked.velocity.set_z jfloat(0.0)
        end
      end
    when Villager
      # job change
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
        consume_item(player) if rand(2) == 0
        player.fall_distance = 0.0
      end
    else
      case action
      when Action::RIGHT_CLICK_BLOCK, Action::RIGHT_CLICK_AIR
        phi = (player.location.yaw + 90) % 360
        x, z =
          Math.cos(phi / 180.0 * Math::PI),
          Math.sin(phi / 180.0 * Math::PI)
        player.velocity = Vector.new(1.5 * x, 0.5, 1.5 * z)
        consume_item(player) if rand(2) == 0
        player.fall_distance = 0.0
      when Action::LEFT_CLICK_BLOCK, Action::LEFT_CLICK_AIR
        player.velocity = player.velocity.tap do |v|
          v.setX jfloat(0)
          v.setY jfloat(0)
          v.setZ jfloat(0)
        end
        consume_item(player) if rand(2) == 0
        player.fall_distance = 0.0
      end
    end
  end
  private :feather_freedom_move

  def on_projectile_hit(evt)
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

  #def chicken_arrow(player, action)
  #  return unless player.item_in_hand.type == Material::GOLD_SWORD
  #  return unless Job.of(player) == :debug
  #  case action
  #  when Action::LEFT_CLICK_BLOCK, Action::LEFT_CLICK_AIR
  #    arrow = JavaWrapper.launch_arrow(player)
  #    later 0 do
  #      arrow.velocity = arrow.velocity.multiply(2.0)
  #    end
  #    loc = add_loc(player.location, 0, 3, 0)
  #    chicken = spawn(loc, EntityType::CHICKEN)
  #    chicken.set_leash_holder arrow
  #  end
  #end
  #private :chicken_arrow

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
            consume_item(player) if rand(3) == 0
          end
        when Material::TNT
          # explode TNT (can be long distance)
          target.type = Material::AIR
          explode(target.location, 3, false)
          consume_item(player) if rand(3) == 0
        end
      end
    end
  end


  def on_player_interact(evt)
    feather_freedom_move(evt.player, evt.action)

    # seeded_p = bulldozer_hoe(evt.player, evt.action)
    # if seeded_p
    #   evt.cancelled = true
    #   return
    # end

    #chicken_arrow(evt.player, evt.action)

    killerqueen_explode(evt)


    if evt.clicked_block

      # Grim Reaper
      Job.set_recipe(:grimreaper, {
        masteries: {novice: 0},
        votive: [
          ItemStack.new(Material::SUGAR, 1),
          ItemStack.new(Material::STONE_HOE, 1)
        ]
      })

      # SPADE can remove grass from dirt
      case [ evt.clicked_block.type, evt.action ]
      when [ Material::GRASS, Action::LEFT_CLICK_BLOCK ]
        if SPADES.include? evt.player.item_in_hand.type
          evt.clicked_block.type = Material::DIRT
          drop_item(evt.clicked_block.location, ItemStack.new(Material::SEEDS)) if rand(3) == 0
        end
      end

      # seeding
      case [ evt.clicked_block.type, evt.action, evt.player.item_in_hand.type ]
      when [ Material::DIRT, Action::RIGHT_CLICK_BLOCK, Material::SEEDS ]
        consume_item(evt.player)
        evt.clicked_block.type = Material::GRASS
      # grim reaper
      when [ Material::DIRT, Action::RIGHT_CLICK_BLOCK, HOES ]
        location_around(evt.clicked_block.location, 10).each do |loc|
          loc.block.type = Material::SOIL if loc.block.type == Material::DIRT
          # Inochi wo karitoru katachi wo shiteru darou?
        end
        evt.player.send_message "The shape looks like, the DEATH."
      end

    else
      #if evt.player.sprinting?
      #  loc = evt.player.location
      #  horse = loc.world.spawn_entity(loc, EntityType::HORSE)
      #  horse.domestication = horse.max_domestication
      #  #later 0 do
      #  #  evt.player.vehicle = horse
      #  #end
      #  later sec(60) do
      #    horse.damage(horse.max_health)
      #  end
      #end
    end
  end

  def on_block_damage(evt)
    evt.player.damage 1 if evt.player.item_in_hand.type == Material::AIR

    case evt.block.type
    when Material::SAND
      the_block = evt.block
      break_naturally_by_dpickaxe(the_block)
      # TODO use location_around
      diffs = [[-1, 0, 0], [1, 0, 0], [0, -1, 0], [0, 1, 0], [0, 0, -1], [0, 0, 1]]
      diffs.each do |x, y, z|
        block = the_block.location.clone.add(x, y, z).block
        if block.type == Material::SAND
          break_naturally_by_dpickaxe(block)
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
    defender = evt.entity
    case evt.damager
    when Arrow
      if Player === defender && defender.blocking?
        evt.damage = 0
      else
        case evt.damager.shooter
        when Player
          player = evt.damager.shooter
          if Job.of(player) == :archer
            # because it's fast
            evt.damage *= 0.85
          else
            evt.damage *= 2
          end
        when Skeleton
          evt.damage *= 2
        end
      end
    when Snowball
      if Player === defender && evt.damager.shooter == defender
        evt.cancelled = true
      end
    when LivingEntity
      case defender
      when Player
        if defender.blocking?
          evt.damager.damage(evt.damage, defender)
          evt.cancelled = true
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
    # when EntityDamageEvent::DamageCause::LAVA
    #   evt.cancelled = true
    #   evt.entity.food_level -= 1 rescue nil
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
    break_naturally_by_dpickaxe(block)
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
    when "mck"
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

  def on_player_move(evt)
    player = evt.player
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
      diff_y = evt.to.y - evt.from.y
      case player.location.pitch
      when -90.0 # up
        if diff_y > 0
          (1..7).each do |i|
            newloc = add_loc(evt.to, 0, i, 0)
            if newloc.block.type == Material::LADDER
              evt.to = newloc
            else
              break
            end
          end
        end
      when 90.0 #down
        if diff_y < 0
          (1..7).each do |i|
            newloc = add_loc(evt.to, 0, -i, 0)
            if newloc.block.type == Material::LADDER
              evt.to = newloc
            else
              break
            end
          end
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
        m.location.tap {|l| l.add(0, -1, 0) }.block.type == Material::LAPIS_BLOCK
    }.each do |m|
      m.damage(4)
    end
  end
  private :holy_water

  def periodically
    online_players = Bukkit.online_players
    nearby_creatures = online_players.map {|p|
      p.get_nearby_entities(2, 2, 2).
        select {|e| Creature === e }
    }.flatten(1).to_set
    holy_water(nearby_creatures)

    online_players.each do |player|
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

  def break_naturally_by_dpickaxe(block)
    block.break_naturally(ItemStack.new(Material::DIAMOND_PICKAXE))
  end
end

EventHandler
