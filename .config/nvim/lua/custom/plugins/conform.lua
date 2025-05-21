return {
  setup = function()
    local isort_cmd
    if require("custom.python").venv_in_project() then
      isort_cmd = ".venv/bin/isort"
    else
      isort_cmd = "isort"
    end

    local ruff_cmd
    if require("custom.python").venv_in_project() then
      ruff_cmd = ".venv/bin/ruff"
    else
      ruff_cmd = "ruff"
    end

    require("conform").setup({
      format_on_save = {
        timeout_ms = 1500,
        lsp_fallback = true,
      },
      log_level = vim.log.levels.DEBUG,
      formatters = {
        isort = {
          command = isort_cmd,
        },
        ruff_format = {
          command = ruff_cmd,
        },
        terraform_fmt = {
          command = "tofu",
          args = { "fmt", "-no-color", "-" },
        },
      },
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "ruff_format" },
        -- Scalafmt standalone is SLOOOOOOOOW, so we fallback to LSP formatting
        -- scala = { "scalafmt" },
        -- Go LSP formatting is fine for now, so no explicit config here
        html = { { "djlint", "prettier" } },
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
