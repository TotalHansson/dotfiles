
local opts = {
	scrolloff=8,
	relativenumber=true,
	number=true,
	wrap=true,
}

for k, v in pairs(opts) do
	vim.opt[k] = v
end

