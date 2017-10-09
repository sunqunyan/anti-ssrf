local _M = {}

    local resolver = require "resty.dns.resolver"
    local net_url = require "net.url"

    function _M:hit(url)
        -- parse url
        local u = net_url.parse(url)
        local host = u.host
        
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

    function _M:is_ip(ip)
        local match = string.match(ip, "^[%d%.]+$") 
        if not match then
            return false
        end
        return true 
    end

    function _M:is_inet(ip)
        local match = string.match(ip, "^([%d]+)%.[%d]+%.[%d]+%.[%d]+") 
        if match == "127" then
            return true
        end
        if match == "192" then
            return true
        end
        if match == "10" then
            return true
        end
        return false
    end

    function _M:resolve(url)

        local r, err = resolver:new{
            nameservers = {"114.114.114.114", "8.8.8.8"},
            retrans = 2,  -- 2 retransmissions on receive timeout
            timeout = 50,  -- 50 milli sec
        }

        if not r then
            ngx.say("failed to instantiate the resolver: ", err)
        end
        
        local answers, err = r:query(url)
        if not answers then
            ngx.say("failed to query the DNS server: ", err)
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
