package com.github.ujihisa.Mckokoro;
import org.bukkit.entity.*;

public class JavaWrapper {
  static Arrow launchArrow(LivingEntity e) {
    return e.launchProjectile(Arrow.class);
  }

  static Egg launchEgg(LivingEntity e) {
    return e.launchProjectile(Egg.class);
  }

  static EnderPearl launchEnderPearl(LivingEntity e) {
    return e.launchProjectile(EnderPearl.class);
  }

  static Fireball launchFireball(LivingEntity e) {
    return e.launchProjectile(Fireball.class);
  }

  static Fish launchFish(LivingEntity e) {
    return e.launchProjectile(Fish.class);
  }

  static LargeFireball launchLargeFireball(LivingEntity e) {
    return e.launchProjectile(LargeFireball.class);
  }

  static SmallFireball launchSmallFireball(LivingEntity e) {
    return e.launchProjectile(SmallFireball.class);
  }

  static Snowball launchSnowball(LivingEntity e) {
    return e.launchProjectile(Snowball.class);
  }

  static ThrownExpBottle launchThrownExpBottle(LivingEntity e) {
    return e.launchProjectile(ThrownExpBottle.class);
  }

  static ThrownPotion launchThrownPotion(LivingEntity e) {
    return e.launchProjectile(ThrownPotion.class);
  }

  static WitherSkull launchWitherSkull(LivingEntity e) {
    return e.launchProjectile(WitherSkull.class);
  }
}
