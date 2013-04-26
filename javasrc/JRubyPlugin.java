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
        jrubyEhCallIfRespond1("async-player-pre-login-event", event);
    }
    @EventHandler
    public void onBlockBurn(org.bukkit.event.block.BlockBurnEvent event) {
        jrubyEhCallIfRespond1("block-burn-event", event);
    }
    @EventHandler
    public void onBlockCanBuild(org.bukkit.event.block.BlockCanBuildEvent event) {
        jrubyEhCallIfRespond1("block-can-build-event", event);
    }
    @EventHandler
    public void onBlockDamage(org.bukkit.event.block.BlockDamageEvent event) {
        jrubyEhCallIfRespond1("block-damage-event", event);
    }
    @EventHandler
    public void onBlockDispense(org.bukkit.event.block.BlockDispenseEvent event) {
        jrubyEhCallIfRespond1("block-dispense-event", event);
    }
    @EventHandler
    public void onBlockBreak(org.bukkit.event.block.BlockBreakEvent event) {
        jrubyEhCallIfRespond1("block-break-event", event);
    }
    @EventHandler
    public void onFurnaceExtract(org.bukkit.event.inventory.FurnaceExtractEvent event) {
        jrubyEhCallIfRespond1("furnace-extract-event", event);
    }
    @EventHandler
    public void onBlockFade(org.bukkit.event.block.BlockFadeEvent event) {
        jrubyEhCallIfRespond1("block-fade-event", event);
    }
    @EventHandler
    public void onBlockFromTo(org.bukkit.event.block.BlockFromToEvent event) {
        jrubyEhCallIfRespond1("block-from-to-event", event);
    }
    @EventHandler
    public void onBlockForm(org.bukkit.event.block.BlockFormEvent event) {
        jrubyEhCallIfRespond1("block-form-event", event);
    }
    @EventHandler
    public void onBlockSpread(org.bukkit.event.block.BlockSpreadEvent event) {
        jrubyEhCallIfRespond1("block-spread-event", event);
    }
    @EventHandler
    public void onEntityBlockForm(org.bukkit.event.block.EntityBlockFormEvent event) {
        jrubyEhCallIfRespond1("entity-block-form-event", event);
    }
    @EventHandler
    public void onBlockIgnite(org.bukkit.event.block.BlockIgniteEvent event) {
        jrubyEhCallIfRespond1("block-ignite-event", event);
    }
    @EventHandler
    public void onBlockPhysics(org.bukkit.event.block.BlockPhysicsEvent event) {
        jrubyEhCallIfRespond1("block-physics-event", event);
    }
    @EventHandler
    public void onBlockPistonExtend(org.bukkit.event.block.BlockPistonExtendEvent event) {
        jrubyEhCallIfRespond1("block-piston-extend-event", event);
    }
    @EventHandler
    public void onBlockPistonRetract(org.bukkit.event.block.BlockPistonRetractEvent event) {
        jrubyEhCallIfRespond1("block-piston-retract-event", event);
    }
    @EventHandler
    public void onBlockPlace(org.bukkit.event.block.BlockPlaceEvent event) {
        jrubyEhCallIfRespond1("block-place-event", event);
    }
    @EventHandler
    public void onBlockRedstone(org.bukkit.event.block.BlockRedstoneEvent event) {
        jrubyEhCallIfRespond1("block-redstone-event", event);
    }
    @EventHandler
    public void onBrew(org.bukkit.event.inventory.BrewEvent event) {
        jrubyEhCallIfRespond1("brew-event", event);
    }
    @EventHandler
    public void onFurnaceBurn(org.bukkit.event.inventory.FurnaceBurnEvent event) {
        jrubyEhCallIfRespond1("furnace-burn-event", event);
    }
    @EventHandler
    public void onFurnaceSmelt(org.bukkit.event.inventory.FurnaceSmeltEvent event) {
        jrubyEhCallIfRespond1("furnace-smelt-event", event);
    }
    @EventHandler
    public void onLeavesDecay(org.bukkit.event.block.LeavesDecayEvent event) {
        jrubyEhCallIfRespond1("leaves-decay-event", event);
    }
    @EventHandler
    public void onNotePlay(org.bukkit.event.block.NotePlayEvent event) {
        jrubyEhCallIfRespond1("note-play-event", event);
    }
    @EventHandler
    public void onSignChange(org.bukkit.event.block.SignChangeEvent event) {
        jrubyEhCallIfRespond1("sign-change-event", event);
    }
    @EventHandler
    public void onCreatureSpawn(org.bukkit.event.entity.CreatureSpawnEvent event) {
        jrubyEhCallIfRespond1("creature-spawn-event", event);
    }
    @EventHandler
    public void onCreeperPower(org.bukkit.event.entity.CreeperPowerEvent event) {
        jrubyEhCallIfRespond1("creeper-power-event", event);
    }
    @EventHandler
    public void onEntityChangeBlock(org.bukkit.event.entity.EntityChangeBlockEvent event) {
        jrubyEhCallIfRespond1("entity-change-block-event", event);
    }
    @EventHandler
    public void onEntityBreakDoor(org.bukkit.event.entity.EntityBreakDoorEvent event) {
        jrubyEhCallIfRespond1("entity-break-door-event", event);
    }
    @EventHandler
    public void onEntityCombust(org.bukkit.event.entity.EntityCombustEvent event) {
        jrubyEhCallIfRespond1("entity-combust-event", event);
    }
    @EventHandler
    public void onEntityCombustByBlock(org.bukkit.event.entity.EntityCombustByBlockEvent event) {
        jrubyEhCallIfRespond1("entity-combust-by-block-event", event);
    }
    @EventHandler
    public void onEntityCombustByEntity(org.bukkit.event.entity.EntityCombustByEntityEvent event) {
        jrubyEhCallIfRespond1("entity-combust-by-entity-event", event);
    }
    @EventHandler
    public void onEntityCreatePortal(org.bukkit.event.entity.EntityCreatePortalEvent event) {
        jrubyEhCallIfRespond1("entity-create-portal-event", event);
    }
    @EventHandler
    public void onEntityDamageByBlock(org.bukkit.event.entity.EntityDamageEvent event) {
        jrubyEhCallIfRespond1("entity-damage-event", event);
    }
    @EventHandler
    public void onEntityDamageByBlock(org.bukkit.event.entity.EntityDamageByBlockEvent event) {
        jrubyEhCallIfRespond1("entity-damage-by-block-event", event);
    }
    @EventHandler
    public void onEntityDamageByEntity(org.bukkit.event.entity.EntityDamageByEntityEvent event) {
        jrubyEhCallIfRespond1("entity-damage-by-entity-event", event);
    }
    @EventHandler
    public void onEntityDeath(org.bukkit.event.entity.EntityDeathEvent event) {
        jrubyEhCallIfRespond1("entity-death-event", event);
    }
    @EventHandler
    public void onPlayerDeath(org.bukkit.event.entity.PlayerDeathEvent event) {
        jrubyEhCallIfRespond1("player-death-event", event);
    }
    @EventHandler
    public void onEntityExplode(org.bukkit.event.entity.EntityExplodeEvent event) {
        jrubyEhCallIfRespond1("entity-explode-event", event);
    }
    @EventHandler
    public void onEntityInteract(org.bukkit.event.entity.EntityInteractEvent event) {
        jrubyEhCallIfRespond1("entity-interact-event", event);
    }
    @EventHandler
    public void onEntityRegainHealth(org.bukkit.event.entity.EntityRegainHealthEvent event) {
        jrubyEhCallIfRespond1("entity-regain-health-event", event);
    }
    @EventHandler
    public void onEntityShootBow(org.bukkit.event.entity.EntityShootBowEvent event) {
        jrubyEhCallIfRespond1("entity-shoot-bow-event", event);
    }
    @EventHandler
    public void onEntityTame(org.bukkit.event.entity.EntityTameEvent event) {
        jrubyEhCallIfRespond1("entity-tame-event", event);
    }
    @EventHandler
    public void onEntityTarget(org.bukkit.event.entity.EntityTargetEvent event) {
        jrubyEhCallIfRespond1("entity-target-event", event);
    }
    @EventHandler
    public void onEntityTargetLivingEntity(org.bukkit.event.entity.EntityTargetLivingEntityEvent event) {
        jrubyEhCallIfRespond1("entity-target-living-entity-event", event);
    }
    @EventHandler
    public void onEntityTeleport(org.bukkit.event.entity.EntityTeleportEvent event) {
        jrubyEhCallIfRespond1("entity-teleport-event", event);
    }
    @EventHandler
    public void onExplosionPrime(org.bukkit.event.entity.ExplosionPrimeEvent event) {
        jrubyEhCallIfRespond1("explosion-prime-event", event);
    }
    @EventHandler
    public void onFoodLevelChange(org.bukkit.event.entity.FoodLevelChangeEvent event) {
        jrubyEhCallIfRespond1("food-level-change-event", event);
    }
    @EventHandler
    public void onItemDespawn(org.bukkit.event.entity.ItemDespawnEvent event) {
        jrubyEhCallIfRespond1("item-despawn-event", event);
    }
    @EventHandler
    public void onItemSpawn(org.bukkit.event.entity.ItemSpawnEvent event) {
        jrubyEhCallIfRespond1("item-spawn-event", event);
    }
    @EventHandler
    public void onPigZap(org.bukkit.event.entity.PigZapEvent event) {
        jrubyEhCallIfRespond1("pig-zap-event", event);
    }
    @EventHandler
    public void onProjectileHit(org.bukkit.event.entity.ProjectileHitEvent event) {
        jrubyEhCallIfRespond1("projectile-hit-event", event);
    }
    @EventHandler
    public void onExpBottle(org.bukkit.event.entity.ExpBottleEvent event) {
        jrubyEhCallIfRespond1("exp-bottle-event", event);
    }
    @EventHandler
    public void onPotionSplash(org.bukkit.event.entity.PotionSplashEvent event) {
        jrubyEhCallIfRespond1("potion-splash-event", event);
    }
    @EventHandler
    public void onProjectileLaunch(org.bukkit.event.entity.ProjectileLaunchEvent event) {
        jrubyEhCallIfRespond1("projectile-launch-event", event);
    }
    @EventHandler
    public void onSheepDyeWool(org.bukkit.event.entity.SheepDyeWoolEvent event) {
        jrubyEhCallIfRespond1("sheep-dye-wool-event", event);
    }
    @EventHandler
    public void onSheepRegrowWool(org.bukkit.event.entity.SheepRegrowWoolEvent event) {
        jrubyEhCallIfRespond1("sheep-regrow-wool-event", event);
    }
    @EventHandler
    public void onSlimeSplit(org.bukkit.event.entity.SlimeSplitEvent event) {
        jrubyEhCallIfRespond1("slime-split-event", event);
    }
    @EventHandler
    public void onHangingBreak(org.bukkit.event.hanging.HangingBreakEvent event) {
        jrubyEhCallIfRespond1("hanging-break-event", event);
    }
    @EventHandler
    public void onHangingBreakByEntity(org.bukkit.event.hanging.HangingBreakByEntityEvent event) {
        jrubyEhCallIfRespond1("hanging-break-by-entity-event", event);
    }
    @EventHandler
    public void onHangingPlace(org.bukkit.event.hanging.HangingPlaceEvent event) {
        jrubyEhCallIfRespond1("hanging-place-event", event);
    }
    @EventHandler
    public void onEnchantItem(org.bukkit.event.enchantment.EnchantItemEvent event) {
        jrubyEhCallIfRespond1("enchant-item-event", event);
    }
    @EventHandler
    public void onInventoryClick(org.bukkit.event.inventory.InventoryClickEvent event) {
        jrubyEhCallIfRespond1("inventory-click-event", event);
    }
    @EventHandler
    public void onCraftItem(org.bukkit.event.inventory.CraftItemEvent event) {
        jrubyEhCallIfRespond1("craft-item-event", event);
    }
    @EventHandler
    public void onInventoryClose(org.bukkit.event.inventory.InventoryCloseEvent event) {
        jrubyEhCallIfRespond1("inventory-close-event", event);
    }
    @EventHandler
    public void onInventoryOpen(org.bukkit.event.inventory.InventoryOpenEvent event) {
        jrubyEhCallIfRespond1("inventory-open-event", event);
    }
    @EventHandler
    public void onPrepareItemCraft(org.bukkit.event.inventory.PrepareItemCraftEvent event) {
        jrubyEhCallIfRespond1("prepare-item-craft-event", event);
    }
    @EventHandler
    public void onPrepareItemEnchant(org.bukkit.event.enchantment.PrepareItemEnchantEvent event) {
        jrubyEhCallIfRespond1("prepare-item-enchant-event", event);
    }
    @EventHandler
    public void onAsyncPlayerChat(org.bukkit.event.player.AsyncPlayerChatEvent event) {
        jrubyEhCallIfRespond1("async-player-chat-event", event);
    }
    @EventHandler
    public void onPlayerAnimation(org.bukkit.event.player.PlayerAnimationEvent event) {
        jrubyEhCallIfRespond1("player-animation-event", event);
    }
    @EventHandler
    public void onPlayerBedEnter(org.bukkit.event.player.PlayerBedEnterEvent event) {
        jrubyEhCallIfRespond1("player-bed-enter-event", event);
    }
    @EventHandler
    public void onPlayerBedLeave(org.bukkit.event.player.PlayerBedLeaveEvent event) {
        jrubyEhCallIfRespond1("player-bed-leave-event", event);
    }
    @EventHandler
    public void onPlayerBucketEmpty(org.bukkit.event.player.PlayerBucketEmptyEvent event) {
        jrubyEhCallIfRespond1("player-bucket-empty-event", event);
    }
    @EventHandler
    public void onPlayerBucketFill(org.bukkit.event.player.PlayerBucketFillEvent event) {
        jrubyEhCallIfRespond1("player-bucket-fill-event", event);
    }
    @EventHandler
    public void onPlayerChangedWorld(org.bukkit.event.player.PlayerChangedWorldEvent event) {
        jrubyEhCallIfRespond1("player-changed-world-event", event);
    }
    @EventHandler
    public void onPlayerRegisterChannel(org.bukkit.event.player.PlayerRegisterChannelEvent event) {
        jrubyEhCallIfRespond1("player-register-channel-event", event);
    }
    @EventHandler
    public void onPlayerUnregisterChannel(org.bukkit.event.player.PlayerUnregisterChannelEvent event) {
        jrubyEhCallIfRespond1("player-unregister-channel-event", event);
    }
    @EventHandler
    public void onPlayerChat(org.bukkit.event.player.PlayerChatEvent event) {
        jrubyEhCallIfRespond1("player-chat-event", event);
    }
    @EventHandler
    public void onPlayerChatTabComplete(org.bukkit.event.player.PlayerChatTabCompleteEvent event) {
        jrubyEhCallIfRespond1("player-chat-tab-complete-event", event);
    }
    @EventHandler
    public void onPlayerCommandPreprocess(org.bukkit.event.player.PlayerCommandPreprocessEvent event) {
        jrubyEhCallIfRespond1("player-command-preprocess-event", event);
    }
    @EventHandler
    public void onPlayerDropItem(org.bukkit.event.player.PlayerDropItemEvent event) {
        jrubyEhCallIfRespond1("player-drop-item-event", event);
    }
    @EventHandler
    public void onPlayerEggThrow(org.bukkit.event.player.PlayerEggThrowEvent event) {
        jrubyEhCallIfRespond1("player-egg-throw-event", event);
    }
    @EventHandler
    public void onPlayerExpChange(org.bukkit.event.player.PlayerExpChangeEvent event) {
        jrubyEhCallIfRespond1("player-exp-change-event", event);
    }
    @EventHandler
    public void onPlayerFish(org.bukkit.event.player.PlayerFishEvent event) {
        jrubyEhCallIfRespond1("player-fish-event", event);
    }
    @EventHandler
    public void onPlayerGameModeChange(org.bukkit.event.player.PlayerGameModeChangeEvent event) {
        jrubyEhCallIfRespond1("player-game-mode-change-event", event);
    }
    @EventHandler
    public void onPlayerInteractEntity(org.bukkit.event.player.PlayerInteractEntityEvent event) {
        jrubyEhCallIfRespond1("player-interact-entity-event", event);
    }
    @EventHandler
    public void onPlayerInteract(org.bukkit.event.player.PlayerInteractEvent event) {
        jrubyEhCallIfRespond1("player-interact-event", event);
    }
    @EventHandler
    public void onPlayerItemBreak(org.bukkit.event.player.PlayerItemBreakEvent event) {
        jrubyEhCallIfRespond1("player-item-break-event", event);
    }
    @EventHandler
    public void onPlayerItemHeld(org.bukkit.event.player.PlayerItemHeldEvent event) {
        jrubyEhCallIfRespond1("player-item-held-event", event);
    }
    @EventHandler
    public void onPlayerJoin(org.bukkit.event.player.PlayerJoinEvent event) {
        jrubyEhCallIfRespond1("player-join-event", event);
    }
    @EventHandler
    public void onPlayerKick(org.bukkit.event.player.PlayerKickEvent event) {
        jrubyEhCallIfRespond1("player-kick-event", event);
    }
    @EventHandler
    public void onPlayerLevelChange(org.bukkit.event.player.PlayerLevelChangeEvent event) {
        jrubyEhCallIfRespond1("player-level-change-event", event);
    }
    @EventHandler
    public void onPlayerLogin(org.bukkit.event.player.PlayerLoginEvent event) {
        jrubyEhCallIfRespond1("player-login-event", event);
    }
    @EventHandler
    public void onPlayerMove(org.bukkit.event.player.PlayerMoveEvent event) {
        jrubyEhCallIfRespond1("player-move-event", event);
    }
    @EventHandler
    public void onPlayerTeleport(org.bukkit.event.player.PlayerTeleportEvent event) {
        jrubyEhCallIfRespond1("player-teleport-event", event);
    }
    @EventHandler
    public void onPlayerPortal(org.bukkit.event.player.PlayerPortalEvent event) {
        jrubyEhCallIfRespond1("player-portal-event", event);
    }
    @EventHandler
    public void onPlayerPickupItem(org.bukkit.event.player.PlayerPickupItemEvent event) {
        jrubyEhCallIfRespond1("player-pickup-item-event", event);
    }
    @EventHandler
    public void onPlayerQuit(org.bukkit.event.player.PlayerQuitEvent event) {
        jrubyEhCallIfRespond1("player-quit-event", event);
    }
    @EventHandler
    public void onPlayerRespawn(org.bukkit.event.player.PlayerRespawnEvent event) {
        jrubyEhCallIfRespond1("player-respawn-event", event);
    }
    @EventHandler
    public void onPlayerShearEntity(org.bukkit.event.player.PlayerShearEntityEvent event) {
        jrubyEhCallIfRespond1("player-shear-entity-event", event);
    }
    @EventHandler
    public void onPlayerToggleFlight(org.bukkit.event.player.PlayerToggleFlightEvent event) {
        jrubyEhCallIfRespond1("player-toggle-flight-event", event);
    }
    @EventHandler
    public void onPlayerToggleSneak(org.bukkit.event.player.PlayerToggleSneakEvent event) {
        jrubyEhCallIfRespond1("player-toggle-sneak-event", event);
    }
    @EventHandler
    public void onPlayerToggleSprint(org.bukkit.event.player.PlayerToggleSprintEvent event) {
        jrubyEhCallIfRespond1("player-toggle-sprint-event", event);
    }
    @EventHandler
    public void onPlayerVelocity(org.bukkit.event.player.PlayerVelocityEvent event) {
        jrubyEhCallIfRespond1("player-velocity-event", event);
    }
    @EventHandler
    public void onPlayerPreLogin(org.bukkit.event.player.PlayerPreLoginEvent event) {
        jrubyEhCallIfRespond1("player-pre-login-event", event);
    }
    @EventHandler
    public void onMapInitialize(org.bukkit.event.server.MapInitializeEvent event) {
        jrubyEhCallIfRespond1("map-initialize-event", event);
    }
    @EventHandler
    public void onPluginDisable(org.bukkit.event.server.PluginDisableEvent event) {
        jrubyEhCallIfRespond1("plugin-disable-event", event);
    }
    @EventHandler
    public void onPluginEnable(org.bukkit.event.server.PluginEnableEvent event) {
        jrubyEhCallIfRespond1("plugin-enable-event", event);
    }
    @EventHandler
    public void onServerCommand(org.bukkit.event.server.ServerCommandEvent event) {
        jrubyEhCallIfRespond1("server-command-event", event);
    }
    @EventHandler
    public void onRemoteServerCommand(org.bukkit.event.server.RemoteServerCommandEvent event) {
        jrubyEhCallIfRespond1("remote-server-command-event", event);
    }
    @EventHandler
    public void onServerListPing(org.bukkit.event.server.ServerListPingEvent event) {
        jrubyEhCallIfRespond1("server-list-ping-event", event);
    }
    @EventHandler
    public void onServiceRegister(org.bukkit.event.server.ServiceRegisterEvent event) {
        jrubyEhCallIfRespond1("service-register-event", event);
    }
    @EventHandler
    public void onServiceUnregister(org.bukkit.event.server.ServiceUnregisterEvent event) {
        jrubyEhCallIfRespond1("service-unregister-event", event);
    }
    @EventHandler
    public void onVehicleBlockCollision(org.bukkit.event.vehicle.VehicleBlockCollisionEvent event) {
        jrubyEhCallIfRespond1("vehicle-block-collision-event", event);
    }
    @EventHandler
    public void onVehicleEntityCollision(org.bukkit.event.vehicle.VehicleEntityCollisionEvent event) {
        jrubyEhCallIfRespond1("vehicle-entity-collision-event", event);
    }
    @EventHandler
    public void onVehicleCreate(org.bukkit.event.vehicle.VehicleCreateEvent event) {
        jrubyEhCallIfRespond1("vehicle-create-event", event);
    }
    @EventHandler
    public void onVehicleDamage(org.bukkit.event.vehicle.VehicleDamageEvent event) {
        jrubyEhCallIfRespond1("vehicle-damage-event", event);
    }
    @EventHandler
    public void onVehicleDestroy(org.bukkit.event.vehicle.VehicleDestroyEvent event) {
        jrubyEhCallIfRespond1("vehicle-destroy-event", event);
    }
    @EventHandler
    public void onVehicleEnter(org.bukkit.event.vehicle.VehicleEnterEvent event) {
        jrubyEhCallIfRespond1("vehicle-enter-event", event);
    }
    @EventHandler
    public void onVehicleExit(org.bukkit.event.vehicle.VehicleExitEvent event) {
        jrubyEhCallIfRespond1("vehicle-exit-event", event);
    }
    @EventHandler
    public void onVehicleMove(org.bukkit.event.vehicle.VehicleMoveEvent event) {
        jrubyEhCallIfRespond1("vehicle-move-event", event);
    }
    @EventHandler
    public void onVehicleUpdate(org.bukkit.event.vehicle.VehicleUpdateEvent event) {
        jrubyEhCallIfRespond1("vehicle-update-event", event);
    }
    @EventHandler
    public void onLightningStrike(org.bukkit.event.weather.LightningStrikeEvent event) {
        jrubyEhCallIfRespond1("lightning-strike-event", event);
    }
    @EventHandler
    public void onThunderChange(org.bukkit.event.weather.ThunderChangeEvent event) {
        jrubyEhCallIfRespond1("thunder-change-event", event);
    }
    @EventHandler
    public void onWeatherChange(org.bukkit.event.weather.WeatherChangeEvent event) {
        jrubyEhCallIfRespond1("weather-change-event", event);
    }
    @EventHandler
    public void onChunkLoad(org.bukkit.event.world.ChunkLoadEvent event) {
        jrubyEhCallIfRespond1("chunk-load-event", event);
    }
    @EventHandler
    public void onChunkPopulate(org.bukkit.event.world.ChunkPopulateEvent event) {
        jrubyEhCallIfRespond1("chunk-populate-event", event);
    }
    @EventHandler
    public void onChunkUnload(org.bukkit.event.world.ChunkUnloadEvent event) {
        jrubyEhCallIfRespond1("chunk-unload-event", event);
    }
    @EventHandler
    public void onPortalCreate(org.bukkit.event.world.PortalCreateEvent event) {
        jrubyEhCallIfRespond1("portal-create-event", event);
    }
    @EventHandler
    public void onSpawnChange(org.bukkit.event.world.SpawnChangeEvent event) {
        jrubyEhCallIfRespond1("spawn-change-event", event);
    }
    @EventHandler
    public void onStructureGrow(org.bukkit.event.world.StructureGrowEvent event) {
        jrubyEhCallIfRespond1("structure-grow-event", event);
    }
    @EventHandler
    public void onWorldInit(org.bukkit.event.world.WorldInitEvent event) {
        jrubyEhCallIfRespond1("world-init-event", event);
    }
    @EventHandler
    public void onWorldLoad(org.bukkit.event.world.WorldLoadEvent event) {
        jrubyEhCallIfRespond1("world-load-event", event);
    }
    @EventHandler
    public void onWorldSave(org.bukkit.event.world.WorldSaveEvent event) {
        jrubyEhCallIfRespond1("world-save-event", event);
    }
    @EventHandler
    public void onWorldUnload(org.bukkit.event.world.WorldUnloadEvent event) {
        jrubyEhCallIfRespond1("world-unload-event", event);
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
