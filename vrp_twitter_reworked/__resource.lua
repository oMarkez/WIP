resource_manifest '44febabe-d386-4d18-afbe-5e627f4af937'

ui_page "nui/ui.html"
dependency 'vrp'
files {
	"nui/ui.html",
	"nui/ui.js",
	"nui/ui.css",
	"nui/assets/css/materialize.min.css",
	"nui/assets/img/twitter.png",
	"nui/assets/js/jquery.js",
	"nui/assets/js/materialize.js",
}

client_script {
	"lib/Proxy.lua",
	"lib/Tunnel.lua",
  	"client.lua"
}

server_script {
  "@vrp/lib/utils.lua",
  "server.lua"
}
