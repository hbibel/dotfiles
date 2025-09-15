return {
  setup = function()
    local venv_dir = require("custom.python").get_venv_dir()
    local python_formatters = {}
    if venv_dir ~= nil then
      python_formatters = {
        ruff_imports = {
          command = venv_dir .. "/bin/ruff",
          args = {
            "check",
            "--select", "I",
            "--fix",
            "--stdin-filename", "$FILENAME",
            "-",
          },
        },
        black = {
          command = venv_dir .. "/bin/black",
          args = {
            "--stdin-filename", "$FILENAME",
            "--quiet",
            "-",
          }
        },
        isort = {
          command = venv_dir .. "/bin/isort",
        },
        ruff_format = {
          command = venv_dir .. "/bin/ruff",
        },
      }
    end

    local formatters = vim.tbl_extend("error",
      python_formatters,
      {
        terraform_fmt = {
          command = "tofu",
          args = { "fmt", "-no-color", "-" },
        },
      }
    )

    require("conform").setup({
      format_on_save = {
        timeout_ms = 1500,
        lsp_fallback = true,
      },
      log_level = vim.log.levels.INFO,
      formatters = formatters,
      formatters_by_ft = {
        lua = { "stylua" },
        python = venv_dir and { "ruff_imports", "ruff_format" } or {},
        -- Scalafmt standalone is SLOOOOOOOOW, so we fallback to LSP formatting
        -- scala = { "scalafmt" },
        -- Go LSP formatting is fine for now, so no explicit config here
        html = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        astro = { "prettier" },
        terraform = { "terraform_fmt" },
      },
    })
  end
}
