-- Resource Metadata
fx_version 'cerulean'
games { 'rdr3' }


author 'Adam Greenwood <adam@adamgr.dev>'
description 'Electrum Network Notebook'
version '1.0.0'

-- What to run
client_scripts {
	"@uiprompt/uiprompt.lua",
    'client.lua'
}

server_scripts {
    'server.lua'
}

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
