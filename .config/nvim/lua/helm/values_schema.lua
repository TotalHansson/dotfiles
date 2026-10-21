local M = {}

function M.attach(client, bufnr)
	local function update_schema()
		local path = vim.api.nvim_buf_get_name(bufnr)
		if not vim.fs.basename(path):match("^values.*%.ya?ml$") then
			return
		end

		local chart = vim.fs.find("Chart.yaml", { upward = true, path = vim.fs.dirname(path) })[1]
		if not chart then
			return
		end

		local chart_dir = vim.fs.dirname(chart)
		if vim.fs.relpath(chart_dir, path):match("^templates/") then
			return
		end

		local schema = vim.fs.joinpath(chart_dir, "values.schema.json")
		if vim.fn.filereadable(schema) ~= 1 then
			return
		end

		local settings = client.config.settings or {}
		settings.yaml = settings.yaml or {}
		settings.yaml.schemas = settings.yaml.schemas or {}
		local uri = vim.uri_from_fname(schema)
		local files = settings.yaml.schemas[uri] or {}
		local pattern = vim.uri_from_fname(path):gsub("^file://", "")
		if not vim.tbl_contains(files, pattern) then
			table.insert(files, pattern)
		end
		settings.yaml.schemas[uri] = files
		client.config.settings = settings
		client:notify("workspace/didChangeConfiguration", { settings = settings })
	end

	update_schema()
	vim.api.nvim_create_autocmd("BufWritePost", {
		buffer = bufnr,
		group = vim.api.nvim_create_augroup("helm-values-schema-" .. client.id .. "-" .. bufnr, { clear = true }),
		callback = function()
			if not client:is_stopped() then
				update_schema()
			end
		end,
	})
end

return M
