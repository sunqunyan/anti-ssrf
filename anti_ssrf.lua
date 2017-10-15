local _M = {}

    local resolver = require "resty.dns.resolver"
    local net_url = require "net.url"
    local php_utils = require 'lua_php_utils'

    function _M:hit(url)
        -- parse url
        local u = net_url.parse(url)
        local host = u.host
        local scheme = u.scheme

        if not self:is_http(scheme) then
            return true 
        end

        if not host then
            return false
        end

        local match = self:is_ip(host)
        local ip = ""
        if match then
            ip = host
        else
            -- resolve
            ip = self:resolve(host)
            if not ip then
                return false
            end
        end
       
        -- judge if ip is internal
        if self:is_inet(ip) then
            return true
		end
        return false
    end

    function _M:is_http(scheme)
        if scheme == "http" or scheme == "https" then
            return true
        end
        return false
    end

    function _M:is_ip(ip)
        local match = string.match(ip, "^[%d%.]+$") 
        if not match then
            return false
        end
        return true 
    end

    function _M:is_inet(ip)
        local ipval = php_utils.ip2long(ip)
		local ip_range = {
			["10.0.0.0"] = "10.255.255.255",
			["172.16.0.0"] = "172.31.255.255",
			["192.168.0.0"] = "192.168.255.255"
		}
        local k, v
        for k, v in pairs(ip_range) do 
            local ip_start = php_utils.ip2long(k)
            local ip_end = php_utils.ip2long(v)
            if ipval >= ip_start and ipval <= ip_end then
                return true
            end
        end
        return false
    end

    function _M:resolve(url)

        local r, err = resolver:new{
            nameservers = {"114.114.114.114"},
            -- nameservers = {"114.114.114.114", "8.8.8.8"},
            retrans = 1,  -- 1 retransmissions on receive timeout
            timeout = 80,
        }

        if not r then
            -- failed to instantiate the resolver
            return false
        end
       
        local answers, err = r:query(url)

        if not answers then
            -- failed to query the DNS server
            return false
        end

        local address = false
        for i, ans in ipairs(answers) do
            if ans.address then
                address = ans.address
                break
            end
        end
        return address
    end

return _M
