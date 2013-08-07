package com.github.ujihisa.Mckokoro;
import org.bukkit.entity.*;

public class JavaWrapper {
  static Arrow launchArrow(LivingEntity e) {
    return e.launchProjectile(Arrow.class);
  }

  static Egg launchEgg(LivingEntity e) {
    return e.launchProjectile(Egg.class);
  }

  static Snowball launchSnowball(LivingEntity e) {
    return e.launchProjectile(Snowball.class);
  }
}
