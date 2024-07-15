fx_version 'adamant'
game 'rdr3'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Phil'
description 'Object Carrying System'
version '1.0.0'

server_script 'server.lua'
client_scripts {
    'utils.lua',  -- Load utility functions
    'client.lua'
}

dependencies {
    'rsg-target'
}
