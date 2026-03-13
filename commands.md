Show nearby mob of a certain type.

    /effect give @e[type=iron_golem] glowing infinite 1


To figure out what a villager has in their inventory

    /data get entity @e[type=villager, limit=1, sort=nearest]
