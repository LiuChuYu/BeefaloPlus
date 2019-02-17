--The name of the mod displayed in the 'mods' screen.
name = "BeefaloPlus"

--A description of the mod.
description = "More action on beefalo."

--Who wrote this awesome mod?
author = "Disz"

--A version number so you can ask people if they are running an old version of your mod.
version = "201902172251"

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

icon_atlas = "modicon.xml"
icon = "modicon.tex"

forumthread = ""


configuration_options = {
  {
    name = "Pick",
    label = "Pick",
    options = {
      {description = "On", data = "on"},
      {description = "Off", data = "off"},
    },
    default = "on"
  },
  {
    name = "Feeding",
    label = "Feeding",
    options = {
      {description = "On", data = "on"},
      {description = "Off", data = "off"},
    },
    default = "on"
  },
  {
    name = "Jumping",
    label = "Jumping",
    options = {
      {description = "On", data = "on"},
      {description = "Off", data = "off"},
    },
    default = "on"
  },
  {
    name = "Teleport",
    label = "Teleport",
    options = {
      {description = "On", data = "on"},
      {description = "Off", data = "off"},
    },
    default = "on"
  },
  {
    name = "Store",
    label = "Store",
    options = {
      {description = "On", data = "on"},
      {description = "Off", data = "off"},
    },
    default = "on"
  },
}
