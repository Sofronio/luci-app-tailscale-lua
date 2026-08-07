-- Tailscale management page for Lua-based LuCI
-- (works on custom OpenWrt builds where the JS luci-app-tailscale-community
--  cannot register its menu, e.g. BleachWrt)
module("luci.controller.tailscale", package.seeall)

function index()
	entry({"admin", "vpn", "tailscale"}, template("tailscale"), _("Tailscale"), 90).index = true
	entry({"admin", "vpn", "tailscale", "status"}, call("action_status")).leaf = true
	entry({"admin", "vpn", "tailscale", "logs"}, call("action_logs")).leaf = true
	entry({"admin", "vpn", "tailscale", "ctl"}, call("action_ctl")).leaf = true
	entry({"admin", "vpn", "tailscale", "login"}, call("action_login")).leaf = true
	entry({"admin", "vpn", "tailscale", "logout"}, call("action_logout")).leaf = true
end

local function ubus_tailscale(method, args)
	local ubus = require "ubus"
	local conn = ubus.connect()
	if not conn then
		return { error = "ubus connect failed" }
	end
	local rv = conn:call("tailscale", method, args or {}) or { error = method .. " no response" }
	conn:close()
	return rv
end

-- Demo/screenshot mode: `uci set tailscale.settings.demo=1` returns fully
-- sanitized fake data (no real hostnames/IPs) so the page can be
-- screenshotted for documentation. `uci set tailscale.settings.demo=0` restores.
local function demo_enabled()
	local v = luci.sys.exec("uci -q get tailscale.settings.demo")
	return v:match("^%s*(.-)%s*$") == "1"
end

local function demo_iso(ago_sec)
	return os.date("!%Y-%m-%dT%H:%M:%S", os.time() - ago_sec) .. "Z"
end

local function demo_data()
	local now = os.time()
	local peers = {
		{
			id = "pL1nuxSrVr1", hostname = "linux-server",
			dnsname = "linux-server.example-tailnet.ts.net",
			ip = "100.64.1.20<br>fd7a:115c:a1e0::1:20", ipv4 = "100.64.1.20",
			ipv6 = "fd7a:115c:a1e0::1:20", ostype = "linux",
			online = true, active = true,
			lastseen = demo_iso(3600), lastwrite = demo_iso(5),
			lasthandshake = demo_iso(8), created = "2026-01-15T10:00:00Z",
			keyexpiry = os.date("!%Y-%m-%dT%H:%M:%SZ", now + 173 * 86400),
			relay = "", caddr = "192.168.10.5:41641",
			tx = 1234567890, rx = 340000000,
			pubkey = "nodekey:aa11bb22cc33dd44ee55ff6677889900aabbccddeeff00112233445566778899",
			allowedips = "100.64.1.20/32, fd7a:115c:a1e0::1:20/128",
			exit_node = false, exit_node_option = false,
			clientversion = "", self = false
		},
		{
			id = "pAndr0idPh0", hostname = "android-phone",
			dnsname = "android-phone.example-tailnet.ts.net",
			ip = "100.64.1.30<br>fd7a:115c:a1e0::1:30", ipv4 = "100.64.1.30",
			ipv6 = "fd7a:115c:a1e0::1:30", ostype = "android",
			online = true, active = false,
			lastseen = demo_iso(7200), lastwrite = demo_iso(180),
			lasthandshake = demo_iso(180), created = "2026-03-02T08:00:00Z",
			keyexpiry = os.date("!%Y-%m-%dT%H:%M:%SZ", now + 42 * 86400),
			relay = "hkg", caddr = "",
			tx = 1020304, rx = 4050607,
			pubkey = "nodekey:bb22cc33dd44ee55ff6677889900aabbccddeeff00112233445566778899aa",
			allowedips = "100.64.1.30/32, fd7a:115c:a1e0::1:30/128",
			exit_node = false, exit_node_option = false,
			clientversion = "", self = false
		},
		{
			id = "pMaccB00kPr", hostname = "macbook",
			dnsname = "macbook.example-tailnet.ts.net",
			ip = "100.64.1.40<br>fd7a:115c:a1e0::1:40", ipv4 = "100.64.1.40",
			ipv6 = "fd7a:115c:a1e0::1:40", ostype = "macOS",
			online = false, active = false,
			lastseen = demo_iso(2 * 86400), lastwrite = demo_iso(2 * 86400),
			lasthandshake = demo_iso(2 * 86400), created = "2025-12-01T12:00:00Z",
			keyexpiry = os.date("!%Y-%m-%dT%H:%M:%SZ", now + 9 * 86400),
			relay = "tok", caddr = "",
			tx = 8561234, rx = 91234567,
			pubkey = "nodekey:cc33dd44ee55ff6677889900aabbccddeeff00112233445566778899aabb",
			allowedips = "100.64.1.40/32, fd7a:115c:a1e0::1:40/128",
			exit_node = false, exit_node_option = true,
			clientversion = "", self = false
		}
	}
	local byid = {}
	for _, p in ipairs(peers) do byid[p.id] = p end
	return {
		status = "running",
		version = "1.80.3",
		TUNMode = true,
		health = { "healthy" },
		ipv4 = "100.64.1.10",
		ipv6 = "fd7a:115c:a1e0::1:10",
		domain_name = "example-tailnet.ts.net",
		self = {
			id = "pR0ut3rS3lf", hostname = "openwrt-router",
			dnsname = "openwrt-router.example-tailnet.ts.net",
			ip = "100.64.1.10<br>fd7a:115c:a1e0::1:10", ipv4 = "100.64.1.10",
			ipv6 = "fd7a:115c:a1e0::1:10", ostype = "linux",
			online = true, active = true,
			lastseen = "", lastwrite = demo_iso(2),
			lasthandshake = demo_iso(2), created = "2025-11-20T09:30:00Z",
			keyexpiry = os.date("!%Y-%m-%dT%H:%M:%SZ", now + 180 * 86400),
			relay = "", caddr = "",
			tx = 51234567, rx = 89012345,
			pubkey = "nodekey:dd44ee55ff6677889900aabbccddeeff00112233445566778899aabbccdd",
			allowedips = "100.64.1.10/32, fd7a:115c:a1e0::1:10/128",
			exit_node = false, exit_node_option = true,
			clientversion = "", self = true
		},
		peers = byid
	}
