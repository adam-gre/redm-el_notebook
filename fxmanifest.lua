-- Resource Metadata
fx_version 'cerulean'
games { 'rdr3' }


author 'Adam Greenwood <adam@adamgr.dev>'
description 'Electrum Network Notebook'
version '1.0.0'

-- What to run
client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/script.js',
    'html/style.css',
    -- 'html/fonts/*.ttf',
    'html/fonts/*.otf',
    'html/img/bg.jpg',
    'html/fitty.min.js',
}

dependency 'vorp_inventory'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
