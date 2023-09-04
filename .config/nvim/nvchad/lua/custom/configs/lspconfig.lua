-- https://nvchad.com/docs/config/lsp
-- https://github.com/neovim/nvim-lspconfig
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local nvim_lsp = require "lspconfig"

nvim_lsp.denols.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    autostart = false,
}

nvim_lsp.tsserver.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

nvim_lsp.clojure_lsp.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

nvim_lsp.pyright.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}
