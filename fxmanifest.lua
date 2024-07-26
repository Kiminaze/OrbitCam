
fx_version "cerulean"
games { "gta5" }

author "Philipp Decker"
description "Allows toggling an orbit camera around a given point or entity."
version "1.1.0"

lua54 "yes"
use_experimental_fxv2_oal "yes"

client_scripts {
	"config.lua",

	"client/client.lua",

	"cameras/*.lua"
}
