local on_attach_func = function(client, bufnr)
    require'lsp_signature'.on_attach({
      bind = true,
      handler_opts = {
        border = "single"
      }
    }, bufnr)
end

local capabilities_var = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

local nvim_lsp = require'lspconfig'

-- language-specific language-servers
nvim_lsp.ansiblels.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.bashls.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.ccls.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.cssls.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.dockerls.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.elixirls.setup{
  capabilities=capabilities_var,
  cmd = { "elixir-ls" },
  on_attach=on_attach_func
}

nvim_lsp.erlangls.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.gopls.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.hls.setup{
  capabilities=capabilities_var,
  cmd = {
    "haskell-language-server",
    "lsp"
  },
  on_attach=on_attach_func
}

nvim_lsp.html.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.jsonls.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.pylsp.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.pyright.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.rnix.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.rust_analyzer.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.sqls.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.stylelint_lsp.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}


nvim_lsp.sumneko_lua.setup{
  capabilities=capabilities_var,
  cmd = {"lua-language-server"},
  on_attach=on_attach_func,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = runtime_path,
      },
      diagnostics = {
        globals = {'vim'},
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      }
    }
  }
}

nvim_lsp.terraformls.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.vimls.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.vuels.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}

nvim_lsp.yamlls.setup{
  capabilities=capabilities_var,
  on_attach=on_attach_func
}
