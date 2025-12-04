Commands
---

To login to ssh to the server

    ssh -i ~/.ssh/trevoroci.key opc@170.9.24.127

To start or restart the server

    systemctl --user start minecraft
    systemctl --user restart minecraft

RCON

    mcrcon -H 170.9.24.127 -p smihP4h16QW1uC3S -t

Logs

    tail -f minecraft/logs/latest.log

To set player sleep rules

    /gamerule playersSleepingPercentage 0

To use the scoreboard https://minecraft.wiki/w/Scoreboard

   /scoreboard objectives ...
   /scoreboard players ...

Software install process:
---

Install the server. We're using fabric-server-mc.1.21.10-loader.0.17.3-launcher.1.1.0.jar


Install mods. We currently run these:

* c2me-fabric-mc1.21.10-0.3.5.0.0.jar
* Chunky-Fabric-1.4.51.jar
* fabric-api-0.136.0%2B1.21.10.jar
* panda-lead-break-1.0.0_1.21.9+1.21.10.jar

And for Skoice we might have these if we can get it to work:

* Cardboard-1.21.10.jar
* iCommon-Fabric-bundle.jar
* Skoice.jar

Go to https://vanillatweaks.net/picker/datapacks/ and select these datapacks from the
picker. You'll download a zip of zips. Expand those into ~/minecraft/world/datapacks 

* 'afk display v1.1.14 (MC 1.21-1.21.10).zip'
* 'anti enderman grief v1.1.14 (MC 1.21-1.21.10).zip'
* 'armor statues v2.8.20 (MC 1.21-1.21.10).zip'
* 'coordinates hud v1.2.15 (MC 1.21-1.21.10).zip'
* 'name colors v1.0.12 (MC 1.21-1.21.10).zip'
* 'nether portal coords v1.1.14 (MC 1.21-1.21.10).zip'
* 'player head drops v1.1.14 (MC 1.21-1.21.10).zip'
* players-drop-heads-1.21.9-88.0.zip
* players-drop-heads-88.0.jar
* 'silence mobs v1.2.8 (MC 1.21-1.21.10).zip'
* 'spawning spheres v1.1.14 (MC 1.21-1.21.10).zip'
* 'track raw statistics v1.7.10 (MC 1.21-1.21.10).zip'
* 'track statistics v1.1.16 (MC 1.21-1.21.10).zip'
* 'villager workstation highlights v1.1.14 (MC 1.21-1.21.10).zip'
