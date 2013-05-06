(defproject mckokoro "1.0.0-SNAPSHOT"
  :description "a minecraft server in JRuby w/o purugin"
  :dependencies [[org.bukkit/bukkit "1.5.2-R0.1-SNAPSHOT"]
                 [org.jruby/jruby-complete "1.7.3"]]
  :dev-dependencies [[org.bukkit/bukkit "1.5.2-R0.1-SNAPSHOT"]]
  :repositories {"org.bukkit"
                 "http://repo.bukkit.org/service/local/repositories/snapshots/content/"}
  :javac-options ["-d" "classes/" "-Xlint:deprecation"]
  :java-source-paths ["javasrc"])
