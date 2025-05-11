fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'bencham1n'
description 'Interakcia s NPC s dialogmi'
version '1.0.0'

client_scripts {
    'client.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}
