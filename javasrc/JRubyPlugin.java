package com.github.ujihisa.Mcsakura;
import java.io.File;
import org.bukkit.plugin.java.JavaPlugin;
import java.net.URL;
import org.bukkit.event.Listener;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Event;
import org.bukkit.configuration.file.FileConfiguration;
import java.net.URL;
import java.net.URLDecoder;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;



import org.jruby.embed.ScriptingContainer;

public class JRubyPlugin extends JavaPlugin implements Listener {
    private ScriptingContainer jruby = new ScriptingContainer();
    private Object eh;
    private Object rubyTrue, rubyFalse, rubyNil;
    private FileConfiguration config;

    //@Override public void onEnable() {}

    @Override public void onEnable() {
        jruby.setClassLoader(this.getClass().getClassLoader());
        jruby.setCompatVersion(org.jruby.CompatVersion.RUBY2_0);
        //jruby.runScriptlet("p RUBY_DESCRIPTION");

        rubyTrue  = jruby.runScriptlet("true");
        rubyFalse = jruby.runScriptlet("false");
        rubyNil   = jruby.runScriptlet("nil");

        // Put config file to path_to_bukkit/plugins/mcsakura-jarname/config.yml
        config = getConfig();

        //URL url = getClass().getResource("/main.rb");
        try {
            System.out.println("Loading ruby script : " + config.getString("path.ruby.script"));
            URL url = new URL(config.getString("path.ruby.script"));
            eh = executeScript(
                url.openStream(),
                URLDecoder.decode(url.getPath().toString(), "UTF-8"));;
            /*
            Object main = jruby.callMethod(
                    brainsClass,
                    "new",
                    this,
                    getPluginLoader(),
                    getConfig().getString("path", "plugins"));
                    */
            //getServer().getPluginManager().registerInterface(RubyPluginLoader.class);
        } catch (Exception e) {
            e.printStackTrace();
        }
        jrubyEhCallIfRespond1("on_load", this);

        /*
        String name = getDescription().getName();
        this.ns = name + ".core";
        System.out.println("Enabling " + name + " clojure Plugin");
        invokeClojureFunc("on-enable", this);
        */

        getServer().getPluginManager().registerEvents(this, this);
    }

    public boolean onCommand(org.bukkit.command.CommandSender sender, org.bukkit.command.Command cmd, String label, String[] args) {
      return jrubyEhCallIfRespond4("on_command", sender, cmd, label, args);
    }

    /*
    private void jrubyCallIfRespond0(String fname) {
        jruby.callMethod(eh, fname, this);
    }
    */

    private void jrubyEhCallIfRespond1(String fname, Object x) {
        if (jruby.callMethod(eh, "respond_to?", fname).equals(rubyTrue))
            jruby.callMethod(eh, fname, x);
    }

    private boolean jrubyEhCallIfRespond4(String fname, Object a, Object b, Object c, Object d) {
        if (jruby.callMethod(eh, "respond_to?", fname).equals(rubyTrue))
            return (Boolean)jruby.callMethod(eh, fname, a, b, c, d);
        return false;
    }

    private Object executeScript(InputStream io, String path) {
        try {
            return jruby.runScriptlet(io, path);
        } finally {
            try { if (io != null) io.close(); } catch (IOException e) {}
        }
    }

    public void onDisable(String ns, String disableFunction) {
        /*
        clojure.lang.RT.var(ns, disableFunction).invoke(this);
        */
    }

    public void onDisable() {
        /*
        String name = getDescription().getName();
        System.out.println("Disabling "+name+" clojure Plugin");
        if ("clj-minecraft".equals(name)) {
            onEnable("cljminecraft.core", "onenable");
        } else {
            onEnable(name+".core", "disable-plugin");
        }
        */
    }

    /*
    @EventHandler
    public void onAsyncPlayerChat(org.bukkit.event.player.AsyncPlayerChatEvent event) {
        jrubyEhCallIfRespond1("on_async_player_chat", event);
    }

    @EventHandler
    public void onPlayerLogin(org.bukkit.event.player.PlayerLoginEvent event) {
        jrubyEhCallIfRespond1("on_player_login", event);
    }
    @EventHandler
    public void onBlockBreak(org.bukkit.event.block.BlockBreakEvent event) {
        jrubyEhCallIfRespond1("on_block_break", event);
    }
    */

