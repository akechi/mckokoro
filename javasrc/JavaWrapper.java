package com.github.ujihisa.Mckokoro;
import org.bukkit.entity.*;

public class JavaWrapper {
  Arrow launchArrow(LivingEntity e) {
    return e.launchProjectile(Arrow.class);
  }

  Egg launchEgg(LivingEntity e) {
    return e.launchProjectile(Egg.class);
  }

  Snowball launchSnowball(LivingEntity e) {
    return e.launchProjectile(Snowball.class);
  }
}
