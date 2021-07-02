local on_attach_func = function(client)
    require'completion'.on_attach(client)
end

local nvim_lsp = require'lspconfig'

-- language-specific language-servers
nvim_lsp.bashls.setup{ on_attach=on_attach_func }

nvim_lsp.ccls.setup{ on_attach=on_attach_func }

nvim_lsp.dockerls.setup{ on_attach=on_attach_func }

nvim_lsp.gopls.setup{ on_attach=on_attach_func }

nvim_lsp.hls.setup{ on_attach=on_attach_func }

nvim_lsp.rnix.setup{ on_attach=on_attach_func }

nvim_lsp.rust_analyzer.setup{ on_attach=on_attach_func }

nvim_lsp.terraformls.setup{ on_attach=on_attach_func }

-- Language-agnostic language-servers
nvim_lsp.diagnosticls.setup{
  on_attach=on_attach_func,
  filetypes = {
    "javascript",
    "javascript.jsx",
    "sh"
  },
  init_options = {
    filetypes = {
      javascript = "eslint",
      ["javascript.jsx"] = "eslint",
      javascriptreact = "eslint",
      typescriptreact = "eslint",
      sh = "shellcheck",
    },
    linters = {
      eslint = {
        sourceName = "eslint",
        command = "eslint",
        rootPatterns = { ".git" },
        debounce = 100,
        args = {
          "--stdin",
          "--stdin-filename",
          "%filepath",
          "--format",
          "json"
        },
        parseJson = {
          errorsRoot = "[0].messages",
          line = "line",
          column = "column",
          endLine = "endLine",
          endColumn = "endColumn",
          message = "${message} [${ruleId}]",
          security = "severity",
        };
        securities = {
          [2] = "error",
          [1] = "warning"
        }
      },
      shellcheck = {
        sourceName = "shellcheck",
        command = "shellcheck",
        debounce = 100,
        args = { "--format=gcc", "-" },
        offsetLine = 0,
        offsetColumn = 0,
        formatLines = 1,
        formatPattern = {
          "^[^:]+:(\\d+):(\\d+)\\s+([^:]+):\\s+(.*)$",
          {
            line = 1,
            column = 2,
            message = 4,
            security = 3
          };
        },
        securities = {
          error = "error",
          warning = "warning",
          note = "info",
        };
      }
    }
  }
}
