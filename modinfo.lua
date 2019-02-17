--The name of the mod displayed in the 'mods' screen.
name = "my Work on Beefalo"

--A description of the mod.
description = "Do work while riding a beefalo. "

--Who wrote this awesome mod?
author = "Ps-Pencil"

--A version number so you can ask people if they are running an old version of your mod.
version = "1.11"

--This lets other players know if your mod is out of date. This typically needs to be updated every time there's a new game update.
api_version = 6
api_version_dst = 10
priority = -1

--Compatible with both the base game and Reign of Giants
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
dst_compatible = true

--This lets clients know if they need to get the mod from the Steam Workshop to join the game
all_clients_require_mod = true
client_only_mod = false

--This lets people search for servers with this mod by these tags
server_filter_tags = {}

icon_atlas = ""
icon = ""

forumthread = ""


configuration_options = {
  {
    name = "Chopping",
    label = "Chopping",
    options = {
      {description = "On", data = "on"},
      {description = "Off", data = "off"},
    },
    default = "on"
  },
  {
    name = "Mining",
    label = "Mining",
    options = {
      {description = "On", data = "on"},
      {description = "Off", data = "off"},
    },
    default = "on"
  },
  {
    name = "Digging",
    label = "Digging",
    options = {
      {description = "On", data = "on"},
      {description = "Off", data = "off"},
    },
    default = "on"
  },
  {
    name = "Hammering",
    label = "Hammering",
    options = {
      {description = "On", data = "on"},
      {description = "Off", data = "off"},
    },
    default = "on"
  },
  {
    name = "Jumping",
    label = "Using wormholes",
    options = {
      {description = "On", data = "on"},
      {description = "Off", data = "off"},
    },
  default = "on",
  },
  {
    name = "Feeding",
    label = "Feeding birds",
    options = {
      {description = "On", data = "on"},
      {description = "Off", data = "off"},
    },
    default = "on",
  },
}
