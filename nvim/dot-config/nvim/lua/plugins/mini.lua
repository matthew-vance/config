return {
	{
		"echasnovski/mini.nvim",
		version = false,
		config = function()
			require("mini.ai").setup()
			require("mini.bracketed").setup()
			require("mini.comment").setup()
			require("mini.icons").setup()
			require("mini.operators").setup()
			require("mini.pairs").setup()
			require("mini.statusline").setup()
		end,
	},
}
