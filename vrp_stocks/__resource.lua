description "vrp_stocks"
 
dependency "vrp"
 
server_script{
    "@vrp/lib/utils.lua",
    "server.lua",
    "vrp.lua"
}
 