end

-- Build a full device record (self or peer) from `tailscale status --json`
local function build_dev(dev, is_self)
	local ips = dev.TailscaleIPs or {}
	local rec = {
		id = dev.ID or "",
		hostname = (dev.DNSName and dev.DNSName:match("^([^%.]+)")) or dev.HostName or "unknown",
		dnsname = dev.DNSName or "",
		ip = table.concat(ips, "<br>"),
		ipv4 = ips[1] or "",
		ipv6 = ips[2] or "",
		ostype = dev.OS or "",
		online = dev.Online or false,
		active = dev.Active or false,
		lastseen = dev.LastSeen or "",
		lastwrite = dev.LastWrite or "",
		lasthandshake = dev.LastHandshake or "",
		created = dev.Created or "",
		keyexpiry = dev.KeyExpiry or "",
		relay = dev.Relay or "",
		caddr = dev.CurAddr or "",
		tx = dev.TxBytes or 0,
		rx = dev.RxBytes or 0,
		pubkey = dev.PublicKey or "",
		allowedips = table.concat(dev.AllowedIPs or {}, ", "),
		exit_node = dev.ExitNode or false,
		exit_node_option = dev.ExitNodeOption or false,
		clientversion = dev.ClientVersion or "",
		self = is_self
	}
	return rec
end

function action_status()
	if demo_enabled() then
		luci.http.prepare_content("application/json")
		luci.http.write_json(demo_data())
		return
	end
	local data = ubus_tailscale("get_status")
	-- when logged out, surface the pending auth URL from the syslog so the
	-- page can show it without waiting for the user to click Login
	if data.status == "logout" then
		local logs = (ubus_tailscale("get_logs", { lines = 200 }) or {}).logs or {}
		for _, line in ipairs(logs) do
			local u = line:match("https://login%.tailscale%.com/a/[^ ]+")
			if u then data.authurl = u end -- last match = newest
		end
	end
	local raw = luci.sys.exec("tailscale status --json 2>/dev/null")
	if raw and raw ~= "" then
		local ok, j = pcall(function() return luci.jsonc.parse(raw) end)
		if ok and j and j.Self then
			data.self = build_dev(j.Self, true)
			local peers = {}
			for _, p in pairs(j.Peer or {}) do
				if type(p) == "table" and p.ID then
					peers[p.ID] = build_dev(p, false)
				end
			end
			data.peers = peers
		end
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(data)
end

function action_logs()
	local lines = tonumber(luci.http.formvalue("lines")) or 30
	if demo_enabled() then
		local demo = {}
		for i = 1, lines do
			demo[i] = string.format(
				"Aug %02d 06:00:00 daemon.err tailscaled: demo log line %03d (sanitized)",
				(i % 28) + 1, i)
		end
		luci.http.prepare_content("application/json")
		luci.http.write_json({ logs = demo })
		return
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(ubus_tailscale("get_logs", { lines = lines }))
end

function action_ctl()
	local act = luci.http.formvalue("action")
	if act == "start" or act == "stop" or act == "restart" then
		luci.sys.call("/etc/init.d/tailscale %s" % act)
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json({ done = true, action = act })
end

-- Login: with an optional auth key (headless first-run flow).
-- Without a key: `tailscale up` prints an auth URL which we return.
-- Login: with an optional auth key (headless first-run flow).
-- The interactive flow spawns `tailscale up` in the background (it prints
-- the auth URL to the tailscaled syslog, then blocks until approved).
-- We poll the syslog via the ubus `tailscale get_logs` object (the same
-- path the log box on the page uses) for a NEW auth URL line (max ~40s).
function action_login()
	local key = luci.http.formvalue("authkey") or ""
	-- clear stale attempts first, so the newest URL in syslog is ours
	luci.sys.call("pkill -f 'tailscale [u]p' 2>/dev/null")
	if key ~= "" then
		local q = key:gsub("'", "'\\''")
		luci.sys.call("tailscale up --auth-key '%s' >/dev/null 2>&1 &" % q)
		luci.http.prepare_content("application/json")
		luci.http.write_json({ url = "" })
		return
	end
	local function last_auth_url()
		local logs = (ubus_tailscale("get_logs", { lines = 200 }) or {}).logs or {}
		local url = ""
		for _, line in ipairs(logs) do
			local u = line:match("https://login%.tailscale%.com/a/[^ ]+")
			if u then url = u end
		end
		return url
	end
	local before = last_auth_url()
	luci.sys.call("tailscale up >/dev/null 2>&1 &")
	local url = ""
	for _ = 1, 80 do
		luci.sys.call("sleep 0.5")
		url = last_auth_url()
		if url ~= "" and url ~= before then break end
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json({ url = url })
end

function action_logout()
	luci.http.prepare_content("application/json")
	luci.http.write_json(ubus_tailscale("do_logout"))
end