    /* begin auto-generated code */
    @EventHandler
    public void onAsyncPlayerPreLogin(org.bukkit.event.player.AsyncPlayerPreLoginEvent event) {
        jrubyEhCallIfRespond1("on_async_player_pre_login", event);
    }
    @EventHandler
    public void onBlockBurn(org.bukkit.event.block.BlockBurnEvent event) {
        jrubyEhCallIfRespond1("on_block_burn", event);
    }
    @EventHandler
    public void onBlockCanBuild(org.bukkit.event.block.BlockCanBuildEvent event) {
        jrubyEhCallIfRespond1("on_block_can_build", event);
    }
    @EventHandler
    public void onBlockDamage(org.bukkit.event.block.BlockDamageEvent event) {
        jrubyEhCallIfRespond1("on_block_damage", event);
    }
    @EventHandler
    public void onBlockDispense(org.bukkit.event.block.BlockDispenseEvent event) {
        jrubyEhCallIfRespond1("on_block_dispense", event);
    }
    @EventHandler
    public void onBlockBreak(org.bukkit.event.block.BlockBreakEvent event) {
        jrubyEhCallIfRespond1("on_block_break", event);
    }
    @EventHandler
    public void onFurnaceExtract(org.bukkit.event.inventory.FurnaceExtractEvent event) {
        jrubyEhCallIfRespond1("on_furnace_extract", event);
    }
    @EventHandler
    public void onBlockFade(org.bukkit.event.block.BlockFadeEvent event) {
        jrubyEhCallIfRespond1("on_block_fade", event);
    }
    @EventHandler
    public void onBlockFromTo(org.bukkit.event.block.BlockFromToEvent event) {
        jrubyEhCallIfRespond1("on_block_from_to", event);
    }
    @EventHandler
    public void onBlockForm(org.bukkit.event.block.BlockFormEvent event) {
        jrubyEhCallIfRespond1("on_block_form", event);
    }
    @EventHandler
    public void onBlockSpread(org.bukkit.event.block.BlockSpreadEvent event) {
        jrubyEhCallIfRespond1("on_block_spread", event);
    }
    @EventHandler
    public void onEntityBlockForm(org.bukkit.event.block.EntityBlockFormEvent event) {
        jrubyEhCallIfRespond1("on_entity_block_form", event);
    }
    @EventHandler
    public void onBlockIgnite(org.bukkit.event.block.BlockIgniteEvent event) {
        jrubyEhCallIfRespond1("on_block_ignite", event);
    }
    @EventHandler
    public void onBlockPhysics(org.bukkit.event.block.BlockPhysicsEvent event) {
        jrubyEhCallIfRespond1("on_block_physics", event);
    }
    @EventHandler
    public void onBlockPistonExtend(org.bukkit.event.block.BlockPistonExtendEvent event) {
        jrubyEhCallIfRespond1("on_block_piston_extend", event);
    }
    @EventHandler
    public void onBlockPistonRetract(org.bukkit.event.block.BlockPistonRetractEvent event) {
        jrubyEhCallIfRespond1("on_block_piston_retract", event);
    }
    @EventHandler
    public void onBlockPlace(org.bukkit.event.block.BlockPlaceEvent event) {
        jrubyEhCallIfRespond1("on_block_place", event);
    }
    @EventHandler
    public void onBlockRedstone(org.bukkit.event.block.BlockRedstoneEvent event) {
        jrubyEhCallIfRespond1("on_block_redstone", event);
    }
    @EventHandler
    public void onBrew(org.bukkit.event.inventory.BrewEvent event) {
        jrubyEhCallIfRespond1("on_brew", event);
    }
    @EventHandler
    public void onFurnaceBurn(org.bukkit.event.inventory.FurnaceBurnEvent event) {
        jrubyEhCallIfRespond1("on_furnace_burn", event);
    }
    @EventHandler
    public void onFurnaceSmelt(org.bukkit.event.inventory.FurnaceSmeltEvent event) {
        jrubyEhCallIfRespond1("on_furnace_smelt", event);
    }
    @EventHandler
    public void onLeavesDecay(org.bukkit.event.block.LeavesDecayEvent event) {
        jrubyEhCallIfRespond1("on_leaves_decay", event);
    }
    @EventHandler
    public void onNotePlay(org.bukkit.event.block.NotePlayEvent event) {
        jrubyEhCallIfRespond1("on_note_play", event);
    }
    @EventHandler
    public void onSignChange(org.bukkit.event.block.SignChangeEvent event) {
        jrubyEhCallIfRespond1("on_sign_change", event);
    }
    @EventHandler
    public void onCreatureSpawn(org.bukkit.event.entity.CreatureSpawnEvent event) {
        jrubyEhCallIfRespond1("on_creature_spawn", event);
    }
    @EventHandler
    public void onCreeperPower(org.bukkit.event.entity.CreeperPowerEvent event) {
        jrubyEhCallIfRespond1("on_creeper_power", event);
    }
    @EventHandler
    public void onEntityChangeBlock(org.bukkit.event.entity.EntityChangeBlockEvent event) {
        jrubyEhCallIfRespond1("on_entity_change_block", event);
    }
    @EventHandler
    public void onEntityBreakDoor(org.bukkit.event.entity.EntityBreakDoorEvent event) {
        jrubyEhCallIfRespond1("on_entity_break_door", event);
    }
    @EventHandler
    public void onEntityCombust(org.bukkit.event.entity.EntityCombustEvent event) {
        jrubyEhCallIfRespond1("on_entity_combust", event);
    }
    @EventHandler
    public void onEntityCombustByBlock(org.bukkit.event.entity.EntityCombustByBlockEvent event) {
        jrubyEhCallIfRespond1("on_entity_combust_by_block", event);
    }
    @EventHandler
    public void onEntityCombustByEntity(org.bukkit.event.entity.EntityCombustByEntityEvent event) {
        jrubyEhCallIfRespond1("on_entity_combust_by_entity", event);
    }
    @EventHandler
    public void onEntityCreatePortal(org.bukkit.event.entity.EntityCreatePortalEvent event) {
        jrubyEhCallIfRespond1("on_entity_create_portal", event);
    }
    @EventHandler
    public void onEntityDamageByBlock(org.bukkit.event.entity.EntityDamageEvent event) {
        jrubyEhCallIfRespond1("on_entity_damage", event);
    }
    @EventHandler
    public void onEntityDamageByBlock(org.bukkit.event.entity.EntityDamageByBlockEvent event) {
        jrubyEhCallIfRespond1("on_entity_damage_by_block", event);
    }
    @EventHandler
    public void onEntityDamageByEntity(org.bukkit.event.entity.EntityDamageByEntityEvent event) {
        jrubyEhCallIfRespond1("on_entity_damage_by_entity", event);
    }
    @EventHandler
    public void onEntityDeath(org.bukkit.event.entity.EntityDeathEvent event) {
        jrubyEhCallIfRespond1("on_entity_death", event);
    }
    @EventHandler
    public void onPlayerDeath(org.bukkit.event.entity.PlayerDeathEvent event) {
        jrubyEhCallIfRespond1("on_player_death", event);
    }
    @EventHandler
    public void onEntityExplode(org.bukkit.event.entity.EntityExplodeEvent event) {
        jrubyEhCallIfRespond1("on_entity_explode", event);
    }
    @EventHandler
    public void onEntityInteract(org.bukkit.event.entity.EntityInteractEvent event) {
        jrubyEhCallIfRespond1("on_entity_interact", event);
    }
    @EventHandler
    public void onEntityRegainHealth(org.bukkit.event.entity.EntityRegainHealthEvent event) {
        jrubyEhCallIfRespond1("on_entity_regain_health", event);
    }
    @EventHandler
    public void onEntityShootBow(org.bukkit.event.entity.EntityShootBowEvent event) {
        jrubyEhCallIfRespond1("on_entity_shoot_bow", event);
    }
    @EventHandler
    public void onEntityTame(org.bukkit.event.entity.EntityTameEvent event) {
        jrubyEhCallIfRespond1("on_entity_tame", event);
    }
    @EventHandler
    public void onEntityTarget(org.bukkit.event.entity.EntityTargetEvent event) {
        jrubyEhCallIfRespond1("on_entity_target", event);
    }
    @EventHandler
    public void onEntityTargetLivingEntity(org.bukkit.event.entity.EntityTargetLivingEntityEvent event) {
        jrubyEhCallIfRespond1("on_entity_target_living_entity", event);
    }
    @EventHandler
    public void onEntityTeleport(org.bukkit.event.entity.EntityTeleportEvent event) {
        jrubyEhCallIfRespond1("on_entity_teleport", event);
    }
    @EventHandler
    public void onExplosionPrime(org.bukkit.event.entity.ExplosionPrimeEvent event) {
        jrubyEhCallIfRespond1("on_explosion_prime", event);
    }
    @EventHandler
    public void onFoodLevelChange(org.bukkit.event.entity.FoodLevelChangeEvent event) {
        jrubyEhCallIfRespond1("on_food_level_change", event);
    }
    @EventHandler
    public void onItemDespawn(org.bukkit.event.entity.ItemDespawnEvent event) {
        jrubyEhCallIfRespond1("on_item_despawn", event);
    }
    @EventHandler
    public void onItemSpawn(org.bukkit.event.entity.ItemSpawnEvent event) {
        jrubyEhCallIfRespond1("on_item_spawn", event);
    }
    @EventHandler
    public void onPigZap(org.bukkit.event.entity.PigZapEvent event) {
        jrubyEhCallIfRespond1("on_pig_zap", event);
    }
    @EventHandler
    public void onProjectileHit(org.bukkit.event.entity.ProjectileHitEvent event) {
        jrubyEhCallIfRespond1("on_projectile_hit", event);
    }
    @EventHandler
    public void onExpBottle(org.bukkit.event.entity.ExpBottleEvent event) {
        jrubyEhCallIfRespond1("on_exp_bottle", event);
    }
    @EventHandler
    public void onPotionSplash(org.bukkit.event.entity.PotionSplashEvent event) {
        jrubyEhCallIfRespond1("on_potion_splash", event);
    }
    @EventHandler
    public void onProjectileLaunch(org.bukkit.event.entity.ProjectileLaunchEvent event) {
        jrubyEhCallIfRespond1("on_projectile_launch", event);
    }
    @EventHandler
    public void onSheepDyeWool(org.bukkit.event.entity.SheepDyeWoolEvent event) {
        jrubyEhCallIfRespond1("on_sheep_dye_wool", event);
    }
    @EventHandler
    public void onSheepRegrowWool(org.bukkit.event.entity.SheepRegrowWoolEvent event) {
        jrubyEhCallIfRespond1("on_sheep_regrow_wool", event);
    }
    @EventHandler
    public void onSlimeSplit(org.bukkit.event.entity.SlimeSplitEvent event) {
        jrubyEhCallIfRespond1("on_slime_split", event);
    }
    @EventHandler
    public void onHangingBreak(org.bukkit.event.hanging.HangingBreakEvent event) {
        jrubyEhCallIfRespond1("on_hanging_break", event);
    }
    @EventHandler
    public void onHangingBreakByEntity(org.bukkit.event.hanging.HangingBreakByEntityEvent event) {
        jrubyEhCallIfRespond1("on_hanging_break_by_entity", event);
    }
    @EventHandler
    public void onHangingPlace(org.bukkit.event.hanging.HangingPlaceEvent event) {
        jrubyEhCallIfRespond1("on_hanging_place", event);
    }
    @EventHandler
    public void onEnchantItem(org.bukkit.event.enchantment.EnchantItemEvent event) {
        jrubyEhCallIfRespond1("on_enchant_item", event);
    }
    @EventHandler
    public void onInventoryClick(org.bukkit.event.inventory.InventoryClickEvent event) {
        jrubyEhCallIfRespond1("on_inventory_click", event);
    }
    @EventHandler
    public void onCraftItem(org.bukkit.event.inventory.CraftItemEvent event) {
        jrubyEhCallIfRespond1("on_craft_item", event);
    }
    @EventHandler
    public void onInventoryClose(org.bukkit.event.inventory.InventoryCloseEvent event) {
        jrubyEhCallIfRespond1("on_inventory_close", event);
    }
    @EventHandler
    public void onInventoryOpen(org.bukkit.event.inventory.InventoryOpenEvent event) {
        jrubyEhCallIfRespond1("on_inventory_open", event);
    }
    @EventHandler
    public void onPrepareItemCraft(org.bukkit.event.inventory.PrepareItemCraftEvent event) {
        jrubyEhCallIfRespond1("on_prepare_item_craft", event);
    }
    @EventHandler
    public void onPrepareItemEnchant(org.bukkit.event.enchantment.PrepareItemEnchantEvent event) {
        jrubyEhCallIfRespond1("on_prepare_item_enchant", event);
    }
    @EventHandler
    public void onAsyncPlayerChat(org.bukkit.event.player.AsyncPlayerChatEvent event) {
        jrubyEhCallIfRespond1("on_async_player_chat", event);
    }
    @EventHandler
    public void onPlayerAnimation(org.bukkit.event.player.PlayerAnimationEvent event) {
        jrubyEhCallIfRespond1("on_player_animation", event);
    }
    @EventHandler
    public void onPlayerBedEnter(org.bukkit.event.player.PlayerBedEnterEvent event) {
        jrubyEhCallIfRespond1("on_player_bed_enter", event);
    }
    @EventHandler
    public void onPlayerBedLeave(org.bukkit.event.player.PlayerBedLeaveEvent event) {
        jrubyEhCallIfRespond1("on_player_bed_leave", event);
    }
    @EventHandler
    public void onPlayerBucketEmpty(org.bukkit.event.player.PlayerBucketEmptyEvent event) {
        jrubyEhCallIfRespond1("on_player_bucket_empty", event);
    }
    @EventHandler
    public void onPlayerBucketFill(org.bukkit.event.player.PlayerBucketFillEvent event) {
        jrubyEhCallIfRespond1("on_player_bucket_fill", event);
    }
    @EventHandler
    public void onPlayerChangedWorld(org.bukkit.event.player.PlayerChangedWorldEvent event) {
        jrubyEhCallIfRespond1("on_player_changed_world", event);
    }
    @EventHandler
    public void onPlayerRegisterChannel(org.bukkit.event.player.PlayerRegisterChannelEvent event) {
        jrubyEhCallIfRespond1("on_player_register_channel", event);
    }
    @EventHandler
    public void onPlayerUnregisterChannel(org.bukkit.event.player.PlayerUnregisterChannelEvent event) {
        jrubyEhCallIfRespond1("on_player_unregister_channel", event);
    }
    @EventHandler
    public void onPlayerChatTabComplete(org.bukkit.event.player.PlayerChatTabCompleteEvent event) {
        jrubyEhCallIfRespond1("on_player_chat_tab_complete", event);
    }
    @EventHandler
    public void onPlayerCommandPreprocess(org.bukkit.event.player.PlayerCommandPreprocessEvent event) {
        jrubyEhCallIfRespond1("on_player_command_preprocess", event);
    }
    @EventHandler
    public void onPlayerDropItem(org.bukkit.event.player.PlayerDropItemEvent event) {
        jrubyEhCallIfRespond1("on_player_drop_item", event);
    }
    @EventHandler
    public void onPlayerEggThrow(org.bukkit.event.player.PlayerEggThrowEvent event) {
        jrubyEhCallIfRespond1("on_player_egg_throw", event);
    }
    @EventHandler
    public void onPlayerExpChange(org.bukkit.event.player.PlayerExpChangeEvent event) {
        jrubyEhCallIfRespond1("on_player_exp_change", event);
    }
    @EventHandler
    public void onPlayerFish(org.bukkit.event.player.PlayerFishEvent event) {
        jrubyEhCallIfRespond1("on_player_fish", event);
    }
    @EventHandler
    public void onPlayerGameModeChange(org.bukkit.event.player.PlayerGameModeChangeEvent event) {
        jrubyEhCallIfRespond1("on_player_game_mode_change", event);
    }
    @EventHandler
    public void onPlayerInteractEntity(org.bukkit.event.player.PlayerInteractEntityEvent event) {
        jrubyEhCallIfRespond1("on_player_interact_entity", event);
    }
    @EventHandler
    public void onPlayerInteract(org.bukkit.event.player.PlayerInteractEvent event) {
        jrubyEhCallIfRespond1("on_player_interact", event);
    }
    @EventHandler
    public void onPlayerItemBreak(org.bukkit.event.player.PlayerItemBreakEvent event) {
        jrubyEhCallIfRespond1("on_player_item_break", event);
    }
    @EventHandler
    public void onPlayerItemHeld(org.bukkit.event.player.PlayerItemHeldEvent event) {
        jrubyEhCallIfRespond1("on_player_item_held", event);
    }
    @EventHandler
    public void onPlayerJoin(org.bukkit.event.player.PlayerJoinEvent event) {
        jrubyEhCallIfRespond1("on_player_join", event);
    }
    @EventHandler
    public void onPlayerKick(org.bukkit.event.player.PlayerKickEvent event) {
        jrubyEhCallIfRespond1("on_player_kick", event);
    }
    @EventHandler
    public void onPlayerLevelChange(org.bukkit.event.player.PlayerLevelChangeEvent event) {
        jrubyEhCallIfRespond1("on_player_level_change", event);
    }
    @EventHandler
    public void onPlayerLogin(org.bukkit.event.player.PlayerLoginEvent event) {
        jrubyEhCallIfRespond1("on_player_login", event);
    }
    @EventHandler
    public void onPlayerMove(org.bukkit.event.player.PlayerMoveEvent event) {
        jrubyEhCallIfRespond1("on_player_move", event);
    }
    @EventHandler
    public void onPlayerTeleport(org.bukkit.event.player.PlayerTeleportEvent event) {
        jrubyEhCallIfRespond1("on_player_teleport", event);
    }
    @EventHandler
    public void onPlayerPortal(org.bukkit.event.player.PlayerPortalEvent event) {
        jrubyEhCallIfRespond1("on_player_portal", event);
    }
    @EventHandler
    public void onPlayerPickupItem(org.bukkit.event.player.PlayerPickupItemEvent event) {
        jrubyEhCallIfRespond1("on_player_pickup_item", event);
    }
    @EventHandler
    public void onPlayerQuit(org.bukkit.event.player.PlayerQuitEvent event) {
        jrubyEhCallIfRespond1("on_player_quit", event);
    }
    @EventHandler
    public void onPlayerRespawn(org.bukkit.event.player.PlayerRespawnEvent event) {
        jrubyEhCallIfRespond1("on_player_respawn", event);
    }
    @EventHandler
    public void onPlayerShearEntity(org.bukkit.event.player.PlayerShearEntityEvent event) {
        jrubyEhCallIfRespond1("on_player_shear_entity", event);
    }
    @EventHandler
    public void onPlayerToggleFlight(org.bukkit.event.player.PlayerToggleFlightEvent event) {
        jrubyEhCallIfRespond1("on_player_toggle_flight", event);
    }
    @EventHandler
    public void onPlayerToggleSneak(org.bukkit.event.player.PlayerToggleSneakEvent event) {
        jrubyEhCallIfRespond1("on_player_toggle_sneak", event);
    }
    @EventHandler
    public void onPlayerToggleSprint(org.bukkit.event.player.PlayerToggleSprintEvent event) {
        jrubyEhCallIfRespond1("on_player_toggle_sprint", event);
    }
    @EventHandler
    public void onPlayerVelocity(org.bukkit.event.player.PlayerVelocityEvent event) {
        jrubyEhCallIfRespond1("on_player_velocity", event);
    }
    @EventHandler
    public void onMapInitialize(org.bukkit.event.server.MapInitializeEvent event) {
        jrubyEhCallIfRespond1("on_map_initialize", event);
    }
    @EventHandler
    public void onPluginDisable(org.bukkit.event.server.PluginDisableEvent event) {
        jrubyEhCallIfRespond1("on_plugin_disable", event);
    }
    @EventHandler
    public void onPluginEnable(org.bukkit.event.server.PluginEnableEvent event) {
        jrubyEhCallIfRespond1("on_plugin_enable", event);
    }
    @EventHandler
    public void onServerCommand(org.bukkit.event.server.ServerCommandEvent event) {
        jrubyEhCallIfRespond1("on_server_command", event);
    }
    @EventHandler
    public void onRemoteServerCommand(org.bukkit.event.server.RemoteServerCommandEvent event) {
        jrubyEhCallIfRespond1("on_remote_server_command", event);
    }
    @EventHandler
    public void onServerListPing(org.bukkit.event.server.ServerListPingEvent event) {
        jrubyEhCallIfRespond1("on_server_list_ping", event);
    }
    @EventHandler
    public void onServiceRegister(org.bukkit.event.server.ServiceRegisterEvent event) {
        jrubyEhCallIfRespond1("on_service_register", event);
    }
    @EventHandler
    public void onServiceUnregister(org.bukkit.event.server.ServiceUnregisterEvent event) {
        jrubyEhCallIfRespond1("on_service_unregister", event);
    }
    @EventHandler
    public void onVehicleBlockCollision(org.bukkit.event.vehicle.VehicleBlockCollisionEvent event) {
        jrubyEhCallIfRespond1("on_vehicle_block_collision", event);
    }
    @EventHandler
    public void onVehicleEntityCollision(org.bukkit.event.vehicle.VehicleEntityCollisionEvent event) {
        jrubyEhCallIfRespond1("on_vehicle_entity_collision", event);
    }
    @EventHandler
    public void onVehicleCreate(org.bukkit.event.vehicle.VehicleCreateEvent event) {
        jrubyEhCallIfRespond1("on_vehicle_create", event);
    }
    @EventHandler
    public void onVehicleDamage(org.bukkit.event.vehicle.VehicleDamageEvent event) {
        jrubyEhCallIfRespond1("on_vehicle_damage", event);
    }
    @EventHandler
    public void onVehicleDestroy(org.bukkit.event.vehicle.VehicleDestroyEvent event) {
        jrubyEhCallIfRespond1("on_vehicle_destroy", event);
    }
    @EventHandler
    public void onVehicleEnter(org.bukkit.event.vehicle.VehicleEnterEvent event) {
        jrubyEhCallIfRespond1("on_vehicle_enter", event);
    }
    @EventHandler
    public void onVehicleExit(org.bukkit.event.vehicle.VehicleExitEvent event) {
        jrubyEhCallIfRespond1("on_vehicle_exit", event);
    }
    @EventHandler
    public void onVehicleMove(org.bukkit.event.vehicle.VehicleMoveEvent event) {
        jrubyEhCallIfRespond1("on_vehicle_move", event);
    }
    @EventHandler
    public void onVehicleUpdate(org.bukkit.event.vehicle.VehicleUpdateEvent event) {
        jrubyEhCallIfRespond1("on_vehicle_update", event);
    }
    @EventHandler
    public void onLightningStrike(org.bukkit.event.weather.LightningStrikeEvent event) {
        jrubyEhCallIfRespond1("on_lightning_strike", event);
    }
    @EventHandler
    public void onThunderChange(org.bukkit.event.weather.ThunderChangeEvent event) {
        jrubyEhCallIfRespond1("on_thunder_change", event);
    }
    @EventHandler
    public void onWeatherChange(org.bukkit.event.weather.WeatherChangeEvent event) {
        jrubyEhCallIfRespond1("on_weather_change", event);
    }
    @EventHandler
    public void onChunkLoad(org.bukkit.event.world.ChunkLoadEvent event) {
        jrubyEhCallIfRespond1("on_chunk_load", event);
    }
    @EventHandler
    public void onChunkPopulate(org.bukkit.event.world.ChunkPopulateEvent event) {
        jrubyEhCallIfRespond1("on_chunk_populate", event);
    }
    @EventHandler
    public void onChunkUnload(org.bukkit.event.world.ChunkUnloadEvent event) {
        jrubyEhCallIfRespond1("on_chunk_unload", event);
    }
    @EventHandler
    public void onPortalCreate(org.bukkit.event.world.PortalCreateEvent event) {
        jrubyEhCallIfRespond1("on_portal_create", event);
    }
    @EventHandler
    public void onSpawnChange(org.bukkit.event.world.SpawnChangeEvent event) {
        jrubyEhCallIfRespond1("on_spawn_change", event);
    }
    @EventHandler
    public void onStructureGrow(org.bukkit.event.world.StructureGrowEvent event) {
        jrubyEhCallIfRespond1("on_structure_grow", event);
    }
    @EventHandler
    public void onWorldInit(org.bukkit.event.world.WorldInitEvent event) {
        jrubyEhCallIfRespond1("on_world_init", event);
    }
    @EventHandler
    public void onWorldLoad(org.bukkit.event.world.WorldLoadEvent event) {
        jrubyEhCallIfRespond1("on_world_load", event);
    }
    @EventHandler
    public void onWorldSave(org.bukkit.event.world.WorldSaveEvent event) {
        jrubyEhCallIfRespond1("on_world_save", event);
    }
    @EventHandler
    public void onWorldUnload(org.bukkit.event.world.WorldUnloadEvent event) {
        jrubyEhCallIfRespond1("on_world_unload", event);
    }
    /*
    @EventHandler
    public void onDynmapWebChat(org.dynmap.DynmapWebChatEvent event) {
        jrubyEhCallIfRespond1("dynmap-web-chat-event", event);
    }
    */

    /* end auto-generated code */
}
