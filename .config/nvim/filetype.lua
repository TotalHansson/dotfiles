vim.filetype.add({
	pattern = {
		[".*/%.config/waybar/.+"] = function(path, bufnr)
			local name = vim.fs.basename(path)
			if name:find("%.") then
				return nil
			end
			return "jsonc"
		end,
	},
})
