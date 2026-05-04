local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local function ctx_field(field)
	return function()
		local ctx = require("go.method_stub").get_method_context()
		if not ctx then
			return (field == "receiver") and "m" or "Struct"
		end
		return ctx[field]
	end
end

return {
	s({ trig = "meth", name = "Go method (struct above)", dscr = "Method for nearest struct above cursor" }, {
		t("func ("),
		f(ctx_field("receiver"), {}),
		t(" *"),
		f(ctx_field("struct"), {}),
		t(") "),
		i(1, "MethodName"),
		t("("),
		i(2),
		t(") "),
		i(3),
		t({ " {", "\t" }),
		i(0),
		t({ "", "}" }),
	}),

	s("iferr", {
		t({ "if err != nil {", "\t" }),
		i(1, ""),
		t({ "", "}", "" }),
	}),

	s("print", {
		t('fmt.Printf("'),
		i(1, ""),
		t('\\n"'),
		i(2, ""),
		t(")"),
	}),

	s("stderr", {
		t('fmt.Fprintf(os.Stderr, "@@ '),
		i(1, ""),
		t('\\n"'),
		i(2, ""),
		t(")"),
	}),
}
