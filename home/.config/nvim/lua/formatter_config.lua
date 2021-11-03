require('formatter').setup({
  filetype = {
    rust = {
      -- Rustfmt
      function()
        return {
          exe = "rustfmt",
          args = {
            "--emit=stdout"
          },
          stdin=true
        }
      end
    },
    sh = {
      -- Shell script formatter
      function()
        return {
          exe = "shfmt",
          args = {
            "-i",
            "4"
          },
          stdin = true
        }
      end
    },
    nix = {
      function()
        return {
          exe = "nixpkgs-fmt",
          args = {
            "--"
          },
          stdin = true
        }
      end
    },
    terraform = {
      function()
        return {
          exe = "terraform",
          args = {
            "fmt",
            "-"
          },
          stdin = true
        }
      end
    }
  }
})
