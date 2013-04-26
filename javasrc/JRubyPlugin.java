package com.github.ujihisa.Mcsakura;
import java.io.File;
import org.bukkit.plugin.java.JavaPlugin;
import org.bukkit.plugin.PluginLoader;
import java.util.HashSet;
import java.net.URLClassLoader;
import org.bukkit.plugin.PluginDescriptionFile;
import org.bukkit.plugin.PluginManager;
import org.bukkit.Server;
import java.lang.ClassLoader;
import java.net.URL;
import org.bukkit.event.Listener;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Event;
//import org.bukkit.event.player.*;
//import org.bukkit.event.entity.*;
//import org.bukkit.event.block.*;
//import org.bukkit.event.vehicle.*;
//import org.bukkit.event.world.*;
//import org.bukkit.event.painting.*;
//import org.bukkit.event.server.*;
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

    //@Override public void onEnable() {}

    @Override public void onEnable() {
        jruby.setClassLoader(this.getClass().getClassLoader());
        jruby.setCompatVersion(org.jruby.CompatVersion.RUBY2_0);
        //jruby.runScriptlet("p RUBY_DESCRIPTION");

        URL url = getClass().getResource("/main.rb");
        try {
            eh = executeScript(
                    url.openStream(),
                    URLDecoder.decode(url.toString(), "UTF-8"));;
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

    /*
    private void jrubyCallIfRespond0(String fname) {
        jruby.callMethod(eh, fname, this);
    }
    */

    private void jrubyEhCallIfRespond1(String fname, Object x) {
        if ((boolean)jruby.callMethod(eh, "respond_to?", fname))
            jruby.callMethod(eh, fname, x);
    }

    private Object executeScript(InputStream io, String path) {
        try {
            return jruby.runScriptlet(io, path);
        } finally {
            try { if (io != null) io.close(); } catch (IOException e) {}
        }
    }

    @Override public void onDisable(String ns, String disableFunction) {
        /*
        clojure.lang.RT.var(ns, disableFunction).invoke(this);
        */
    }

    @Override public void onDisable() {
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
        jrubyEhCallIfRespond1("async_player_pre_login_event", event);
    }
    @EventHandler
    public void onBlockBurn(org.bukkit.event.block.BlockBurnEvent event) {
        jrubyEhCallIfRespond1("block_burn_event", event);
    }
    @EventHandler
    public void onBlockCanBuild(org.bukkit.event.block.BlockCanBuildEvent event) {
        jrubyEhCallIfRespond1("block_can_build_event", event);
    }
    @EventHandler
    public void onBlockDamage(org.bukkit.event.block.BlockDamageEvent event) {
        jrubyEhCallIfRespond1("block_damage_event", event);
    }
    @EventHandler
    public void onBlockDispense(org.bukkit.event.block.BlockDispenseEvent event) {
        jrubyEhCallIfRespond1("block_dispense_event", event);
    }
    @EventHandler
    public void onBlockBreak(org.bukkit.event.block.BlockBreakEvent event) {
        jrubyEhCallIfRespond1("block_break_event", event);
    }
    @EventHandler
    public void onFurnaceExtract(org.bukkit.event.inventory.FurnaceExtractEvent event) {
        jrubyEhCallIfRespond1("furnace_extract_event", event);
    }
    @EventHandler
    public void onBlockFade(org.bukkit.event.block.BlockFadeEvent event) {
        jrubyEhCallIfRespond1("block_fade_event", event);
    }
    @EventHandler
    public void onBlockFromTo(org.bukkit.event.block.BlockFromToEvent event) {
        jrubyEhCallIfRespond1("block_from_to_event", event);
    }
    @EventHandler
    public void onBlockForm(org.bukkit.event.block.BlockFormEvent event) {
        jrubyEhCallIfRespond1("block_form_event", event);
    }
    @EventHandler
    public void onBlockSpread(org.bukkit.event.block.BlockSpreadEvent event) {
        jrubyEhCallIfRespond1("block_spread_event", event);
    }
    @EventHandler
    public void onEntityBlockForm(org.bukkit.event.block.EntityBlockFormEvent event) {
        jrubyEhCallIfRespond1("entity_block_form_event", event);
    }
    @EventHandler
    public void onBlockIgnite(org.bukkit.event.block.BlockIgniteEvent event) {
        jrubyEhCallIfRespond1("block_ignite_event", event);
    }
    @EventHandler
    public void onBlockPhysics(org.bukkit.event.block.BlockPhysicsEvent event) {
        jrubyEhCallIfRespond1("block_physics_event", event);
    }
    @EventHandler
    public void onBlockPistonExtend(org.bukkit.event.block.BlockPistonExtendEvent event) {
        jrubyEhCallIfRespond1("block_piston_extend_event", event);
    }
    @EventHandler
    public void onBlockPistonRetract(org.bukkit.event.block.BlockPistonRetractEvent event) {
        jrubyEhCallIfRespond1("block_piston_retract_event", event);
    }
    @EventHandler
    public void onBlockPlace(org.bukkit.event.block.BlockPlaceEvent event) {
        jrubyEhCallIfRespond1("block_place_event", event);
    }
    @EventHandler
    public void onBlockRedstone(org.bukkit.event.block.BlockRedstoneEvent event) {
        jrubyEhCallIfRespond1("block_redstone_event", event);
    }
    @EventHandler
    public void onBrew(org.bukkit.event.inventory.BrewEvent event) {
        jrubyEhCallIfRespond1("brew_event", event);
    }
    @EventHandler
    public void onFurnaceBurn(org.bukkit.event.inventory.FurnaceBurnEvent event) {
        jrubyEhCallIfRespond1("furnace_burn_event", event);
    }
    @EventHandler
    public void onFurnaceSmelt(org.bukkit.event.inventory.FurnaceSmeltEvent event) {
        jrubyEhCallIfRespond1("furnace_smelt_event", event);
    }
    @EventHandler
    public void onLeavesDecay(org.bukkit.event.block.LeavesDecayEvent event) {
        jrubyEhCallIfRespond1("leaves_decay_event", event);
    }
    @EventHandler
    public void onNotePlay(org.bukkit.event.block.NotePlayEvent event) {
        jrubyEhCallIfRespond1("note_play_event", event);
    }
    @EventHandler
    public void onSignChange(org.bukkit.event.block.SignChangeEvent event) {
        jrubyEhCallIfRespond1("sign_change_event", event);
    }
    @EventHandler
    public void onCreatureSpawn(org.bukkit.event.entity.CreatureSpawnEvent event) {
        jrubyEhCallIfRespond1("creature_spawn_event", event);
    }
    @EventHandler
    public void onCreeperPower(org.bukkit.event.entity.CreeperPowerEvent event) {
        jrubyEhCallIfRespond1("creeper_power_event", event);
    }
    @EventHandler
    public void onEntityChangeBlock(org.bukkit.event.entity.EntityChangeBlockEvent event) {
        jrubyEhCallIfRespond1("entity_change_block_event", event);
    }
    @EventHandler
    public void onEntityBreakDoor(org.bukkit.event.entity.EntityBreakDoorEvent event) {
        jrubyEhCallIfRespond1("entity_break_door_event", event);
    }
    @EventHandler
    public void onEntityCombust(org.bukkit.event.entity.EntityCombustEvent event) {
        jrubyEhCallIfRespond1("entity_combust_event", event);
    }
    @EventHandler
    public void onEntityCombustByBlock(org.bukkit.event.entity.EntityCombustByBlockEvent event) {
        jrubyEhCallIfRespond1("entity_combust_by_block_event", event);
    }
    @EventHandler
    public void onEntityCombustByEntity(org.bukkit.event.entity.EntityCombustByEntityEvent event) {
        jrubyEhCallIfRespond1("entity_combust_by_entity_event", event);
    }
    @EventHandler
    public void onEntityCreatePortal(org.bukkit.event.entity.EntityCreatePortalEvent event) {
        jrubyEhCallIfRespond1("entity_create_portal_event", event);
    }
    @EventHandler
    public void onEntityDamageByBlock(org.bukkit.event.entity.EntityDamageEvent event) {
        jrubyEhCallIfRespond1("entity_damage_event", event);
    }
    @EventHandler
    public void onEntityDamageByBlock(org.bukkit.event.entity.EntityDamageByBlockEvent event) {
        jrubyEhCallIfRespond1("entity_damage_by_block_event", event);
    }
    @EventHandler
    public void onEntityDamageByEntity(org.bukkit.event.entity.EntityDamageByEntityEvent event) {
        jrubyEhCallIfRespond1("entity_damage_by_entity_event", event);
    }
    @EventHandler
    public void onEntityDeath(org.bukkit.event.entity.EntityDeathEvent event) {
        jrubyEhCallIfRespond1("entity_death_event", event);
    }
    @EventHandler
    public void onPlayerDeath(org.bukkit.event.entity.PlayerDeathEvent event) {
        jrubyEhCallIfRespond1("player_death_event", event);
    }
    @EventHandler
    public void onEntityExplode(org.bukkit.event.entity.EntityExplodeEvent event) {
        jrubyEhCallIfRespond1("entity_explode_event", event);
    }
    @EventHandler
    public void onEntityInteract(org.bukkit.event.entity.EntityInteractEvent event) {
        jrubyEhCallIfRespond1("entity_interact_event", event);
    }
    @EventHandler
    public void onEntityRegainHealth(org.bukkit.event.entity.EntityRegainHealthEvent event) {
        jrubyEhCallIfRespond1("entity_regain_health_event", event);
    }
    @EventHandler
    public void onEntityShootBow(org.bukkit.event.entity.EntityShootBowEvent event) {
        jrubyEhCallIfRespond1("entity_shoot_bow_event", event);
    }
    @EventHandler
    public void onEntityTame(org.bukkit.event.entity.EntityTameEvent event) {
        jrubyEhCallIfRespond1("entity_tame_event", event);
    }
    @EventHandler
    public void onEntityTarget(org.bukkit.event.entity.EntityTargetEvent event) {
        jrubyEhCallIfRespond1("entity_target_event", event);
    }
    @EventHandler
    public void onEntityTargetLivingEntity(org.bukkit.event.entity.EntityTargetLivingEntityEvent event) {
        jrubyEhCallIfRespond1("entity_target_living_entity_event", event);
    }
    @EventHandler
    public void onEntityTeleport(org.bukkit.event.entity.EntityTeleportEvent event) {
        jrubyEhCallIfRespond1("entity_teleport_event", event);
    }
    @EventHandler
    public void onExplosionPrime(org.bukkit.event.entity.ExplosionPrimeEvent event) {
        jrubyEhCallIfRespond1("explosion_prime_event", event);
    }
    @EventHandler
    public void onFoodLevelChange(org.bukkit.event.entity.FoodLevelChangeEvent event) {
        jrubyEhCallIfRespond1("food_level_change_event", event);
    }
    @EventHandler
    public void onItemDespawn(org.bukkit.event.entity.ItemDespawnEvent event) {
        jrubyEhCallIfRespond1("item_despawn_event", event);
    }
    @EventHandler
    public void onItemSpawn(org.bukkit.event.entity.ItemSpawnEvent event) {
        jrubyEhCallIfRespond1("item_spawn_event", event);
    }
    @EventHandler
    public void onPigZap(org.bukkit.event.entity.PigZapEvent event) {
        jrubyEhCallIfRespond1("pig_zap_event", event);
    }
    @EventHandler
    public void onProjectileHit(org.bukkit.event.entity.ProjectileHitEvent event) {
        jrubyEhCallIfRespond1("projectile_hit_event", event);
    }
    @EventHandler
    public void onExpBottle(org.bukkit.event.entity.ExpBottleEvent event) {
        jrubyEhCallIfRespond1("exp_bottle_event", event);
    }
    @EventHandler
    public void onPotionSplash(org.bukkit.event.entity.PotionSplashEvent event) {
        jrubyEhCallIfRespond1("potion_splash_event", event);
    }
    @EventHandler
    public void onProjectileLaunch(org.bukkit.event.entity.ProjectileLaunchEvent event) {
        jrubyEhCallIfRespond1("projectile_launch_event", event);
    }
    @EventHandler
    public void onSheepDyeWool(org.bukkit.event.entity.SheepDyeWoolEvent event) {
        jrubyEhCallIfRespond1("sheep_dye_wool_event", event);
    }
    @EventHandler
    public void onSheepRegrowWool(org.bukkit.event.entity.SheepRegrowWoolEvent event) {
        jrubyEhCallIfRespond1("sheep_regrow_wool_event", event);
    }
    @EventHandler
    public void onSlimeSplit(org.bukkit.event.entity.SlimeSplitEvent event) {
        jrubyEhCallIfRespond1("slime_split_event", event);
    }
    @EventHandler
    public void onHangingBreak(org.bukkit.event.hanging.HangingBreakEvent event) {
        jrubyEhCallIfRespond1("hanging_break_event", event);
    }
    @EventHandler
    public void onHangingBreakByEntity(org.bukkit.event.hanging.HangingBreakByEntityEvent event) {
        jrubyEhCallIfRespond1("hanging_break_by_entity_event", event);
    }
    @EventHandler
    public void onHangingPlace(org.bukkit.event.hanging.HangingPlaceEvent event) {
        jrubyEhCallIfRespond1("hanging_place_event", event);
    }
    @EventHandler
    public void onEnchantItem(org.bukkit.event.enchantment.EnchantItemEvent event) {
        jrubyEhCallIfRespond1("enchant_item_event", event);
    }
    @EventHandler
    public void onInventoryClick(org.bukkit.event.inventory.InventoryClickEvent event) {
        jrubyEhCallIfRespond1("inventory_click_event", event);
    }
    @EventHandler
    public void onCraftItem(org.bukkit.event.inventory.CraftItemEvent event) {
        jrubyEhCallIfRespond1("craft_item_event", event);
    }
    @EventHandler
    public void onInventoryClose(org.bukkit.event.inventory.InventoryCloseEvent event) {
        jrubyEhCallIfRespond1("inventory_close_event", event);
    }
    @EventHandler
    public void onInventoryOpen(org.bukkit.event.inventory.InventoryOpenEvent event) {
        jrubyEhCallIfRespond1("inventory_open_event", event);
    }
    @EventHandler
    public void onPrepareItemCraft(org.bukkit.event.inventory.PrepareItemCraftEvent event) {
        jrubyEhCallIfRespond1("prepare_item_craft_event", event);
    }
    @EventHandler
    public void onPrepareItemEnchant(org.bukkit.event.enchantment.PrepareItemEnchantEvent event) {
        jrubyEhCallIfRespond1("prepare_item_enchant_event", event);
    }
    @EventHandler
    public void onAsyncPlayerChat(org.bukkit.event.player.AsyncPlayerChatEvent event) {
        jrubyEhCallIfRespond1("async_player_chat_event", event);
    }
    @EventHandler
    public void onPlayerAnimation(org.bukkit.event.player.PlayerAnimationEvent event) {
        jrubyEhCallIfRespond1("player_animation_event", event);
    }
    @EventHandler
    public void onPlayerBedEnter(org.bukkit.event.player.PlayerBedEnterEvent event) {
        jrubyEhCallIfRespond1("player_bed_enter_event", event);
    }
    @EventHandler
    public void onPlayerBedLeave(org.bukkit.event.player.PlayerBedLeaveEvent event) {
        jrubyEhCallIfRespond1("player_bed_leave_event", event);
    }
    @EventHandler
    public void onPlayerBucketEmpty(org.bukkit.event.player.PlayerBucketEmptyEvent event) {
        jrubyEhCallIfRespond1("player_bucket_empty_event", event);
    }
    @EventHandler
    public void onPlayerBucketFill(org.bukkit.event.player.PlayerBucketFillEvent event) {
        jrubyEhCallIfRespond1("player_bucket_fill_event", event);
    }
    @EventHandler
    public void onPlayerChangedWorld(org.bukkit.event.player.PlayerChangedWorldEvent event) {
        jrubyEhCallIfRespond1("player_changed_world_event", event);
    }
    @EventHandler
    public void onPlayerRegisterChannel(org.bukkit.event.player.PlayerRegisterChannelEvent event) {
        jrubyEhCallIfRespond1("player_register_channel_event", event);
    }
    @EventHandler
    public void onPlayerUnregisterChannel(org.bukkit.event.player.PlayerUnregisterChannelEvent event) {
        jrubyEhCallIfRespond1("player_unregister_channel_event", event);
    }
    @EventHandler
    public void onPlayerChat(org.bukkit.event.player.PlayerChatEvent event) {
        jrubyEhCallIfRespond1("player_chat_event", event);
    }
    @EventHandler
    public void onPlayerChatTabComplete(org.bukkit.event.player.PlayerChatTabCompleteEvent event) {
        jrubyEhCallIfRespond1("player_chat_tab_complete_event", event);
    }
    @EventHandler
    public void onPlayerCommandPreprocess(org.bukkit.event.player.PlayerCommandPreprocessEvent event) {
        jrubyEhCallIfRespond1("player_command_preprocess_event", event);
    }
    @EventHandler
    public void onPlayerDropItem(org.bukkit.event.player.PlayerDropItemEvent event) {
        jrubyEhCallIfRespond1("player_drop_item_event", event);
    }
    @EventHandler
    public void onPlayerEggThrow(org.bukkit.event.player.PlayerEggThrowEvent event) {
        jrubyEhCallIfRespond1("player_egg_throw_event", event);
    }
    @EventHandler
    public void onPlayerExpChange(org.bukkit.event.player.PlayerExpChangeEvent event) {
        jrubyEhCallIfRespond1("player_exp_change_event", event);
    }
    @EventHandler
    public void onPlayerFish(org.bukkit.event.player.PlayerFishEvent event) {
        jrubyEhCallIfRespond1("player_fish_event", event);
    }
    @EventHandler
    public void onPlayerGameModeChange(org.bukkit.event.player.PlayerGameModeChangeEvent event) {
        jrubyEhCallIfRespond1("player_game_mode_change_event", event);
    }
    @EventHandler
    public void onPlayerInteractEntity(org.bukkit.event.player.PlayerInteractEntityEvent event) {
        jrubyEhCallIfRespond1("player_interact_entity_event", event);
    }
    @EventHandler
    public void onPlayerInteract(org.bukkit.event.player.PlayerInteractEvent event) {
        jrubyEhCallIfRespond1("player_interact_event", event);
    }
    @EventHandler
    public void onPlayerItemBreak(org.bukkit.event.player.PlayerItemBreakEvent event) {
        jrubyEhCallIfRespond1("player_item_break_event", event);
    }
    @EventHandler
    public void onPlayerItemHeld(org.bukkit.event.player.PlayerItemHeldEvent event) {
        jrubyEhCallIfRespond1("player_item_held_event", event);
    }
    @EventHandler
    public void onPlayerJoin(org.bukkit.event.player.PlayerJoinEvent event) {
        jrubyEhCallIfRespond1("player_join_event", event);
    }
    @EventHandler
    public void onPlayerKick(org.bukkit.event.player.PlayerKickEvent event) {
        jrubyEhCallIfRespond1("player_kick_event", event);
    }
    @EventHandler
    public void onPlayerLevelChange(org.bukkit.event.player.PlayerLevelChangeEvent event) {
        jrubyEhCallIfRespond1("player_level_change_event", event);
    }
    @EventHandler
    public void onPlayerLogin(org.bukkit.event.player.PlayerLoginEvent event) {
        jrubyEhCallIfRespond1("player_login_event", event);
    }
    @EventHandler
    public void onPlayerMove(org.bukkit.event.player.PlayerMoveEvent event) {
        jrubyEhCallIfRespond1("player_move_event", event);
    }
    @EventHandler
    public void onPlayerTeleport(org.bukkit.event.player.PlayerTeleportEvent event) {
        jrubyEhCallIfRespond1("player_teleport_event", event);
    }
    @EventHandler
    public void onPlayerPortal(org.bukkit.event.player.PlayerPortalEvent event) {
        jrubyEhCallIfRespond1("player_portal_event", event);
    }
    @EventHandler
    public void onPlayerPickupItem(org.bukkit.event.player.PlayerPickupItemEvent event) {
        jrubyEhCallIfRespond1("player_pickup_item_event", event);
    }
    @EventHandler
    public void onPlayerQuit(org.bukkit.event.player.PlayerQuitEvent event) {
        jrubyEhCallIfRespond1("player_quit_event", event);
    }
    @EventHandler
    public void onPlayerRespawn(org.bukkit.event.player.PlayerRespawnEvent event) {
        jrubyEhCallIfRespond1("player_respawn_event", event);
    }
    @EventHandler
    public void onPlayerShearEntity(org.bukkit.event.player.PlayerShearEntityEvent event) {
        jrubyEhCallIfRespond1("player_shear_entity_event", event);
    }
    @EventHandler
    public void onPlayerToggleFlight(org.bukkit.event.player.PlayerToggleFlightEvent event) {
        jrubyEhCallIfRespond1("player_toggle_flight_event", event);
    }
    @EventHandler
    public void onPlayerToggleSneak(org.bukkit.event.player.PlayerToggleSneakEvent event) {
        jrubyEhCallIfRespond1("player_toggle_sneak_event", event);
    }
    @EventHandler
    public void onPlayerToggleSprint(org.bukkit.event.player.PlayerToggleSprintEvent event) {
        jrubyEhCallIfRespond1("player_toggle_sprint_event", event);
    }
    @EventHandler
    public void onPlayerVelocity(org.bukkit.event.player.PlayerVelocityEvent event) {
        jrubyEhCallIfRespond1("player_velocity_event", event);
    }
    @EventHandler
    public void onPlayerPreLogin(org.bukkit.event.player.PlayerPreLoginEvent event) {
        jrubyEhCallIfRespond1("player_pre_login_event", event);
    }
    @EventHandler
    public void onMapInitialize(org.bukkit.event.server.MapInitializeEvent event) {
        jrubyEhCallIfRespond1("map_initialize_event", event);
    }
    @EventHandler
    public void onPluginDisable(org.bukkit.event.server.PluginDisableEvent event) {
        jrubyEhCallIfRespond1("plugin_disable_event", event);
    }
    @EventHandler
    public void onPluginEnable(org.bukkit.event.server.PluginEnableEvent event) {
        jrubyEhCallIfRespond1("plugin_enable_event", event);
    }
    @EventHandler
    public void onServerCommand(org.bukkit.event.server.ServerCommandEvent event) {
        jrubyEhCallIfRespond1("server_command_event", event);
    }
    @EventHandler
    public void onRemoteServerCommand(org.bukkit.event.server.RemoteServerCommandEvent event) {
        jrubyEhCallIfRespond1("remote_server_command_event", event);
    }
    @EventHandler
    public void onServerListPing(org.bukkit.event.server.ServerListPingEvent event) {
        jrubyEhCallIfRespond1("server_list_ping_event", event);
    }
    @EventHandler
    public void onServiceRegister(org.bukkit.event.server.ServiceRegisterEvent event) {
        jrubyEhCallIfRespond1("service_register_event", event);
    }
    @EventHandler
    public void onServiceUnregister(org.bukkit.event.server.ServiceUnregisterEvent event) {
        jrubyEhCallIfRespond1("service_unregister_event", event);
    }
    @EventHandler
    public void onVehicleBlockCollision(org.bukkit.event.vehicle.VehicleBlockCollisionEvent event) {
        jrubyEhCallIfRespond1("vehicle_block_collision_event", event);
    }
    @EventHandler
    public void onVehicleEntityCollision(org.bukkit.event.vehicle.VehicleEntityCollisionEvent event) {
        jrubyEhCallIfRespond1("vehicle_entity_collision_event", event);
    }
    @EventHandler
    public void onVehicleCreate(org.bukkit.event.vehicle.VehicleCreateEvent event) {
        jrubyEhCallIfRespond1("vehicle_create_event", event);
    }
    @EventHandler
    public void onVehicleDamage(org.bukkit.event.vehicle.VehicleDamageEvent event) {
        jrubyEhCallIfRespond1("vehicle_damage_event", event);
    }
    @EventHandler
    public void onVehicleDestroy(org.bukkit.event.vehicle.VehicleDestroyEvent event) {
        jrubyEhCallIfRespond1("vehicle_destroy_event", event);
    }
    @EventHandler
    public void onVehicleEnter(org.bukkit.event.vehicle.VehicleEnterEvent event) {
        jrubyEhCallIfRespond1("vehicle_enter_event", event);
    }
    @EventHandler
    public void onVehicleExit(org.bukkit.event.vehicle.VehicleExitEvent event) {
        jrubyEhCallIfRespond1("vehicle_exit_event", event);
    }
    @EventHandler
    public void onVehicleMove(org.bukkit.event.vehicle.VehicleMoveEvent event) {
        jrubyEhCallIfRespond1("vehicle_move_event", event);
    }
    @EventHandler
    public void onVehicleUpdate(org.bukkit.event.vehicle.VehicleUpdateEvent event) {
        jrubyEhCallIfRespond1("vehicle_update_event", event);
    }
    @EventHandler
    public void onLightningStrike(org.bukkit.event.weather.LightningStrikeEvent event) {
        jrubyEhCallIfRespond1("lightning_strike_event", event);
    }
    @EventHandler
    public void onThunderChange(org.bukkit.event.weather.ThunderChangeEvent event) {
        jrubyEhCallIfRespond1("thunder_change_event", event);
    }
    @EventHandler
    public void onWeatherChange(org.bukkit.event.weather.WeatherChangeEvent event) {
        jrubyEhCallIfRespond1("weather_change_event", event);
    }
    @EventHandler
    public void onChunkLoad(org.bukkit.event.world.ChunkLoadEvent event) {
        jrubyEhCallIfRespond1("chunk_load_event", event);
    }
    @EventHandler
    public void onChunkPopulate(org.bukkit.event.world.ChunkPopulateEvent event) {
        jrubyEhCallIfRespond1("chunk_populate_event", event);
    }
    @EventHandler
    public void onChunkUnload(org.bukkit.event.world.ChunkUnloadEvent event) {
        jrubyEhCallIfRespond1("chunk_unload_event", event);
    }
    @EventHandler
    public void onPortalCreate(org.bukkit.event.world.PortalCreateEvent event) {
        jrubyEhCallIfRespond1("portal_create_event", event);
    }
    @EventHandler
    public void onSpawnChange(org.bukkit.event.world.SpawnChangeEvent event) {
        jrubyEhCallIfRespond1("spawn_change_event", event);
    }
    @EventHandler
    public void onStructureGrow(org.bukkit.event.world.StructureGrowEvent event) {
        jrubyEhCallIfRespond1("structure_grow_event", event);
    }
    @EventHandler
    public void onWorldInit(org.bukkit.event.world.WorldInitEvent event) {
        jrubyEhCallIfRespond1("world_init_event", event);
    }
    @EventHandler
    public void onWorldLoad(org.bukkit.event.world.WorldLoadEvent event) {
        jrubyEhCallIfRespond1("world_load_event", event);
    }
    @EventHandler
    public void onWorldSave(org.bukkit.event.world.WorldSaveEvent event) {
        jrubyEhCallIfRespond1("world_save_event", event);
    }
    @EventHandler
    public void onWorldUnload(org.bukkit.event.world.WorldUnloadEvent event) {
        jrubyEhCallIfRespond1("world_unload_event", event);
    }
    /*
    @EventHandler
    public void onDynmapWebChat(org.dynmap.DynmapWebChatEvent event) {
        jrubyEhCallIfRespond1("dynmap-web-chat-event", event);
    }
    */

    /* end auto-generated code */

    /*
    private void invokeClojureFunc(String enableFunction, Object arg) {
        try {
            ClassLoader previous = Thread.currentThread().getContextClassLoader();
            Thread.currentThread().setContextClassLoader(this.getClass().getClassLoader()); 

            clojure.lang.RT.loadResourceScript(ns.replaceAll("[.]", "/")+".clj");
            clojure.lang.RT.var(ns, enableFunction).invoke(arg);

            Thread.currentThread().setContextClassLoader(previous);
        } catch (Exception e) {
            System.out.println("Something broke setting up Clojure");
            e.printStackTrace();
        }
    }
    */
}
