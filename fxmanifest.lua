fx_version 'cerulean'
game 'gta5'

name 'sxHelpMenu_example'
description 'Examples of menus made with sxHelpMenu: a vehicle widget with live values and a guide'
author '0xS4cha'
version '1.1.0'
repository 'https://github.com/0xS4cha/sxHelpMenu_example'

lua54 'yes'

dependency 'sxHelpMenu'

shared_script 'shared/config.lua'

client_scripts {
    '@sxHelpMenu/lib/menu.lua',
    'client/cl_utils.lua',
    'client/cl_vehicle.lua',
    'client/cl_guide.lua',
}

files {
    'images/*.svg',
}
