local M = {}

local function lower_first_letter(name)
	return name:sub(1, 1):lower()
end

-- iter_matches returns captures as lists (even if there is only one node).
local function cap1(match, capid)
	local v = match[capid]
	if type(v) == "table" then
		return v[1]
	end
	return v
end

local function get_capids(query)
	local ids = {}
	for i, cap in ipairs(query.captures) do
		ids[cap] = i
	end
	return ids
end

local function find_struct_above_cursor(bufnr)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "go")
	if not ok or not parser then
		return nil
	end

	local tree = parser:parse()[1]
	local root = tree:root()
	local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1

	local q = vim.treesitter.query.parse(
		"go",
		[[
      (type_declaration
        (type_spec
          name: (type_identifier) @name
          type: (struct_type))) @decl
    ]]
	)
	local ids = get_capids(q)

	local best_row, best_name, best_decl = -1, nil, nil

	for _, match in q:iter_matches(root, bufnr, 0, cursor_row + 1) do
		local name_node = cap1(match, ids.name)
		local decl_node = cap1(match, ids.decl)

		if name_node and decl_node then
			local sr = select(1, decl_node:range())
			if sr <= cursor_row and sr > best_row then
				best_row = sr
				best_name = vim.treesitter.get_node_text(name_node, bufnr)
				best_decl = decl_node
			end
		end
	end

	if not best_name or not best_decl then
		return nil
	end

	local decl_end_row = select(3, best_decl:range()) -- 0-based inclusive end row
	return { name = best_name, decl_end_row = decl_end_row }
end

local function find_existing_receiver_between(bufnr, struct_name, start_row, end_row)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "go")
	if not ok or not parser then
		return nil
	end

	local tree = parser:parse()[1]
	local root = tree:root()

	local q = vim.treesitter.query.parse(
		"go",
		[[
      (method_declaration
        receiver: (parameter_list
          (parameter_declaration
            name: (identifier) @rname
            type: [
              (pointer_type (type_identifier) @rtype)
              (type_identifier) @rtype
            ]))
      ) @mdecl
    ]]
	)
	local ids = get_capids(q)

	local best_row = -1
	local best_rname = nil

	-- end_row + 1 because iter_matches end is exclusive
	for _, match in q:iter_matches(root, bufnr, start_row, end_row + 1) do
		local rname_node = cap1(match, ids.rname)
		local rtype_node = cap1(match, ids.rtype)
		local mdecl_node = cap1(match, ids.mdecl)

		if rname_node and rtype_node and mdecl_node then
			local rtype = vim.treesitter.get_node_text(rtype_node, bufnr)
			if rtype == struct_name then
				local sr = select(1, mdecl_node:range())
				if sr >= start_row and sr <= end_row and sr > best_row then
					best_row = sr
					best_rname = vim.treesitter.get_node_text(rname_node, bufnr)
				end
			end
		end
	end

	return best_rname
end

function M.get_method_context()
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.bo[bufnr].filetype ~= "go" then
		return nil
	end

	local cursor_row0 = vim.api.nvim_win_get_cursor(0)[1] - 1
	local st = find_struct_above_cursor(bufnr)
	if not st then
		return nil
	end

	local scan_start = st.decl_end_row or 0
	local recv = find_existing_receiver_between(bufnr, st.name, scan_start, cursor_row0)
	if not recv or recv == "" then
		recv = lower_first_letter(st.name)
	end

	return { struct = st.name, receiver = recv }
end

return M
