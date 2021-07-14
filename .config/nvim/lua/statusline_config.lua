require('lualine').setup{
    options = {
        icons_enabled = true,
        theme = 'onedark',
    },
    sections = {
        lualine_a = {{'mode', upper = true}},
        lualine_b = {{'branch', lower = true}},
        lualine_c = {'diff', 'hostname', 'filename'},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    }
}
