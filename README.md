This is a lua script for ssrf defense in openresty.
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

[1]: "谈一谈如何在Python开发中拒绝SSRF漏洞" http://bobao.360.cn/learning/detail/3074.html

[2]: "openresty/lua-resty-dns" https://github.com/openresty/lua-resty-dns

[3]: "agentzh/lua-php-utils" https://github.com/agentzh/lua-php-utils
