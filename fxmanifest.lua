fx_version "cerulean"
lua54 "yes"
game "gta5"

author "Xirvin#0985 and Project Sloth"
version "1.0.4"
repository "Project-Sloth/ps-housing"

ui_page "html/index.html"

shared_script {
	"@ox_lib/init.lua",
	"modules/**/shared.lua",
	"shared/config.lua",
	"shared/framework.lua",
}

client_script {
	"modules/**/client.lua",
	"client/apartment.lua",
	"client/cl_property.lua",
	"client/client.lua",
	"client/modeler.lua",
}

server_script {
	"@oxmysql/lib/MySQL.lua",
	"modules/**/server.lua",
	"server/sv_property.lua",
	"server/server.lua",
}

files {
	"html/**",
	"stream/starter_shells_k4mb1.ytyp",
}

this_is_a_map "yes"
data_file "DLC_ITYP_REQUEST" "starter_shells_k4mb1.ytyp"

dependencies {
	"fivem-freecam",
	"oxmysql",
	"ox_lib",
}