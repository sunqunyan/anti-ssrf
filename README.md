This is a lua script for ssrf defense.
===

How to use:
---

```
local u_url = ngx.unescape_uri(ngx.var.arg_u) or ''  -- page url
local assrf = require "anti_ssrf"
if assrf:hit(u_url) then
    -- do something
    return
end
-- do something
```

References:
---

[1]: "SSRF漏洞分析，利用及其防御" http://www.voidcn.com/article/p-qofjzhuk-st.html
