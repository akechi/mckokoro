(defproject mckokoro "1.0.0-SNAPSHOT"
  :description "a minecraft server in JRuby w/o purugin"
  :dependencies [[org.bukkit/bukkit "1.6.4-R0.1-SNAPSHOT"]
                 [org.jruby/jruby-complete "1.7.5"]]
  :license {:name "GNU GPL v3+"
            :url "http://www.gnu.org/licenses/gpl-3.0.en.html"}
  :repositories {"org.bukkit"
                 "http://repo.bukkit.org/service/local/repositories/snapshots/content/"}
  :javac-options ["-d" "classes/" "-Xlint:deprecation"]
  :java-source-paths ["javasrc"])
