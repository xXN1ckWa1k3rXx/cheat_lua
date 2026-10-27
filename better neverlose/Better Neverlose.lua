--[[
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
]]

--[[ 
	Better Neverlose Recode v5.4
	author: xXYu3_zH3nGL1ngXx
	Updated date: 8/23/2026 from 6/11/2026

	The update of Better Neverlose mainly about script developer and reworked
	previous features. Concise and modular approach will help script developers 
	better understand how Better Neverlose features works. The recoded script 
	will fully utilize LuAJIT's performance to avoid wasting resources, thus 
	improving performance and reducing CG.

	This is final recoded version, and based to maintenance and updates.
	No another recode, every recode meaning those users config need to re-create


	Thrid-party libraries are integrated in Code:
	Clipboard by Salvatore - https://neverlose.cc/market/item?id=VYmTC6
	http_lib by DarkLuny - https://neverlose.cc/market/item?id=8wPcks
	Base64 by Salvatore - https://neverlose.cc/market/item?id=PjUYKJ
	Gradient Text by Brotgeschmack - https://neverlose.cc/market/item?id=oaTQg7 (May be subject to copyright warnings)

	Change log:
	- Fully recode (I don't remember how many times I coded it.)
	- Removed 'nick' tables, using modular design
	- Reworked Debug mode indicators
	- Reworked Debug mode watermark
	- Reworked GS indicators
	- Reworked crosshair indicators
	- Reworked Slow down indicator
	- Reworked Condition Antiaim
	- Reworked HDR Bloom
	- Renamed Condition Antiaim to Premium Antiaim
	- Added elements for debug indicators - Threat Target, Desync delta, Exploit charge, LC Break
	- Added elements for crosshair indicators - Script Name(Supported custom), Player Condition, Maxium Desync, DT&HS, FL History, LC Break(Defensive)
	- Added elements for GS indicators - FL history, Manual Yaw, Slow down, LC Break
	- Added Adaptive mode in defensive snap pitch/yaw
	- Added Recovery Guard in defensive snap for stop early
	- Added events to events sound - "Bomb planted/defused", "Exploits charged"
	- Added Solus UI, (Watermark, Keybinds, Spectators and Slow down Available)
	- Added GS Spectators
	- Added drag support for Solus UI
	- Added fired logs for log events
	- Added Hide shots on crouch to Premium Antiaim
	- Added auto teleport for two modes - Legacy and Fake duck
	- Added Anti Taser/Knife*
	- Added Adaptive Hit Chance for Scout
	- Added Predict Teleport 3D Box
	- Added Predict shot (_DEBUG)**
	- Improved log events
	- Improved defensive snap in normal mode
	- Improved script performance, reduce 30% loading time
	- Improved slient shots to supported double tap
	- Improved Materials Modifier
	- Improved items layout to make menu more clear
	- Fixed Premium antiaim stopped other script to overriding orginal antiaim items
	- Fixed HDR Bloom not reset to normal
	- Removed Disabled buybot when low money
	- Removed some shitty AI code

	*not test it yet
	**Maybe not work or break normally gameplay
]]


local __DISABLED_VISUALS = false -- disable visuals to find the performance issues
	
local version_ = "5.4"

local ffi = require 'ffi'
local clipboard = ( function () local char_array = ffi.typeof 'char[?]' local native_GetClipboardTextCount = utils.get_vfunc('vgui2.dll', 'VGUI_System010', 7, 'int(__thiscall*)(void*)') local native_SetClipboardText = utils.get_vfunc('vgui2.dll', 'VGUI_System010', 9, 'void(__thiscall*)(void*, const char*, int)') local native_GetClipboardText = utils.get_vfunc('vgui2.dll', 'VGUI_System010', 11, 'int(__thiscall*)(void*, int, const char*, int)') local function get() local len = native_GetClipboardTextCount() if len > 0 then local char_arr = char_array(len) native_GetClipboardText(0, char_arr, len) return ffi.string(char_arr, len - 1) end end local function set(...) local text = tostring(table.concat({ ... })) native_SetClipboardText(text, string.len(text)) end return { set = set, get = get } end )()
local http_lib = ( function () local steam_http_raw = ffi.cast("uint32_t**", ffi.cast("char**", ffi.cast("char*", utils.opcode_scan("client.dll", "B9 ? ? ? ? E8 ? ? ? ? 83 3D ? ? ? ? ? 0F 84")) + 1)[0] + 48)[0] or error("steam_http error") local steam_http_ptr = ffi.cast("void***", steam_http_raw) or error("steam_http_ptr error") local steam_http = steam_http_ptr[0] or error("steam_http_ptr was null") local function __thiscall(func, this) return function (...) return func(this, ...) end end local createHTTPRequest_native = __thiscall(ffi.cast(ffi.typeof("uint32_t(__thiscall*)(void*, uint32_t, const char*)"), steam_http[0]), steam_http_raw) local sendHTTPRequest_native = __thiscall(ffi.cast(ffi.typeof("bool(__thiscall*)(void*, uint32_t, uint64_t)"), steam_http[5]), steam_http_raw) local getHTTPResponseHeaderSize_native = __thiscall(ffi.cast(ffi.typeof("bool(__thiscall*)(void*, uint32_t, const char*, uint32_t*)"), steam_http[9]), steam_http_raw) local getHTTPResponseHeaderValue_native = __thiscall(ffi.cast(ffi.typeof("bool(__thiscall*)(void*, uint32_t, const char*, char*, uint32_t)"), steam_http[10]), steam_http_raw) local getHTTPResponseBodySize_native = __thiscall(ffi.cast(ffi.typeof("bool(__thiscall*)(void*, uint32_t, uint32_t*)"), steam_http[11]), steam_http_raw) local getHTTPBodyData_native = __thiscall(ffi.cast(ffi.typeof("bool(__thiscall*)(void*, uint32_t, char*, uint32_t)"), steam_http[12]), steam_http_raw) local setHTTPHeaderValue_native = __thiscall(ffi.cast(ffi.typeof("bool(__thiscall*)(void*, uint32_t, const char*, const char*)"), steam_http[3]), steam_http_raw) local setHTTPRequestParam_native = __thiscall(ffi.cast(ffi.typeof("bool(__thiscall*)(void*, uint32_t, const char*, const char*)"), steam_http[4]), steam_http_raw) local setHTTPUserAgent_native = __thiscall(ffi.cast(ffi.typeof("bool(__thiscall*)(void*, uint32_t, const char*)"), steam_http[21]), steam_http_raw) local setHTTPRequestRaw_native = __thiscall(ffi.cast("bool(__thiscall*)(void*, uint32_t, const char*, const char*, uint32_t)", steam_http[16]), steam_http_raw) local releaseHTTPRequest_native = __thiscall(ffi.cast(ffi.typeof("bool(__thiscall*)(void*, uint32_t)"), steam_http[14]), steam_http_raw) local requests = {} events.render:set( function () for _, instance in ipairs(requests) do if globals.curtime - instance.ls > instance.task_interval then instance:_process_tasks() instance.ls = globals.curtime end end end ) local request = {} local request_mt = {__index = request} function request.new(requestHandle, requestAddress, callbackFunction) return setmetatable({handle = requestHandle, url = requestAddress, callback = callbackFunction, ticks = 0}, request_mt) end local data = {} local data_mt = {__index = data} function data.new(state, body, headers) return setmetatable({status = state, body = body, headers = headers}, data_mt) end function data:success() return self.status == 200 end local http = {state = {ok = 200, no_response = 204, timed_out = 408, unknown = 0}} local http_mt = {__index = http} function http.new(task) task = task or {} local instance = setmetatable({requests = {}, task_interval = task.task_interval or 0.3, enable_debug = task.debug or false, timeout = task.timeout or 10, ls = globals.curtime}, http_mt) table.insert(requests, instance) return instance end local method_t = {['get'] = 1, ['head'] = 2, ['post'] = 3, ['put'] = 4, ['delete'] = 5, ['options'] = 6, ['patch'] = 7} function http:request(method, url, options, callback) if type(options) == "function" and callback == nil then callback = options options = {} end options = options or {} local method_num = method_t[tostring(method):lower()] local reqHandle = createHTTPRequest_native(method_num, url) local content_type = "application/text" if type(options.headers) == "table" then for name, value in pairs(options.headers) do name = tostring(name) value = tostring(value) if name:lower() == "content-type" then content_type = value end setHTTPHeaderValue_native(reqHandle, name, value) end end if type(options.body) == "string" then local len = options.body:len() setHTTPRequestRaw_native(reqHandle, content_type, ffi.cast("unsigned char*", options.body), len) end if type(options.params) == "table" then for k, v in pairs(options.params) do setHTTPRequestParam_native(reqHandle, k, v) end end if type(options.user_agent_info) == "string" then setHTTPUserAgent_native(reqHandle, options.user_agent_info) end if not sendHTTPRequest_native(reqHandle, 0) then return end local reqInstance = request.new(reqHandle, url, callback) self:_debug("[HTTP] New %s request to: %s", method:upper(), url) table.insert(self.requests, reqInstance) end function http:get(url, callback) local reqHandle = createHTTPRequest_native(1, url) if not sendHTTPRequest_native(reqHandle, 0) then return end local reqInstance = request.new(reqHandle, url, callback) self:_debug("[HTTP] New GET request to: %s", url) table.insert(self.requests, reqInstance) end function http:post(url, params, callback) local reqHandle = createHTTPRequest_native(3, url) for k, v in pairs(params) do setHTTPRequestParam_native(reqHandle, k, v) end if not sendHTTPRequest_native(reqHandle, 0) then return end local reqInstance = request.new(reqHandle, url, callback) self:_debug("[HTTP] New POST request to: %s", url) table.insert(self.requests, reqInstance) end function http:_process_tasks() for k, v in ipairs(self.requests) do local data_ptr = ffi.new("uint32_t[1]") self:_debug("[HTTP] Processing request #%s", k) if getHTTPResponseBodySize_native(v.handle, data_ptr) then local reqData = data_ptr[0] if reqData > 0 then local strBuffer = ffi.new("char[?]", reqData) if getHTTPBodyData_native(v.handle, strBuffer, reqData) then self:_debug("[HTTP] Request #%s finished. Invoking callback.", k) v.callback(data.new(http.state.ok, ffi.string(strBuffer, reqData), setmetatable({}, {__index = function (tbl, val) return http._get_header(v, val) end }))) table.remove(self.requests, k) releaseHTTPRequest_native(v.handle) end else v.callback(data.new(http.state.no_response, nil, {})) table.remove(self.requests, k) releaseHTTPRequest_native(v.handle) end end local timeoutCheck = v.ticks + 1; if timeoutCheck >= self.timeout then v.callback(data.new(http.state.timed_out, nil, {})) table.remove(self.requests, k) releaseHTTPRequest_native(v.handle) else v.ticks = timeoutCheck end end end function http:_debug(...) if self.enable_debug then print(string.format(...)) print_dev(string.format(...)) end end function http._get_header(reqInstance, query) local data_ptr = ffi.new("uint32_t[1]") if getHTTPResponseHeaderSize_native(reqInstance.handle, query, data_ptr) then local reqData = data_ptr[0] local strBuffer = ffi.new("char[?]", reqData) if getHTTPResponseHeaderValue_native(reqInstance.handle, query, strBuffer, reqData) then return ffi.string(strBuffer, reqData) end end return nil end function http._bind(class, funcName) return function (...) return class[funcName](class, ...) end end return http end )()
local base64 = (function() local shl, shr, band = bit.lshift, bit.rshift, bit.band local char, byte, gsub, sub, format, concat, tostring, error, pairs = string.char, string.byte, string.gsub, string.sub, string.format, table.concat, tostring, error, pairs local extract = function(v, from, width) return band(shr(v, from), shl(1, width) - 1) end local function makeencoder(alphabet) local encoder, decoder = {}, {} for i=1, 65 do local chr = byte(sub(alphabet, i, i)) or 32 if decoder[chr] ~= nil then error('invalid alphabet: duplicate character ' .. tostring(chr), 3) end encoder[i-1] = chr decoder[chr] = i-1 end return encoder, decoder end local encoders, decoders = {}, {} encoders['base64'], decoders['base64'] = makeencoder('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=') encoders['base64url'], decoders['base64url'] = makeencoder('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_') local alphabet_mt = { __index = function(tbl, key) if type(key) == 'string' and key:len() == 64 or key:len() == 65 then encoders[key], decoders[key] = makeencoder(key) return tbl[key] end end } setmetatable(encoders, alphabet_mt) setmetatable(decoders, alphabet_mt) local function encode(str, encoder) encoder = encoders[encoder or 'base64'] or error('invalid alphabet specified', 2) str = tostring(str) local t, k, n = {}, 1, #str local lastn = n % 3 local cache = {} for i = 1, n-lastn, 3 do local a, b, c = byte(str, i, i+2) local v = a*0x10000 + b*0x100 + c local s = cache[v] if not s then s = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[extract(v,0,6)]) cache[v] = s end t[k] = s k = k + 1 end if lastn == 2 then local a, b = byte(str, n-1, n) local v = a*0x10000 + b*0x100 t[k] = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[64]) elseif lastn == 1 then local v = byte(str, n)*0x10000 t[k] = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[64], encoder[64]) end return concat(t) end local function decode(b64, decoder) decoder = decoders[decoder or 'base64'] or error('invalid alphabet specified', 2) local pattern = '[^%w%+%/%=]' if decoder then local s62, s63 for charcode, b64code in pairs(decoder) do if b64code == 62 then s62 = charcode elseif b64code == 63 then s63 = charcode end end pattern = format('[^%%w%%%s%%%s%%=]', char(s62), char(s63)) end b64 = gsub(tostring(b64), pattern, '') local cache = {} local t, k = {}, 1 local n = #b64 local padding = sub(b64, -2) == '==' and 2 or sub(b64, -1) == '=' and 1 or 0 for i = 1, padding > 0 and n-4 or n, 4 do local a, b, c, d = byte(b64, i, i+3) local v0 = a*0x1000000 + b*0x10000 + c*0x100 + d local s = cache[v0] if not s then local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 + decoder[d] s = char(extract(v,16,8), extract(v,8,8), extract(v,0,8)) cache[v0] = s end t[k] = s k = k + 1 end if padding == 1 then local a, b, c = byte(b64, n-3, n-1) local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 t[k] = char(extract(v,16,8), extract(v,8,8)) elseif padding == 2 then local a, b = byte(b64, n-3, n-2) local v = decoder[a]*0x40000 + decoder[b]*0x1000 t[k] = char(extract(v,16,8)) end return concat(t) end return { encode = encode, decode = decode } end)()
local gradient = (function() local v0 = "[%z\001-\127\194-\244][\128-\191]*"; local function v3(v1, v2) if v1 < 0 then v1 = v2 + v1 + 1; end; return v1; end; local v12 = { map = function(v4, v5, v6) local v7 = 0; if v6 then for v8, v9 in v4:gmatch("()" .. v0 .. "()") do v7 = v7 + 1; v5(v7, v9 - v8, v8); end; else for v10, v11 in v4:gmatch("()(" .. v0 .. ")") do v7 = v7 + 1; v5(v7, v11, v10); end; end; end }; v12.chars = function(v13, v14) return coroutine.wrap(function() return v12.map(v13, coroutine.yield, v14); end); end; v12.len = function(v15) return select(2, v15:gsub("[^\128-\193]", "")); end; v12.replace = function(v16, v17) return v16:gsub(v0, v17); end; v12.reverse = function(v18) return v18:gsub(v0, function(v19) return #v19 > 1 and v19:reverse(); end):reverse(); end; v12.strip = function(v20) return v20:gsub(v0, function(v21) return #v21 > 1 and ""; end); end; v12.sub = function(v22, v23, v24) local v25 = v12.len(v22); v23 = v3(v23, v25); v24 = v24 and v3(v24, v25) or v25; if v23 < 1 then v23 = 1; end; if v25 < v24 then v24 = v25; end; if v24 < v23 then return ""; else local v26 = v24 - v23; local v27 = v12.chars(v22, true); for _ = 1, v23 - 1 do v27(); end; local v29, v30 = select(2, v27()); if v26 == 0 then return string.sub(v22, v30, v30 + v29 - 1); else v23 = v30; for _ = 1, v26 - 1 do v27(); end; local v32, v33 = select(2, v27()); return string.sub(v22, v23, v33 + v32 - 1); end; end; end; local function v39(v34) if #v34 < 2 then error("2 or more colors required!"); end; if v34[1][2] ~= 0 then error("First color must start at position 0!"); end; if v34[#v34][2] ~= 1 then error("Last color must end at position 1!"); end; local v35 = 0; for _, v37 in ipairs(v34) do local v38 = v37[2]; if not v38 then error("Color doesn't have a stop property!"); end; if v38 < 0 or v38 > 1 then error("Color stop is out of boundaries!"); end; if v35 <= v38 then v35 = v38; else error("Color stops are out of order!"); end; end; return v34; end; local function v43(v40, v41, v42) v41 = (v41 + v42 - 1) % #v40 + 1; return v40[v41], v41; end; local function v46(v44, v45) return (color((v44.r / 255) ^ (1 / v45) * 255, (v44.g / 255) ^ (1 / v45) * 255, (v44.b / 255) ^ (1 / v45) * 255)); end; local function v53(v47, v48) local v49 = #v47; local v50 = v48 / (1 / (v49 - 1)); local v51 = 1 + math.floor(v50); if v50 == v49 - 1 then return v47[v49]; else local v52 = v50 % 1; return v47[v51]:lerp(v47[v51 + 1], v52); end; end; local v54 = {}; local v55 = {}; v55.__index = v55; local v56 = {}; v56.__index = v56; v55.linear = function(v57, v58) if type(v57[1]) ~= "table" then return v53(v57, v58); else local v59 = v39(v57); local v60 = 1; while v59[v60 + 1][2] < v58 do v60 = v60 + 1; end; local v61 = (v58 - v59[v60][2]) / (v59[v60 + 1][2] - v59[v60][2]); return v59[v60][1]:lerp(v59[v60 + 1][1], v61); end; end; v55.text = function(v62, v63, v64) local v65 = ""; local v66 = v12.len(v62) - 1; for v67, _, _ in v12.chars(v62) do local v70 = v55.linear(v64, (v67 - 1) / v66):to_hex(); if v63 then v70 = v70:sub(1, 6); end; v65 = string.format("%s\a%s%s", v65, v70, v12.sub(v62, v67, v67)); end; return v65; end; v55.text_animate = function(v71, v72, v73) local v74 = v71 .. v72; for _, v76 in ipairs(v73) do v74 = v74 .. tostring(v76); end; local v77 = v54[v74]; if not v77 then v77 = setmetatable({}, v56); v77.text = v71; v77.animated_text = ""; v77.speed = 1 / v72; v77.current_pos = 0; v77.colors = v73; v77.colors[#v77.colors + 1] = v77.colors[1]; v77:populate_gradient(); end; v54[v74] = v77; return v77; end; v56.populate_gradient = function(v78) local v79 = v78:get_colors(); local v80 = v78:get_text(); local v81 = {}; local v82 = v12.len(v80); local v83 = #v79; local v84 = v80 .. string.rep("|", math.floor(v82 / (v83 - 2) + 0.5)); local v85 = v12.len(v84); for v86, _, _ in v12.chars(v84) do local v89 = v55.linear(v79, (v86 - 1) / (v85 - 1)); v81[#v81 + 1] = v89:to_hex(); end; v78.gradients = v81; v78:populate_text(); end; v56.populate_text = function(v90) local l_text_0 = v90.text; v90.animated_text = ""; for v92, _, _ in v12.chars(l_text_0) do v90.animated_text = string.format("%s\a%s%s", v90.animated_text, v43(v90.gradients, v92, 0), v12.sub(l_text_0, v92, v92)); end; end; v56.animate = function(v95) if math.abs(v95.current_pos) >= 1 then v95.current_pos = v95.speed * globals.frametime; end; v95.animated_text = ""; v95.current_pos = v95.current_pos + v95.speed * globals.frametime; local l_text_1 = v95.text; local v97 = math.floor(v95.current_pos * #v95.gradients); for v98, _, _ in v12.chars(l_text_1) do v95.animated_text = string.format("%s\a%s%s", v95.animated_text, v43(v95.gradients, v98, v97), v12.sub(l_text_1, v98, v98)); end; end; v56.get_colors = function(v101) return v101.colors; end; v56.set_colors = function(v102, v103) local v104 = false; for v105, v106 in ipairs(v103) do if v102.colors[v105] ~= v106 then v104 = true; end; end; if v104 then v102.colors = v103; v102.colors[#v102.colors + 1] = v102.colors[1]; v102:populate_gradient(); end; end; v56.get_speed = function(v107) return 1 / v107.speed; end; v56.set_speed = function(v108, v109) v108.speed = 1 / v109; end; v56.get_current_position = function(v110) return v110.current_pos; end; v56.set_current_position = function(v111, v112) v111.current_pos = math.clamp(v112, -1, 1); v111.animated_text = ""; local l_text_2 = v111.text; local v114 = math.floor(v111.current_pos * #v111.gradients); for v115, _, _ in v12.chars(l_text_2) do v111.animated_text = string.format("%s\a%s%s", v111.animated_text, v43(v111.gradients, v115, v114), v12.sub(l_text_2, v115, v115)); end; end; v56.get_text = function(v118) return v118.text; end; v56.set_text = function(v119, v120) if v119.text ~= v120 then v119.text = v120; v119:populate_gradient(); end; end; v56.get_animated_text = function(v121) return v121.animated_text; end; v56.gamma_correct = function(v122, v123) for v124, v125 in ipairs(v122.gradients) do v122.gradients[v124] = v46(color(v125), v123):to_hex(); end; end; return v55; end)()

-- Neverlose doesn't like GS..
local print_pro = function(...)
	print(...)
	print_dev(...)
end

math.lerp = function(current, target, speed)
	return current + (target - current) * speed
end

---------------------- localplayer ---------------------
local localplayer_ = {
	ent = nil,
	packets = 0,
	choking = 1,

	ent_refresh = function(self)
		local this = self

		events.render:set(function()
			this.ent = entity.get_local_player()
		end)
	end,
}

localplayer_:ent_refresh()
---------------------------------------------------------

------------------------ ffi cdef -----------------------

ffi.cdef[[
	typedef struct {
		unsigned long pid;
		unsigned long tid;
		unsigned long exit_code;
		unsigned long reserved;
	} PROCESS_INFORMATION;

	typedef struct {
		unsigned long length;
		void* reserved1;
		void* desktop;
		void* title;
		unsigned long x;
		unsigned long y;
		unsigned long x_size;
		unsigned long y_size;
		unsigned long x_count_chars;
		unsigned long y_count_chars;
		unsigned long fill_attribute;
		unsigned long flags;
		unsigned short show_window;
		unsigned short reserved2;
		void* reserved3;
		void* std_input;
		void* std_output;
		void* std_error;
	} STARTUPINFOA;

	bool CreateProcessA(
		const char* lpApplicationName,
		char* lpCommandLine,
		void* lpProcessAttributes,
		void* lpThreadAttributes,
		bool bInheritHandles,
		unsigned long dwCreationFlags,
		void* lpEnvironment,
		const char* lpCurrentDirectory,
		STARTUPINFOA* lpStartupInfo,
		PROCESS_INFORMATION* lpProcessInformation
	);

	bool PlaySound(
		const char* pszSound,
		void* hmod,
		unsigned int fdwSound
	);

	typedef void* HANDLE;
	typedef HANDLE HWND;
	typedef const char* LPCSTR;
	typedef int BOOL;
	typedef unsigned int UINT;
	typedef long LONG;
	typedef LONG LPARAM;
	typedef LONG LRESULT;
	typedef UINT WPARAM;

	HWND FindWindowA(LPCSTR lpClassName, LPCSTR lpWindowName);
	BOOL SetWindowTextA(HWND hWnd, LPCSTR lpString);

	void* __stdcall URLDownloadToFileA(void* LPUNKNOWN, const char* LPCSTR, const char* LPCSTR2, int a, int LPBINDSTATUSCALLBACK); 
	bool DeleteUrlCacheEntryA(const char* lpszUrlName);

	typedef struct {
		char pad[3];
		char m_bForceWeaponUpdate;
		char pad1[91];
		void* m_pBaseEntity;
		void* m_pActiveWeapon;
		void* m_pLastActiveWeapon;
		float m_flLastClientSideAnimationUpdateTime;
		int m_iLastClientSideAnimationUpdateFramecount;
		float m_flAnimUpdateDelta;
		float m_flEyeYaw;
		float m_flPitch;
		float m_flGoalFeetYaw;
		float m_flCurrentFeetYaw;
		float m_flCurrentTorsoYaw;
		float m_flUnknownVelocityLean;
		float m_flLeanAmount;
	} AnimStateVtable;
]]

---------------------------------------------------------

-- @region Share pool
local __share_pool = {
	slow_walk = false,
	defensive_ticks = 0,
	anti_lethal_ax = false,
}

local teleport_prediction
events.createmove:set(function(cmd)
	if teleport_prediction then teleport_prediction.begin_command(cmd) end
end)

local defensive_state = {
	window = 0,
	generation = 0,
}

local reset_defensive_ticks = function()
	defensive_state.max_tickbase = nil
	defensive_state.userid = nil
	defensive_state.command = nil
	defensive_state.generation = defensive_state.generation + 1
	__share_pool.defensive_ticks = 0
end

-- The code from Salvatore who working in Neverlose
-- Orginal github repository: https://github.com/tickcount/lagrecord-csgo.lua
local get_defensive_ticks = function(cmd)
	local me = entity.get_local_player()
	localplayer_.ent = me
	if not globals.is_in_game or not me or not me:is_alive() then reset_defensive_ticks() return end
	local info = me:get_player_info()
	local userid = info and info.userid or me:get_index()
	local tickbase = me.m_nTickBase
	local command = cmd.command_number
	if defensive_state.userid ~= userid or not defensive_state.max_tickbase
		or math.abs(tickbase - defensive_state.max_tickbase) > 64
		or (defensive_state.command and command < defensive_state.command) then
		reset_defensive_ticks()
		defensive_state.userid = userid
		defensive_state.max_tickbase = tickbase
	end
	if defensive_state.command == command then return end
	defensive_state.command = command
	local previous = __share_pool.defensive_ticks
	defensive_state.max_tickbase = math.max(defensive_state.max_tickbase, tickbase)

	-- defensive effect can be achieved because the lag compensation is made so that
	-- it doesn't write records if the current simulation time is less than/equals highest acknowledged simulation time
	-- https://gitlab.com/KittenPopo/csgo-2018-source/-/blame/main/game/server/player_lagcompensation.cpp#L723
	__share_pool.defensive_ticks = math.min(14, math.max(0, defensive_state.max_tickbase - tickbase - 1))
	if previous == 0 and __share_pool.defensive_ticks > 0 then defensive_state.window = defensive_state.window + 1 end
end

events.createmove:set(get_defensive_ticks)
events.round_start:set(reset_defensive_ticks)
events.level_init:set(reset_defensive_ticks)
events.cs_game_disconnected:set(reset_defensive_ticks)

local health_override = {
	whitelist = {},
	threats = {},
	isolate = false,
	backup = {},
}

local player_identity = function(player)
	local info = player:get_player_info()
	return info and info.userid or player:get_index()
end

local player_health = function(player)
	local resource = player:get_resource()
	local health = resource and resource.m_iHealth
	if health ~= nil and tonumber(health) == nil then
		health = health[player:get_index()]
	end
	if tonumber(health) ~= nil then return tonumber(health) end
	local backup = health_override.backup[player:get_index()]
	if backup and backup.userid == player_identity(player) and player.m_iHealth == 0 then
		return backup.health
	end
	return player.m_iHealth
end

local update_health_override = function(release)
	if not health_override.isolate and next(health_override.whitelist) == nil
		and next(health_override.backup) == nil then return end
	local localplayer = entity.get_local_player()
	local active = not release and globals.is_in_game and localplayer ~= nil and localplayer:is_alive()
	local seen = {}
	for _, player in ipairs(entity.get_players(false, true)) do
		local index = player:get_index()
		local userid = player_identity(player)
		local backup = health_override.backup[index]
		seen[index] = true
		if backup and backup.userid ~= userid then
			health_override.backup[index] = nil
			backup = nil
		end
		local health = player_health(player)
		local alive = player.m_lifeState == 0 and health ~= nil and health > 0
		local whitelist = health_override.isolate and not health_override.threats[userid]
			or (not health_override.isolate and health_override.whitelist[player:get_name()])
		if active and player ~= localplayer and alive and whitelist then
			health_override.backup[index] = {userid = userid, health = health}
			if player.m_iHealth ~= 0 then player.m_iHealth = 0 end
		elseif backup then
			if alive and player.m_iHealth == 0 then player.m_iHealth = health end
			health_override.backup[index] = nil
		end
	end
	for index in pairs(health_override.backup) do
		if not seen[index] then health_override.backup[index] = nil end
	end
end

local reset_health_override = function()
	update_health_override(true)
	health_override.threats = {}
	health_override.isolate = false
	health_override.backup = {}
end

events.round_start:set(reset_health_override)
events.level_init:set(reset_health_override)
events.cs_game_disconnected:set(reset_health_override)
events.shutdown:set(function()
	reset_health_override()
	health_override.whitelist = {}
end)

local GetClientEntityPointer = function(ent)
	if not ent then
		return nil
	end

	local success, ptr = pcall(ffi.cast, "void*", ent[0])
	if success and ptr and ptr ~= ffi.NULL then
		return ptr
	end

	return nil
end

local GetAnimationState = function(ent)
	local ptr = GetClientEntityPointer(ent)
	if not ptr then
		return nil
	end

	return ffi.cast("AnimStateVtable*", ffi.cast("char*", ptr) + 0x9960)
end

local get_shot_between = function ()
	local localplayer = localplayer_.ent
	if not localplayer then return end
	
	local my_weapon = localplayer:get_player_weapon()
	if not my_weapon then return end

	local last_shot_time = my_weapon["m_fLastShotTime"]

	return (globals.curtime - last_shot_time)
end

local condition_refs
local check_condition = function (ent)
	-- local localplayer = localplayer_.ent
	-- if not localplayer or not localplayer:is_alive() then return "Globals" end
	if not ent or not ent:is_alive() then return "Globals" end

	if not condition_refs then
		condition_refs = {
			ui.find("Aimbot", "Anti Aim", "Misc", "Slow Walk"),
			ui.find("Aimbot", "Anti Aim", "Misc", "Custom Slow Walk"),
			ui.find("Aimbot", "Anti Aim", "Better Neverlose - MISC", "Slow Walk"),
		}
	end
	local slow_walk = condition_refs[1]:get() or condition_refs[2]:get() or condition_refs[3]:get()

	local vec = ent.m_vecVelocity
	local velocity = math.sqrt( (vec.x * vec.x) + (vec.y * vec.y) )

	-- {"Globals", "Standing", "Running", "Walking", "In Air + Crouching", "In Air", "Crouching"}
	if ((ent == localplayer_.ent) and slow_walk) or ((ent ~= localplayer_.ent) and velocity > 5 and velocity <= 100) then
		return "Walking"
	elseif ent.m_fFlags == 262 and ent.m_flDuckAmount > 0.8 then
		return "In Air + Crouching"
	elseif ent.m_fFlags == 256 then
		return "In Air"
	elseif ent.m_flDuckAmount > 0.8 then
		return "Crouching"
	elseif velocity <= 2 then
		return "Standing"
	elseif velocity >= 3 then
		return "Running"
	end
end

local get_dmg_text = function (dmg)
	local dmg_text

	if dmg == 0 then
		dmg_text = "Auto"
	elseif dmg > 100 then
		dmg_text = "+".. dmg - 100
	else
		dmg_text = dmg
	end

	return dmg_text
end

-- @region override
local override_state = {
	baim = nil,
	safepoint = nil,
	anti_lethal_baim = false,
	anti_lethal_safepoint = false,
	hitboxes = {},
	multipoint = {},
	ui_item = {
		baim = nil,
		safepoint = nil,
		onlyhead = nil,
	}
}

local override_cache = {}
local update_override = function ()
	local refs = override_cache.refs
	if not refs then
		refs = {
			ui.find("Aimbot", "Ragebot", "Safety", "Body Aim"),
			ui.find("Aimbot", "Ragebot", "Safety", "Safe Points"),
			ui.find("Aimbot", "Ragebot", "Selection", "Hitboxes"),
			ui.find("Aimbot", "Ragebot", "Selection", "Multipoint"),
		}
		override_cache.refs = refs
	end
	local bodyaim, safepoint, hitboxes, multipoint = refs[1], refs[2], refs[3], refs[4]

	local baim = (override_state.baim or override_state.anti_lethal_baim or override_state.ui_item.baim) and "Force" or nil
	local safe = (override_state.safepoint or override_state.anti_lethal_safepoint or override_state.ui_item.safepoint) and "Force" or nil
	local hitbox_values = #override_state.hitboxes > 0 and override_state.hitboxes
		or (override_state.ui_item.onlyhead and {"Head"} or {})
	local multipoint_values = #override_state.multipoint > 0 and override_state.multipoint
		or (override_state.ui_item.onlyhead and {"Head"} or {})
	local hitbox_key = table.concat(hitbox_values, "\0")
	local multipoint_key = table.concat(multipoint_values, "\0")

	if override_cache.baim ~= baim then
		bodyaim:override(baim)
		override_cache.baim = baim
	end
	if override_cache.safe ~= safe then
		safepoint:override(safe)
		override_cache.safe = safe
	end
	if override_cache.hitboxes ~= hitbox_key then
		hitboxes:override(table.unpack(hitbox_values))
		override_cache.hitboxes = hitbox_key
	end
	if override_cache.multipoint ~= multipoint_key then
		multipoint:override(table.unpack(multipoint_values))
		override_cache.multipoint = multipoint_key
	end
end


-- @region Ragebot
local ragebot do
    
	local ref = {
		main = ui.find("Aimbot", "Ragebot", "Main"),
		group = ui.find("Aimbot", "Ragebot"),

		safety_scout = ui.find("Aimbot", "Ragebot", "Safety", "SSG-08"),
		safety_awp = ui.find("Aimbot", "Ragebot", "Safety", "AWP"),
	}

	local anti_defensive do
	
		local ax = ref.main:switch("Anti Defensive")
		local original_lc = cvar.cl_lagcompensation:int()
		local shutdown = false
		local last_ax_state = nil

		local ax_main = function ()
			if shutdown then return end
			local active = ax:get()
			local disable_lc = active or __share_pool.anti_lethal_ax
			if disable_lc ~= last_ax_state then
				cvar.cl_lagcompensation:int(disable_lc and 0 or 1)
				last_ax_state = disable_lc
			end
		end

		__share_pool.update_lagcompensation = ax_main
		events.render:set(ax_main)
		events.shutdown:set(function()
			shutdown = true
			cvar.cl_lagcompensation:int(original_lc)
		end)
	end

	local os_peek do
		local hs_options = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots", "Options")
		local hs = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots")
		local auto_peek = ui.find("Aimbot", "Ragebot", "Main", "Peek Assist")
	
		local enabled = ref.main:switch("OS Peek")
		local settings = enabled:create()
		local lag_on_peek = settings:switch("Lag On Peek")
		local last_enabled = false
		local main = function ()
		
			if enabled:get() then
				last_enabled = true
				hs_options:override(lag_on_peek:get() and "Break LC" or nil)
				auto_peek:override(true)
				if get_shot_between() == nil then return end
				if get_shot_between() <= .5 and get_shot_between() >= .255 then
					hs:override(false)
				elseif get_shot_between() >= .5 then
					hs:override(true)
				end
			else
				if last_enabled then
					hs:override(nil)
					hs_options:override(nil)
					auto_peek:override(nil)
					last_enabled = false
				end
			end
		end
		events.createmove:set(main)
	end

	local global_safety do
		local settings = ref.main:label("Global Safety"):create()
		local force_sp = settings:switch("Force Safe Point")
		local force_baim = settings:switch("Force Body Aim")
		local only_head = settings:switch("Only Head")

		main = function ()
			override_state.safepoint = force_sp:get()
			override_state.force_baim = force_baim:get()

			if force_baim:get() then
				override_state.hitboxes = {"Chest", "Stomach"}
				override_state.multipoint = {"Chest", "Stomach"}
			else
				override_state.hitboxes = {}
				override_state.multipoint = {}            
			end

			if only_head:get() then
				override_state.hitboxes = {"Head"}
				override_state.multipoint = {"Head"}
			end

			override_state.ui_item.baim = force_baim:get()
			override_state.ui_item.safepoint = force_sp:get()
			override_state.ui_item.onlyhead = only_head:get()
			update_override()
		end
	
		events.createmove:set(main)
		events.shutdown:set(function() -- wait to test
			override_state.hitboxes = {}
			override_state.multipoint = {}  
			override_state.ui_item.baim = false
			override_state.ui_item.safepoint = false
			override_state.ui_item.onlyhead = false
			update_override()
		end)
	end

	local jump_scout do
		local ref_scout = ui.find("Aimbot", "Ragebot", "Accuracy", "SSG-08")
		local enabled = ref_scout:switch("Jump Scout")
		local ref_air_strafe = ui.find("Miscellaneous", "Main", "Movement", "Air Strafe")
		local last_enabled = false
		local main = function ()
			local localplayer = localplayer_.ent
			local active = enabled:get() and localplayer ~= nil
			if active then
				local vel = localplayer.m_vecVelocity
				local speed = math.floor(math.sqrt(vel.x * vel.x + vel.y * vel.y))
				ref_air_strafe:override(speed > 15)
			elseif last_enabled then
				ref_air_strafe:override()
			end
			last_enabled = active
		end
		events.createmove:set(main)
	end

	local others do
		local group_ = ref.group:create("Better Neverlose - Others")
		local auto_teleport = group_:switch("Auto Teleport")
		local tp_group = auto_teleport:create()
		local teleport_mode = tp_group:combo("Teleport mode", {"Legacy", "LC Break"})
		local anti_lethal = group_:switch("Anti Taser/Knife")
		local al_group = anti_lethal:create()
		local al_tooltip = al_group:label("Force Body Aim and Safe Points against enemies approaching with a knife or Zeus within 25ft.")
		local al_ax = al_group:switch("\aFFFF00FFForce AX [Attention]", true):tooltip("Anti-Defensive can using extrapolation also known prediction.\n\nExtrapolation is unstablable, it can't fully shoot enemy correct movement record.\n\n\aFFFF00FFPlease note: If the server rules have AX is not allowed, you should turn off AX option.")
		local al_whitelist = al_group:switch("\aFFFF00FFTemporary Whitelist [Attention]"):tooltip("While threatened, set other players' HP to zero, excluding you and all approaching threats. Restore HP when the threat ends; existing whitelist settings remain active.")
		local distances = {}

		local fd = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck")
		local auto_tp_armed = true
		local auto_tp_pending = false
		local auto_tp_generation = 0
		local auto_tp_fd = false

		local reset_auto_tp = function()
			auto_tp_generation = auto_tp_generation + 1
			auto_tp_armed = true
			auto_tp_pending = false
			if auto_tp_fd and fd:get_override() == true then fd:override(nil) end
			auto_tp_fd = false
		end

		local auto_tp = function()
			local localplayer = entity.get_local_player()
			local threat = entity.get_threat(true)
			if not auto_teleport:get() or not localplayer or not localplayer:is_alive() or not threat then
				if not auto_tp_armed or auto_tp_pending or auto_tp_fd then reset_auto_tp() end
				return
			end
			local condition = check_condition(localplayer)
			if condition ~= "In Air" and condition ~= "In Air + Crouching" then
				if not auto_tp_armed or auto_tp_pending or auto_tp_fd then reset_auto_tp() end
				return
			end
			if not auto_tp_armed or auto_tp_pending then return end
			auto_tp_armed = false
			if teleport_mode:get() == "Legacy" then
				rage.exploit:force_teleport()
				return
			end
			auto_tp_pending = true
			local generation = auto_tp_generation
			utils.execute_after(0.15, function()
				if generation ~= auto_tp_generation then return end
				auto_tp_pending = false
				local player = entity.get_local_player()
				if not auto_teleport:get() or teleport_mode:get() ~= "LC Break"
					or not player or not player:is_alive() or not entity.get_threat(true) then return end
				local state = check_condition(player)
				if state ~= "In Air" and state ~= "In Air + Crouching" then return end
				if fd:get_override() ~= nil then return end
				fd:override(true)
				auto_tp_fd = true
				utils.execute_after(0.025, function()
					if generation ~= auto_tp_generation then return end
					if auto_tp_fd and fd:get_override() == true then fd:override(nil) end
					auto_tp_fd = false
				end)
			end)
		end

		local clear_anti_lethal = function()
			distances = {}
			health_override.threats = {}
			health_override.isolate = false
			override_state.anti_lethal_baim = false
			override_state.anti_lethal_safepoint = false
			__share_pool.anti_lethal_ax = false
			__share_pool.update_lagcompensation()
			update_override()
			update_health_override()
		end

		local anti_lethal_main = function()
			local localplayer = entity.get_local_player()
			if not anti_lethal:get() or not localplayer or not localplayer:is_alive() then
				if next(distances) ~= nil or override_state.anti_lethal_baim then clear_anti_lethal() end
				return
			end
			local origin = localplayer:get_origin()
			local current_distances, threats = {}, {}
			for _, player in ipairs(entity.get_players(true, false)) do
				if player:is_enemy() and not player:is_dormant() and player.m_lifeState == 0
					and player_health(player) > 0 then
					local userid = player_identity(player)
					local position = player:get_origin()
					local dx, dy, dz = position.x - origin.x, position.y - origin.y, position.z - origin.z
					local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
					local weapon = player:get_player_weapon()
					local info = weapon and weapon:get_weapon_info()
					local name = info and info.weapon_name or ""
					local lethal = info and (info.weapon_type == 0 or name == "weapon_taser"
						or name == "weapon_zeus" or name:find("weapon_knife", 1, true) == 1)
					local previous = distances[userid]
					local approaching = previous and distance < previous.distance - 0.01
					local last_approach = approaching and globals.curtime or previous and previous.last_approach
					if previous and math.abs(distance - previous.distance) <= 0.01 then
						approaching = last_approach ~= nil and globals.curtime - last_approach <= 0.15
					elseif not approaching then
						last_approach = nil
					end
					current_distances[userid] = {distance = distance, last_approach = last_approach}
					if lethal and distance <= 25 * 12 and approaching then
						threats[userid] = true
					end
				end
			end
			distances = current_distances
			local lethal = next(threats) ~= nil
			health_override.threats = threats
			health_override.isolate = lethal and al_whitelist:get()
			override_state.anti_lethal_baim = lethal
			override_state.anti_lethal_safepoint = lethal
			__share_pool.anti_lethal_ax = lethal and al_ax:get()
			__share_pool.update_lagcompensation()
			update_override()
		end

		auto_teleport:set_callback(reset_auto_tp)
		teleport_mode:set_callback(reset_auto_tp)
		anti_lethal:set_callback(clear_anti_lethal)
		al_ax:set_callback(function()
			__share_pool.anti_lethal_ax = anti_lethal:get() and al_ax:get() and next(health_override.threats) ~= nil
			__share_pool.update_lagcompensation()
		end)
		al_whitelist:set_callback(function()
			health_override.isolate = anti_lethal:get() and al_whitelist:get() and next(health_override.threats) ~= nil
			update_health_override()
		end)
		events.round_start:set(reset_auto_tp)
		events.round_start:set(clear_anti_lethal)
		events.level_init:set(reset_auto_tp)
		events.level_init:set(clear_anti_lethal)
		events.cs_game_disconnected:set(reset_auto_tp)
		events.cs_game_disconnected:set(clear_anti_lethal)
		events.shutdown:set(reset_auto_tp)
		events.shutdown:set(clear_anti_lethal)
		events.render:set(function()
			local localplayer = entity.get_local_player()
			if not localplayer or not localplayer:is_alive() then
				if next(distances) ~= nil or override_state.anti_lethal_baim then clear_anti_lethal() end
				if not auto_tp_armed or auto_tp_pending or auto_tp_fd then reset_auto_tp() end
			end
		end)
		events.createmove:set(anti_lethal_main)
		events.createmove:set(auto_tp)
	end

	local advanced_ragebot do
		local scout = ref.safety_scout:switch("Adaptive Hit Chance"):tooltip("Blend distance and visible hitbox samples equally. Distance scales from 0 to 100ft. Applies only while holding SSG-08.")
		local scout_group = scout:create()
		local scout_hc = {
			far = scout_group:slider("Far HC", 0, 100, 70, 1, "%"),
			near = scout_group:slider("Near HC", 0, 100, 30, 1, "%"),
			exposed = scout_group:slider("High Exposure HC", 0, 100, 65, 1, "%"),
			covered = scout_group:slider("Low Exposure HC", 0, 100, 30, 1, "%"),
		}
		local hit_chance = ui.find("Aimbot", "Ragebot", "Selection", "SSG-08", "Hit Chance")
		local hitboxes = ui.find("Aimbot", "Ragebot", "Selection", "SSG-08", "Hitboxes")
		local hitbox_groups = {
			{"Head", {0}, 3}, {"Chest", {4, 5, 6}, 5}, {"Stomach", {2, 3}, 5},
			{"Arms", {13, 14, 15, 16, 17, 18}, 2}, {"Legs", {7, 8, 9, 10}, 3}, {"Feet", {11, 12}, 2},
		}
		local hc_active = false
		local hc_value
		local exposure_cache

		local clear_scout_hc = function()
			if hc_active then hit_chance:override(nil) end
			hc_active = false
			hc_value = nil
			exposure_cache = nil
		end

		local scout_main = function()
			local localplayer = entity.get_local_player()
			local weapon = localplayer and localplayer:get_player_weapon()
			local info = weapon and weapon:get_weapon_info()
			local threat = scout:get() and entity.get_threat() or nil
			if not scout:get() or not localplayer or not localplayer:is_alive()
				or not info or info.weapon_name ~= "weapon_ssg08" or not threat
				or not threat:is_enemy() or threat:is_dormant() or not threat:is_alive() then
				clear_scout_hc()
				return
			end
			local origin, target = localplayer:get_origin(), threat:get_origin()
			local dx, dy, dz = target.x - origin.x, target.y - origin.y, target.z - origin.z
			local distance = math.min(math.sqrt(dx * dx + dy * dy + dz * dz) / (100 * 12), 1)
			local eye = localplayer:get_eye_position()
			local selected = hitboxes:get_override() or hitboxes:get()
			local userid = player_identity(threat)
			local selection = table.concat(selected, "\0")
			if not exposure_cache or exposure_cache.userid ~= userid or exposure_cache.selection ~= selection
				or globals.curtime - exposure_cache.time >= 0.05 then
				local enabled_hitboxes = {}
				for _, name in ipairs(selected) do enabled_hitboxes[name] = true end
				local horizontal = math.sqrt(dx * dx + dy * dy)
				local side_x = horizontal > 0 and -dy / horizontal or 1
				local side_y = horizontal > 0 and dx / horizontal or 0
				local visible, total = 0, 0
				for _, group in ipairs(hitbox_groups) do
					if enabled_hitboxes[group[1]] then
						for _, index in ipairs(group[2]) do
							local position = threat:get_hitbox_position(index)
							if position then
								local radius = group[3]
								local points = {
									position,
									vector(position.x + side_x * radius, position.y + side_y * radius, position.z),
									vector(position.x - side_x * radius, position.y - side_y * radius, position.z),
									vector(position.x, position.y, position.z + radius),
									vector(position.x, position.y, position.z - radius),
								}
								for _, point in ipairs(points) do
									local trace = utils.trace_line(eye, point, localplayer, 0x4600400B)
									total = total + 1
									if not trace.start_solid and not trace.all_solid
										and (trace.entity == threat or trace.fraction >= 1) then
										visible = visible + 1
									end
								end
							end
						end
					end
				end
				if total == 0 then clear_scout_hc() return end
				exposure_cache = {userid = userid, selection = selection, time = globals.curtime, value = visible / total}
			end
			local exposure = exposure_cache.value
			local distance_hc = scout_hc.near:get() + (scout_hc.far:get() - scout_hc.near:get()) * distance
			local exposure_hc = scout_hc.covered:get() + (scout_hc.exposed:get() - scout_hc.covered:get()) * exposure
			local value = math.floor((distance_hc + exposure_hc) * 0.5 + 0.5)
			if value ~= hc_value then hit_chance:override(value) end
			hc_active = true
			hc_value = value
		end
		scout:set_callback(function() if not scout:get() then clear_scout_hc() end end)
		events.createmove:set(scout_main)
		events.round_start:set(clear_scout_hc)
		events.level_init:set(clear_scout_hc)
		events.cs_game_disconnected:set(clear_scout_hc)
		events.shutdown:set(clear_scout_hc)
		events.render:set(function()
			local localplayer = entity.get_local_player()
			if hc_active and (not localplayer or not localplayer:is_alive()) then clear_scout_hc() end
		end)

		local awp = {
			emeny_crouching = ref.safety_awp:selectable("Emeny crouching", {"Force Body", "HC Override", "DMG. Override"}),
			hc_override = ref.safety_awp:slider("> HC Override", 0, 100, 50, 1, "%"),
			dmg_override = ref.safety_awp:slider("> DMG Override", 0, 130, 0, 1, function(self)
				if self == 0 then return "Auto" end
				if self > 100 then
					return "+" .. self - 100
				end
			end),
		}
		

		local items_visible = function ()
			awp.hc_override:visibility(awp.emeny_crouching:get("HC Override"))
			awp.dmg_override:visibility(awp.emeny_crouching:get("DMG. Override"))
		end
		events.render:set(items_visible)
	end
end

local function get_item_value(item, ...)
	local value = item:get_override()
	if value ~= nil then
		return value
	end
	return item:get(...)
end

local air_exploit_state = {
	active = false,
	fake_duck = false,
}

local premium_aa_active = false
local silent_shots_active = false

local defensive_controller = {
	providers = {},
	slots = {},
	phase = 0,
}

local override_if_changed = function(item, value)
	local current = item:get_override()
	if current == value then return end
	if type(current) == "table" and type(value) == "table" and #current == #value then
		local equal = true
		for i = 1, #value do if current[i] ~= value[i] then equal = false break end end
		if equal then return end
	end
	item:override(value)
end

local defensive_choices = {pitch = {-89, -60, -25, 25, 60, 89}, yaw = {-165, -105, -60, 60, 105, 165}}
local defensive_sequence = {-52, -1, 60}

local aa_enabled_ref = ui.find("Aimbot", "Anti Aim", "Angles", "Enabled")
local aa_context_valid = function(cmd)
	local player = entity.get_local_player()
	if not globals.is_in_game or not player or not player:is_alive() then return false end
	if not get_item_value(aa_enabled_ref) then return false end
	if player.m_MoveType == 8 or player.m_MoveType == 9 then return false end
	return not cmd.in_use and not cmd.in_attack and not cmd.in_attack2
end

local premium_is_active = function()
	return __share_pool.premium_is_active and __share_pool.premium_is_active() or false
end

local hidden_ref = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Hidden")
local defensive_lag_ref = ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options")
local defensive_dt_ref = ui.find("Aimbot", "Ragebot", "Main", "Double Tap")
local defensive_fd_ref = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck")

defensive_controller.release_angles = function()
	if not defensive_controller.hidden_owned and not defensive_controller.window then return end
	if defensive_controller.hidden_owned and hidden_ref:get_override() == true then
		hidden_ref:override(defensive_controller.hidden_backup)
	end
	defensive_controller.hidden_owned = false
	defensive_controller.window = nil
	defensive_controller.last_command = nil
	defensive_controller.slots = {}
end

defensive_controller.reset = function()
	defensive_controller.release_angles()
	if defensive_controller.lag_owned and defensive_lag_ref:get_override() == defensive_controller.lag_value then
		defensive_lag_ref:override(defensive_controller.lag_backup)
	end
	defensive_controller.lag_owned = false
	defensive_controller.owner = nil
	defensive_controller.next_request = nil
end

local defensive_pattern = function(axis, mode, first, second, period)
	if mode == "Default" then return nil end
	local state = defensive_controller
	local phase = state.phase
	period = math.max(1, math.floor(period or 1))
	local value
	if mode == "Static" then
		value = first
	elseif mode == "Up" or mode == "Fake Up" then
		value = -89
	elseif mode == "Down" then
		value = 89
	elseif mode == "45 Deg" then
		value = -45
	elseif mode == "45° Jitter" then
		value = math.floor(phase / 2) % 2 == 0 and 45 or -45
	elseif mode == "Side-Way" or mode == "90 Jitter" then
		value = math.floor(phase / period) % 2 == 0 and 89 or -89
	elseif mode == "Jitter" then
		value = math.floor(phase / period) % 2 == 0 and first or second
	elseif mode == "Flicker" then
		value = phase % period == 0 and first or second
	elseif mode == "3-Way" then
		value = defensive_sequence[math.floor(phase / period) % #defensive_sequence + 1]
	elseif mode == "Cycle" or mode == "Spin" then
		if axis == "yaw" and first == second then
			value = state.spin_start + phase * 37 / period
		else
			local length = math.abs(second - first)
			local step = (phase * (axis == "pitch" and 20 or 10) / period) % (length * 2 + 1)
			if step > length then step = length * 2 - step end
			value = first + (second >= first and step or -step)
		end
	elseif mode == "Fake" and __share_pool.defensive_ticks > 10 then
		value = first
	else
		local slot = state.slots[axis]
		if not slot or slot.mode ~= mode or slot.first ~= first or slot.second ~= second
			or slot.period ~= period or phase >= slot.next_phase then
			local previous = slot and slot.value
			if mode == "Random" then
				value = utils.random_int(axis == "yaw" and -180 or -89, axis == "yaw" and 180 or 89)
			else
				local candidates = defensive_choices[axis]
				local index = utils.random_int(1, #candidates)
				value = candidates[index]
				if previous then
					for offset = 0, #candidates - 1 do
						local candidate = candidates[(index + offset - 1) % #candidates + 1]
						if math.abs(axis == "yaw" and math.normalize_yaw(candidate - previous) or candidate - previous) >= 35 then
							value = candidate
							break
						end
					end
				end
				value = value + utils.random_int(-7, 7)
			end
			slot = slot or {}
			slot.mode, slot.first, slot.second, slot.period = mode, first, second, period
			slot.value = value
			slot.next_phase = phase + (mode == "Random" and period or utils.random_int(1, 3))
			state.slots[axis] = slot
		end
		value = slot.value
	end
	return axis == "yaw" and math.normalize_yaw(value) or math.max(-89, math.min(89, value))
end

defensive_controller.settings = function(cmd)
	local provider = defensive_controller.providers[premium_is_active() and "premium" or "standalone"]
	return provider and provider(cmd) or nil
end

defensive_controller.apply = function(cmd)
	local state = defensive_controller
	if state.generation ~= defensive_state.generation then
		state.reset()
		state.generation = defensive_state.generation
	end
	if not aa_context_valid(cmd) or not get_item_value(defensive_dt_ref)
		or get_item_value(defensive_fd_ref) or silent_shots_active then
		state.reset()
		return
	end
	local settings = state.settings(cmd)
	if not settings or settings.lc == "Disabled" then
		state.reset()
		return
	end
	if state.owner ~= settings.owner then state.reset() end
	state.owner = settings.owner
	if not state.lag_owned then
		state.lag_backup = defensive_lag_ref:get_override()
		state.lag_owned = true
	end
	state.lag_value = settings.lc
	if defensive_lag_ref:get_override() ~= settings.lc then defensive_lag_ref:override(settings.lc) end
	local command = cmd.command_number
	if settings.lc == "Always On" and rage.exploit:get() == 1 and __share_pool.defensive_ticks == 0
		and cmd.choked_commands == 0 and (not state.next_request or command >= state.next_request) then
		cmd.force_defensive = true
		state.next_request = command + utils.random_int(18, 30)
	end
	if __share_pool.defensive_ticks <= settings.guard then
		state.release_angles()
		return
	end
	if settings.pitch == "Default" and settings.yaw == "Default" then state.release_angles() return end
	if state.window ~= defensive_state.window then
		state.window = defensive_state.window
		state.phase = 0
		state.last_command = command
		state.spin_start = utils.random_int(-180, 180)
		state.slots = {}
	elseif state.last_command ~= command then
		if cmd.choked_commands == 0 or cmd.no_choke or cmd.send_packet == true then state.phase = state.phase + 1 end
		state.last_command = command
	end
	local pitch = defensive_pattern("pitch", settings.pitch, settings.p1, settings.p2, settings.p_period)
	local yaw = defensive_pattern("yaw", settings.yaw, settings.y1, settings.y2, settings.y_period)
	if not state.hidden_owned then
		state.hidden_backup = hidden_ref:get_override()
		state.hidden_owned = true
	end
	if hidden_ref:get_override() ~= true then hidden_ref:override(true) end
	if pitch ~= nil then rage.antiaim:override_hidden_pitch(pitch) end
	if yaw ~= nil then rage.antiaim:override_hidden_yaw_offset(yaw) end
end

local slow_walk_controller = {
	providers = {},
	stage = 0,
}
local native_slow_walk = ui.find("Aimbot", "Anti Aim", "Misc", "Slow Walk")

slow_walk_controller.reset = function()
	if slow_walk_controller.owned and native_slow_walk:get_override() == false then
		native_slow_walk:override(slow_walk_controller.backup)
	end
	slow_walk_controller.owned = false
	slow_walk_controller.stage = 0
	slow_walk_controller.last_command = nil
	__share_pool.slow_walk = false
end

slow_walk_controller.settings = function()
	local provider = slow_walk_controller.providers[premium_is_active() and "premium" or "standalone"]
	return provider and provider() or nil
end

slow_walk_controller.apply = function(cmd)
	local state = slow_walk_controller
	local player = entity.get_local_player()
	local settings = state.settings()
	if not settings or not globals.is_in_game or not player or not player:is_alive()
		or player.m_MoveType == 8 or player.m_MoveType == 9 then state.reset() return end
	if not state.owned then state.backup = native_slow_walk:get_override() state.owned = true end
	if native_slow_walk:get_override() ~= false then native_slow_walk:override(false) end
	__share_pool.slow_walk = true
	local speed = settings.speed
	if settings.mode == "Jitter" then
		speed = math.floor(cmd.command_number / math.max(1, settings.ticks)) % 2 == 0 and settings.speed or settings.speed2
	elseif settings.mode == "Prefer Anti-Aim" then
		if state.last_command ~= cmd.command_number and cmd.choked_commands == 0 then state.stage = (state.stage + 1) % 4 end
		speed = state.stage > 0 and 80 or 20
	elseif settings.mode == "Prefer Aimbot" then
		if cmd.block_movement ~= 2 then cmd.block_movement = 1 end
	end
	state.last_command = cmd.command_number
	local movement = math.sqrt(cmd.forwardmove * cmd.forwardmove + cmd.sidemove * cmd.sidemove)
	if movement == 0 or cmd.block_movement == 2 then return end
	cmd.in_speed = false
	cmd.jitter_move = false
	local duck = math.max(0, math.min(1, player.m_flDuckAmount or 0))
	local limit = speed / (1 - 0.66 * duck)
	if movement > limit then
		local factor = limit / movement
		cmd.forwardmove = cmd.forwardmove * factor
		cmd.sidemove = cmd.sidemove * factor
	end
end

local reset_aa_runtime = function()
	defensive_controller.reset()
	slow_walk_controller.reset()
end
events.round_start:set(reset_aa_runtime)
events.level_init:set(reset_aa_runtime)
events.cs_game_disconnected:set(reset_aa_runtime)
events.shutdown:set(reset_aa_runtime)
events.render:set(function()
	local player = entity.get_local_player()
	if not globals.is_in_game or not player or not player:is_alive() then reset_aa_runtime() return end
	if defensive_controller.lag_owned or defensive_controller.hidden_owned then
		local settings = defensive_controller.settings()
		if not settings or settings.lc == "Disabled" then defensive_controller.reset() end
	end
	if slow_walk_controller.owned and not slow_walk_controller.settings() then slow_walk_controller.reset() end
end)


-- @region AntiAim
local antiaim do

	local ref = {
		fakelag = ui.find("Aimbot", "Anti Aim", "Fake Lag"),
		misc = ui.find("Aimbot", "Anti Aim", "Misc"),
		angles = ui.find("Aimbot", "Anti Aim", "Angles"),
		limit = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Limit"),
		variability = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Variability"),
	}

	local slient_shots do
		local fakelag_enabled = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Enabled")
	
		local body_yaw = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw")
		local enabled = ref.fakelag:switch("Slient Shots")
		local last_enabled = false
        local fire_time = 0
		local premium_ref
		local dt_ref = ui.find("Aimbot", "Ragebot", "Main", "Double Tap")
	
		local main_slient_shots = function (event)
			if not premium_ref then
				premium_ref = ui.find("Scripts", "Better Neverlose", "Main", "Better Neverlose - Info.", ui.get_icon("user-plus") .. "  Enabled Premium Antiaim")
			end
			local premium_aa_enabled = premium_ref:get()
			if premium_aa_enabled then
				ss_enabled = enabled:get_override()
			else
				ss_enabled = enabled:get()
			end

			fire_time = ss_enabled and get_shot_between() or nil
			local is_dt = dt_ref:get() and .235 or .03
			local active = fire_time ~= nil and fire_time <= is_dt

			if active then
			    	
			    	event.no_choke = true
			    	event.send_packet = true
		    	
			    	fakelag_enabled:override(false)
			    	body_yaw:override(false)
			    	ref.variability:override(0)
			    	ref.limit:override(1)
			elseif last_enabled then
				fakelag_enabled:override()
				body_yaw:override()
				ref.variability:override()
				ref.limit:override()
			end
			silent_shots_active = active
			last_enabled = active
		end
		events.createmove:set(main_slient_shots)
	end

	local defensive_snap do
		local enabled = ref.angles:switch("Defensive Anti-Aim")
		local group = enabled:create()
		local yaw = group:combo("Yaw", {"Default", "Spin", "Static", "Side-Way", "Jitter", "3-Way", "Adaptive"})
		local yaw_settings = {
			yaw = group:slider("\n", -180, 180, 0, 1, "°"),
			yaw_override = group:slider("\n", -180, 180, 0, 1, "°"),
			velocity = group:slider("> Velocity", 0, 100, 30),
		}
		local pitch = group:combo("Pitch", {"Default", "Up", "Down", "Static", "45° Jitter", "Jitter", "Cycle", "Adaptive"})
		local pitch_settings = {
			pitch = group:slider("\n", -89, 89, 0, 1, "°"),
			pitch_override = group:slider("\n", -89, 89, 0, 1, "°"),
			velocity = group:slider("> Velocity", 0, 100, 30),
		}
		local defensive = group:combo("Defensive", {"On Peek", "Always On"})
		local guard = group:slider("Recovery Guard", 0, 4, 2, 1, "t"):tooltip("Restore normal angles before the estimated defensive window ends. Tickbase detection is an estimate of the server's record gap.")

		defensive_controller.providers.standalone = function()
			if not enabled:get() then return end
			return {
				owner = "standalone", lc = defensive:get(), guard = guard:get(),
				yaw = yaw:get(), y1 = yaw_settings.yaw:get(), y2 = yaw_settings.yaw_override:get(),
				y_period = math.max(1, math.floor(1 / (globals.tickinterval * (yaw_settings.velocity:get() * 0.5 + 1)))),
				pitch = pitch:get(), p1 = pitch_settings.pitch:get(), p2 = pitch_settings.pitch_override:get(),
				p_period = math.max(1, math.floor(1 / (globals.tickinterval * (pitch_settings.velocity:get() * 0.5 + 1)))),
			}
		end
		events.render:set(function()
			local get_yaw, get_pitch = yaw:get(), pitch:get()
			yaw_settings.yaw:visibility(get_yaw == "Static" or get_yaw == "Jitter")
			yaw_settings.yaw_override:visibility(get_yaw == "Jitter")
			yaw_settings.velocity:visibility(get_yaw == "Jitter")
			pitch_settings.pitch:visibility(get_pitch == "Static" or get_pitch == "Jitter" or get_pitch == "Cycle")
			pitch_settings.pitch_override:visibility(get_pitch == "Jitter" or get_pitch == "Cycle")
			pitch_settings.velocity:visibility(get_pitch == "Jitter" or get_pitch == "Cycle")
		end)
	end

	local manual_aa do
		local freestanding = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding")
		local yaw_offset = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset")
		local yaw = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw")
		local combo = ref.misc:combo("Manual Yaw", {"None", "Left", "Right", "Backward", "Forward", "Freestanding"})
		local last_enabled = false
	
		local main = function ()
			-- Standalone for condition AA
			local selection = get_item_value(combo)
			local yaw_value = ({
				["None"] = nil,
				["Left"] = -90,
				["Right"] = 90,
				["Backward"] = 0,
				["Forward"] = 180,
				["Freestanding"] = true,
			})[selection] or nil
			local active = selection ~= nil and selection ~= "None"
			if active then
				yaw:override("Backward")
				yaw_offset:override(selection ~= "Freestanding" and yaw_value or nil)
				freestanding:override(selection == "Freestanding" and true or nil)
			elseif last_enabled then
				yaw:override()
				yaw_offset:override()
				freestanding:override()
			end
			last_enabled = active
		end
		events.createmove:set(main)
	end

	local air_exploit do
		local dt = ui.find("Aimbot", "Ragebot", "Main", "Double Tap")
		local fake_duck = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck")
		local enabled = ref.misc:switch("Air Exploit")
		local group = enabled:create()
		local ticks = group:slider("Tick(s)", 1, 30, 15)
		local active = false

		local function reset_air_exploit(keep_limit)
			air_exploit_state.active = false
			air_exploit_state.fake_duck = false
			if not active then return end
			if not keep_limit then ref.limit:override(nil) end
			fake_duck:override(nil)
			cvar.sv_maxusrcmdprocessticks:int()
			active = false
		end

		local main = function ()
			local localplayer = localplayer_.ent
			if not localplayer then
				reset_air_exploit()
				return
			end
			local air_exploit_enabled = get_item_value(enabled)
			local air_exploit_ticks = get_item_value(ticks)
			if not air_exploit_enabled or not get_item_value(dt) or silent_shots_active then
				reset_air_exploit(silent_shots_active)
				return
			end

			active = true
			air_exploit_state.active = true
			air_exploit_state.fake_duck = globals.tickcount % air_exploit_ticks == 0
			cvar.sv_maxusrcmdprocessticks:int(19)
		
			ref.limit:override(17)
			fake_duck:override(air_exploit_state.fake_duck)
		end
		events.createmove:set(main)
	end
    
	local slow_walk do
		local enabled = ref.misc:switch("Custom Slow Walk")
		local group = enabled:create()
		local mode = group:combo("Mode", {"Static", "Jitter", "Prefer Anti-Aim", "Prefer Aimbot"})
		local speed = group:slider("Speed", 1, 120, 100, 1, "u")
		local speed_override = group:slider("Speed #2", 1, 120, 100, 1, "u")
		local ticks = group:slider("Tick(s)", 1, 30, 10)
		slow_walk_controller.providers.standalone = function()
			if not get_item_value(enabled) then return end
			return {
				mode = get_item_value(mode), speed = get_item_value(speed),
				speed2 = get_item_value(speed_override), ticks = get_item_value(ticks),
			}
		end
		events.render:set(function()
			speed:visibility(mode:get() ~= "Prefer Anti-Aim" and mode:get() ~= "Prefer Aimbot")
			speed_override:visibility(mode:get() == "Jitter")
			ticks:visibility(mode:get() == "Jitter")
		end)
	end
end

-- @region visuals
local visuals do

    if not __DISABLED_VISUALS then

	local spectators_list = {}
	local spectators_avatar_cache = {}
	local spectators_anim = {}
	local spectator_target
	local reset_spectators = function()
		spectators_list = {}
		spectators_avatar_cache = {}
		spectators_anim = {}
		spectator_target = nil
	end

	local get_spectator = function ()
		local localplayer = entity.get_local_player()
		if not globals.is_in_game or not localplayer then
			if spectator_target ~= nil or next(spectators_avatar_cache) ~= nil then reset_spectators() end
			return
		end

		-- Alive: list players observing us. Dead: list players observing the
		-- same player that we are currently spectating.
		local observed_player = localplayer:is_alive() and localplayer or localplayer.m_hObserverTarget
		if not observed_player then
			reset_spectators()
			return
		end

		local observed_index = observed_player:get_index()
		local target = player_identity(observed_player)
		if spectator_target ~= target then reset_spectators() end
		spectator_target = target
		local current_spectators = {}
		local connected_players = {}

		for _, player in ipairs(entity.get_players(false, true)) do
			local idx = player:get_index()
			local p_name = player:get_name()
			local userid = player_identity(player)
			connected_players[idx] = userid
			local observer_target = player.m_lifeState ~= 0 and player.m_hObserverTarget or nil

			if idx ~= localplayer:get_index() and observer_target ~= nil
				and (player.m_iObserverMode == 4 or player.m_iObserverMode == 5)
				and observer_target:get_index() == observed_index then
				local cached_avatar = spectators_avatar_cache[idx]
				if not cached_avatar or cached_avatar.userid ~= userid
					or (cached_avatar.avatar == nil and globals.curtime - cached_avatar.updated >= 1) then
					cached_avatar = {userid = userid, avatar = player:get_steam_avatar(), updated = globals.curtime}
					spectators_avatar_cache[idx] = cached_avatar
				end
				local avatar = cached_avatar.avatar

				current_spectators[#current_spectators + 1] = {
					index = idx,
					name = p_name,
					is_active = true,
					avatar = avatar,
				}
			end
		end
		for index, cached in pairs(spectators_avatar_cache) do
			if connected_players[index] ~= cached.userid then spectators_avatar_cache[index] = nil end
		end
		table.sort(current_spectators, function(a, b)
			return a.index < b.index
		end)

		-- Rebuild the table so disconnected players and reused entity indices
		-- cannot leave stale entries from a previous round or match.
		spectators_list = current_spectators
		return spectators_list
	end

	-- Render still runs while the local player is dead; createmove may not.
	events.render:set(get_spectator)
	events.round_start:set(reset_spectators)
	events.level_init:set(reset_spectators)
	events.player_connect_full:set(function(event)
		local localplayer = entity.get_local_player()
		if localplayer and entity.get(event.userid, true) == localplayer then reset_spectators() end
	end)
	events.cs_game_disconnected:set(reset_spectators)

	local ref = {
		main = ui.find("Visuals", "World", "Main"),
		ambient = ui.find("Visuals", "World", "Ambient"),
		other = ui.find("Visuals", "World", "Other"),
		dt = ui.find("Aimbot", "Ragebot", "Main", "Double Tap"),
		hs = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots"),
		dmg = ui.find("Aimbot", "Ragebot", "Selection", "Min. Damage"),
		hc = ui.find("Aimbot", "Ragebot", "Selection", "Hit Chance"),
	}

	local animation_camera do
		local thridperson = ui.find("Visuals", "World", "Main", "Force Thirdperson")
		local ref = thridperson:create()
		local enabled = ref:switch("Anim. Camera")
		local distance = ref:slider("~ Distance", 15, 250, 110)

		local orginal_ref = ui.find("Visuals", "World", "Main", "Force Thirdperson", "Distance")
		orginal_ref:visibility(false)

		local camera_dist = 0

		local main = function ()
			local lp_check = (localplayer_.ent and localplayer_.ent:is_alive())
			
			camera_dist = (enabled:get() and math.lerp(camera_dist, thridperson:get() and distance:get() or 0, globals.frametime * 15) or distance:get())
			orginal_ref:set(not lp_check and distance:get() or camera_dist)

		end

		events.render:set(main)
		events.shutdown:set(function()
			orginal_ref:visibility(true)
		end)
	end

	local custom_viewmodel do
		local enabled = ref.main:switch("Custom Viewmodel")
		local group = enabled:create()
		local fov = group:slider("Fov", 0, 160, 70, 0.1)
		local x = group:slider("X", -200, 200, 0, 0.1)
		local y = group:slider("Y", -200, 200, 0, 0.1)
		local z = group:slider("Z", -200, 200, 0, 0.1)
		local aspectratio = group:slider("Aspect Ratio", 0, 50, 0, 0.1)

		local main = function ()

			m_fov = enabled:get() and fov:get() or 68
			m_x = enabled:get() and x:get() / 10 or 0
			m_y = enabled:get() and y:get() / 10 or 0
			m_z = enabled:get() and z:get() / 10 or 0
			m_aspectratio = enabled:get() and aspectratio:get() / 10 or 0
			
			cvar["sv_competitive_minspec"]:int(1)
			cvar["viewmodel_fov"]:float(m_fov, true)
			cvar["viewmodel_offset_x"]:float(m_x, true)
			cvar["viewmodel_offset_y"]:float(m_y, true)
			cvar["viewmodel_offset_z"]:float(m_z, true)
			cvar["r_aspectratio"]:float(m_aspectratio)
		end

		events.render:set(main)
		events.shutdown:set(function()
			cvar["sv_competitive_minspec"]:int()
			cvar["viewmodel_fov"]:int(68)
			cvar["viewmodel_offset_x"]:int(0)
			cvar["viewmodel_offset_y"]:int(0)
			cvar["viewmodel_offset_z"]:int(0)
			cvar["r_aspectratio"]:float(0)
		end)
	end


	local debug_visuals do
		local enabled = ref.main:switch("\a{Link Active}".. ui.get_icon("triangle-exclamation") .." Debug Visuals")
		-- What a BS, you must use fontawesome icon to be applied color, unicode(emoji) won't
		local group = enabled:create()
			group:label("Press\a{Link Active} Shift\aDEFAULT and \a{Link Active}Left Click\aDEFAULT on the screen to set debug info position.")
		local elements = group:selectable("Elements", {"Threat Target", "Desync delta", "Real Yaw", "Abs Yaw", "Feet Yaw", "Choked Commands", "Exploit charge", "LC Break"})
		local choked_style = group:combo("Choked Style", {"Number", "Bar", "Both"})
		local choked_color = choked_style:color_picker(ui.get_style("Link Active"))

		local charge_style = group:combo("Charge Style", {"Number", "Bar", "Both"})
		local charge_color = charge_style:color_picker(ui.get_style("Link Active"))

		local lc_style = group:combo("LC Style", {"Number", "Bar", "Both"})
		local lc_color = lc_style:color_picker(ui.get_style("Link Active"))

		local watermark = group:switch("Watermark")

		local w, h = render.screen_size().x, render.screen_size().y
		local save_x, save_y = group:slider("indicator_x", 0, w, 100), group:slider("indicator_y", 0, h, 100)

		local last_update_time = 0
		local last_frame_count = 0
		local displayed_fps = 0

		local items_visible = function ()
			choked_style:visibility(elements:get("Choked Commands"))
			charge_style:visibility(elements:get("Exploit charge"))
			lc_style:visibility(elements:get("LC Break"))
			save_x:visibility(false)
			save_y:visibility(false)
		end

		local render_elements = function ()
			w, h = render.screen_size().x, render.screen_size().y

			local localplayer = localplayer_.ent
			if not localplayer then return end

			if not enabled:get() then return end    
			local x, y = save_x:get(), save_y:get()
			local mouse_x, mouse_y = ui.get_mouse_position().x, ui.get_mouse_position().y
			local kb_shift = common.is_button_down(0xA0) or common.is_button_down(0xA1) -- 0xA0 LShift, 0xA1 RShift
			local kb_lmb = common.is_button_down(0x01) -- Mouse Left Click
			-- https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes you want to know
			local menu_open = ui.get_alpha()
			local fps = math.floor( 1 / globals.absoluteframetime )

			local offset = 0
			local offset_x = 0

			if kb_shift and kb_lmb and menu_open > .5 then -- affected by menu animation speed, for unexpected prevent
				save_x:set(mouse_x)
				save_y:set(mouse_y)
				x, y = save_x:get(), save_y:get()
			end

			local get_desync_angle = function (ent) -- code from Elysia.lua, my first essential script
				return math.abs(math.normalize_yaw(ent:get_anim_state().eye_yaw % 360 - math.floor(ent:get_anim_state().abs_yaw) % 360)) or "?"
			end

			if elements:get("Threat Target") then
				local threat = entity.get_threat()
				local threat_name = threat and threat:get_name() or "unk."
				local delta = threat and string.format("%.2f°", math.abs(threat.m_flPoseParameter[11] - threat.m_flPoseParameter[10]) * 120) or "?"
				local desync = threat and string.format("%.1f°", get_desync_angle(threat))

				render.text(1, vector(x, y + offset), color(255), nil, string.format("Threat: %s", threat_name))
				offset = offset + 15
				render.text(1, vector(x, y + offset), color(255), nil, string.format("Δ: %s / Desync: %s", delta, desync))
				offset = offset + 18
			end
			if elements:get("Desync delta") then
				delta = string.format("%.1f", get_desync_angle(localplayer))              

				render.text(1, vector(x, y + offset), color(255), nil, string.format("Desync Δ: %s°", delta))
				offset = offset + 18
			end
			if elements:get("Real Yaw") or elements:get("Abs Yaw") or elements:get("Feet Yaw") then
				if elements:get("Real Yaw") then
					render.text(1, vector(x + offset_x, y + offset), color(255), nil, string.format("Real: %s", math.floor(localplayer:get_anim_state().eye_yaw)))
					offset_x = offset_x + 60
				end
				if elements:get("Abs Yaw") then
					render.text(1, vector(x + offset_x, y + offset), color(255), nil, string.format("Abs: %s", math.floor(localplayer:get_anim_state().abs_yaw)))
					offset_x = offset_x + 60
				end
				if elements:get("Feet Yaw") then
					render.text(1, vector(x + offset_x, y + offset), color(255), nil, string.format("Feet: %s", math.floor(localplayer.m_flPoseParameter[11] == nil and 0 or localplayer.m_flPoseParameter[11] * 120 - 60) or "Unknown ?"))
					offset_x = offset_x + 60
				end
				offset = offset + 18
			end
			if elements:get("Choked Commands") then
				local choked = globals.choked_commands
				local maxusrcmdprocessticks = cvar.sv_maxusrcmdprocessticks:int() - 2

				render.text(1, vector(x, y + offset), color(255), nil, "Choked: ")

				if choked_style:get() == "Number" or choked_style:get() == "Both" then
					render.text(1, vector(x + 120, y + offset), color(255), "r", string.format("%st/%st", choked, maxusrcmdprocessticks))
				end
				if choked_style:get() == "Bar" or choked_style:get() == "Both" then
					render.gradient(vector(x, y + offset + 15), vector(x + choked * (120 / 14), y + offset + 25), color("#000000"), choked_color:get(), color("#000000"), choked_color:get())
					offset = offset + 10
				end

				offset = offset + 18
			end
			if elements:get("Exploit charge") then
				local charged = string.format("%.2f", rage.exploit:get())

				render.text(1, vector(x, y + offset), color(255), nil, "Exploit Charged: ")

				if charge_style:get() == "Number" or charge_style:get() == "Both" then
					render.text(1, vector(x + 120, y + offset), color(255), "r", string.format("%s%%", charged * 100))
				end
				if charge_style:get() == "Bar" or charge_style:get() == "Both" then
					render.gradient(vector(x, y + offset + 15), vector(x + 120 * charged, y + offset + 25), color("#000000"), charge_color:get(), color("#000000"), charge_color:get())
					offset = offset + 10
				end
				
				offset = offset + 18
			end
			if elements:get("LC Break") then
				local length = (__share_pool.defensive_ticks * (120 / 14))
				render.text(1, vector(x, y + offset), color(255), nil, "Defensive: ")

				if lc_style:get() == "Number" or lc_style:get() == "Both" then
					render.text(1, vector(x + 120, y + offset), color(255), "r", string.format("%st", __share_pool.defensive_ticks))
				end
				if lc_style:get() == "Bar" or lc_style:get() == "Both" then
					render.gradient(vector(x, y + offset + 15), vector(x + (length), y + offset + 25), color("#000000"), lc_color:get(), color("#000000"), lc_color:get())
					offset = offset + 10
				end
				
				offset = offset + 18
			end


		end

		local debug_watermark = function ()
			if not enabled:get() then return end
			if not watermark:get() then return end

			local current_time = globals.realtime
			local current_frame = globals.framecount
			
			if current_time - last_update_time >= 0.3 then
				local frames_passed = current_frame - last_frame_count
				local time_passed = current_time - last_update_time
				
				displayed_fps = math.floor(frames_passed / time_passed)
				
				last_update_time = current_time
				last_frame_count = current_frame
			end

			local get_time = common.get_system_time()
			local time = string.format("%02d:%02d:%02d", get_time.hours, get_time.minutes, get_time.seconds)

			-- Neverlose.cc w/ Better Neverlose [Debug Mode] Client version: 1.12.33 xXYu3zH3nGL1ngXx FPS: 300 - 13:33:37 info: 127.0.0.1:25525 | idk
			local product_name = "Neverlose.cc w/ Better Neverlose 5.4 [Debug Mode]"
			local client_version = common.get_product_version()
			local username = common.get_username()
			fps = displayed_fps
			local connected = (globals.is_in_game or globals.is_connected)
			local info = connected and "info: " .. utils.net_channel():get_server_info().address .. " | " .. utils.net_channel():get_server_info().name or ""

			local text = string.format("%s \a4FFF1EFFClient version: %s\aDEFAULT %s FPS: %s - %s %s",
									product_name,
									client_version,
									username,
									fps,
									time,
									info)

			render.text(1, vector(5, h - 15), color(255), nil, text)
		end

		events.render:set(function()
			items_visible()
			render_elements()
			debug_watermark()
		end)

			
	end

	local HDR_bloom do
		-- Reworked, previous code is pretty BS and useless. Too much for doing
		local enabled = ref.ambient:switch("HDR Bloom")
		local group = enabled:create()
		group:label("\a{Link Active}" .. ui.get_icon("triangle-exclamation") .. " It may result in irreversible changes.")
		local scale = group:slider("Scale", -1, 500, -1, 0.01, function (e) if e == -1 then return "Off" end end)
		local exposure = group:slider("Exposure", -1, 2000, -1, 0.001, function (e) if e == -1 then return "Off" end end)
		local model_ambient = group:slider("Model ambient", -1, 1000, -1, 0.05, function (e) if e == -1 then return "Off" end end)
        

		local init = function ()

            local tone_map_controllers = entity.get_entities("CEnvTonemapController")

			for i = 1, #tone_map_controllers do
				local controller = tone_map_controllers[i]

				-- can't set 0, it will cause auto HDR bloom and that is we don't wanna see it.
				controller.m_bUseCustomBloomScale = 1
				controller.m_bUseCustomAutoExposureMin = 1
				controller.m_bUseCustomAutoExposureMax = 1

				-- Bloom
				controller.m_flCustomBloomScale = ((scale:get() ~= -1) and enabled:get()) and scale:get() * 0.01 or 0

				-- Exposure
				controller.m_flCustomAutoExposureMin = exposure:get() ~= -1 and enabled:get() and math.max(0.0000, exposure:get()*0.001) or 1.5
				controller.m_flCustomAutoExposureMax = exposure:get() ~= -1 and enabled:get() and math.max(0.0000, exposure:get()*0.001) or 1.5

				-- Ambient
				local ambient_min = ((model_ambient:get() ~= -1) and enabled:get()) and model_ambient:get()*0.05 or 0.05
				cvar.r_modelAmbientMin:float(ambient_min, true)
			end
			
		end

		--events.createmove:set(init)
	end

	local events_sound do
		local open_explorer = function (path)
			local startup_info = ffi.new("STARTUPINFOA")
			local process_info = ffi.new("PROCESS_INFORMATION")
			local command_line = ffi.new("char[?]", #path + 1, path)

			startup_info.length = ffi.sizeof(startup_info)

			local success = ffi.C.CreateProcessA(
				nil,
				command_line,
				nil,
				nil,
				false,
				0,
				nil,
				nil,
				startup_info,
				process_info
			)

			if not success then
				error("Failed to open explorer")
			end
		end

		local PlaySound = (function()
			local PlaySound = utils.get_vfunc("engine.dll", "IEngineSoundClient003", 12, "void*(__thiscall*)(void*, const char*, float, int, int, float)")
			return function(sound_name, volume)
				local name = sound_name:lower():find(".wav") and sound_name or ("%s.wav"):format(sound_name)
				pcall(PlaySound, name, tonumber(volume) / 100, 100, 0, 0)
			end
		end)()

		local enabled = ref.other:switch("Events sound")
		local group = enabled:create()
		local events_select = group:selectable("Events trigger", {"Missed shots", "Taser kill", "Knife kill", "Bomb planted", "Bomb defused", "Exploits charged"})
		group:label("\a{Link Active}Put files in csgo/sounds folder and type file name")
		local only_me = group:switch("Only localplayer plant/defuse")
		local file = {
			missed = group:input("Missed shots"),
			taser = group:input("Taser kill"),
			knife = group:input("Knife kill"),
			planted = group:input("Bomb planted"),
			defused = group:input("Bomb defused"),
			charged = group:input("Exploits charged"),
		}
		local volume = group:slider("Volume", 0, 100, 70)
		local open_folder = group:button("Open sounds folder", function() open_explorer("C:\\Windows\\explorer.exe " .. common.get_game_directory() .. "\\sound") end, true)

		local last_charge = false
		local last_one = false

		local items_visible = function ()
			only_me:visibility(events_select:get("Bomb planted") or events_select:get("Bomb defused"))

			file.missed:visibility(events_select:get("Missed shots"))
			file.taser:visibility(events_select:get("Taser kill"))
			file.knife:visibility(events_select:get("Knife kill"))
			file.planted:visibility(events_select:get("Bomb planted"))
			file.defused:visibility(events_select:get("Bomb defused"))
			file.charged:visibility(events_select:get("Exploits charged"))
		end

		local main = function()
			-- Each event have own function and callback
			local missed_shots = function (event)
				local missed = event.state ~= nil
				if enabled:get() and missed and events_select:get("Missed shots") then
					PlaySound(file.missed:get(), volume:get())
				end
			end

			local taser_kill = function (event)
				local localplayer = localplayer_.ent
				if not localplayer then return end

				if entity.get(event.attacker, true) ~= localplayer then
				return end
				
				if event.weapon ~= "taser" then return end

				if events_select:get("Taser kill") then
					PlaySound(file.taser:get(), volume:get())
				end
			end

			local knife_kill = function (event)
				local localplayer = localplayer_.ent
				if not localplayer then return end

				if entity.get(event.attacker, true) ~= localplayer then
				return end
				
				--print_pro(localplayer:get_player_weapon():get_weapon_info().weapon_type)
				local is_knife = localplayer:get_player_weapon():get_weapon_info().weapon_type == 0
				-- weapon_type is number class, 0 is knives class

				if not is_knife then return end

				if events_select:get("Knife kill") then
				    PlaySound(file.knife:get(), volume:get())
				end
			end

			local bomb_planted = function (event)
				local who_planted = entity.get(event.userid, true)
				
				if events_select:get("Bomb planted") then
					if only_me:get() then
						if who_planted == localplayer then
							PlaySound(file.planted:get(), volume:get())
						end
					else
						PlaySound(file.planted:get(), volume:get())
					end
				end
			end

			local bomb_defused = function (event) -- different event
				local who_defused = entity.get(event.userid, true)
				
				if events_select:get("Bomb defused") then
					if only_me:get() then
						if who_defused == localplayer then
							PlaySound(file.defused:get(), volume:get())
						end
					else
						PlaySound(file.defused:get(), volume:get())
					end
				end
			end

			local exploits_charge = function ()

				local charge_state = rage.exploit:get()

				if events_select:get("Exploits charged") then
					if charge_state == 1 then
						if not last_charge then
							PlaySound(file.charged:get(), volume:get())
							last_charge = true
						end
					else
						last_charge = false
					end
				end
			end

			events.aim_ack:set(missed_shots)
			events.player_hurt:set(taser_kill)
			events.player_hurt:set(knife_kill)
			events.bomb_planted:set(bomb_planted)
			events.bomb_defused:set(bomb_defused)
			events.createmove:set(exploits_charge)
		end

		main()
		events.render:set(items_visible)
	end

	local indicators do
		local drop_font = (function ()
		    local smallest_pixel_7 = [[AAEAAAAMAIAAAwBAT1MvMmSz/H0AAAFIAAAAYFZETVhoYG/3AAAGmAAABeBjbWFwel+AIwAADHgAAAUwZ2FzcP//AAEAAGP4AAAACGdseWa90hIhAAARqAAARRRoZWFk/hqSzwAAAMwAAAA2aGhlYQegBbsAAAEEAAAAJGhtdHhmdgAAAAABqAAABPBsb2Nh73HeDAAAVrwAAAJ6bWF4cAFBADMAAAEoAAAAIG5hbWX/R4pVAABZOAAABC1wb3N0fPqooAAAXWgAAAaOAAEAAAABAAArGZw2Xw889QAJA+gAAAAAzSamLgAAAADNJqljAAD/OASwAyAAAAAJAAIAAAAAAAAAAQAAAu7/BgAABRQAAABkBLAAAQAAAAAAAAAAAAAAAAAAATwAAQAAATwAMgAEAAAAAAABAAAAAAAAAAAAAAAAAAAAAAADAfMBkAAFAAACvAKKAAD/nAK8AooAAAD6ADIA+gAAAgAAAAAAAAAAAIAAAi8AAAAKAAAAAAAAAABQWVJTAEAAICEiAu7/BgAAAyAAyAAAAAUAAAAAAPoB9AAAACAAAAH0AAAAAAAAAfQAAAH0AAACWAAAAlgAAAJYAAAAyAAAAS0AAAEtAAABkAAAAZAAAAEsAAABkAAAAMgAAAJYAAAB9AAAAZAAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAMgAAAEsAAABkAAAAZAAAAGQAAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAZAAAAH0AAAB9AAAAfQAAAJYAAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAABkAAAAfQAAAGQAAACWAAAAfQAAAGQAAAB9AAAASwAAAJYAAABLAAAAlgAAAH0AAABLAAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAABkAAAAfQAAAH0AAAB9AAAAlgAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAGQAAAB9AAAAZAAAAJYAAAB9AAAAZAAAAH0AAABkAAAAMgAAAGQAAAB9AAAAlgAAAH0AAABLAAAAfQAAAJYAAACWAAAAZAAAAGQAAACWAAAAyAAAAJYAAABkAAAAlgAAAH0AAACWAAAAZAAAAJYAAABLAAAASwAAAJYAAACWAAAASwAAAGQAAAB9AAAA4QAAAJYAAABkAAAAlgAAAH0AAACWAAAAZAAAAGQAAABkAAAAfQAAAH0AAAB9AAAAMgAAAH0AAAB9AAAAyAAAAH0AAACvAAAAfQAAAEsAAADIAAAAZAAAAGQAAABkAAAAZAAAAGQAAAB9AAAAlgAAAJYAAAAyAAAAfQAAAK8AAAB9AAAArwAAAH0AAAB9AAAAfQAAAGQAAAB9AAAAfQAAAH0AAAB9AAAAlgAAAH0AAACWAAAAfQAAAH0AAAB9AAAAfQAAAH0AAACWAAAAfQAAAH0AAAB9AAAAfQAAAH0AAABkAAAAfQAAAJYAAAB9AAAAlgAAAH0AAACWAAAArwAAAJYAAACvAAAAfQAAAH0AAACWAAAAfQAAAH0AAAB9AAAAfQAAAH0AAACWAAAAfQAAAJYAAAB9AAAAfQAAAH0AAAB9AAAAfQAAAJYAAAB9AAAAfQAAAH0AAAB9AAAAfQAAAGQAAAB9AAAAlgAAAH0AAACWAAAAfQAAAJYAAACvAAAAlgAAAK8AAAB9AAAAfQAAAJYAAAB9AAAAfQAAAH0AAAAyAAAAlgAAAH0AAABkAAAAZAAAAH0AAAB9AAAAfQAAAEsAAABkAAAAZAAAAH0AAAFFAAABRQAAAUUAAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAlgAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAZAAAAGQAAABkAAAAZAAAAJYAAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAABkAAAAlgAAAH0AAAB9AAAAfQAAAH0AAABkAAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAACWAAAAfQAAAH0AAAB9AAAAfQAAAH0AAABkAAAAZAAAAGQAAABkAAAAlgAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAGQAAACWAAAAfQAAAH0AAAB9AAAAfQAAAGQAAAB9AAAAZAAAAJYAAACWAAAAfQAAAH0AAABkAAAAfQAAAH0AAAB9AAAAZAAAAH0AAACWAAAAMgAAAGQAAAAAAABAAEBAQEBAAwA+Aj/AAgAB//+AAkACP/+AAoACP/+AAsACf/9AAwACv/9AA0AC//9AA4ADP/9AA8ADP/9ABAADf/8ABEADv/8ABIAD//8ABMAEP/8ABQAEP/8ABUAEf/7ABYAEv/7ABcAE//7ABgAFP/7ABkAFP/7ABoAFf/6ABsAFv/6ABwAF//6AB0AGP/6AB4AGP/6AB8AGf/5ACAAGv/5ACEAG//5ACIAHP/5ACMAHP/5ACQAHf/4ACUAHv/4ACYAH//4ACcAIP/4ACgAIP/4ACkAIf/3ACoAIv/3ACsAI//3ACwAJP/3AC0AJP/3AC4AJf/2AC8AJv/2ADAAJ//2ADEAKP/2ADIAKP/2ADMAKf/1ADQAKv/1ADUAK//1ADYALP/1ADcALP/1ADgALf/0ADkALv/0ADoAL//0ADsAMP/0ADwAMP/0AD0AMf/zAD4AMv/zAD8AM//zAEAANP/zAEEANP/zAEIANf/yAEMANv/yAEQAN//yAEUAOP/yAEYAOP/yAEcAOf/xAEgAOv/xAEkAO//xAEoAPP/xAEsAPP/xAEwAPf/wAE0APv/wAE4AP//wAE8AQP/wAFAAQP/wAFEAQf/vAFIAQv/vAFMAQ//vAFQARP/vAFUARP/vAFYARf/uAFcARv/uAFgAR//uAFkASP/uAFoASP/uAFsASf/tAFwASv/tAF0AS//tAF4ATP/tAF8ATP/tAGAATf/sAGEATv/sAGIAT//sAGMAUP/sAGQAUP/sAGUAUf/rAGYAUv/rAGcAU//rAGgAVP/rAGkAVP/rAGoAVf/qAGsAVv/qAGwAV//qAG0AWP/qAG4AWP/qAG8AWf/pAHAAWv/pAHEAW//pAHIAXP/pAHMAXP/pAHQAXf/oAHUAXv/oAHYAX//oAHcAYP/oAHgAYP/oAHkAYf/nAHoAYv/nAHsAY//nAHwAZP/nAH0AZP/nAH4AZf/mAH8AZv/mAIAAZ//mAIEAaP/mAIIAaP/mAIMAaf/lAIQAav/lAIUAa//lAIYAbP/lAIcAbP/lAIgAbf/kAIkAbv/kAIoAb//kAIsAcP/kAIwAcP/kAI0Acf/jAI4Acv/jAI8Ac//jAJAAdP/jAJEAdP/jAJIAdf/iAJMAdv/iAJQAd//iAJUAeP/iAJYAeP/iAJcAef/hAJgAev/hAJkAe//hAJoAfP/hAJsAfP/hAJwAff/gAJ0Afv/gAJ4Af//gAJ8AgP/gAKAAgP/gAKEAgf/fAKIAgv/fAKMAg//fAKQAhP/fAKUAhP/fAKYAhf/eAKcAhv/eAKgAh//eAKkAiP/eAKoAiP/eAKsAif/dAKwAiv/dAK0Ai//dAK4AjP/dAK8AjP/dALAAjf/cALEAjv/cALIAj//cALMAkP/cALQAkP/cALUAkf/bALYAkv/bALcAk//bALgAlP/bALkAlP/bALoAlf/aALsAlv/aALwAl//aAL0AmP/aAL4AmP/aAL8Amf/ZAMAAmv/ZAMEAm//ZAMIAnP/ZAMMAnP/ZAMQAnf/YAMUAnv/YAMYAn//YAMcAoP/YAMgAoP/YAMkAof/XAMoAov/XAMsAo//XAMwApP/XAM0ApP/XAM4Apf/WAM8Apv/WANAAp//WANEAqP/WANIAqP/WANMAqf/VANQAqv/VANUAq//VANYArP/VANcArP/VANgArf/UANkArv/UANoAr//UANsAsP/UANwAsP/UAN0Asf/TAN4Asv/TAN8As//TAOAAtP/TAOEAtP/TAOIAtf/SAOMAtv/SAOQAt//SAOUAuP/SAOYAuP/SAOcAuf/RAOgAuv/RAOkAu//RAOoAvP/RAOsAvP/RAOwAvf/QAO0Avv/QAO4Av//QAO8AwP/QAPAAwP/QAPEAwf/PAPIAwv/PAPMAw//PAPQAxP/PAPUAxP/PAPYAxf/OAPcAxv/OAPgAx//OAPkAyP/OAPoAyP/OAPsAyf/NAPwAyv/NAP0Ay//NAP4AzP/NAP8AzP/NAAAAAwAAAAMAAAOoAAEAAAAAABwAAwABAAACIAAGAgQAAAAAAP0AAQAAAAAAAAAAAAAAAAAAAAEAAgAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAMBOgE7ATkABAAFAAYABwAIAAkACgALAAwADQAOAA8AEAARABIAEwAUABUAFgAXABgAGQAaABsAHAAdAB4AHwAgACEAIgAjACQAJQAmACcAKAApACoAKwAsAC0ALgAvADAAMQAyADMANAA1ADYANwA4ADkAOgA7ADwAPQA+AD8AQABBAEIAQwBEAEUARgBHAEgASQBKAEsATABNAE4ATwBQAFEAUgBTAFQAVQBWAFcAWABZAFoAWwBcAF0AXgAAAPMA9AD2APgBAAEFAQsBEAEPAREBEwESARQBFgEYARcBGQEaARwBGwEdAR4BIAEiASEBIwElASQBKQEoASoBKwBlAI0A4ADhAIQAdACTAQ4AiwCGAHcA5wDjAAAA9QEHAAAAjgAAAAAA4gCSAAAAAAAAAAAAAADkAOoAAAEVAScA7gDfAIkAAAE2AAAAAACIAJgAZAADAO8A8gEEAS8BMAB1AHYAcgBzAHAAcQEmAAABLgEzAAAAZwBqAHkAAAAAAGYAlABhAGMAaADxAPkA8AD6APcA/AD9AP4A+wECAQMAAAEBAQkBCgEIAAABNwE4AAAAAAAAAAAA6AAEAYgAAAA8ACAABAAcACMAfgCqAK4AuwD/AVMBYQF4AX4BkgLGAtwEDAQPBE8EXARfBJEgFCAaIB4gIiAmIDAgOiCsIRYhIv//AAAAIAAkAKAAqwCwALwBUgFgAXgBfQGSAsYC3AQBBA4EEARRBF4EkCATIBggHCAgICYgMCA5IKwhFiEi//8AAP/gAAD/3QAAAC//3f/R/7v/t/+k/nH+XAAAAAD8jQAAAAAAAOBiAAAAAAAA4D7gOAAA37vfgN9VAAEAPAAAAEAAAABSAAAAAAAAAAAAAAAAAAAAAABYAG4AAABuAIQAhgAAAIYAigCOAAAAAACOAAAAAAAAAAAAAwE6ATsBOQADAN8A4ADhAIEA4gCDAIQA4wCGAOQAjQCOAOUA5gDnAJIAkwCUAOgA6QDqAJgAhQBfAGAAhwCaAI8AjACAAGkAawBtAGwAfgBuAJUAbwBiAJcAmwCQAJwAmQB4AHoAfAB7AH8AfQCCAJEAcABxAGEAcgBzAGMAZQBmAHQAagB5AAQBiAAAADwAIAAEABwAIwB+AKoArgC7AP8BUwFhAXgBfgGSAsYC3AQMBA8ETwRcBF8EkSAUIBogHiAiICYgMCA6IKwhFiEi//8AAAAgACQAoACrALAAvAFSAWABeAF9AZICxgLcBAEEDgQQBFEEXgSQIBMgGCAcICAgJiAwIDkgrCEWISL//wAA/+AAAP/dAAAAL//d/9H/u/+3/6T+cf5cAAAAAPyNAAAAAAAA4GIAAAAAAADgPuA4AADfu9+A31UAAQA8AAAAQAAAAFIAAAAAAAAAAAAAAAAAAAAAAFgAbgAAAG4AhACGAAAAhgCKAI4AAAAAAI4AAAAAAAAAAAADAToBOwE5AAMA3wDgAOEAgQDiAIMAhADjAIYA5ACNAI4A5QDmAOcAkgCTAJQA6ADpAOoAmACFAF8AYACHAJoAjwCMAIAAaQBrAG0AbAB+AG4AlQBvAGIAlwCbAJAAnACZAHgAegB8AHsAfwB9AIIAkQBwAHEAYQByAHMAYwBlAGYAdABqAHkAAwAA/5wB9AJYABsAHwAjAAARMzUzNTMVMxUjFTMVMxUjFSMVIzUjNTM1IzUjBTM1IyczNSNkZGTIyGRkZGRkyMhkZAEsZGTIZGQBkGRkZGRkZGRkZGRkZGTIZGRkAAAAAwAAAAAB9AH0ABMAFwAbAAA1MzUzNTM1MzUzFSMVIxUjFSMVIxEzFSMBMxUjZGRkZGRkZGRkZGRkAZBkZGRkZGRkZGRkZGQB9GT+1GQAAAAEAAAAAAH0AfQAFwAbAB8AIwAAETM1MxUzFTMVIxUzFSM1IxUjNSM1MzUjFzM1IzUVMzUVMzUjZMhkZGRkZGTIZGRkZMjIyGRkAZBkZGRkZGRkZGRkZMhkyGRjx2QAAAABAAABLABkAfQAAwAAETMVI2RkAfTIAAABAAAAAADIAfQACwAAETM1MxUjETMVIzUjZGRkZGRkAZBkZP7UZGQAAQAAAAAAyAH0AAsAABEzFTMRIxUjNTMRI2RkZGRkZAH0ZP7UZGQBLAAAAAABAAAAZAEsAZAAEwAAETMVMzUzFSMVMxUjNSMVIzUzNSNkZGRkZGRkZGRkAZBkZGRkZGRkZGQAAAEAAABkASwBkAALAAARMzUzFTMVIxUjNSNkZGRkZGQBLGRkZGRkAAABAAD/nADIAGQABwAANTMVMxUjNSNkZGRkZGRkZAAAAAEAAADIASwBLAADAAARIRUhASz+1AEsZAAAAAABAAAAAABkAGQAAwAANTMVI2RkZGQAAAABAAAAAAH0AfQAEwAANTM1MzUzNTM1MxUjFSMVIxUjFSNkZGRkZGRkZGRkZGRkZGRkZGRkZAAAAAIAAAAAAZAB9AALAA8AABEzNTMVMxEjFSM1IzsBESNkyGRkyGRkyMgBkGRk/tRkZAEsAAABAAAAAAEsAfQACwAAETM1MxEzFSE1MzUjZGRk/tRkZAGQZP5wZGTIAAAAAAEAAAAAAZAB9AARAAARIRUzFSMVIxUhFSE1MzUzNSEBLGRkyAEs/nBkyP7UAfRkZGRkZMhkZAAAAQAAAAABkAH0ABMAABMzNSE1IRUzFSMVMxUjFSE1ITUjZMj+1AEsZGRkZP7UASzIASxkZGRkZGRkZGQAAQAAAAABkAH0AAkAABEzFTM1MxEjNSFkyGRk/tQB9MjI/gzIAAAAAAEAAAAAAZAB9AAPAAARIRUhFTMVMxUjFSE1ITUhAZD+1MhkZP7UASz+1AH0ZGRkZGRkZAACAAAAAAGQAfQADwATAAARMzUzFSMVMxUzFSMVIzUjOwE1I2TIyMhkZMhkZMjIAZBkZGRkZGRkZAAAAAABAAAAAAGQAfQADQAAESEVIxUjFSM1MzUzNSEBkGRkZGRk/tQB9MhkyMhkZAAAAAADAAAAAAGQAfQAEwAXABsAABEzNTMVMxUjFTMVIxUjNSM1MzUjFzM1IzUzNSNkyGRkZGTIZGRkZMjIyMgBkGRkZGRkZGRkZMhkZGQAAgAAAAABkAH0AA8AEwAAETM1MxUzESMVIzUzNSM1IzsBNSNkyGRkyMjIZGTIyAGQZGT+1GRkZGRkAAAAAgAAAGQAZAGQAAMABwAAETMVIxUzFSNkZGRkAZBkZGQAAAAAAgAA/5wAyAGQAAcACwAANTMVMxUjNSMRMxUjZGRkZGRkZGRkZAGQZAAAAAABAAAAAAEsAfQAEwAAETM1MzUzFSMVIxUzFTMVIzUjNSNkZGRkZGRkZGRkASxkZGRkZGRkZGQAAAIAAABkASwBkAADAAcAABEhFSEVIRUhASz+1AEs/tQBkGRkZAAAAAABAAAAAAEsAfQAEwAAETMVMxUzFSMVIxUjNTM1MzUjNSNkZGRkZGRkZGRkAfRkZGRkZGRkZGQAAAIAAAAAAZAB9AALAA8AABMzNSE1IRUzFSMVIxUzFSNkyP7UASxkZMhkZAEsZGRkZGRkZAABAAAAAAGQAfQAEQAAETM1MxUzFSM1MzUjESEVITUjZMhkyGTIASz+1GQBkGRkyGRk/tRkZAAAAAIAAAAAAZAB9AALAA8AABEzNTMVMxEjNSMVIxMzNSNkyGRkyGRkyMgBkGRk/nDIyAEsZAADAAAAAAGQAfQACwAPABMAABEhFTMVIxUzFSMVIRMVMzUDMzUjASxkZGRk/tRkyMjIyAH0ZGRkZGQBkGRj/tVkAAAAAAEAAAAAAZAB9AALAAARMzUhFSERIRUhNSNkASz+1AEs/tRkAZBkZP7UZGQAAgAAAAABkAH0AAcACwAAESEVMxEjFSE3MxEjASxkZP7UZMjIAfRk/tRkZAEsAAAAAQAAAAABkAH0AAsAABEhFSEVMxUjFSEVIQGQ/tTIyAEs/nAB9GRkZGRkAAABAAAAAAGQAfQACQAAESEVIRUzFSMVIwGQ/tTIyGQB9GRkZMgAAAAAAQAAAAABkAH0AA8AABEzNSEVIREzNSM1MxEhNSNkASz+1MhkyP7UZAGQZGT+1GRk/tRkAAEAAAAAAZAB9AALAAARMxUzNTMRIzUjFSNkyGRkyGQB9MjI/gzIyAABAAAAAAEsAfQACwAAESEVIxEzFSE1MxEjASxkZP7UZGQB9GT+1GRkASwAAAEAAAAAAZAB9AANAAARIREjFSM1IzUzFTMRIQGQZMhkZMj+1AH0/nBkZGRkASwAAAEAAAAAAZAB9AAXAAARMxUzNTM1MxUjFSMVMxUzFSM1IzUjFSNkZGRkZGRkZGRkZGQB9MhkZGRkZGRkZGTIAAABAAAAAAGQAfQABQAAETMRIRUhZAEs/nAB9P5wZAAAAAEAAAAAAfQB9AATAAARMxUzFTM1MzUzESMRIxUjNSMRI2RkZGRkZGRkZGQB9GRkZGT+DAEsZGT+1AAAAAEAAAAAAZAB9AAPAAARMxUzFTM1MxEjNSM1IxEjZGRkZGRkZGQB9GRkyP4MyGT+1AAAAAACAAAAAAGQAfQACwAPAAARMzUzFTMRIxUjNSM7AREjZMhkZMhkZMjIAZBkZP7UZGQBLAAAAgAAAAABkAH0AAkADQAAESEVMxUjFSMVIxMzNSMBLGRkyGRkyMgB9GRkZMgBLGQAAgAA/5wBkAH0AA8AEwAAETM1MxUzESMVMxUjNSM1IwEjETNkyGRkZGTIZAEsyMgBkGRk/tRkZGRkASz+1AAAAAIAAAAAAZAB9AAPABMAABEhFTMVIxUzFSM1IzUjFSMTMzUjASxkZGRkZGRkZMjIAfRkZMhkZGTIASxkAAEAAAAAAZAB9AATAAARMzUhFSEVMxUzFSMVITUhNSM1I2QBLP7UyGRk/tQBLMhkAZBkZGRkZGRkZGQAAAEAAAAAASwB9AAHAAARIRUjESMRIwEsZGRkAfRk/nABkAAAAAEAAAAAAZAB9AALAAARMxEzETMRIxUjNSNkyGRkyGQB9P5wAZD+cGRkAAAAAQAAAAABLAH0AAsAABEzETMRMxEjFSM1I2RkZGRkZAH0/nABkP5wZGQAAAABAAAAAAH0AfQAEwAAETMRMxEzETMRMxEjFSM1IxUjNSNkZGRkZGRkZGRkAfT+cAEs/tQBkP5wZGRkZAABAAAAAAGQAfQAEwAAETMVMzUzFSMVMxUjNSMVIzUzNSNkyGRkZGTIZGRkAfTIyMhkyMjIyGQAAAEAAAAAASwB9AALAAARMxUzNTMVIxEjESNkZGRkZGQB9MjIyP7UASwAAAAAAQAAAAABkAH0AA8AABEhFSMVIxUhFSE1MzUzNSEBkGTIASz+cGTI/tQB9MhkZGTIZGQAAAEAAAAAAMgB9AAHAAARMxUjETMVI8hkZMgB9GT+1GQAAQAAAAAB9AH0ABMAABEzFTMVMxUzFTMVIzUjNSM1IzUjZGRkZGRkZGRkZAH0ZGRkZGRkZGRkAAABAAAAAADIAfQABwAAETMRIzUzESPIyGRkAfT+DGQBLAAAAAABAAAAyAH0AfQAEwAAETM1MzUzFTMVMxUjNSM1IxUjFSNkZGRkZGRkZGRkASxkZGRkZGRkZGQAAAEAAAAAAZAAZAADAAA1IRUhAZD+cGRkAAEAAAEsAMgB9AAHAAARMxUzFSM1I2RkZGQB9GRkZAAAAgAAAAABkAH0AAsADwAAETM1MxUzESM1IxUjEzM1I2TIZGTIZGTIyAGQZGT+cMjIASxkAAMAAAAAAZAB9AALAA8AEwAAESEVMxUjFTMVIxUhExUzNQMzNSMBLGRkZGT+1GTIyMjIAfRkZGRkZAGQZGP+1WQAAAAAAQAAAAABkAH0AAsAABEzNSEVIREhFSE1I2QBLP7UASz+1GQBkGRk/tRkZAACAAAAAAGQAfQABwALAAARIRUzESMVITczESMBLGRk/tRkyMgB9GT+1GRkASwAAAABAAAAAAGQAfQACwAAESEVIRUzFSMVIRUhAZD+1MjIASz+cAH0ZGRkZGQAAAEAAAAAAZAB9AAJAAARIRUhFTMVIxUjAZD+1MjIZAH0ZGRkyAAAAAABAAAAAAGQAfQADwAAETM1IRUhETM1IzUzESE1I2QBLP7UyGTI/tRkAZBkZP7UZGT+1GQAAQAAAAABkAH0AAsAABEzFTM1MxEjNSMVI2TIZGTIZAH0yMj+DMjIAAEAAAAAASwB9AALAAARIRUjETMVITUzESMBLGRk/tRkZAH0ZP7UZGQBLAAAAQAAAAABkAH0AA0AABEhESMVIzUjNTMVMxEhAZBkyGRkyP7UAfT+cGRkZGQBLAAAAQAAAAABkAH0ABcAABEzFTM1MzUzFSMVIxUzFTMVIzUjNSMVI2RkZGRkZGRkZGRkZAH0yGRkZGRkZGRkZMgAAAEAAAAAAZAB9AAFAAARMxEhFSFkASz+cAH0/nBkAAAAAQAAAAAB9AH0ABMAABEzFTMVMzUzNTMRIxEjFSM1IxEjZGRkZGRkZGRkZAH0ZGRkZP4MASxkZP7UAAAAAQAAAAABkAH0AA8AABEzFTMVMzUzESM1IzUjESNkZGRkZGRkZAH0ZGTI/gzIZP7UAAAAAAIAAAAAAZAB9AALAA8AABEzNTMVMxEjFSM1IzsBESNkyGRkyGRkyMgBkGRk/tRkZAEsAAACAAAAAAGQAfQACQANAAARIRUzFSMVIxUjEzM1IwEsZGTIZGTIyAH0ZGRkyAEsZAACAAD/nAGQAfQADwATAAARMzUzFTMRIxUzFSM1IzUjASMRM2TIZGRkZMhkASzIyAGQZGT+1GRkZGQBLP7UAAAAAgAAAAABkAH0AA8AEwAAESEVMxUjFTMVIzUjNSMVIxMzNSMBLGRkZGRkZGRkyMgB9GRkyGRkZMgBLGQAAQAAAAABkAH0ABMAABEzNSEVIRUzFTMVIxUhNSE1IzUjZAEs/tTIZGT+1AEsyGQBkGRkZGRkZGRkZAAAAQAAAAABLAH0AAcAABEhFSMRIxEjASxkZGQB9GT+cAGQAAAAAQAAAAABkAH0AAsAABEzETMRMxEjFSM1I2TIZGTIZAH0/nABkP5wZGQAAAABAAAAAAEsAfQACwAAETMRMxEzESMVIzUjZGRkZGRkAfT+cAGQ/nBkZAAAAAEAAAAAAfQB9AATAAARMxEzETMRMxEzESMVIzUjFSM1I2RkZGRkZGRkZGQB9P5wASz+1AGQ/nBkZGRkAAEAAAAAAZAB9AATAAARMxUzNTMVIxUzFSM1IxUjNTM1I2TIZGRkZMhkZGQB9MjIyGTIyMjIZAAAAQAAAAABLAH0AAsAABEzFTM1MxUjESMRI2RkZGRkZAH0yMjI/tQBLAAAAAABAAAAAAGQAfQADwAAESEVIxUjFSEVITUzNTM1IQGQZMgBLP5wZMj+1AH0yGRkZMhkZAAAAQAAAAABLAH0AAsAABEzNTMVIxEzFSM1I2TIZGTIZAEsyGT+1GTIAAEAAAAAAGQB9AADAAARMxEjZGQB9P4MAAEAAAAAASwB9AALAAARMxUzFSMVIzUzESPIZGTIZGQB9MhkyGQBLAABAAAAyAGQAZAADwAAETM1MxUzNTMVIxUjNSMVI2RkZGRkZGRkASxkZGRkZGRkAAABAAAAAAH0AfQAEwAAESEVIxUzFTMVIxUjNTM1IxUjESMBLGTIZGRkZMhkZAH0ZGRkZGRkZMgBkAAAAAACAAAAAAGQAyAABQANAAARIRUhESMTMzUzFSMVIwGQ/tRkyGRkZGQB9GT+cAK8ZGRkAAAAAQAA/5wAyABkAAcAADUzFTMVIzUjZGRkZGRkZGQAAAACAAAAAAGQAyAABQANAAARIRUhESMTMzUzFSMVIwGQ/tRkyGRkZGQB9GT+cAK8ZGRkAAAAAgAA/5wB9ABkAAcADwAANTMVMxUjNSMlMxUzFSM1I2RkZGQBLGRkZGRkZGRkZGRkZAAAAAMAAAAAAfQAZAADAAcACwAANTMVIyUzFSMnMxUjZGQBkGRkyGRkZGRkZGRkAAAAAAEAAAAAASwB9AALAAARMzUzFTMVIxEjESNkZGRkZGQBkGRkZP7UASwAAAAAAQAAAAABLAH0ABMAABEzNTMVMxUjFTMVIxUjNSM1MzUjZGRkZGRkZGRkZAGQZGRkZGRkZGRkAAABAAD/nAH0AlgAGwAAETM1MzUhFSEVMxUjFTMVIxUhFSE1IzUjNTM1I2RkASz+1MjIyMgBLP7UZGRkZAGQZGRkZGRkZGRkZGRkZAAABAAAAAACvAH0ABMAFwAbAB8AADUzNTM1MzUzNTMVIxUjFSMVIxUjJTMVIzczFSMBMxUjZGRkZGRkZGRkZAGQZGTIZGT9qGRkZGRkZGRkZGRkZMjIyMgB9MgAAAACAAAAAAH0AfQADwATAAARMzUzFTMVMxUjFSMRIxEjJTM1I2TIZGRkyGRkASxkZAGQZMhkZGQBkP5wZGQAAAAAAQAAAAABLAH0ABMAABEzNTM1MxUjFSMVMxUzFSM1IzUjZGRkZGRkZGRkZAEsZGRkZGRkZGRkAAACAAAAAAH0AfQAEQAVAAARMxUzNTMVMxUzFSMVIzUjFSMlMzUjZGRkZGRkyGRkASxkZAH0yMjIZGRkyMhkZAAAAgAAAAABkAMgABcAHwAAETMVMzUzNTMVIxUjFTMVMxUjNSM1IxUjEzM1MxUjFSNkZGRkZGRkZGRkZGTIZGRkZAH0yGRkZGRkZGRkZMgCvGRkZAAAAQAAAAAB9AH0AA8AABEhFSMVMxUzFSM1IxUjESMBLGTIZGTIZGQB9GRkZMjIyAGQAAAAAAEAAP+cASwB9AALAAARMxEzETMRIxUjNSNkZGRkZGQB9P5wAZD+DGRkAAAAAQAAAAAB9AH0ABMAABEhFSMVMxUzFSMVIzUzNSMVIxEjASxkyGRkZGTIZGQB9GRkZGRkZGTIAZAAAAAAAQAAAZAAyAJYAAcAABEzNTMVIxUjZGRkZAH0ZGRkAAABAAABLADIAfQABwAAETMVMxUjNSNkZGRkAfRkZGQAAAIAAAGQAfQCWAAHAA8AABEzFTMVIzUjJTMVMxUjNSNkZGRkASxkZGRkAlhkZGRkZGRkAAACAAABLAH0AfQABwAPAAARMxUzFSM1IyUzFTMVIzUjZGRkZAEsZGRkZAH0ZGRkZGRkZAAAAQAAAMgAyAGQAAMAABEzFSPIyAGQyAAAAQAAAMgBLAEsAAMAABEhFSEBLP7UASxkAAAAAAEAAADIAZABLAADAAARIRUhAZD+cAEsZAAAAAABAAAAZAMgAfQAGQAAESEVMxUzNTM1MxEjNSMVIzUjFSMRIxEjESMBkGRkZGRkZGRkZGRkZAH0ZGRkZP5wyGRkyAEs/tQBLAACAAAAAAH0AfQADwATAAARMzUzFTMVMxUjFSMRIxEjJTM1I2TIZGRkyGRkASxkZAGQZMhkZGQBkP5wZGQAAAAAAQAAAAABLAH0ABMAABEzFTMVMxUjFSMVIzUzNTM1IzUjZGRkZGRkZGRkZAH0ZGRkZGRkZGRkAAACAAAAAAH0AfQAEQAVAAARMxUzNTMVMxUzFSMVIzUjFSMlMzUjZGRkZGRkyGRkASxkZAH0yMjIZGRkyMhkZAAAAgAAAAABkAMgABcAHwAAETMVMzUzNTMVIxUjFTMVMxUjNSM1IxUjEzM1MxUjFSNkZGRkZGRkZGRkZGTIZGRkZAH0yGRkZGRkZGRkZMgCvGRkZAAAAQAAAAAB9AH0AA8AABEhFSMVMxUzFSM1IxUjESMBLGTIZGTIZGQB9GRkZMjIyAGQAAAAAAEAAP+cASwB9AALAAARMxEzETMRIxUjNSNkZGRkZGQB9P5wAZD+DGRkAAAAAgAAAAABLAMgAAsAFwAAETMVMzUzFSMRIxEjETMVMzUzFSMVIzUjZGRkZGRkZGRkZGRkAfTIyMj+1AEsAfRkZGRkZAACAAAAAAEsAyAACwAXAAARMxUzNTMVIxEjESMRMxUzNTMVIxUjNSNkZGRkZGRkZGRkZGQB9MjIyP7UASwB9GRkZGRkAAEAAAAAAZAB9AANAAARIREjFSM1IzUzFTMRIQGQZMhkZMj+1AH0/nBkZGRkASwAAAEAAABkAZAB9AATAAARMxUzNTMVIxUzFSM1IxUjNTM1I2TIZGRkZMhkZGQB9GRkZMhkZGRkyAAAAQAAAAABkAJYAAcAABEhNTMVIREjASxk/tRkAfRkyP5wAAAAAgAAAAAAZAH0AAMABwAAETMVIxUzFSNkZGRkAfTIZMgAAAAAAgAA/5wBkAJYABMAFwAAETM1IRUhFTMVMxEjFSE1ITUjNSM7ATUjZAEs/tTIZGT+1AEsyGRkyMgB9GRkZGT+1GRkZGRkAAAAAwAAAAABkAK8AAsADwATAAARIRUhFTMVIxUhFSERMxUjJTMVIwGQ/tTIyAEs/nBkZAEsZGQB9GRkZGRkArxkZGQAAAADAAD/OAK8AlgACwAPABcAABEzNSEVMxEjFSE1IzMhESEXIRUjFTMVIWQB9GRk/gxkZAH0/gxkASzIyP7UAfRkZP2oZGQCWGRkyGQAAQAAAAABkAH0AA8AABEzNSEVIRUzFSMVIRUhNSNkASz+1MjIASz+1GQBkGRkZGRkZGQAAAIAAAAAAlgB9AATACcAABEzNTM1MxUjFSMVMxUzFSM1IzUjJTM1MzUzFSMVIxUzFTMVIzUjNSNkZGRkZGRkZGRkASxkZGRkZGRkZGRkASxkZGRkZGRkZGRkZGRkZGRkZGRkAAABAAABLAGQAfQABQAAESEVIzUhAZBk/tQB9MhkAAAAAAEAAADIAMgBLAADAAARMxUjyMgBLGQAAAQAAP84ArwCWAALAA8AHQAhAAARMzUhFTMRIxUhNSMzIREhFzMVMxUjFTMVIzUjFSM3MzUjZAH0ZGT+DGRkAfT+DGTIZGRkZGRkZGRkAfRkZP2oZGQCWGRkZGRkZGTIZAAAAAADAAAAAAEsArwACwAPABMAABEhFSMRMxUhNTMRIxEzFSM3MxUjASxkZP7UZGRkZMhkZAH0ZP7UZGQBLAEsZGRkAAAAAAIAAADIASwB9AALAA8AABEzNTMVMxUjFSM1IzsBNSNkZGRkZGRkZGQBkGRkZGRkZAAAAAACAAAAAAEsAfQACwAPAAARMzUzFTMVIxUjNSMVIRUhZGRkZGRkASz+1AGQZGRkZGTIZAAAAQAAAAABLAH0AAsAABEhFSMRMxUhNTMRIwEsZGT+1GRkAfRk/tRkZAEsAAABAAAAAAEsAfQACwAAESEVIxEzFSE1MxEjASxkZP7UZGQB9GT+1GRkASwAAAEAAAAAAZACWAAHAAARITUzFSERIwEsZP7UZAH0ZMj+cAAAAAEAAP+cAfQB9AATAAARMxEzFTM1MxEzESM1IxUjNSMVI2RkZGRkZGRkZGQB9P7UZGQBLP4MZGRkyAAAAAEAAAAAAfQB9AALAAARIRUjESMRIxEjESMB9GRkZGRkAfRk/nABkP5wASwAAQAAAMgAZAEsAAMAABEzFSNkZAEsZAAAAwAAAAABkAK8AAsADwATAAARIRUhFTMVIxUhFSERMxUjJTMVIwGQ/tTIyAEs/nBkZAEsZGQB9GRkZGRkArxkZGQAAAACAAAAAAJYAfQAEQAVAAARMxUzFTM1IRUjESM1IzUjESMBMxUjZGRkASzIZGRkZAH0ZGQB9GRkyGT+cMhk/tQBLGQAAAEAAAAAAZAB9AAPAAARMzUhFSEVMxUjFSEVITUjZAEs/tTIyAEs/tRkAZBkZGRkZGRkAAACAAAAAAJYAfQAEwAnAAARMxUzFTMVIxUjFSM1MzUzNSM1IyUzFTMVMxUjFSMVIzUzNTM1IzUjZGRkZGRkZGRkZAEsZGRkZGRkZGRkZAH0ZGRkZGRkZGRkZGRkZGRkZGRkZAAAAQAAAAABkAH0AA0AABEhESMVIzUjNTMVMxEhAZBkyGRkyP7UAfT+cGRkZGQBLAAAAQAAAAABkAH0ABMAABEzNSEVIRUzFTMVIxUhNSE1IzUjZAEs/tTIZGT+1AEsyGQBkGRkZGRkZGRkZAAAAQAAAAABkAH0ABMAABEzNSEVIRUzFTMVIxUhNSE1IzUjZAEs/tTIZGT+1AEsyGQBkGRkZGRkZGRkZAAAAwAAAAABLAK8AAsADwATAAARIRUjETMVITUzESMRMxUjNzMVIwEsZGT+1GRkZGTIZGQB9GT+1GRkASwBLGRkZAAAAAACAAAAAAGQAfQACwAPAAARMzUzFTMRIzUjFSMTMzUjZMhkZMhkZMjIAZBkZP5wyMgBLGQAAgAAAAABkAH0AAsADwAAESEVIRUzFTMVIxUhNzM1IwGQ/tTIZGT+1GTIyAH0ZGRkZGRkZAAAAAADAAAAAAGQAfQACwAPABMAABEhFTMVIxUzFSMVIRMVMzUDMzUjASxkZGRk/tRkyMjIyAH0ZGRkZGQBkGRj/tVkAAAAAAEAAAAAAZAB9AAFAAARIRUhESMBkP7UZAH0ZP5wAAAAAgAA/5wB9AH0AA0AEQAANTMRMzUzETMVIzUhFSMBIxEzZGTIZGT+1GQBLGRkZAEsZP5wyGRkAfT+1AAAAQAAAAABkAH0AAsAABEhFSEVMxUjFSEVIQGQ/tTIyAEs/nAB9GRkZGRkAAABAAAAAAH0AfQAGwAAETMVMzUzFTM1MxUjFTMVIzUjFSM1IxUjNTM1I2RkZGRkZGRkZGRkZGRkAfTIyMjIyGTIyMjIyMhkAAABAAAAAAGQAfQAEwAAEzM1ITUhFTMVIxUzFSMVITUhNSNkyP7UASxkZGRk/tQBLMgBLGRkZGRkZGRkZAABAAAAAAGQAfQADwAAETMRMzUzNTMRIzUjFSMVI2RkZGRkZGRkAfT+1GTI/gzIZGQAAAAAAgAAAAABkAK8AA8AEwAAETMRMzUzNTMRIzUjFSMVIxMzFSNkZGRkZGRkZGTIyAH0/tRkyP4MyGRkArxkAAAAAAEAAAAAAZAB9AAXAAARMxUzNTM1MxUjFSMVMxUzFSM1IzUjFSNkZGRkZGRkZGRkZGQB9MhkZGRkZGRkZGTIAAABAAAAAAGQAfQACQAAETM1IREjESMRI2QBLGTIZAGQZP4MAZD+cAAAAQAAAAAB9AH0ABMAABEzFTMVMzUzNTMRIxEjFSM1IxEjZGRkZGRkZGRkZAH0ZGRkZP4MASxkZP7UAAAAAQAAAAABkAH0AAsAABEzFTM1MxEjNSMVI2TIZGTIZAH0yMj+DMjIAAIAAAAAAZAB9AALAA8AABEzNTMVMxEjFSM1IzsBESNkyGRkyGRkyMgBkGRk/tRkZAEsAAABAAAAAAGQAfQABwAAESERIxEjESMBkGTIZAH0/gwBkP5wAAACAAAAAAGQAfQACQANAAARIRUzFSMVIxUjEzM1IwEsZGTIZGTIyAH0ZGRkyAEsZAABAAAAAAGQAfQACwAAETM1IRUhESEVITUjZAEs/tQBLP7UZAGQZGT+1GRkAAEAAAAAASwB9AAHAAARIRUjESMRIwEsZGRkAfRk/nABkAAAAAEAAAAAAZAB9AAPAAARMxUzNTMRIxUjNTM1IzUjZMhkZMjIyGQB9MjI/nBkZGRkAAMAAAAAAfQB9AAPABMAFwAAETM1IRUzFSMVIxUjNSM1IzsBNSMhIxUzZAEsZGRkZGRkZGRkASxkZAGQZGTIZGRkZMjIAAAAAAEAAAAAAZAB9AATAAARMxUzNTMVIxUzFSM1IxUjNTM1I2TIZGRkZMhkZGQB9MjIyGTIyMjIZAAAAQAA/5wB9AH0AAsAABEzETMRMxEzFSM1IWTIZGRk/nAB9P5wAZD+cMhkAAABAAAAAAGQAfQACwAAETMVMzUzESM1IzUjZMhkZMhkAfTIyP4MyGQAAQAAAAAB9AH0AAsAABEzETMRMxEzETMRIWRkZGRk/gwB9P5wAZD+cAGQ/gwAAAAAAQAA/5wCWAH0AA8AABEzETMRMxEzETMRMxUjNSFkZGRkZGRk/gwB9P5wAZD+cAGQ/nDIZAAAAAACAAAAAAH0AfQACwAPAAARMxUzFTMVIxUhESMXFTM1yMhkZP7UZMjIAfTIZGRkAZDIZGMAAwAAAAACWAH0AAkADQARAAARMxUzFTMVIxUhATMRIyUzNSNkyGRk/tQB9GRk/nDIyAH0yGRkZAH0/gxkZAAAAAIAAAAAAZAB9AAJAA0AABEzFTMVMxUjFSE3MzUjZMhkZP7UZMjIAfTIZGRkZGQAAAEAAAAAAZAB9AAPAAATMzUhNSEVMxEjFSE1ITUjZMj+1AEsZGT+1AEsyAEsZGRk/tRkZGQAAAAAAgAAAAAB9AH0ABMAFwAAETMVMzUzNTMVMxEjFSM1IzUjFSMBIxEzZGRkZGRkZGRkZAGQZGQB9MhkZGT+1GRkZMgBkP7UAAAAAgAAAAABkAH0AA8AEwAAETM1IREjNSMVIxUjNTM1IzcVMzVkASxkZGRkZGRkyAGQZP4MyGRkZMhkZGQAAgAAAAABkAH0AAsADwAAETM1MxUzESM1IxUjEzM1I2TIZGTIZGTIyAGQZGT+cMjIASxkAAIAAAAAAZAB9AALAA8AABEhFSEVMxUzFSMVITczNSMBkP7UyGRk/tRkyMgB9GRkZGRkZGQAAAAAAwAAAAABkAH0AAsADwATAAARIRUzFSMVMxUjFSETFTM1AzM1IwEsZGRkZP7UZMjIyMgB9GRkZGRkAZBkY/7VZAAAAAABAAAAAAGQAfQABQAAESEVIREjAZD+1GQB9GT+cAAAAAIAAP+cAfQB9AANABEAADUzETM1MxEzFSM1IRUjASMRM2RkyGRk/tRkASxkZGQBLGT+cMhkZAH0/tQAAAEAAAAAAZAB9AALAAARIRUhFTMVIxUhFSEBkP7UyMgBLP5wAfRkZGRkZAAAAQAAAAAB9AH0ABsAABEzFTM1MxUzNTMVIxUzFSM1IxUjNSMVIzUzNSNkZGRkZGRkZGRkZGRkZAH0yMjIyMhkyMjIyMjIZAAAAQAAAAABkAH0ABMAABMzNSE1IRUzFSMVMxUjFSE1ITUjZMj+1AEsZGRkZP7UASzIASxkZGRkZGRkZGQAAQAAAAABkAH0AA8AABEzETM1MzUzESM1IxUjFSNkZGRkZGRkZAH0/tRkyP4MyGRkAAAAAAIAAAAAAZACvAAPABMAABEzETM1MzUzESM1IxUjFSMTMxUjZGRkZGRkZGRkyMgB9P7UZMj+DMhkZAK8ZAAAAAABAAAAAAGQAfQAFwAAETMVMzUzNTMVIxUjFTMVMxUjNSM1IxUjZGRkZGRkZGRkZGRkAfTIZGRkZGRkZGRkyAAAAQAAAAABkAH0AAkAABEzNSERIxEjESNkASxkyGQBkGT+DAGQ/nAAAAEAAAAAAfQB9AATAAARMxUzFTM1MzUzESMRIxUjNSMRI2RkZGRkZGRkZGQB9GRkZGT+DAEsZGT+1AAAAAEAAAAAAZAB9AALAAARMxUzNTMRIzUjFSNkyGRkyGQB9MjI/gzIyAACAAAAAAGQAfQACwAPAAARMzUzFTMRIxUjNSM7AREjZMhkZMhkZMjIAZBkZP7UZGQBLAAAAQAAAAABkAH0AAcAABEhESMRIxEjAZBkyGQB9P4MAZD+cAAAAgAAAAABkAH0AAkADQAAESEVMxUjFSMVIxMzNSMBLGRkyGRkyMgB9GRkZMgBLGQAAQAAAAABkAH0AAsAABEzNSEVIREhFSE1I2QBLP7UASz+1GQBkGRk/tRkZAABAAAAAAEsAfQABwAAESEVIxEjESMBLGRkZAH0ZP5wAZAAAAABAAAAAAGQAfQADwAAETMVMzUzESMVIzUzNSM1I2TIZGTIyMhkAfTIyP5wZGRkZAADAAAAAAH0AfQADwATABcAABEzNSEVMxUjFSMVIzUjNSM7ATUjISMVM2QBLGRkZGRkZGRkZAEsZGQBkGRkyGRkZGTIyAAAAAABAAAAAAGQAfQAEwAAETMVMzUzFSMVMxUjNSMVIzUzNSNkyGRkZGTIZGRkAfTIyMhkyMjIyGQAAAEAAP+cAfQB9AALAAARMxEzETMRMxUjNSFkyGRkZP5wAfT+cAGQ/nDIZAAAAQAAAAABkAH0AAsAABEzFTM1MxEjNSM1I2TIZGTIZAH0yMj+DMhkAAEAAAAAAfQB9AALAAARMxEzETMRMxEzESFkZGRkZP4MAfT+cAGQ/nABkP4MAAAAAAEAAP+cAlgB9AAPAAARMxEzETMRMxEzETMVIzUhZGRkZGRkZP4MAfT+cAGQ/nABkP5wyGQAAAAAAgAAAAAB9AH0AAsADwAAETMVMxUzFSMVIREjFxUzNcjIZGT+1GTIyAH0yGRkZAGQyGRjAAMAAAAAAlgB9AAJAA0AEQAAETMVMxUzFSMVIQEzESMlMzUjZMhkZP7UAfRkZP5wyMgB9MhkZGQB9P4MZGQAAAACAAAAAAGQAfQACQANAAARMxUzFTMVIxUhNzM1I2TIZGT+1GTIyAH0yGRkZGRkAAABAAAAAAGQAfQADwAAEzM1ITUhFTMRIxUhNSE1I2TI/tQBLGRk/tQBLMgBLGRkZP7UZGRkAAAAAAIAAAAAAfQB9AATABcAABEzFTM1MzUzFTMRIxUjNSM1IxUjASMRM2RkZGRkZGRkZGQBkGRkAfTIZGRk/tRkZGTIAZD+1AAAAAIAAAAAAZAB9AAPABMAABEzNSERIzUjFSMVIzUzNSM3FTM1ZAEsZGRkZGRkZMgBkGT+DMhkZGTIZGRkAAIAAAAAAGQB9AADAAcAABEzESMRMxUjZGRkZAEs/tQB9GQAAAIAAP+cAfQCWAATABcAABEzNTM1MxUzFSMRMxUjFSM1IzUjOwERI2RkZMjIyMhkZGRkZGQBkGRkZGT+1GRkZGQBLAAAAQAAAAABkAH0ABMAABEzNTM1MxUjFTMVIxUzFSE1MzUjZGTIyGRkyP5wZGQBLGRkZGRkZGRkZAABAAAAAAEsAlgAFwAAETMVMzUzFSMVMxUjFTMVITUzNSM1MzUjZGRkZGRkZP7UZGRkZAJYyMjIZGRkZGRkZGQAAgAAAZABLAH0AAMABwAAETMVIzczFSNkZMhkZAH0ZGRkAAAAAgAAAAABkAH0AA0AEQAAEzMVMxEhNSM1MzUzNSMRMzUjZMhk/tRkZMjIyMgB9GT+cGRkZGT+1GQAAAAAAQAAAMgBkAK8ABEAABEhFTMVIxUjFSEVITUzNTM1IQEsZGTIASz+cGTI/tQCvGRkZGRkyGRkAAABAAAAyAGQArwAEwAAEzM1ITUhFTMVIxUzFSMVITUhNSNkyP7UASxkZGRk/tQBLMgB9GRkZGRkZGRkZAABAAABLADIAfQABwAAETM1MxUjFSNkZGRkAZBkZGQAAAEAAP84ASwAAAAHAAAVMzUzFSMVI8hkZMhkZGRkAAAAAQAAAMgBLAK8AAsAABEzNTMRMxUhNTM1I2RkZP7UZGQCWGT+cGRkyAAAAAACAAAAyAGQArwACwAPAAARMzUzFTMRIxUjNSM7AREjZMhkZMhkZMjIAlhkZP7UZGQBLAAAAwAA/zgEsAK8AAkAEwAnAAABMxUzNTMRIzUhATMRMxUhNTMRIwEzNTM1MzUzNTMVIxUjFSMVIxUjAyBkyGRk/tT84Mhk/tRkZAEsZGRkZGRkZGRkZAEsyMj+DMgCvP5wZGQBLP4MZGRkZGRkZGRkAAMAAP84BLACvAARABsALwAAITM1MzUhNSEVMxUjFSMVIRUhATMRMxUhNTMRIwEzNTM1MzUzNTMVIxUjFSMVIxUjAyBkyP7UASxkZMgBLP5w/ODIZP7UZGQBLGRkZGRkZGRkZGRkZGRkZGRkZAOE/nBkZAEs/gxkZGRkZGRkZGQAAwAA/zgEsAK8ABMAHQAxAAATMzUhNSEVMxUjFTMVIxUhNSE1IwUzFTM1MxEjNSElMzUzNTM1MzUzFSMVIxUjFSMVI2TI/tQBLGRkZGT+1AEsyAK8ZMhkZP7U/gxkZGRkZGRkZGRkAfRkZGRkZGRkZGRkyMj+DMhkZGRkZGRkZGRkAAAAAgAAAAABkAH0AAsADwAANTM1MxUjFSEVITUjEzMVI2TIyAEs/tRkyGRkyGRkZGRkAZBkAAMAAAAAAZADIAAHABMAFwAAETMVMxUjNSMRMzUzFTMRIzUjFSMTMzUjZGRkZGTIZGTIZGTIyAMgZGRk/tRkZP5wyMgBLGQAAAMAAAAAAZADIAAHABMAFwAAEzM1MxUjFSMHMzUzFTMRIzUjFSMTMzUjyGRkZGTIZMhkZMhkZMjIArxkZGTIZGT+cMjIASxkAAMAAAAAAZADIAALABcAGwAAETM1MxUzFSM1IxUjFTM1MxUzESM1IxUjEzM1I2TIZGTIZGTIZGTIZGTIyAK8ZGRkZGTIZGT+cMjIASxkAAAAAwAAAAABkAMgAA8AGwAfAAARMzUzFTM1MxUjFSM1IxUjFTM1MxUzESM1IxUjEzM1I2RkZGRkZGRkZMhkZMhkZMjIArxkZGRkZGRkyGRk/nDIyAEsZAAAAAQAAAAAAZACvAADAAcAEwAXAAARMxUjJTMVIwUzNTMVMxEjNSMVIxMzNSNkZAEsZGT+1GTIZGTIZGTIyAK8ZGRkyGRk/nDIyAEsZAADAAAAAAGQArwAEwAXABsAABEzNTMVMxUjFTMRIzUjFSMRMzUjOwE1Ix0BMzVkyGRkZGTIZGRkZMjIyAJYZGRkZP5wyMgBkGRkyGRjAAAAAAIAAAAAAfQB9AARABUAABEzNSEVIxUzFSMVMxUhNSMVIxMzNSNkAZDIZGTI/tRkZGRkZAGQZGRkZGRkyMgBLGQAAAAAAQAA/zgBkAH0ABMAABEzNSEVIREhFSMVIxUjNTM1IzUjZAEs/tQBLGRkyMhkZAGQZGT+1GRkZGRkZAAAAgAAAAABkAMgAAsAEwAAESEVIRUzFSMVIRUhETMVMxUjNSMBkP7UyMgBLP5wZGRkZAH0ZGRkZGQDIGRkZAAAAAIAAAAAAZADIAALABMAABEhFSEVMxUjFSEVIRMzNTMVIxUjAZD+1MjIASz+cMhkZGRkAfRkZGRkZAK8ZGRkAAACAAAAAAGQAyAACwAXAAARIRUhFTMVIxUhFSERMzUzFTMVIzUjFSMBkP7UyMgBLP5wZMhkZMhkAfRkZGRkZAK8ZGRkZGQAAAADAAAAAAGQArwACwAPABMAABEhFSEVMxUjFSEVIREzFSMlMxUjAZD+1MjIASz+cGRkASxkZAH0ZGRkZGQCvGRkZAAAAAIAAAAAASwDIAALABMAABEhFSMRMxUhNTMRIxEzFTMVIzUjASxkZP7UZGRkZGRkAfRk/tRkZAEsAZBkZGQAAAACAAAAAAEsAyAACwATAAARIRUjETMVITUzESMTMzUzFSMVIwEsZGT+1GRkZGRkZGQB9GT+1GRkASwBLGRkZAAAAgAAAAABLAMgAAsAFwAAESEVIxEzFSE1MxEjETM1MxUzFSM1IxUjASxkZP7UZGRkZGRkZGQB9GT+1GRkASwBLGRkZGRkAAAAAwAAAAABLAK8AAsADwATAAARIRUjETMVITUzESMRMxUjNzMVIwEsZGT+1GRkZGTIZGQB9GT+1GRkASwBLGRkZAAAAAACAAAAAAH0AfQACwATAAARMzUhFTMRIxUhNSM3MxUjFTMRI2QBLGRk/tRkyGRkyMgBLMhk/tRkyGRkZAEsAAAAAgAAAAABkAMgAA8AHwAAETMVMxUzNTMRIzUjNSMRIxEzNTMVMzUzFSMVIzUjFSNkZGRkZGRkZGRkZGRkZGRkAfRkZMj+DMhk/tQCvGRkZGRkZGQAAwAAAAABkAMgAAsADwAXAAARMzUzFTMRIxUjNSM7AREjAzMVMxUjNSNkyGRkyGRkyMhkZGRkZAGQZGT+1GRkASwBkGRkZAAAAwAAAAABkAMgAAsADwAXAAARMzUzFTMRIxUjNSM7AREjEzM1MxUjFSNkyGRkyGRkyMhkZGRkZAGQZGT+1GRkASwBLGRkZAAAAwAAAAABkAMgAAsADwAbAAARMzUzFTMRIxUjNSM7AREjAzM1MxUzFSM1IxUjZMhkZMhkZMjIZGTIZGTIZAGQZGT+1GRkASwBLGRkZGRkAAADAAAAAAGQAyAACwAPAB8AABEzNTMVMxEjFSM1IzsBESMDMzUzFTM1MxUjFSM1IxUjZMhkZMhkZMjIZGRkZGRkZGRkAZBkZP7UZGQBLAEsZGRkZGRkZAAABAAAAAABkAK8AAsADwATABcAABEzNTMVMxEjFSM1IzsBESMTMxUjJTMVI2TIZGTIZGTIyMhkZP7UZGQBkGRk/tRkZAEsASxkZGQAAAEAAABkASwBkAATAAARMxUzNTMVIxUzFSM1IxUjNTM1I2RkZGRkZGRkZGQBkGRkZGRkZGRkZAAAAwAAAAAB9AH0AAsAEQAXAAARMzUhFTMRIxUhNSM3MzUzNSMXFTM1IxVkASxkZP7UZGRkZMhkyGQBkGRk/tRkZGRkZMhkyGQAAgAAAAABkAMgAAsAEwAAETMRMxEzESMVIzUjETMVMxUjNSNkyGRkyGRkZGRkAfT+cAGQ/nBkZAK8ZGRkAAAAAAIAAAAAAZADIAALABMAABEzETMRMxEjFSM1IxMzNTMVIxUjZMhkZMhkyGRkZGQB9P5wAZD+cGRkAlhkZGQAAAACAAAAAAGQAyAACwAXAAARMxEzETMRIxUjNSMRMzUzFTMVIzUjFSNkyGRkyGRkyGRkyGQB9P5wAZD+cGRkAlhkZGRkZAAAAAADAAAAAAGQArwACwAPABMAABEzETMRMxEjFSM1IxEzFSMlMxUjZMhkZMhkZGQBLGRkAfT+cAGQ/nBkZAJYZGRkAAAAAAIAAAAAASwDIAALABMAABEzFTM1MxUjESMRIxMzNTMVIxUjZGRkZGRkZGRkZGQB9MjIyP7UASwBkGRkZAAAAAACAAAAAAGQAfQACwAPAAARMxUzFTMVIxUjFSMTFTM1ZMhkZMhkZMgB9GRkZGRkASxkYwAAAgAAAAABkAH0ABMAFwAAETM1MxUzFSMVMxUjFSM1MzUjFSMTMzUjZMhkZGRkZGTIZGTIyAGQZGRkZGRkZGTIASxkAAADAAAAAAGQAyAABwATABcAABEzFTMVIzUjETM1MxUzESM1IxUjEzM1I2RkZGRkyGRkyGRkyMgDIGRkZP7UZGT+cMjIASxkAAADAAAAAAGQAyAABwATABcAABMzNTMVIxUjBzM1MxUzESM1IxUjEzM1I8hkZGRkyGTIZGTIZGTIyAK8ZGRkyGRk/nDIyAEsZAADAAAAAAGQAyAACwAXABsAABEzNTMVMxUjNSMVIxUzNTMVMxEjNSMVIxMzNSNkyGRkyGRkyGRkyGRkyMgCvGRkZGRkyGRk/nDIyAEsZAAAAAMAAAAAAZADIAAPABsAHwAAETM1MxUzNTMVIxUjNSMVIxUzNTMVMxEjNSMVIxMzNSNkZGRkZGRkZGTIZGTIZGTIyAK8ZGRkZGRkZMhkZP5wyMgBLGQAAAAEAAAAAAGQArwAAwAHABMAFwAAETMVIyUzFSMFMzUzFTMRIzUjFSMTMzUjZGQBLGRk/tRkyGRkyGRkyMgCvGRkZMhkZP5wyMgBLGQAAwAAAAABkAK8ABMAFwAbAAARMzUzFTMVIxUzESM1IxUjETM1IzsBNSMdATM1ZMhkZGRkyGRkZGTIyMgCWGRkZGT+cMjIAZBkZMhkYwAAAAACAAAAAAH0AfQAEQAVAAARMzUhFSMVMxUjFTMVITUjFSMTMzUjZAGQyGRkyP7UZGRkZGQBkGRkZGRkZMjIASxkAAAAAAEAAP84AZAB9AATAAARMzUhFSERIRUjFSMVIzUzNSM1I2QBLP7UASxkZMjIZGQBkGRk/tRkZGRkZGQAAAIAAAAAAZADIAALABMAABEhFSEVMxUjFSEVIREzFTMVIzUjAZD+1MjIASz+cGRkZGQB9GRkZGRkAyBkZGQAAAACAAAAAAGQAyAACwATAAARIRUhFTMVIxUhFSETMzUzFSMVIwGQ/tTIyAEs/nDIZGRkZAH0ZGRkZGQCvGRkZAAAAgAAAAABkAMgAAsAFwAAESEVIRUzFSMVIRUhETM1MxUzFSM1IxUjAZD+1MjIASz+cGTIZGTIZAH0ZGRkZGQCvGRkZGRkAAAAAwAAAAABkAK8AAsADwATAAARIRUhFTMVIxUhFSERMxUjJTMVIwGQ/tTIyAEs/nBkZAEsZGQB9GRkZGRkArxkZGQAAAACAAAAAAEsAyAACwATAAARIRUjETMVITUzESMRMxUzFSM1IwEsZGT+1GRkZGRkZAH0ZP7UZGQBLAGQZGRkAAAAAgAAAAABLAMgAAsAEwAAESEVIxEzFSE1MxEjEzM1MxUjFSMBLGRk/tRkZGRkZGRkAfRk/tRkZAEsASxkZGQAAAIAAAAAASwDIAALABcAABEhFSMRMxUhNTMRIxEzNTMVMxUjNSMVIwEsZGT+1GRkZGRkZGRkAfRk/tRkZAEsASxkZGRkZAAAAAMAAAAAASwCvAALAA8AEwAAESEVIxEzFSE1MxEjETMVIzczFSMBLGRk/tRkZGRkyGRkAfRk/tRkZAEsASxkZGQAAAAAAgAAAAAB9AH0AAsAEwAAETM1IRUzESMVITUjNzMVIxUzESNkASxkZP7UZMhkZMjIASzIZP7UZMhkZGQBLAAAAAIAAAAAAZADIAAPAB8AABEzFTMVMzUzESM1IzUjESMRMzUzFTM1MxUjFSM1IxUjZGRkZGRkZGRkZGRkZGRkZAH0ZGTI/gzIZP7UArxkZGRkZGRkAAMAAAAAAZADIAALAA8AFwAAETM1MxUzESMVIzUjOwERIwMzFTMVIzUjZMhkZMhkZMjIZGRkZGQBkGRk/tRkZAEsAZBkZGQAAAMAAAAAAZADIAALAA8AFwAAETM1MxUzESMVIzUjOwERIxMzNTMVIxUjZMhkZMhkZMjIZGRkZGQBkGRk/tRkZAEsASxkZGQAAAMAAAAAAZADIAALAA8AGwAAETM1MxUzESMVIzUjOwERIwMzNTMVMxUjNSMVI2TIZGTIZGTIyGRkyGRkyGQBkGRk/tRkZAEsASxkZGRkZAAAAwAAAAABkAMgAAsADwAfAAARMzUzFTMRIxUjNSM7AREjAzM1MxUzNTMVIxUjNSMVI2TIZGTIZGTIyGRkZGRkZGRkZAGQZGT+1GRkASwBLGRkZGRkZGQAAAQAAAAAAZACvAALAA8AEwAXAAARMzUzFTMRIxUjNSM7AREjEzMVIyUzFSNkyGRkyGRkyMjIZGT+1GRkAZBkZP7UZGQBLAEsZGRkAAADAAAAAAEsAfQAAwAHAAsAABEhFSEXMxUjETMVIwEs/tRkZGRkZAEsZGRkAfRkAAADAAAAAAH0AfQACwARABcAABEzNSEVMxEjFSE1IzczNTM1IxcVMzUjFWQBLGRk/tRkZGRkyGTIZAGQZGT+1GRkZGRkyGTIZAACAAAAAAGQAyAACwATAAARMxEzETMRIxUjNSMRMxUzFSM1I2TIZGTIZGRkZGQB9P5wAZD+cGRkArxkZGQAAAAAAgAAAAABkAMgAAsAEwAAETMRMxEzESMVIzUjEzM1MxUjFSNkyGRkyGTIZGRkZAH0/nABkP5wZGQCWGRkZAAAAAIAAAAAAZADIAALABcAABEzETMRMxEjFSM1IxEzNTMVMxUjNSMVI2TIZGTIZGTIZGTIZAH0/nABkP5wZGQCWGRkZGRkAAAAAAMAAAAAAZACvAALAA8AEwAAETMRMxEzESMVIzUjETMVIyUzFSNkyGRkyGRkZAEsZGQB9P5wAZD+cGRkAlhkZGQAAAAAAgAAAAABLAMgAAsAEwAAETMVMzUzFSMRIxEjEzM1MxUjFSNkZGRkZGRkZGRkZAH0yMjI/tQBLAGQZGRkAAAAAAIAAAAAAZAB9AALAA8AABEzFTMVMxUjFSMVIxMVMzVkyGRkyGRkyAH0ZGRkZGQBLGRjAAADAAAAAAEsArwACwAPABMAABEzFTM1MxUjESMRIxEzFSM3MxUjZGRkZGRkZGTIZGQB9MjIyP7UASwBkGRkZAAAAgAAAAAB9AH0AA8AEwAAETM1IRUjFTMVIxUzFSE1IzsBESNkAZDIZGTI/nBkZGRkAZBkZGRkZGRkASwAAgAAAAAB9AH0AA8AEwAAETM1IRUjFTMVIxUzFSE1IzsBESNkAZDIZGTI/nBkZGRkAZBkZGRkZGRkASwAAgAAAAABkAMgABMAHwAAETM1IRUhFTMVMxUjFSE1ITUjNSMTMxUzNTMVIxUjNSNkASz+1MhkZP7UASzIZGRkZGRkZGQBkGRkZGRkZGRkZAH0ZGRkZGQAAAIAAAAAAZADIAATAB8AABEzNSEVIRUzFTMVIxUhNSE1IzUjEzMVMzUzFSMVIzUjZAEs/tTIZGT+1AEsyGRkZGRkZGRkAZBkZGRkZGRkZGQB9GRkZGRkAAADAAAAAAEsArwACwAPABMAABEzFTM1MxUjESMRIxEzFSM3MxUjZGRkZGRkZGTIZGQB9MjIyP7UASwBkGRkZAAAAgAAAAABkAMgAA8AGwAAESEVIxUjFSEVITUzNTM1IRMzFTM1MxUjFSM1IwGQZMgBLP5wZMj+1GRkZGRkZGQB9MhkZGTIZGQBkGRkZGRkAAACAAAAAAGQAyAADwAbAAARIRUjFSMVIRUhNTM1MzUhEzMVMzUzFSMVIzUjAZBkyAEs/nBkyP7UZGRkZGRkZAH0yGRkZMhkZAGQZGRkZGQAAAEAAP84AZAB9AATAAARMzUzNTMVIxUzFSMRIxUjNTMRI2RkyMhkZGRkZGQBLGRkZGRk/tRkZAEsAAAAAAEAAAEsASwB9AALAAARMzUzFTMVIzUjFSNkZGRkZGQBkGRkZGRkAAABAAABLAGQAfQADwAAETM1MxUzNTMVIxUjNSMVI2RkZGRkZGRkAZBkZGRkZGRkAAACAAAAAAH0AfQAGwAfAAARMzUzFTM1MxUzFSMVMxUjFSM1IxUjNSM1MzUjFzM1I2RkZGRkZGRkZGRkZGRkyGRkAZBkZGRkZGRkZGRkZGRkZGQAAAACAAAAAABkAfQAAwAHAAARMxEjFTMVI2RkZGQB9P7UZGQAAAACAAABLAEsAfQAAwAHAAARMxUjNzMVI2RkyGRkAfTIyMgAAAAAAAAAAAAAAAAAMABYAIgAlACoAL4A2gDuAP4BDAEYATQBTgFkAYABngGyAcwB6gICAigCRgJYAm4CigKeAroC1ALwAwoDLANCA1oDcAOEA54DsgPIA+AEAAQQBC4ESARiBHoEmgS4BNYE6AT+BRQFMgVOBWQFfgWOBaoFvAXYBeQF9AYOBjAGRgZeBnQGiAaiBrYGzAbkBwQHFAcyB0wHZgd+B54HvAfaB+wIAggYCDYIUghoCIIIlgiiCLYIzgjsCQYJFgkwCUoJYgl4CZQJugnoCggKJApECm4KiAqeCrwKzArcCvYLEAscCyoLOAtcC3wLmAu4C+IL/AwSDDQMVgxuDIoMnAyuDNIM9A0aDTQNZg12DYINtA3WDfAOCg4gDjYOSA5mDnwOiA6qDswO5g8YDzAPTg9sD44PqA/ED+YP9hAUECoQThBsEIYQphDGENoQ+BEMESYROBFQEWYReBGQEbQR0BHmEfoSEhIuEkgSaBKAEpwSwBLeEvgTFBM2E0YTZBN6E54TvBPWE/YUFhQqFEgUXBR2FIgUoBS2FMgU4BUEFSAVNhVKFWIVfhWYFbgV0BXsFhAWLhYuFi4WQBZiFn4WnhawFs4W6hcIFxgXKBc+F1gXkBfQGBIYLBhQGHQYnBjIGO4ZFhk4GVYZdhmWGboZ3Bn8GhwaQBpiGoIarBrQGvQbHBtIG24bihuuG84b7hwSHDQcVBxuHJActBzYHQAdLB1SHXodnB26Hdod+h4eHkAeYB6AHqQexh7mHxAfNB9YH4AfrB/SH+ogDiAuIE4gciCUILQgziDuIQwhKiFWIYIhoiHKIfIiECIkIjwiZiJ4IooAAAAAABcBGgABAAAAAAAAAE0AAAABAAAAAAABABAATQABAAAAAAACAAcAXQABAAAAAAADAB8AZAABAAAAAAAEABAAgwABAAAAAAAFAA0AkwABAAAAAAAGAA8AoAABAAAAAAAIAAcArwABAAAAAAAJABEAtgABAAAAAAAMABkAxwABAAAAAAANACEA4AABAAAAAAASABABAQADAAEECQAAAJoBEQADAAEECQABACABqwADAAEECQACAA4BywADAAEECQADAD4B2QADAAEECQAEACACFwADAAEECQAFABoCNwADAAEECQAGAB4CUQADAAEECQAIAA4CbwADAAEECQAJACICfQADAAEECQAMADICnwADAAEECQANAEIC0UNvcHlyaWdodCAoYykgMjAxMyBieSBTdHlsZS03LiBBbGwgcmlnaHRzIHJlc2VydmVkLiBodHRwOi8vd3d3LnN0eWxlc2V2ZW4uY29tU21hbGxlc3QgUGl4ZWwtN1JlZ3VsYXJTdHlsZS03OiBTbWFsbGVzdCBQaXhlbC03OiAyMDEzU21hbGxlc3QgUGl4ZWwtN1ZlcnNpb24gMS4wMDBTbWFsbGVzdFBpeGVsLTdTdHlsZS03U2l6ZW5rbyBBbGV4YW5kZXJodHRwOi8vd3d3LnN0eWxlc2V2ZW4uY29tRnJlZXdhcmUgZm9yIHBlcnNvbmFsIHVzaW5nIG9ubHkuU21hbGxlc3QgUGl4ZWwtNwBDAG8AcAB5AHIAaQBnAGgAdAAgACgAYwApACAAMgAwADEAMwAgAGIAeQAgAFMAdAB5AGwAZQAtADcALgAgAEEAbABsACAAcgBpAGcAaAB0AHMAIAByAGUAcwBlAHIAdgBlAGQALgAgAGgAdAB0AHAAOgAvAC8AdwB3AHcALgBzAHQAeQBsAGUAcwBlAHYAZQBuAC4AYwBvAG0AUwBtAGEAbABsAGUAcwB0ACAAUABpAHgAZQBsAC0ANwBSAGUAZwB1AGwAYQByAFMAdAB5AGwAZQAtADcAOgAgAFMAbQBhAGwAbABlAHMAdAAgAFAAaQB4AGUAbAAtADcAOgAgADIAMAAxADMAUwBtAGEAbABsAGUAcwB0ACAAUABpAHgAZQBsAC0ANwBWAGUAcgBzAGkAbwBuACAAMQAuADAAMAAwAFMAbQBhAGwAbABlAHMAdABQAGkAeABlAGwALQA3AFMAdAB5AGwAZQAtADcAUwBpAHoAZQBuAGsAbwAgAEEAbABlAHgAYQBuAGQAZQByAGgAdAB0AHAAOgAvAC8AdwB3AHcALgBzAHQAeQBsAGUAcwBlAHYAZQBuAC4AYwBvAG0ARgByAGUAZQB3AGEAcgBlACAAZgBvAHIAIABwAGUAcgBzAG8AbgBhAGwAIAB1AHMAaQBuAGcAIABvAG4AbAB5AC4AAAAAAgAAAAAAAP+1ADIAAAAAAAAAAAAAAAAAAAAAAAAAAAE8AAABAgACAAMABwAIAAkACgALAAwADQAOAA8AEAARABIAEwAUABUAFgAXABgAGQAaABsAHAAdAB4AHwAgACEAIgAjACQAJQAmACcAKAApACoAKwAsAC0ALgAvADAAMQAyADMANAA1ADYANwA4ADkAOgA7ADwAPQA+AD8AQABBAEIAQwBEAEUARgBHAEgASQBKAEsATABNAE4ATwBQAFEAUgBTAFQAVQBWAFcAWABZAFoAWwBcAF0AXgBfAGAAYQEDAQQAxAEFAMUAqwCCAMIBBgDGAQcAvgEIAQkBCgELAQwAtgC3ALQAtQCHALIAswCMAQ0AvwEOAQ8BEAERARIBEwEUAL0BFQDoAIYBFgCLARcAqQCkARgAigEZAIMAkwEaARsBHACXAIgBHQEeAR8BIACqASEBIgEjASQBJQEmAScBKAEpASoBKwEsAS0BLgEvATABMQEyATMBNAE1ATYBNwE4ATkBOgE7ATwBPQE+AT8BQAFBAUIBQwFEAUUBRgFHAUgBSQFKAUsBTAFNAU4BTwFQAVEBUgFTAVQBVQFWAVcBWAFZAVoBWwFcAV0BXgFfAWABYQFiAWMBZAFlAWYAowCEAIUAlgCOAJ0A8gDzAI0A3gDxAJ4A9QD0APYAogCtAMkAxwCuAGIAYwCQAGQAywBlAMgAygDPAMwAzQDOAOkAZgDTANAA0QCvAGcA8ACRANYA1ADVAGgA6wDtAIkAagBpAGsAbQBsAG4AoABvAHEAcAByAHMAdQB0AHYAdwDqAHgAegB5AHsAfQB8ALgAoQB/AH4AgACBAOwA7gC6ALAAsQDkAOUAuwDmAOcApgDYANkABgAEAAUFLm51bGwJYWZpaTEwMDUxCWFmaWkxMDA1MglhZmlpMTAxMDAERXVybwlhZmlpMTAwNTgJYWZpaTEwMDU5CWFmaWkxMDA2MQlhZmlpMTAwNjAJYWZpaTEwMTQ1CWFmaWkxMDA5OQlhZmlpMTAxMDYJYWZpaTEwMTA3CWFmaWkxMDEwOQlhZmlpMTAxMDgJYWZpaTEwMTkzCWFmaWkxMDA2MglhZmlpMTAxMTAJYWZpaTEwMDU3CWFmaWkxMDA1MAlhZmlpMTAwMjMJYWZpaTEwMDUzB3VuaTAwQUQJYWZpaTEwMDU2CWFmaWkxMDA1NQlhZmlpMTAxMDMJYWZpaTEwMDk4DnBlcmlvZGNlbnRlcmVkCWFmaWkxMDA3MQlhZmlpNjEzNTIJYWZpaTEwMTAxCWFmaWkxMDEwNQlhZmlpMTAwNTQJYWZpaTEwMTAyCWFmaWkxMDEwNAlhZmlpMTAwMTcJYWZpaTEwMDE4CWFmaWkxMDAxOQlhZmlpMTAwMjAJYWZpaTEwMDIxCWFmaWkxMDAyMglhZmlpMTAwMjQJYWZpaTEwMDI1CWFmaWkxMDAyNglhZmlpMTAwMjcJYWZpaTEwMDI4CWFmaWkxMDAyOQlhZmlpMTAwMzAJYWZpaTEwMDMxCWFmaWkxMDAzMglhZmlpMTAwMzMJYWZpaTEwMDM0CWFmaWkxMDAzNQlhZmlpMTAwMzYJYWZpaTEwMDM3CWFmaWkxMDAzOAlhZmlpMTAwMzkJYWZpaTEwMDQwCWFmaWkxMDA0MQlhZmlpMTAwNDIJYWZpaTEwMDQzCWFmaWkxMDA0NAlhZmlpMTAwNDUJYWZpaTEwMDQ2CWFmaWkxMDA0NwlhZmlpMTAwNDgJYWZpaTEwMDQ5CWFmaWkxMDA2NQlhZmlpMTAwNjYJYWZpaTEwMDY3CWFmaWkxMDA2OAlhZmlpMTAwNjkJYWZpaTEwMDcwCWFmaWkxMDA3MglhZmlpMTAwNzMJYWZpaTEwMDc0CWFmaWkxMDA3NQlhZmlpMTAwNzYJYWZpaTEwMDc3CWFmaWkxMDA3OAlhZmlpMTAwNzkJYWZpaTEwMDgwCWFmaWkxMDA4MQlhZmlpMTAwODIJYWZpaTEwMDgzCWFmaWkxMDA4NAlhZmlpMTAwODUJYWZpaTEwMDg2CWFmaWkxMDA4NwlhZmlpMTAwODgJYWZpaTEwMDg5CWFmaWkxMDA5MAlhZmlpMTAwOTEJYWZpaTEwMDkyCWFmaWkxMDA5MwlhZmlpMTAwOTQJYWZpaTEwMDk1CWFmaWkxMDA5NglhZmlpMTAwOTcNYWZpaTEwMDQ1LjAwMQ1hZmlpMTAwNDcuMDAxAAAAAAAB//8AAA==]]

			if files.read("nl\\smallest_pixel_7.ttf") == nil then
				files.write("nl\\smallest_pixel_7.ttf", base64.decode(smallest_pixel_7), true)
			end

		end)()

		local w, h = render.screen_size().x, render.screen_size().y

		local enabled = ref.other:switch("Indicators")
		local group = enabled:create()

		local crosshair = group:selectable("Crosshair", "Min. DMG", "Hit Chance", "Script Name", "Player Condition", "Maximum Desync", "Double Tap & Hide shots", "Fake Lag History", "LC Break (Defensive)")
		local script_name = group:combo("- Style", {"Better Neverlose", "Neverlose.cc", "Custom"})
		local script_name_color = script_name:color_picker({["Gradient"] = {color(55, 177, 218), color("#3C4EFFFF")}, ["Solid"] = {color(55, 177, 218)},})
		local script_name_type = group:input("\n", "Better Neverlose")
		local elements = group:selectable("\ab5e007ffGS\aDEFAULT Indicators", {"Double Tap & Hide Shots", "Fake Duck", "Fake Lag History", "Manual Yaw", "Dormant Aimbot", "Anti Defensive (AX)", "Min. DMG", "Hit Chance", "LC break (defensive)", "Slow down"})
		local gs_spectators = group:switch("\ab5e007ffGS\aDEFAULT Spectators")
		local spectators_offset = group:slider("- Y Offset", 0, h / 2, 0, "px")

		local font_path = common.get_game_directory() .. "\\..\\nl\\smallest_pixel_7.ttf"
		local font_smallest_pixel_7 = render.load_font(font_path, 10, "ao")
		local font_calibrib = render.load_font("c:/windows/fonts/calibrib.ttf", 25, "ad")
		
		local lerp_x, lerp_y = 0, 0
		local fakelag_history = {0,0,0,0,0}
		local last_choked = 0
		local current_max = 0

		local hc_is_dragging = false
		local hc_drag_off = vector(0,0)
		local dmg_is_dragging = false
		local dmg_drag_off = vector(0,0)

		local drag_pos_items = {
			hc = {
				x = group:slider("hc - x", 0, w, w / 2 - 80):visibility(false),
				y = group:slider("hc - y", 0, h, h / 2 - 20):visibility(false),
			},
			dmg = {
				x = group:slider("dmg - x", 0, w, w / 2 + 80):visibility(false),
				y = group:slider("dmg - y", 0, h, h / 2 - 20):visibility(false),
			}
		}

		local drag_active = {
			hitchance = false,
			damage = false,
		}

		local drag_pos = {
			hc = {x1 = drag_pos_items.hc.x:get(), y1 = drag_pos_items.hc.y:get(),
		            x2 = drag_pos_items.hc.x:get() + 38, y2 = drag_pos_items.hc.y:get() + 15},
			dmg = {x1 = drag_pos_items.dmg.x:get(), y1 = drag_pos_items.dmg.y:get(),
		            x2 = drag_pos_items.dmg.x:get() + 40, y2 = drag_pos_items.dmg.y:get() + 15},
		}

		local crosshair_indicator = function ()
			w, h = render.screen_size().x, render.screen_size().y

			local dt = ref.dt:get()
			local hs = ref.hs:get()

			if not enabled:get() then return end
			if #crosshair:get() == 0 then return end
			if not localplayer_.ent then return end
			
			-- math.lerp(camera_dist, thridperson:get() and distance:get() or 0, globals.frametime * 15)
			local is_scope = (localplayer_.ent and localplayer_.ent.m_bIsScoped)
			local center = is_scope and "" or "c"
			lerp_x = math.lerp(lerp_x, is_scope and 30 or 0, globals.frametime * 15)
			lerp_y = is_scope and -6 or 0

			local offset = 0
			local x, y = w/2 + lerp_x, h/2 + 80 + lerp_y

			if crosshair:get("Min. DMG") then
				local pos = {x = drag_pos_items.dmg.x:get(), y = drag_pos_items.dmg.y:get()}
				local dmg = ref.dmg:get()
				render.text(font_smallest_pixel_7, vector(pos.x + 5, pos.y), color(255, 255, 255, 255), nil, string.format("D: %s", get_dmg_text(dmg)))

				drag_pos.dmg.x1 = pos.x; drag_pos.dmg.y1 = pos.y
				drag_pos.dmg.x2 = drag_pos.dmg.x1 + 40;drag_pos.dmg.y2 = drag_pos.dmg.y1 + 15

				render.rect_outline(vector(drag_pos.dmg.x1, drag_pos.dmg.y1), vector(drag_pos.dmg.x2, drag_pos.dmg.y2), color(255,255,255, ui.get_alpha() * 255),1, 0, false)
				render.shadow(vector(drag_pos.dmg.x1, drag_pos.dmg.y1), vector(drag_pos.dmg.x2, drag_pos.dmg.y2), color(255,255,255, ui.get_alpha() * 255), 20, 0, 2)

				--@region: drag system
				local in_area = function (pos)
					--[[
					    x in [x1, x2]
						y in [y1, y2]
					]]

					return  pos.x >= drag_pos.dmg.x1 and pos.x <= drag_pos.dmg.x2 and 
					        pos.y >= drag_pos.dmg.y1 and pos.y <= drag_pos.dmg.y2
				end

				local is_menu_open = (ui.get_alpha() == 1)
				local mouse_pos = ui.get_mouse_position()
				local is_clicked = common.is_button_down(0x1)
				local mouse_in_box = in_area(mouse_pos)

				if is_menu_open then
					if is_clicked then
						if not drag_active.hitchance then
						    if not dmg_is_dragging and mouse_in_box then
						    	dmg_is_dragging = true
								drag_active.damage = true
						    	dmg_drag_off = vector(mouse_pos.x - pos.x, mouse_pos.y - pos.y)
						    end
						    
						    if dmg_is_dragging then
						    	new_x = mouse_pos.x - dmg_drag_off.x
						    	new_y = mouse_pos.y - dmg_drag_off.y

								drag_pos_items.dmg.x:set(math.floor(new_x))
								drag_pos_items.dmg.y:set(math.floor(new_y))
						    end
    
						    
						end
					else
						dmg_is_dragging = false
						drag_active.damage = false
					end
				end
				--@endregion
			end

			if crosshair:get("Hit Chance") then
				local pos = {x = drag_pos_items.hc.x:get(), y = drag_pos_items.hc.y:get()}
				local hc = ref.hc:get()
				render.text(font_smallest_pixel_7, vector(pos.x + 5, pos.y), color(255, 255, 255, 255), nil, string.format("HC: %s", hc))

				drag_pos.hc.x1 = pos.x; drag_pos.hc.y1 = pos.y
				drag_pos.hc.x2 = drag_pos.hc.x1 + 38;drag_pos.hc.y2 = drag_pos.hc.y1 + 15

				render.rect_outline(vector(drag_pos.hc.x1, drag_pos.hc.y1), vector(drag_pos.hc.x2, drag_pos.hc.y2), color(255,255,255, ui.get_alpha() * 255),1, 0, false)
				render.shadow(vector(drag_pos.hc.x1, drag_pos.hc.y1), vector(drag_pos.hc.x2, drag_pos.hc.y2), color(255,255,255, ui.get_alpha() * 255), 20, 0, 2)

				--@region: drag system
				local in_area = function (pos)
					--[[
					    x in [x1, x2]
						y in [y1, y2]
					]]

					return  pos.x >= drag_pos.hc.x1 and pos.x <= drag_pos.hc.x2 and 
					        pos.y >= drag_pos.hc.y1 and pos.y <= drag_pos.hc.y2
				end

				local is_menu_open = (ui.get_alpha() == 1)
				local mouse_pos = ui.get_mouse_position()
				local is_clicked = common.is_button_down(0x1)
				local mouse_in_box = in_area(mouse_pos)

				if is_menu_open then
					if is_clicked then
						if not drag_active.damage then
						    if not hc_is_dragging and mouse_in_box then
						    	hc_is_dragging = true
								drag_active.hitchance = true
						    	hc_drag_off = vector(mouse_pos.x - pos.x, mouse_pos.y - pos.y)
						    end
						    
						    if hc_is_dragging then
						    	new_x = mouse_pos.x - hc_drag_off.x
						    	new_y = mouse_pos.y - hc_drag_off.y

								drag_pos_items.hc.x:set(math.floor(new_x))
								drag_pos_items.hc.y:set(math.floor(new_y))
						    end
    
						    
						end
					else
						hc_is_dragging = false
						drag_active.hitchance = false
					end
				end
				--@endregion
			end

			if crosshair:get("Script Name") then
				local text = (function()

					local script_names = ({
						["Better Neverlose"] = "Better Neverlose",
						["Neverlose.cc"] = "Neverlose.cc",
						["Custom"] = script_name_type:get()
					})[script_name:get()]

					local mode, colors = script_name_color:get()

					if mode == "Gradient" then
					    script_name_text = gradient.text_animate(script_names, -2, {unpack(colors)})
					    render.text(font_smallest_pixel_7, vector(x, y + offset), color(0,255,255,255), center, script_name_text:get_animated_text())
					    script_name_text:animate()
					else
						render.text(font_smallest_pixel_7, vector(x, y + offset), colors, center, script_names)
					end
				end)()
				offset = offset + 10
			end
			if crosshair:get("Player Condition") then
				local condition_ = check_condition(localplayer_.ent) 
				local condition_state = condition_ and condition_ or "Unknown" -- Somehow some movement or action what doesn't expected will trigger nil
				render.text(font_smallest_pixel_7, vector(x, y + offset), color(255, 255, 255, 255), center, string.format("- %s -", condition_state))
				offset = offset + 10
			end
			if crosshair:get("Fake Lag History") then
				local chocked = globals.choked_commands
				
				if chocked > 0 then
					if chocked > current_max then
						current_max = chocked
					end
				else
					if last_choked > 0 and current_max > 0 then
						table.remove(fakelag_history, 1)						
						table.insert(fakelag_history, current_max)					
						current_max = 0
					end
				end

				last_choked = chocked

				render.text(font_smallest_pixel_7, vector(x, y + offset), color(255, 255, 255, 255), center, string.format("%s-%s-%s-%s-%s", unpack(fakelag_history)))
				offset = offset + 10
			end
			if crosshair:get("Maximum Desync") then
				render.text(font_smallest_pixel_7, vector(x, y + offset), color(255, 255, 255, 255), center, string.format("MAX: %.2f°", rage.antiaim:get_max_desync()))
				offset = offset + 10
			end
			if crosshair:get("Double Tap & Hide Shots") then
				
				local text = dt and "DT" or hs and "OSAA" or ""
				local color_changed = rage.exploit:get() * 255

				render.text(font_smallest_pixel_7, vector(x, y + offset), color(255, color_changed, color_changed), center, text)
				offset = (dt or hs) and (offset + 10) or offset + 0
			end
			if crosshair:get("LC Break (Defensive)") then
				if not (dt or hs) then return end
				local text = "LC Break"
				local alpha = __share_pool.defensive_ticks * 21.25
				
				render.text(font_smallest_pixel_7, vector(x, y + offset), color(0, 255, 255, alpha), center, text)
				offset = offset + 10
			end
		end

		local gs_indicator = function ()
			w, h = render.screen_size().x, render.screen_size().y

			if not enabled:get() then return end
			if #elements:get() == 0 then return end
			if not localplayer_.ent then return end

			local dt = ref.dt:get()
			local hs = ref.hs:get()

			local y = h / 2 + 80
			local next_y = y

			--[[
			    Do not use return in your sub function like:
				if not xxx:get() then return end

				it will blocked next code render
			]]
			local add_ind = function (text, color_)
				local text_long = render.measure_text(font_calibrib, nil, text)
				local offset_y = (text_long.x / 2 + 5)
				local draw_y = next_y

				render.gradient(vector(20, draw_y - 2), vector(20 + offset_y, draw_y + 25), color("#00000000"), color("#5f5f5f3d"), color("#00000000"), color("#5f5f5f3d"))
				render.gradient(vector(20 + offset_y, draw_y - 2), vector(20 + offset_y * 2, draw_y + 25), color("#5f5f5f3d"), color("#00000000"), color("#5f5f5f3d"), color("#00000000"))

				render.text(font_calibrib, vector(25, draw_y), color_, nil, text)
				next_y = draw_y + 40
			end

			-- {"Double Tap & Hide Shots", "Fake Duck", "Fake Lag History", "Manual Yaw", "Dormant Aimbot", "Anti Defensive (AX)", "Min. DMG", "Hit Chance", "LC break (defensive)", "Slow down"}
			if elements:get("Double Tap & Hide Shots") then
				if (dt) or (hs) then
				    local text = dt and "DT" or hs and "OSAA" or ""
				    local color_changed = rage.exploit:get() == 1 and color("#cccccd") or color("#ff0000")
    
				    add_ind(text, color_changed)
				end
			end
			if elements:get("Fake Duck") then
				local fd = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck"):get()
				if fd then
				    add_ind("DUCK", color("#cccccd"))
				end
			end
			if elements:get("Fake Lag History") then

				local chocked = globals.choked_commands
				
				if chocked > 0 then
					if chocked > current_max then
						current_max = chocked
					end
				else
					if last_choked > 0 and current_max > 0 then
						table.remove(fakelag_history, 1)						
						table.insert(fakelag_history, current_max)					
						current_max = 0
					end
				end

				last_choked = chocked

				add_ind(string.format("%s-%s-%s-%s-%s", unpack(fakelag_history)), color("#cccccd"))
			end
			if elements:get("Manual Yaw") then
				local manual_item = ui.find("Aimbot", "Anti Aim", "Misc", "Manual Yaw")
				local manual = get_item_value(manual_item)

				if manual ~= "None" then
				    local manual_text = ({
				    	["Left"] = "LEFT",
				    	["Backward"] = "BACK",
				    	["Right"] = "RIGHT",
				    	["Forward"] = "FORWARD",
				    	["Freestanding"] = "FS",
				    })[manual]
    
				    add_ind(manual_text, color("#cccccd"))
				end
			end
			if elements:get("Dormant Aimbot") then
				local DA = ui.find("Aimbot", "Ragebot", "Main", "Enabled", "Dormant Aimbot"):get()
				if DA then
					add_ind("DA", color("#FFD65A"))
				end
			end
			if elements:get("Anti Defensive (AX)") then
				local AX = cvar.cl_lagcompensation:int() == 0
				if AX then
					add_ind("AX", color("#FFD65A"))
				end
			end
			if elements:get("Min. DMG") then
				local dmg = ref.dmg:get()			
				add_ind(string.format("DMG: %s", dmg), color("#cccccd"))
			end
			if elements:get("Hit Chance") then
				local hc = ref.hc:get()
				add_ind(string.format("HC: %s", hc), color("#cccccd"))
			end
			if elements:get("Slow down") then
				local slowdown = localplayer_.ent["m_flVelocityModifier"]
				-- rgb(127, 189, 20)
				-- rgb(204, 204, 205)
				local r_, g_, b_ = (204-127) * slowdown, (204-189) * slowdown, (205-20) * slowdown
				if slowdown < 1 then
					add_ind(string.format("SLOW: %s%%", math.floor(slowdown * 100 + 0.5)), color(127 + r_, 189 + g_, 20 + b_))
				end
			end
			if elements:get("LC break (defensive)") then
				local color_ = __share_pool.defensive_ticks > 0 and color("#7fbd14") or color("#ff000000")
				if __share_pool.defensive_ticks > 0 then add_ind("LC", color_) end
			end
		end

		local gs_spectator_ do
			local name_list = {}

		    local main = function ()
				w, h = render.screen_size().x, render.screen_size().y
		    	if not gs_spectators:get() then return end

				local offset = 0 + spectators_offset:get()

		    	if globals.is_in_game then
		    		for _, spectators in ipairs(spectators_list) do

						-- if not name_list[spectators.name] then
						-- 	name_list[spectators.name] = {alpha = 0}
						-- end

						if spectators ~= nil then
							if spectators.is_active then
								--name_list[spectators.name].alpha = math.lerp(name_list[spectators.name].alpha, (spectators.is_active and 255 or 0), globals.frametime * 15)
								render.text(1, vector(w - 8, 5 + offset), color(255), "r", spectators.name)

								offset = offset + 14
							end
						end
		    		end
		    	end
		    end

			events.render:set(main)
		end

		local items_visible = function ()
			script_name:visibility(crosshair:get("Script Name"))
			script_name_type:visibility(crosshair:get("Script Name") and script_name:get() == "Custom")
			spectators_offset:visibility(gs_spectators:get())
		end

		events.render:set(function()
			items_visible()
			crosshair_indicator()
			gs_indicator()
		end)
	end

	local windows do

		w, h = render.screen_size().x, render.screen_size().y

		local enabled = ref.other:switch("Solus UI")
		local group = enabled:create()

		local elements = group:selectable("Elements", {"Watermark", "Keybinds", "Spectators", "Slow Down"})
		local style_color = elements:color_picker(ui.get_style("Link Active"))
		local style = group:combo("Style", {"Solus UI", "Modern"})
		local disabled_effects = group:selectable("Disabled Effects", {"Blur", "Glow"})
		local watermark_icons = group:switch("Watermark - Icons")
		local spectators_avatars = group:switch("Spectators - Avatars", true)

		-- drag_pos_items.xx.x:get()
		local drag_pos_items = {
			keybinds = {
				x = group:slider("kb - x", 0, w, 600):visibility(false),
				y = group:slider("kb - y", 0, w, 256):visibility(false),
			},
			spectators = {
				x = group:slider("st - x", 0, w, 780):visibility(false),
				y = group:slider("st - y", 0, w, 256):visibility(false),
			},
			slowdown = {
				x = group:slider("sd - x", 0, w, w/2.4):visibility(false),
				y = group:slider("sd - y", 0, w, h/8):visibility(false),
			},
		}

		local drag_active = {
			keybinds = false,
			spectators = false,
			slow_down = false,
		}
		
		local items_visible = function ()
			w, h = render.screen_size().x, render.screen_size().y

			watermark_icons:visibility(elements:get("Watermark"))
			spectators_avatars:visibility(elements:get("Spectators"))
		end

		local weight = function (x, y, w, color_, text, center, solus)
			local size = render.measure_text(1, nil, text).x

			if solus then
				render.rect(vector(x, y), vector(x + 5 + w + size, y + 20), color(20, 20, 20, 160))
				render.rect(vector(x, y), vector(x + 5 + w + size, y + 2), color_)
				local glow = not disabled_effects:get("Glow") and
							render.shadow(vector(x, y), vector(x + 5 + w + size, y + 2), color_, 10, 0, 0) or nil

				if not center then
					render.text(1, vector(x + 8, y + 4), color(255), nil, text)
				else
					local center_x = x + (5 + w + size) / 2
					render.text(1, vector(center_x, y + 10), color(255), "c", text)
				end
			else
				-- Modern
				local blur = not disabled_effects:get("Blur") and 
							render.blur(vector(x + 2, y + 2), vector(x + 3 + w + size, y + 20), 2, 255, 2)

				render.rect(vector(x + 2, y + 2), vector(x + 3 + w + size, y + 20), color(20, 20, 20, 160), 2)

				local L = render.rect(vector(x + 1 , y + 6), vector(x + 3, y + 15), color_, 2)
				local R = render.rect(vector(x + 2+ w + size , y + 6), vector(x + 4 + w + size, y + 15), color_, 2)
				local glow_l = not disabled_effects:get("Glow") and 
				                render.shadow(vector(x + 1 , y + 6), vector(x + 3, y + 15), color_, 20, 0, 2) or nil
				local glow_r = not disabled_effects:get("Glow") and 
				                render.shadow(vector(x + 2+ w + size , y + 6), vector(x + 4 + w + size, y + 15), color_, 20, 0, 2) or nil

				if not center then
					render.text(1, vector(x + 8, y + 4), color(255), nil, text)
				else
					local center_x = x + (5 + w + size) / 2
					render.text(1, vector(center_x, y + 10), color(255), "c", text)
				end
			end
        end

		local watermark do
			local cheat_name = "Neverlose.cc"
			local username = common.get_username()

			local main = function ()
				if not enabled:get() then return end
				if not elements:get("Watermark") then return end

				local get_time = common.get_system_time()
				local time = string.format("%02d:%02d:%02d", get_time.hours, get_time.minutes, get_time.seconds)

				local is_connected = globals.is_connected
				local ip_address = is_connected and utils.net_channel():get_server_info().address or ""
				local latency = is_connected and math.floor((utils.net_channel().avg_latency[1] * 1000) + 5) .. " ms" or ""

				local icons = {
					["cheat"] = watermark_icons:get() and ui.get_icon("star") .. " " or "",
					["user"] = watermark_icons:get() and ui.get_icon("user") .. " " or "",
					["ip"] = watermark_icons:get() and ui.get_icon("server") .. " " or "",
					["delay"] = watermark_icons:get() and ui.get_icon("hourglass-half") .. " " or "",
					["time"] = watermark_icons:get() and ui.get_icon("clock") .. " " or "",
				}

				local online = string.format("%s%s | %s%s | %s%s | %s%s | %s%s", icons.cheat, cheat_name, icons.user, username, icons.ip, ip_address, icons.delay, latency, icons.time, time)
				local offline = string.format("%s%s | %s%s | %s%s", icons.cheat, cheat_name, icons.user, username, icons.time, time)
				local text = is_connected and online or offline
				local size = render.measure_text(1, nil, text).x

				weight(w - 25 - size, 8, 10, style_color:get(), text, false, style:get() == "Solus UI")
			end

			events.render:set(main)
		end

		local keybinds do
			local anim = {}
			
			local drag_pos = {x1 = 598, y1 = 254, x2 = 685, y2 = 278}
			local kb_is_dragging = false
			local kb_drag_off = vector(0, 0)
			local width = 90

			local main = function()
				if not enabled:get() then return end
				if not elements:get("Keybinds") then return end

				local offset = 0
				local target_width = 90
				local size = render.measure_text(1, nil, "Keybinds").x
				local pos = {x = drag_pos_items.keybinds.x:get(), y = drag_pos_items.keybinds.y:get()}

				local binds = ui.get_binds()
				for i = 1, #binds do
					local get_name = binds[i].name
					local get_value
					if get_name == "Min. Damage" then
						get_value = get_dmg_text(binds[i].value)
					else
						get_value = (tostring(type(binds[i].value) == "boolean" and (binds[i].mode == 1 and "Hold" or "Toggle") or binds[i].value))

					end
					local value_str = string.format("[%s]", get_value)
					local value_size = render.measure_text(1, "", value_str)
					local name_size = render.measure_text(1, "", get_name)

					if not anim[get_name] then
						anim[get_name] = {alpha = 0, offset = 0}
					end

					local max_width = name_size.x + value_size.x - 10
					target_width = math.max(target_width, max_width)

					anim[get_name].alpha = (math.lerp(anim[get_name].alpha, (binds[i].active and 255 or 0), globals.frametime * 50))
					anim[get_name].offset = (math.lerp(anim[get_name].offset, (binds[i].active and offset or offset - 14), globals.frametime * 50))

					render.text(1, vector(pos.x, pos.y + 22 + anim[get_name].offset), color(255, 255, 255, anim[get_name].alpha), nil, get_name)
					render.text(1, vector(pos.x + math.floor(width + 0.5) + 50, pos.y + 22 + anim[get_name].offset), color(255, 255, 255, anim[get_name].alpha), "r", value_str)

					if anim[get_name].alpha > 1 then
					    offset = offset + 14
					end
					
				end

				width = math.lerp(width, target_width, globals.frametime * 30)
				drag_pos.x1 = pos.x;drag_pos.y1 = pos.y
				drag_pos.x2 = drag_pos.x1 + width + size + 7;drag_pos.y2 = drag_pos.y1 + 22
				
				weight(pos.x, pos.y, math.floor(width + 0.5), style_color:get(), "Keybinds", true, style:get() == "Solus UI")
				render.rect_outline(vector(drag_pos.x1, drag_pos.y1), vector(drag_pos.x2, drag_pos.y2), color(255,255,255, ui.get_alpha() * 255),1, 0, false)
				render.shadow(vector(drag_pos.x1, drag_pos.y1), vector(drag_pos.x2, drag_pos.y2), color(255,255,255, ui.get_alpha() * 255), 30, 0, 2)


				--@region: drag system
				--[[
				    Pretty messy, basically is it
				]]
				local in_area = function (pos)
					--[[
					    x in [x1, x2]
						y in [y1, y2]
					]]

					return  pos.x >= drag_pos.x1 and pos.x <= drag_pos.x2 and 
					        pos.y >= drag_pos.y1 and pos.y <= drag_pos.y2
				end

				local is_menu_open = (ui.get_alpha() == 1)
				local mouse_pos = ui.get_mouse_position()
				local is_clicked = common.is_button_down(0x1)
				local mouse_in_box = in_area(mouse_pos)

				if is_menu_open then
					if is_clicked then
						if not drag_active.spectators and not drag_active.slow_down then
						    if not kb_is_dragging and mouse_in_box then
						    	kb_is_dragging = true
								drag_active.keybinds = true
						    	kb_drag_off = vector(mouse_pos.x - pos.x, mouse_pos.y - pos.y)
						    end
						    
						    if kb_is_dragging then
						    	new_x = mouse_pos.x - kb_drag_off.x
						    	new_y = mouse_pos.y - kb_drag_off.y

								drag_pos_items.keybinds.x:set(math.floor(new_x))
								drag_pos_items.keybinds.y:set(math.floor(new_y))
						    end
    
						    
						end
					else
						kb_is_dragging = false
						drag_active.keybinds = false
					end
				end
				--@endregion

				
			end

			events.render:set(main)
		end

		local spectators do
			
			local drag_pos = {x1 = 730, y1 = 254, x2 = 812, y2 = 278}
			local st_is_dragging = false
			local st_drag_off = vector(0, 0)
			local width = 90

			local main = function()
				if not enabled:get() then return end
				if not elements:get("Spectators") then return end

				local offset = 0
				local target_width = 90
				local size = render.measure_text(1, nil, "Spectators").x
				local pos = {x = drag_pos_items.spectators.x:get(), y = drag_pos_items.spectators.y:get()}

				local avatar_offset = spectators_avatars:get() and 18 or 2
				
				if globals.is_in_game then
					local active_names = {}
					for _, spectators in ipairs(spectators_list) do
						local get_name = spectators.index
						active_names[get_name] = true
						

						if not spectators_anim[get_name] then
							spectators_anim[get_name] = {alpha = 0, offset = 0}
						end

						spectators_anim[get_name].alpha = (math.lerp(spectators_anim[get_name].alpha, (spectators.is_active and 255 or 0), globals.frametime * 30))
						spectators_anim[get_name].offset = (math.lerp(spectators_anim[get_name].offset, (spectators.is_active and offset or offset - 14), globals.frametime * 30))

						if spectators ~= nil then
							render.text(1, vector(pos.x + avatar_offset, pos.y + 22 + spectators_anim[get_name].offset), color(255, 255, 255, spectators_anim[get_name].alpha), nil, spectators.name)
							local avatar_ = spectators_avatars:get() and spectators.avatar ~= nil and
											render.texture(spectators.avatar, vector(pos.x + 2 , pos.y + 22 + spectators_anim[get_name].offset), vector(12, 12), color(255, 255, 255, spectators_anim[get_name].alpha), nil, 0) or nil

							if spectators_anim[get_name].alpha > 1 then
								offset = offset + 15
							end
						end
		    		end
					for index in pairs(spectators_anim) do
						if not active_names[index] then spectators_anim[index] = nil end
					end
				end

				width = math.lerp(width, target_width, globals.frametime * 30)
				drag_pos.x1 = pos.x;drag_pos.y1 = pos.y
				drag_pos.x2 = drag_pos.x1 + width + size + 7;drag_pos.y2 = drag_pos.y1 + 22
				
				weight(pos.x, pos.y, math.floor(width + 0.5), style_color:get(), "Spectators", true, style:get() == "Solus UI")
				render.rect_outline(vector(drag_pos.x1, drag_pos.y1), vector(drag_pos.x2, drag_pos.y2), color(255,255,255, ui.get_alpha() * 255),1, 0, false)
				render.shadow(vector(drag_pos.x1, drag_pos.y1), vector(drag_pos.x2, drag_pos.y2), color(255,255,255, ui.get_alpha() * 255), 30, 0, 2)


				--@region: drag system
				--[[
				    Pretty messy, basically is it
				]]
				local in_area = function (pos)
					--[[
					    x in [x1, x2]
						y in [y1, y2]
					]]

					return  pos.x >= drag_pos.x1 and pos.x <= drag_pos.x2 and 
					        pos.y >= drag_pos.y1 and pos.y <= drag_pos.y2
				end

				local is_menu_open = (ui.get_alpha() == 1)
				local mouse_pos = ui.get_mouse_position()
				local is_clicked = common.is_button_down(0x1)
				local mouse_in_box = in_area(mouse_pos)

				if is_menu_open then
					if is_clicked then
						if not drag_active.keybinds and not drag_active.slow_down then
						    if not st_is_dragging and mouse_in_box then
						    	st_is_dragging = true
								drag_active.spectators = true
						    	st_drag_off = vector(mouse_pos.x - pos.x, mouse_pos.y - pos.y)
						    end
						    
						    if st_is_dragging then
						    	new_x = mouse_pos.x - st_drag_off.x
						    	new_y = mouse_pos.y - st_drag_off.y

								drag_pos_items.spectators.x:set(math.floor(new_x))
								drag_pos_items.spectators.y:set(math.floor(new_y))
						    end
						end
					else
						st_is_dragging = false
						drag_active.spectators = false
					end
				end
				--@endregion
			end

			events.render:set(main)

		end

		local slow_down do
			local anim = {}
			local drag_pos = {x1 = drag_pos_items.slowdown.x:get(), y1 = drag_pos_items.slowdown.y:get(), 
			                x2 = drag_pos_items.slowdown.x:get() + 320, y2 = drag_pos_items.slowdown.y:get() + 80}
			local sd_is_dragging = false
			local sd_drag_off = vector(0, 0)
			local width = 90
			local alpha = 255
			local bg_alpha = 255

			local main = function ()
				if not enabled:get() then return end
				if not elements:get("Slow Down") then return end

				local solus = style:get() == "Solus UI"
				local pos = {x = drag_pos_items.slowdown.x:get(), y = drag_pos_items.slowdown.y:get()}

				local localplayer = localplayer_.ent
				local prop = localplayer and localplayer["m_flVelocityModifier"] or 1

				local color_ = style_color:get()

				if solus then
				    render.rect(vector(pos.x, pos.y), vector(pos.x + 320, pos.y + 80), color(20, 20, 20, bg_alpha))
				    render.rect(vector(pos.x, pos.y), vector(pos.x + 320, pos.y + 2), color(color_.r, color_.g, color_.b, alpha))
				    local glow = not disabled_effects:get("Glow") and
				    			render.shadow(vector(pos.x, pos.y), vector(pos.x + 320, pos.y + 2), color(color_.r, color_.g, color_.b, alpha), 10, 0, 0) or nil
    
				    render.text(1, vector(pos.x + 165, pos.y + 30), color(255, 255, 255, alpha), "c", ("%s Slow Down: %s%%"):format(ui.get_icon("triangle-exclamation"), math.floor(prop * 100 + .5)))
				    render.rect_outline(vector(pos.x + 30, pos.y + 50), vector(pos.x + 290, pos.y + 56), color(255,255,255,alpha), 1, 2, false)
				    render.rect(vector(pos.x + 31, pos.y + 51), vector(pos.x + 31 + 258 * prop, pos.y + 55), color(color_.r, color_.g, color_.b, alpha), 2, false)
                    -- 289 - 31 = 258
    
				    local glow = not disabled_effects:get("Glow") and
				    			render.shadow(vector(pos.x + 31, pos.y + 51), vector(pos.x + 289, pos.y + 55), color(color_.r, color_.g, color_.b, alpha), 30, 0, 2) or nil
				else
					local blur = not disabled_effects:get("Blur") and 
							render.blur(vector(pos.x + 5, pos.y + 5), vector(pos.x + 315, pos.y + 75), 2, ui.get_alpha() >= .5 and 255 or 0, 2)

					render.rect(vector(pos.x + 5, pos.y + 5), vector(pos.x + 315, pos.y + 75), color(20, 20, 20, bg_alpha), 2)
					local L = render.rect(vector(pos.x + 3, pos.y + 25), vector(pos.x + 6, pos.y + 55), color(color_.r, color_.g, color_.b, alpha), 2)
					local R = render.rect(vector(pos.x + 313, pos.y + 25), vector(pos.x + 316, pos.y + 55), color(color_.r, color_.g, color_.b, alpha), 2)
					local glow_l = not disabled_effects:get("Glow") and
								render.shadow(vector(pos.x + 3, pos.y + 25), vector(pos.x + 6, pos.y + 55), color(color_.r, color_.g, color_.b, alpha), 30, 0, 2) or nil
					local glow_r = not disabled_effects:get("Glow") and
								render.shadow(vector(pos.x + 313, pos.y + 25), vector(pos.x + 316, pos.y + 55), color(color_.r, color_.g, color_.b, alpha), 30, 0, 2) or nil

    
				    render.text(1, vector(pos.x + 162, pos.y + 30), color(255, 255, 255, alpha), "c", ("%s Slow Down: %s%%"):format(ui.get_icon("triangle-exclamation"), math.floor(prop * 100 + .5)))
				    render.rect_outline(vector(pos.x + 30, pos.y + 50), vector(pos.x + 290, pos.y + 56), color(255,255,255,alpha), 1, 2, false)
				    render.rect(vector(pos.x + 31, pos.y + 51), vector(pos.x + 31 + 258 * prop, pos.y + 55), color(color_.r, color_.g, color_.b, alpha), 2, false)
                    -- 289 - 31 = 258
    
				    local glow = not disabled_effects:get("Glow") and
				    		render.shadow(vector(pos.x + 31, pos.y + 51), vector(pos.x + 289, pos.y + 55), color(color_.r, color_.g, color_.b, alpha), 30, 0, 2) or nil
				end

				drag_pos.x1 = pos.x;drag_pos.y1 = pos.y
				drag_pos.x2 = drag_pos.x1 + 320;drag_pos.y2 = drag_pos.y1 + 80
				render.rect_outline(vector(drag_pos.x1 - 2, drag_pos.y1 - 2), vector(drag_pos.x2 + 2, drag_pos.y2 + 2), color(255,255,255, ui.get_alpha() * 255),1, 0, false)
				render.shadow(vector(drag_pos.x1 - 2, drag_pos.y1 - 2), vector(drag_pos.x2 + 2, drag_pos.y2 + 2), color(255,255,255, ui.get_alpha() * 255), 30, 0, 2)

				--@region: drag system
				local in_area = function (pos)
					--[[
					    x in [x1, x2]
						y in [y1, y2]
					]]

					return  pos.x >= drag_pos.x1 and pos.x <= drag_pos.x2 and 
					        pos.y >= drag_pos.y1 and pos.y <= drag_pos.y2
				end

				local is_menu_open = (ui.get_alpha() >= .4)
				local mouse_pos = ui.get_mouse_position()
				local is_clicked = common.is_button_down(0x1)
				local mouse_in_box = in_area(mouse_pos)

				if is_menu_open then
					if is_clicked then
						if not drag_active.spectators and not drag_active.keybinds then
						    if not sd_is_dragging and mouse_in_box then
						    	sd_is_dragging = true
								drag_active.slow_down = true
						    	sd_drag_off = vector(mouse_pos.x - pos.x, mouse_pos.y - pos.y)
						    end
						    
						    if sd_is_dragging then
						    	new_x = mouse_pos.x - sd_drag_off.x
						    	new_y = mouse_pos.y - sd_drag_off.y

								drag_pos_items.slowdown.x:set(math.floor(new_x))
								drag_pos_items.slowdown.y:set(math.floor(new_y))
						    end
    
						    
						end
					else
						sd_is_dragging = false
						drag_active.slow_down = false
					end
				end
				--@endregion
				local show_up = is_menu_open or prop < 1
				alpha = (math.lerp(alpha, (show_up and 255 or 0), globals.frametime * 50))
				bg_alpha = (math.lerp(bg_alpha, (show_up and 160 or 0), globals.frametime * 50))
			end

			events.render:set(main)
		end
		
		events.render:set(items_visible)
	end

	local materials_modifier do
		local var_flags = {
			DEBUG = 0, NO_DEBUG_OVERRIDE = 1, NO_DRAW = 2,
			USE_IN_FILLRATE_MODE = 3, VERTEXCOLOR = 4, VERTEXALPHA = 5,
			SELFILLUM = 6, ADDITIVE = 7, ALPHATEST = 8, MULTIPASS = 9,
			ZNEARER = 10, MODEL = 11, FLAT = 12, NOCULL = 13, NOFOG = 14,
			IGNOREZ = 15, DECAL = 16, ENVMAPSPHERE = 17, NOALPHAMOD = 18,
			ENVMAPCAMERASPACE = 19, BASEALPHAENVMAPMASK = 20,
			TRANSLUCENT = 21, NORMALMAPALPHAENVMAPMASK = 22,
			NEEDS_SOFTWARE_SKINNING = 23, OPAQUETEXTURE = 24,
			ENVMAPMODE = 25, SUPPRESS_DECALS = 26, HALFLAMBERT = 27,
			WIREFRAME = 28, ALLOWALPHATOCOVERAGE = 29,
			IGNORE_ALPHA_MODULATION = 30, VERTEXFOG = 31,
		}

		local var_flag_names = {}
		for name in pairs(var_flags) do
			var_flag_names[#var_flag_names + 1] = name
		end
		table.sort(var_flag_names)

		local material_paths = {
			enemies = {
				model = "neverlose/enemies/model", weapon = "neverlose/enemies/weapon",
				history = "neverlose/enemies/history", on_shot = "neverlose/enemies/onshot",
				ragdolls = "neverlose/enemies/ragdoll",
			},
			teammates = {
				model = "neverlose/teammate/model", weapon = "neverlose/teammate/weapon",
				ragdolls = "neverlose/teammate/ragdoll",
			},
			localplayer = {
				model = "neverlose/self/model", weapon = "neverlose/self/weapon",
				viewmodel = "neverlose/self/viewmodel", fake = "neverlose/self/fake",
			},
		}

		local chams_paths = {
			enemies = {
				model = {"Enemies", "Model"}, weapon = {"Enemies", "Weapon"},
				history = {"Enemies", "History"}, on_shot = {"Enemies", "On Shot"},
				ragdolls = {"Enemies", "Ragdolls"},
			},
			teammates = {
				model = {"Teammates", "Model"}, weapon = {"Teammates", "Weapon"},
				ragdolls = {"Teammates", "Ragdolls"},
			},
			localplayer = {
				model = {"Self", "Model"}, weapon = {"Self", "Weapon"},
				viewmodel = {"Self", "Viewmodel"}, fake = {"Self", "Fake"},
			},
		}

		local controls = {}
		for category, entries in pairs(chams_paths) do
			controls[category] = {}
			for name, path in pairs(entries) do
				local item = ui.find("Visuals", "Players", path[1], "Chams", path[2])
				if item ~= nil then
					controls[category][name] = item:create():listable("Var Flags", var_flag_names)
				end
			end
		end

		local function get_selected_flags(control)
			local result = {}
			for _, value in ipairs(control:get() or {}) do
				-- 5.3 returns selected indices; accept strings on newer UI builds too.
				local name = type(value) == "number" and var_flag_names[value] or value
				if var_flags[name] ~= nil then result[#result + 1] = name end
			end
			return result
		end

		local function apply_material_flags(category, name, control)
			local path = material_paths[category] and material_paths[category][name]
			if path == nil then return end

			local selected = get_selected_flags(control)
			for _, material in ipairs(materials.get_materials(path) or {}) do
				for _, flag in pairs(var_flags) do material:var_flag(flag, false) end
				for _, flag_name in ipairs(selected) do
					material:var_flag(var_flags[flag_name], true)
				end
			end
		end

		local function apply_all()
			for category, entries in pairs(controls) do
				for name, control in pairs(entries) do
					apply_material_flags(category, name, control)
				end
			end
		end

		local function reset_all()
			for _, entries in pairs(material_paths) do
				for _, path in pairs(entries) do
					for _, material in ipairs(materials.get_materials(path) or {}) do
						material:reset()
					end
				end
			end
		end

		for category, entries in pairs(controls) do
			for name, control in pairs(entries) do
				local category_ref, name_ref, control_ref = category, name, control
				control_ref:set_callback(function()
					apply_material_flags(category_ref, name_ref, control_ref)
				end, true)
			end
		end

		events.round_start:set(apply_all)
		events.shutdown:set(reset_all)
	end

    end -- Disabled visuals end, you can move this word the cover u want
	
end

local misc do
	local ref = {
		movement = ui.find("Miscellaneous", "Main", "Movement"),
		in_game = ui.find("Miscellaneous", "Main", "In-Game"),
		other = ui.find("Miscellaneous", "Main", "Other"),
	}

	local fast_fall do
		local enabled = ref.movement:switch("Fast Fall")
		
		local main = function ()
			local localplayer = localplayer_.ent
			if not localplayer then return end

			if localplayer.m_vecVelocity.z > - 480 then return end

			local x, y, z = localplayer.m_vecOrigin.x, localplayer.m_vecOrigin.y, localplayer.m_vecOrigin.z

			for a = 0, math.pi * 2, math.pi * 2 / 8 do
				local ptX, ptY = ((10 * math.cos(a)) + x), ((10 * math.sin(a)) + y)
				local trace = utils.trace_line(vector(ptX, ptY, z), vector(ptX, ptY, z - 75), localplayer)

				if trace.fraction ~= 1 then 
					rage.exploit:force_teleport()
				end
			end
		end

		events.createmove:set(main)
	end

	local clan_tag do
		local nl_clantag = ui.find("Miscellaneous", "Main", "In-Game", "Clan Tag")
		nl_clantag:visibility(false)

		local enabled = ref.in_game:switch("Clan Tag")
		local group = enabled:create()
		local style = group:combo("Style", "Neverlose", "Custom")
		local custom = group:input("\n")
		local custom_style = group:combo("- Style", {"Static", "Roll", "Sway"})
		local velocity = group:slider("- Velocity", 30, 100, 50)
		local last_clan_tag

		local items_visible = function()
			custom:visibility(style:get() == "Custom")
			custom_style:visibility(style:get() == "Custom")
			velocity:visibility(style:get() == "Custom")
		end

		local main = function ()
			if not localplayer_.ent then return end
			if not enabled:get() then nl_clantag:override(false) return end

			if style:get() == "Neverlose" then
				nl_clantag:override(true)
			else
				nl_clantag:override(false)
				local tag

				if custom_style:get() == "Static" then
					tag = custom:get()
				elseif custom_style:get() == "Roll" then
					local text = custom:get() .. "  "
					local len = #text
					local timing = globals.realtime
					local interval = 20 / velocity:get()
					local idx = math.floor((timing / interval) % len) + 1

					local head = text:sub(idx)
					local tail = text:sub(1, idx - 1)
					tag = (head .. tail):sub(1, len)
				else
					local length = #custom:get()
					local interval = math.floor(500 / 30)
					local index = math.floor(globals.tickcount / interval) % (length * 2 + 10)
			
					if index >= length then
						if index < length * 2 then
							index = length
						else
							index = length * 2 - index + 10
						end
					end

					tag = custom:get():sub(1, index)
				end

				if tag and tag ~= last_clan_tag then
					common.set_clan_tag(tag)
					last_clan_tag = tag
				end
			end
		end

		events.render:set(items_visible)
		events.createmove:set(main)
		events.shutdown:set(function()
			nl_clantag:override()
			nl_clantag:visibility(true)
			common.set_clan_tag("")
		end)
	end

	local trashtalk do
        local enabled = ref.in_game:switch("Trash Talk")
        local group = enabled:create()
        local text = group:input("\n")
        group:label("Protip: You can add \a{Link Active}%s\aDEFAULT in your text, it will add victim nickname to your message.")

        local main = function (event)
            if not enabled:get() then return end

            local target = event.target
            local ent = entity.get(target)
            if not ent then return end

            local health = ent.m_iHealth
            local nickname = target:get_name()

            if not nickname or not health then return end
            if health ~= 0 then return end

            local text_ = text:get():gsub("%%s", nickname)
        
            utils.console_exec("say " .. text_) 
        end

        events.aim_ack:set(main)
	end

    local vote_reveals do
        local enabled = ref.in_game:switch("Vote Reveals")
        local start = function (event)
            if not enabled:get() then return end

            print_pro(string.format("Vote started! ~ %s initiated by %s", event.issue, entity.get(event.initiator, true):get_name()))
        end

        local cast = function (event)
            if not enabled:get() then return end
            local voteOption = event.vote_option == 0 and "YES" or "NO"

            local user = entity.get(event.entityid)
            local userName = user:get_name()

            print_pro(("%s voted %s"):format(userName, voteOption))
        end

        events.vote_cast:set(cast)
        events.vote_started:set(start)
    end

    local modifier do
        local enabled = ref.other:selectable("Modifier", {"Force sv_cheats 1", "Bypass sv_pure", "Performance +"})
		local previous = {cheats = false, pure = false, performance = false}
        local main = function ()
			local cheats = enabled:get("Force sv_cheats 1")
			local pure = enabled:get("Bypass sv_pure")
			local performance = enabled:get("Performance +")

			if cheats ~= previous.cheats then
				if cheats then cvar["sv_cheats"]:int(1) else cvar["sv_cheats"]:int() end
				previous.cheats = cheats
			end

			if pure ~= previous.pure then
				if pure then cvar["sv_pure"]:int(0) else cvar["sv_pure"]:int() end
				previous.pure = pure
			end

			if performance ~= previous.performance then
				if performance then
					cvar["mat_queue_mode"]:int(2)
					cvar["fps_max"]:int(0)
					cvar["fps_max_menu"]:int(0)
					cvar["@panorama_disable_blur"]:int(1)
				else
					cvar["mat_queue_mode"]:int()
					cvar["fps_max"]:int()
					cvar["fps_max_menu"]:int()
					cvar["@panorama_disable_blur"]:int()
				end
				previous.performance = performance
			end
        end

        events.render:set(main)
    end

    local log_events do
		local hitgroups = {
			[0] = "body",
			[1] = "head",
			[2] = "chest",
			[3] = "stomach",
			[4] = "left arm",
			[5] = "right arm",
			[6] = "left leg",
			[7] = "right leg",
			[8] = "neck",
			[9] = "generic",
			[10] = "unknown"
		}

		local ref_orginal = ui.find("Miscellaneous", "Main", "Other", "Log Events")
		ref_orginal:visibility(false)
		ref_orginal:override({})
		events.shutdown:set(function()
			ref_orginal:override()
			ref_orginal:visibility(true)
		end)
		local enabled = ref.other:selectable("Log Events", {"Aimbot Shots", "Damage Dealt", "Purchases"})
		local group = enabled:create()
		local developer = group:switch("Legacy developer logs")
		local fired_log = group:switch("Fired shot logs")

		-- Lua is Top-down Execution, 
		-- The position of a function determines its priority, including which function is printed first.

        local fired_logs = function (event)
			if not fired_log:get() or not enabled:get("Aimbot Shots") then return end
			
			local target = event.target
			local damage = event.damage
			local hitchance = event.hitchance
			local hitgroup = hitgroups[event.hitgroup]
			local bt = event.backtrack

			local nickname = target and target:get_name() or "unk."

			local text = "Fired at %s's %s expected %s dmg ~ HC:%s%% | BT:%st"
			local f_format_text = string.format(text, nickname, hitgroup, math.floor(damage), math.floor(hitchance), bt)
			
			print(f_format_text)
			if developer:get() then
				print_dev(f_format_text)
			else
				common.add_event(f_format_text, "crosshairs")
			end
		end

		events.aim_fire:set(fired_logs)

		local missed_logs = function (event)
			if not enabled:get("Aimbot Shots") then return end
			if not state == nil then return end

			local target = event.target
			local damage = event.wanted_damage
			local hitchance = event.hitchance ~= nil and event.hitchance or 0
			local hitgroup = hitgroups[event.wanted_hitgroup]
			local bt = event.backtrack
			local spread = event.spread
			local state = event.state
			local health = target and target.m_iHealth or -1

			local nickname = target and target:get_name() or "unk."

			local text, format_text

			if state == nil then return end

			if state == "unregistered shot" then
				text = "Missed shot %s's %s due to %s (%s remaining)"
				format_text = string.format(text, nickname, hitgroup, state, health)
			else
				text = "Missed shot %s's %s due to %s (%s remaining / %s dmg expected) ~ Δ:%.2f° - HC:%s%% | BT:%st"
				format_text = string.format(text, nickname, hitgroup, state, health, math.floor(damage), spread, hitchance, bt)
			end

			print(format_text)
			if developer:get() then
				print_dev(format_text)
			else
				common.add_event(format_text, "xmark")
			end
		end

		events.aim_ack:set(missed_logs)

		local hurt_harmed = function (event)
			if not enabled:get("Damage Dealt") then return end

			local userid = event.userid
			local victim = entity.get(userid, true)
			local attacker = entity.get(event.attacker, true)

			local health = event.health
			local hitgroup = hitgroups[event.hitgroup]
			local damage = event.dmg_health

			if (attacker:get_name() == (localplayer_.ent):get_name()) then
				if victim:get_name() ~= localplayer_.ent:get_name() then
				    local h_text = "Hurt %s in the %s for %s hp (%s remaining)"
				    local h_format_text = string.format(h_text, victim:get_name(), hitgroup, damage, health)
    
				    print(h_format_text)
    
				    if developer:get() then
				    	print_dev(h_format_text)
				    else
				    	common.add_event(h_format_text, "check")
				    end
				else
					local text = string.format("You hurt yourself %s hp!", damage)
					print(text)
    
				    if developer:get() then
				    	print_dev(text)
				    else
				    	common.add_event(text, "triangle-exclamation")
				    end
				end
			end

			if victim:get_name() == localplayer_.ent:get_name() then
				local hurt_text = "Harmed by %s in the %s for %s hp"
				local format_text = string.format(hurt_text, attacker:get_name(), hitgroup, damage)

				print(format_text)

				if developer:get() then
					print_dev(format_text)
				else
					common.add_event(format_text, "triangle-exclamation")
				end
			end

		end

		events.player_hurt:set(hurt_harmed)

		local purchases = function (event)
			if not enabled:get("Purchases") then return end

			local userid = event.userid
            local nickname = entity.get(userid, true):get_name()
            local team = event.team
            local weapon = event.weapon

			local text = string.format( "%s bought %s", nickname, weapon )

			print(string.format( "\a9bf0ebff%s\aDEFAULT bought \ac0ff91ff%s", nickname, weapon ))

			if developer:get() then
                print_dev(text)
            else
                common.add_event(text, "cart-shopping")
            end
		end

		events.item_purchase:set(purchases)

    end
end

-- @region info & Plist & Premium Antiaim
local info do
	local check_update

	ui.sidebar("Better Neverlose", "star")
	local info = ui.create("Better Neverlose - Info.")
	local plist_g = ui.create("Players list")

	local open_link = function (link)
		local steam_overlay_API = panorama.SteamOverlayAPI
		local open_external_browser_url = steam_overlay_API.OpenExternalBrowserURL
		open_external_browser_url(link)
	end

	local update do
		local http = http_lib.new({
			task_interval = 0.3, -- polling intervals
			enable_debug = false, -- print http request s to the console
			timeout = 10 -- request expiration time
		})

		check_update = function ()

			local pass = (string.find(version_, "WIP", 1, true) ~= nil) or (string.find(version_, "Alpha", 1, true) ~= nil) or (string.find(version_, "Beta", 1, true) ~= nil)
			local branch = string.find(version_, "WIP", 1, true) and "WIP" 
							or string.find(version_, "Alpha", 1, true) and "Alpha" 
							or "Beta"
                

			if pass then
				print_pro(("You're using %s branch. Get updates only for Live/Release"):format(branch))
			else
				http:get("https://raw.githubusercontent.com/xXN1ckWa1k3rXx/cheat_lua/refs/heads/main/better%20neverlose/version.json", function(data)
					if data:success() and data.status == 200 and data.body then
						local data_decoded = json.parse(data.body)
						if version_ == data_decoded.version then
							print("You are using the latest version.")
							print_dev("You are using the latest version.")
						else
							print("new version available - " .. data_decoded.version)
							print_dev("new version available - " .. data_decoded.version)
						end
					elseif data:success() == false then
						print("Failed to connect github raw")
						print_dev("Failed to connect github raw")
					end
				end)
			end
		end
	end

	local icons = {
		warning = ui.get_icon("triangle-exclamation"),
		github = ui.get_icon("github"),
		user = ui.get_icon("user"),
		star = ui.get_icon("star"),
		branch = ui.get_icon("code-branch"),
		arrows_rotate = ui.get_icon("arrows-rotate"),
		user_plus = ui.get_icon("user-plus"),
		telegram = ui.get_icon("telegram"),
	}

	info:label(icons.star .. " Better Neverlose")
	info:button(icons.branch .. " " .. version_, nil, true)
	info:label(icons.user .. " Author")
	info:button("xXYu3_zH3nGL1ngXx", nil, true)
	info:label("\a{Link Active}" .. icons.warning .. " Protip: Every items from script all have tooltip.\n")

	local wip_warning = info:label("\affc400ff" .. icons.warning .. " Attention: You are using WIP \n(Work in Progress) version. \n\nSome features are under construction. \n\nRecommended to use stable release unless you're developer\n")
	local alpha_warning = info:label("\affc400ff" .. icons.warning .. " Attention: You are using Alpha version. \n\nSome features are under construction or unstable and might be crashed. \n\nRecommended to use stable release for normal users.\nPlease pay attention on console.")
	local beta_warning = info:label("\a00ffffff" .. icons.warning .. " Attention: You are using Beta version. It might be unstable and script crash often. \n\nThe beta version does not represent the final version.")

	local github = info:button(icons.github .. " Github", function () open_link("https://github.com/xXN1ckWa1k3rXx/cheat_lua") end, true)
	local get_update = info:button(icons.arrows_rotate .. " Get update", function() check_update() end, true)
	local telegram = info:button(icons.telegram .. " Telegram", function() open_link("https://t.me/xXN1ckWa1k3rXx") end , true)

	local plist do
		local list = plist_g:list("\n", {"None."})

		local options_selection = {}
		local whilelist_switches = {}
		local body_yaw_switches = {}
		local body_yaw_slider = {}
		local body_yaw_backup = {}

		local plist_ui = function ()
			local localplayer = entity.get_local_player()
			if not localplayer or not localplayer:is_alive() or ui.get_alpha() <= .4 then return end
			local players = entity.get_players(true, true)
			local plist = {}
			local previous = list:list()
			local current_count = #players
			local changed = #previous ~= current_count
			for i, player in ipairs(players) do
				if previous[i] ~= player:get_name() then changed = true break end
			end

			if changed then
				for i = 1, current_count do
					local player = players[i]
					local player_name = player:get_name()
					table.insert(plist, player_name)
					if not options_selection[player_name] then
						options_selection[player_name] = plist_g:selectable(
							"Options",
							{"Highlight", "Force Safe", "Force Body Aim"}
						):visibility(false)
					end
					if not whilelist_switches[player_name] then
						whilelist_switches[player_name] = plist_g:switch("Add to whitelist"):visibility(false)
					end
					if not body_yaw_switches[player_name] then
						body_yaw_switches[player_name] = plist_g:switch("Override Body Yaw"):visibility(false)
					end
					if not body_yaw_slider[player_name] then
						body_yaw_slider[player_name] = plist_g:slider("\n", -60, 60, 0, 1, "°"):visibility(false)
					end
				end
				list:update(plist)
			else
				plist = list:list()
			end

			local selected_id = list:get()
			local selected_player_name = selected_id and plist[selected_id]
			for player_name, options in pairs(options_selection) do
				options:visibility(player_name == selected_player_name)
			end
			for player_name, switch in pairs(whilelist_switches) do
				switch:visibility(player_name == selected_player_name)
			end
			for _, switch in pairs(body_yaw_switches) do switch:visibility(false) end
			for _, slider in pairs(body_yaw_slider) do slider:visibility(false) end

		end

		local plist = function ()
			local localplayer = entity.get_local_player()
			if not localplayer or not localplayer:is_alive() then return end

			local threat_player = entity.get_threat(true)
			local threat_name = threat_player and threat_player:get_name() or ""

			override_state.baim = false
			override_state.safepoint = false
			override_state.hitboxes = {}
			override_state.multipoint = {}

			local options = options_selection[threat_name]
			if options then
				if options:get("Force Body Aim") then
					override_state.baim = true
					override_state.hitboxes = {"Chest", "Stomach"}
					override_state.multipoint = {"Chest", "Stomach"}
				end
				override_state.safepoint = options:get("Force Safe")
			end

			update_override()


			--@region whitelist
			--[[
				How to work?
				m_iHealth is a prop for player health
				Set m_iHealth to zero, can cheating hack the player is not alive
				Aimbot not shooting dead player cuz meaningless, ignored

				That's why you will see someone health bar is empty who added to whitelist
			]]
			health_override.whitelist = {}
			for player_name, switch in pairs(whilelist_switches) do
				if switch:get() then health_override.whitelist[player_name] = true end
			end

			--[[ if body_yaw_switches ~= nil and body_yaw_slider ~= nil then
				-- body_yaw_switches and body_yaw_slider are tables keyed by player name
				-- apply override only for the current threat (similar to bodyaim/safepoint logic)
				for player_name, switch in pairs(body_yaw_switches) do
					local is_active = switch:get() and player_name == threat_name
					local slider = body_yaw_slider[player_name]
					local value = slider and slider:get() or 0
					for _, ent in ipairs(players) do
						if ent ~= nil and ent:get_name() == player_name then
							if is_active then
								if not body_yaw_backup[player_name] then
									local anim_state = GetAnimationState(ent)
									body_yaw_backup[player_name] = {
										lower_body_yaw_target = ent.m_flLowerBodyYawTarget,
										goal_feet_yaw = anim_state and anim_state ~= ffi.NULL and anim_state.m_flGoalFeetYaw or nil,
									}
								end
								ent.m_flLowerBodyYawTarget = value
								local anim_state = GetAnimationState(ent)
								if anim_state and anim_state ~= ffi.NULL then
									anim_state.m_flGoalFeetYaw = math.normalize_yaw(anim_state.m_flEyeYaw + value)
								end
							elseif body_yaw_backup[player_name] then
								local backup = body_yaw_backup[player_name]
								if backup.lower_body_yaw_target ~= nil then
									ent.m_flLowerBodyYawTarget = backup.lower_body_yaw_target
								end
								if backup.goal_feet_yaw ~= nil then
									local anim_state = GetAnimationState(ent)
									if anim_state and anim_state ~= ffi.NULL then
										anim_state.m_flGoalFeetYaw = backup.goal_feet_yaw
									end
								end
								body_yaw_backup[player_name] = nil
							end
						end
					end
				end
			end ]]
		end

		local highlight = esp.enemy:new_text("Highlight", "HIGHLIGHT", function(player)
			local name = player:get_name()

			if options_selection[name] and options_selection[name]:get("Highlight") then
				return "HIGHLIGHT"
			end
		end)

		local whilelist = esp.enemy:new_text("Whilelist", "WHILELIST", function(player)
			local name = player:get_name()

			if whilelist_switches[name] and whilelist_switches[name]:get() then
				return "WHILELIST"
			end
		end)

		events.render:set(plist_ui)
		events.render:set(function()
			local localplayer = entity.get_local_player()
			if (not localplayer or not localplayer:is_alive()) and (override_state.baim or override_state.safepoint) then
				override_state.baim = false
				override_state.safepoint = false
				override_state.hitboxes = {}
				override_state.multipoint = {}
				update_override()
			end
		end)
		events.createmove:set(plist)
	end

	local premium_antiaim do
		--[[
		    Time to use the most extreme measure—and the one I least wish to see.
			Hidden the original misc group.
			Dunno it a good idea, but that will cause anything eg override will re-setting

			But to counteract the automatic position...
			That is only way..

			So far, no method has been found to beautify groups while preserving
			the original misc group.
			You cannot have it both ways, beautify the original group and preserve it.

			So touch grass and stop fighting for this shit
		]]

		ref = {
			misc = ui.find("Aimbot", "Anti Aim", "Misc"),
			angles = ui.find("Aimbot", "Anti Aim", "Angles"),
			fakelag = ui.find("Aimbot", "Anti Aim", "Fake Lag"),
			antiaim = ui.find("Aimbot", "Anti Aim"),

			enabled_aa = ui.find("Aimbot", "Anti Aim", "Angles", "Enabled"),
		}

		local enabled = info:switch(icons.user_plus .. "  Enabled Premium Antiaim")
		local premium_enabled = {premium = enabled:get(), aa = nil}

		enabled:set_callback(function(self)
			premium_enabled.premium = self:get()

			if self:get() then
				ref.enabled_aa:override(true)
			else
				ref.enabled_aa:override()
			end
		end)

		local group = {	
			select = ref.antiaim:create("\nBetter Neverlose - Select"),
			misc = ref.antiaim:create("Better Neverlose - MISC"),
			globals_ = ref.antiaim:create("Better Neverlose - Globals"),
			yaw_desync = ref.antiaim:create("Better Neverlose - Yaw / Desync"),
			defensive = ref.antiaim:create("Better Neverlose - Defensive"),
			fakelag = ref.antiaim:create("Better Neverlose - Fakelag"),
			config = ref.antiaim:create("Better Neverlose - Config"),
		}

		local aa_misc do
		    local misc = {
		    	enabled = group.misc:switch("Enabled Anti-Aim"),
		    	tip = group.misc:label("\a{Link Active}These part aren't orginal settings, you should add binds for these. \nOr turn off the premium antiaim and add bind for original settings"),
		    	fake_duck = group.misc:switch("Fake Duck"),
		    	slow_walk = group.misc:switch("Slow Walk"),
				hs_on_crouch = group.misc:switch("Hide Shots On Crouch"),
		    	air_exploit = group.misc:switch("Air Exploit"),
		    	leg_movement = group.misc:combo("Leg Movement", "Default", "Sliding", "Walking"),
		    	manual_yaw = group.misc:combo("Manual Yaw", {"None", "Left", "Right", "Backward", "Forward", "Freestanding"}),
		    }
    
		    local sw_group = misc.slow_walk:create()
			local ae_group = misc.air_exploit:create()
		    local sw = {
		    	mode = sw_group:combo("Mode", {"Static", "Jitter", "Prefer Anti-Aim", "Prefer Aimbot"}),
		    	speed = sw_group:slider("Speed", 1, 120, 100, 1, "u"),
		    	speed_override = sw_group:slider("Speed #2", 1, 120, 100, 1, "u"),
		    	ticks = sw_group:slider("Tick(s)", 1, 30, 10),
		    }

			local ae = {
				tick = ae_group:slider("Tick(s)", 1, 30, 15)
			}

			misc.enabled:set_callback(function(self)
				premium_enabled.aa = self:get()
			end)
			premium_enabled.aa = misc.enabled:get()
			__share_pool.premium_is_active = function() return enabled:get() and misc.enabled:get() end
			slow_walk_controller.providers.premium = function()
				if not misc.slow_walk:get() then return end
				return {mode = sw.mode:get(), speed = sw.speed:get(), speed2 = sw.speed_override:get(), ticks = sw.ticks:get()}
			end

			local refs = {
				fd = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck"),
				sw = {
					sw = ui.find("Aimbot", "Anti Aim", "Misc", "Custom Slow Walk"),
					mode = ui.find("Aimbot", "Anti Aim", "Misc", "Custom Slow Walk", "Mode"),
					speed = ui.find("Aimbot", "Anti Aim", "Misc", "Custom Slow Walk", "Speed"),
					speed_2 = ui.find("Aimbot", "Anti Aim", "Misc", "Custom Slow Walk", "Speed #2"),
					ticks = ui.find("Aimbot", "Anti Aim", "Misc", "Custom Slow Walk", "Tick(s)"),
				},
				lm = ui.find("Aimbot", "Anti Aim", "Misc", "Leg Movement"),
				my = ui.find("Aimbot", "Anti Aim", "Misc", "Manual Yaw"),
				ae = {
					ae = ui.find("Aimbot", "Anti Aim", "Misc", "Air Exploit"),
					ticks = ui.find("Aimbot", "Anti Aim", "Misc", "Air Exploit", "Tick(s)"),
				},

				hs = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots"),
				hs_options = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots", "Options"),
				dt = ui.find("Aimbot", "Ragebot", "Main", "Double Tap"),
			}

			local last_enabled = nil
			local last_enabled_hs = nil
			local main = function ()
				premium_aa_active = enabled:get() and misc.enabled:get()
				if premium_aa_active then
					-- Synchronize every tick. A callback only runs after a value changes,
					-- so registering callbacks here does not apply the current values.
					if air_exploit_state.active then
						override_if_changed(refs.fd, air_exploit_state.fake_duck)
					else
						override_if_changed(refs.fd, misc.fake_duck:get() and true or nil)
					end
					override_if_changed(refs.lm, misc.leg_movement:get())
					override_if_changed(refs.my, misc.manual_yaw:get())

					override_if_changed(refs.sw.sw, misc.slow_walk:get())
					override_if_changed(refs.sw.mode, sw.mode:get())
					override_if_changed(refs.sw.speed, sw.speed:get())
					override_if_changed(refs.sw.speed_2, sw.speed_override:get())
					override_if_changed(refs.sw.ticks, sw.ticks:get())

					override_if_changed(refs.ae.ae, misc.air_exploit:get())
					override_if_changed(refs.ae.ticks, ae.tick:get())

					last_enabled = true
				else
					if last_enabled ~= false then
						last_enabled = false
						override_if_changed(refs.fd, nil)
						override_if_changed(refs.sw.sw, nil)
						override_if_changed(refs.lm, nil)
						override_if_changed(refs.my, nil)
						override_if_changed(refs.ae.ae, nil)
						override_if_changed(refs.sw.mode, nil)
						override_if_changed(refs.sw.speed, nil)
						override_if_changed(refs.sw.speed_2, nil)
						override_if_changed(refs.sw.ticks, nil)
						override_if_changed(refs.ae.ticks, nil)
					end
				end
			end

			local auto_hs = function ()
				if premium_aa_active and misc.hs_on_crouch:get() then
					if check_condition(localplayer_.ent) == "Crouching" then
						if rage.exploit:get() == 1 then
							override_if_changed(refs.hs, true)
							override_if_changed(refs.hs_options, "Break LC")
							override_if_changed(refs.dt, false)
						end
					else
						override_if_changed(refs.hs, nil)
						override_if_changed(refs.hs_options, nil)
						override_if_changed(refs.dt, nil)
					end
					last_enabled_hs = true
				else
					if last_enabled_hs ~= false then
						last_enabled_hs = false
						override_if_changed(refs.hs, nil)
						override_if_changed(refs.hs_options, nil)
						override_if_changed(refs.dt, nil)
					end
				end
			end

			events.createmove:set(main)
			events.createmove:set(auto_hs)
			events.render:set(function()
				if ui.get_alpha() <= .4 then return end
			    sw.speed:visibility((sw.mode:get() ~= "Prefer Anti-Aim") and (sw.mode:get() ~= "Prefer Aimbot"))
			    sw.speed_override:visibility((sw.mode:get() == "Jitter"))
			    sw.ticks:visibility((sw.mode:get() == "Jitter"))
			end)
		end

		local selected
		local list_selected = 1
		local selection = function ()
			local names = {"Globals", "Yaw / Desync", "Defensive Snap", "Fake Lag"}
			local updating = false

			selected = group.select:list("\n", names)

			local function update_selection()
				if updating then return end

				local value = selected:get()
				if type(value) ~= "number" or not names[value] then
					value = list_selected
				end
				list_selected = value

				local items = {}
				for i, name in ipairs(names) do
					items[i] = (i == value and "\a{Link Active}" or "") .. name .. "\aDEFAULT"
				end

				updating = true
				selected:update(items)
				selected:set(value)
				updating = false
			end

			selected:set_callback(update_selection)
			update_selection()
		end
		selection()


		local aa_ui = {
			globals = {},
			yaw_desync = {},
			defensive_snap = {},
			fakelag = {},
		}

		local _condition = {"Globals", "Standing", "Running", "Walking", "In Air + Crouching", "In Air", "Crouching"}
		local condition = group.select:combo(ui.get_icon("transporter") .. "  Player Condition", _condition)
		local function condition_item(name, index)
			return name .. string.rep("\226\128\139", index)
		end

		local function condition_index()
			local value = condition:get()
			if type(value) == "number" and _condition[value] then
				return value
			end

			for i, name in ipairs(_condition) do
				if value == name then return i end
			end

			return 1
		end

		local globals_builder do
			for i, v in ipairs(_condition) do
				aa_ui.globals[i] = {
					override = group.select:switch(string.format("\a{Link Active}[%s]\aDEFAULT Override", v)),

			        pitch = group.globals_:combo(condition_item("Pitch", i), "Disabled", "Down", "Fake Down", "Fake Up"),
			        yaw = group.globals_:combo(condition_item("Yaw", i), {"Disabled", "Backward", "Static"}),
			        avoid_backstab = group.globals_:switch(condition_item("Avoid Backstab", i)),
			        fs_options = group.globals_:selectable(condition_item("Freestanding Options", i), {"Disbaled Yaw Modifiers", "Body Freestanding"}),
				}
			end

			local refs = {
				pitch = ui.find("Aimbot", "Anti Aim", "Angles", "Pitch"),
				yaw = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw"),
				avoid_backstab = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Avoid Backstab"),
				fs = {
					dym = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding", "Disable Yaw Modifiers"),
					bf = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding", "Body Freestanding"),
				},
			}
			
			local last_enabled = nil
			local main = function ()
				local current = check_condition(localplayer_.ent)
				for i, v in ipairs(_condition) do
					if current == v then
						if premium_aa_active then
							if not aa_ui.globals[i].override:get() then i = 1 end
							
							local ui_global = aa_ui.globals[i]
							override_if_changed(refs.pitch, ui_global.pitch:get())
							override_if_changed(refs.yaw, ui_global.yaw:get())
							override_if_changed(refs.avoid_backstab, ui_global.avoid_backstab:get())
							override_if_changed(refs.fs.dym, ui_global.fs_options:get("Disbaled Yaw Modifiers"))
							override_if_changed(refs.fs.bf, ui_global.fs_options:get("Body Freestanding"))
	
							last_enabled = true
						else
							if last_enabled ~= false then
								override_if_changed(refs.pitch, nil)
								override_if_changed(refs.yaw, nil)
								override_if_changed(refs.avoid_backstab, nil)
								override_if_changed(refs.fs.dym, nil)
								override_if_changed(refs.fs.bf, nil)
								last_enabled = false
							end
						end
					end
				end
			end

			events.createmove:set(main)
			events.render:set(function()
				if ui.get_alpha() <= .4 then return end
				local current = condition_index()
				local page_visible = enabled:get() and list_selected == 1

				for i in ipairs(_condition) do
					local visible = page_visible and current == i
					for _, p in ipairs({"pitch", "yaw", "avoid_backstab", "fs_options"}) do
						aa_ui.globals[i][p]:visibility(visible)
					end

					aa_ui.globals[i].override:visibility(page_visible and current == i and i ~= 1)
				end
			end)
		end

		local yaw_desync do
			for i, v in ipairs(_condition) do
				aa_ui.yaw_desync[i] = {
					override = group.select:switch(string.format("\a{Link Active}[%s]\aDEFAULT Override", v)),

				        offset = group.yaw_desync:combo(condition_item("Yaw offset", i), {"Static", "Jitter", "Sway", "Flicker", "Rand Jitter Switch", "Fake Flick", "L/R"}),
			        l = group.yaw_desync:slider(condition_item("\nLEFT", i), -180, 180, 0, 1, "°"),
			        r = group.yaw_desync:slider(condition_item("\nRIGHT", i), -180, 180, 0, 1,  "°"),
			        switch_time = group.yaw_desync:slider(condition_item("Switch Timer", i), 1, 50, 1, 1, "t"),
			        at_target = group.yaw_desync:switch(condition_item("At Target", i)),
        
			        modifiers = group.yaw_desync:combo(condition_item("Modifiers", i), {"Disabled", "Center", "Offset", "Random", "Spin", "3-Way", "5-Way"}),
			        modifiers_offset = group.yaw_desync:slider(condition_item("\nmodifiers_offset", i), -180, 180, 0, "°"),
        
			        desync = group.yaw_desync:switch(condition_item("Body Yaw", i)),
					desync_mode = group.yaw_desync:combo(condition_item("\nDesync Mode", i), {"Static", "Low Delta", "Opposite", "Rand Invent"}),
			        desync_delta = group.yaw_desync:slider(condition_item("\nMax desync", i), -60, 60, 0, 1, "°"),
			        desync_options = group.yaw_desync:selectable(condition_item("Options", i), "Avoid Overlap", "Jitter", "Randomize Jitter", "Anti Bruteforce"),
			        desync_fs = group.yaw_desync:combo(condition_item("Freestanding", i), "Off", "Peek Fake", "Peek Real"),
				}
			end

			local refs = {
				offset = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset"),
				base = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Base"), -- At target
				freestanding = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding"),
				manual_yaw = ui.find("Aimbot", "Anti Aim", "Misc", "Manual Yaw"),
				yaw_modifier = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier"),
				yaw_modifier_offset = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier", "Offset"),
				desync = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw"),
				l_limit = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Left Limit"),
				r_limit = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Right Limit"),
				desync_options = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Options"),
				desync_fs = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Freestanding"),
				inventer = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Inverter"),
			}

			local last_enabled = false
			local rand_jitter_state = {}
			local fake_flick_state = {}
			local rand_desync_state = {}
			local desync_limit, desync_invent = 0, nil

			local main = function ()
				local current = check_condition(localplayer_.ent)
				for i, v in ipairs(_condition) do
					if current == v then
						if premium_aa_active then
							if not aa_ui.yaw_desync[i].override:get() then i = 1 end
							
							local group_ = aa_ui.yaw_desync[i]
							local mode = group_.offset:get()
							local left, right, period = group_.l:get(), group_.r:get(), group_.switch_time:get()
							local tick = globals.tickcount
							local yaw_settings = left
							local jitter = rand_jitter_state[i]
							if mode ~= "Rand Jitter Switch" and jitter then jitter.active = false end
							if mode == "Jitter" then
								yaw_settings = math.floor(tick / period) % 2 == 0 and right or left
							elseif mode == "Sway" then
								local step = (tick % period) / period
								local sway = step < .5 and step * 2 or 2 - step * 2
								yaw_settings = math.floor(left + (right - left) * sway)
							elseif mode == "Flicker" then
								yaw_settings = tick % period == 0 and right or left
							elseif mode == "Rand Jitter Switch" then
								if not jitter then jitter = {} rand_jitter_state[i] = jitter end
								if not jitter.active or tick < (jitter.last_tick or 0) then
									jitter.active, jitter.use_right = true, true
									jitter.next_switch_tick = tick + utils.random_int(1, 15)
								elseif tick >= jitter.next_switch_tick then
									jitter.use_right = not jitter.use_right
									jitter.next_switch_tick = tick + utils.random_int(1, 15)
								end
								jitter.last_tick = tick
								yaw_settings = jitter.use_right and right or left
							elseif mode == "L/R" then
								yaw_settings = refs.inventer:get_override() and right or left
							elseif mode == "Fake Flick" then
								local flick = fake_flick_state[i]
								if not flick or flick.last_tick and tick < flick.last_tick then
									flick = {next_flick = tick + utils.random_int(1, 15), flick_tick = -1}
									fake_flick_state[i] = flick
								end
								if tick >= flick.next_flick then
									flick.flick_tick = tick
									flick.next_flick = tick + utils.random_int(1, 15)
								end
								flick.last_tick = tick
								yaw_settings = flick.flick_tick == tick and right or left
							end
							local manual = get_item_value(refs.manual_yaw)
							local manual_offset = ({
								["Left"] = -90,
								["Right"] = 90,
								["Backward"] = 0,
								["Forward"] = 180,
							})[manual]

							if manual == "Freestanding" then
								override_if_changed(refs.offset, nil)
							else
								override_if_changed(refs.offset, manual_offset or yaw_settings)
							end
							override_if_changed(refs.base, not manual_active and group_.at_target:get() and "At Target" or nil)
							override_if_changed(refs.freestanding, manual == "Freestanding" and true or nil)

							override_if_changed(refs.yaw_modifier, group_.modifiers:get())
							override_if_changed(refs.yaw_modifier_offset, group_.modifiers_offset:get())

							if not silent_shots_active then
								override_if_changed(refs.desync, group_.desync:get())
							end

							if group_.desync_mode:get() == "Static" then
								desync_limit = math.abs(group_.desync_delta:get())
								desync_invent = (group_.desync_delta:get() > 0 and true or nil)
							elseif group_.desync_mode:get() == "Low Delta" then
								desync_limit = utils.random_int(0, 1) == 1 and 28 or 30
								desync_invent = (group_.desync_delta:get() > 0 and true or nil)
							elseif group_.desync_mode:get() == "Opposite" then
								desync_limit = 60
								desync_invent = (group_.desync_delta:get() > 0 and true or nil)
							elseif group_.desync_mode:get() == "Rand Invent" then
								desync_limit = math.abs(group_.desync_delta:get())
								desync_invent = (function()
									local state = rand_desync_state[i]
									if not state then
										state = {}
										rand_desync_state[i] = state
									end

									if state.mode ~= "Rand Invent" or globals.tickcount < (state.last_tick or 0) then
										state.mode = "Rand Invent"
										state.active = true
										state.use_right = false
										state.switch_timing = utils.random_int(4, 20)
										state.next_switch_tick = globals.tickcount + state.switch_timing
									elseif globals.tickcount >= state.next_switch_tick then
										state.use_right = not state.use_right
										state.switch_timing = utils.random_int(4, 20)
										state.next_switch_tick = globals.tickcount + state.switch_timing
									end

									state.last_tick = globals.tickcount
									return state.use_right
								end)()
							end

							override_if_changed(refs.l_limit, desync_limit)
							override_if_changed(refs.r_limit, desync_limit)
							override_if_changed(refs.inventer, desync_invent)

							override_if_changed(refs.desync_options, group_.desync_options:get())
							override_if_changed(refs.desync_fs, group_.desync_fs:get())
							last_enabled = true
						else
							if last_enabled ~= false then
								override_if_changed(refs.offset, nil)
								override_if_changed(refs.base, nil)
								override_if_changed(refs.freestanding, nil)

								override_if_changed(refs.yaw_modifier, nil)
								override_if_changed(refs.yaw_modifier_offset, nil)

								if not silent_shots_active then override_if_changed(refs.desync, nil) end
								override_if_changed(refs.l_limit, nil)
								override_if_changed(refs.r_limit, nil)
								override_if_changed(refs.inventer, nil)

								override_if_changed(refs.desync_options, nil)
								override_if_changed(refs.desync_fs, nil)
								last_enabled = false
							end
						end
					end
				end
			end
			
			events.createmove:set(main)
			events.render:set(function()
				if ui.get_alpha() <= .4 then return end
				local current = condition_index()
				local page_visible = enabled:get() and list_selected == 2

				for i in ipairs(_condition) do
					local visible = page_visible and current == i
					for _, o in ipairs({"offset", "l", "at_target", "modifiers", "desync", "desync_options", "desync_fs"}) do
						aa_ui.yaw_desync[i][o]:visibility(visible)
						
					end

					aa_ui.yaw_desync[i].override:visibility(page_visible and current == i and i ~= 1)
					
					aa_ui.yaw_desync[i].r:visibility(visible and (aa_ui.yaw_desync[i].offset:get() ~= "Static") and ((aa_ui.yaw_desync[i].offset:get() == "Jitter") or (aa_ui.yaw_desync[i].offset:get() == "Sway") or (aa_ui.yaw_desync[i].offset:get() == "Flicker") or (aa_ui.yaw_desync[i].offset:get() == "Rand Jitter Switch") or (aa_ui.yaw_desync[i].offset:get() == "Fake Flick") or (aa_ui.yaw_desync[i].offset:get() == "L/R")))
				    				    aa_ui.yaw_desync[i].switch_time:visibility(visible and aa_ui.yaw_desync[i].offset:get() ~= "Static" and ((aa_ui.yaw_desync[i].offset:get() == "Jitter") or (aa_ui.yaw_desync[i].offset:get() == "Sway") or (aa_ui.yaw_desync[i].offset:get() == "Flicker")))
				    aa_ui.yaw_desync[i].modifiers_offset:visibility(visible and aa_ui.yaw_desync[i].modifiers:get() ~= "Disabled")
    
					aa_ui.yaw_desync[i].desync_mode:visibility(visible and aa_ui.yaw_desync[i].desync:get())
				    aa_ui.yaw_desync[i].desync_delta:visibility(visible and aa_ui.yaw_desync[i].desync:get())
				end

			end)
		end

		local defensive_snap do
			for i, v in ipairs(_condition) do
				aa_ui.defensive_snap[i] = {
					override = group.select:switch(string.format("\a{Link Active}[%s]\aDEFAULT Override", v)),

			        lc = group.defensive:combo(string.format("\a{Link Active}[%s]\aDEFAULT Defensive", v), {"Disabled", "On Peek", "Always On"}),
			        pitch = group.defensive:combo("> Pitch", {"Default", "Static", "Jitter", "Flicker", "Spin", "45 Deg", "Fake Up", "Random", "Adaptive"}),
			        p_1 = group.defensive:slider("\nPitch 1", -89, 89, 0, 1, "°"),
			        p_2 = group.defensive:slider("\nPitch 2", -89, 89, 0, 1, "°"),
			        p_switch_time = group.defensive:slider("Switch Timer", 1, 50, 1, 1, "t"),
					
			        yaw = group.defensive:combo("> Yaw", {"Default", "Static", "Jitter", "Flicker", "Spin", "90 Jitter", "Fake", "Random", "Adaptive"}),
			        y_1 = group.defensive:slider("\nYaw 1", -180, 180, 0, 1, "°"),
			        y_2 = group.defensive:slider("\nYaw 2", -180, 180, 0, 1, "°"),
			        y_switch_time = group.defensive:slider("Switch Timer", 1, 50, 1, 1, "t"),
			        guard_ticks = group.defensive:slider(condition_item("Recovery Guard", i), 0, 4, 2, 1, "t"),
				}
			end

			local cached_settings = {owner = "premium:1"}
			local cached_index = 1
			defensive_controller.providers.premium = function(cmd)
				local current = check_condition(entity.get_local_player())
				local index = 1
				for i, name in ipairs(_condition) do if name == current then index = i break end end
				if not aa_ui.defensive_snap[index].override:get() then index = 1 end
				local settings = aa_ui.defensive_snap[index]
				if cached_index ~= index then cached_settings.owner = "premium:" .. index cached_index = index end
				cached_settings.lc, cached_settings.guard = settings.lc:get(), settings.guard_ticks:get()
				if cmd and cached_settings.lc ~= "Disabled" and __share_pool.defensive_ticks > cached_settings.guard then
					cached_settings.pitch, cached_settings.yaw = settings.pitch:get(), settings.yaw:get()
					cached_settings.p1, cached_settings.p2, cached_settings.p_period = settings.p_1:get(), settings.p_2:get(), settings.p_switch_time:get()
					cached_settings.y1, cached_settings.y2, cached_settings.y_period = settings.y_1:get(), settings.y_2:get(), settings.y_switch_time:get()
				end
				return cached_settings
			end

			events.render:set(function()
				if ui.get_alpha() <= .4 then return end
				local current = condition_index()
				local page_visible = enabled:get() and list_selected == 3

				for i in ipairs(_condition) do
					local visible = page_visible and current == i
					for _, o in ipairs({"lc", "pitch", "p_1", "p_2", "p_switch_time", "yaw", "y_1", "y_2", "y_switch_time", "guard_ticks"}) do
						aa_ui.defensive_snap[i][o]:visibility(visible)
						
					end

					aa_ui.defensive_snap[i].override:visibility(page_visible and current == i and i ~= 1)

					local _pitch_get, _yaw_get = aa_ui.defensive_snap[i].pitch:get(), aa_ui.defensive_snap[i].yaw:get()

					-- i'm not planning to make a good way to unity UI visible manage.
					-- Unless use pui, but they are mass
					local hide_pitch_1 = _pitch_get == "Default" or _pitch_get == "45 Deg" or _pitch_get == "Fake Up" or _pitch_get == "Random" or _pitch_get == "Adaptive"
					local hide_pitch_2 = _pitch_get == "Default" or _pitch_get == "45 Deg" or _pitch_get == "Static" or _pitch_get == "Fake Up" or _pitch_get == "Random" or _pitch_get == "Adaptive"
					local hide_pitch_switch_time = _pitch_get == "Default" or _pitch_get == "45 Deg" or _pitch_get == "Static" or _pitch_get == "Spin" or _pitch_get == "Fake Up" or _pitch_get == "Random" or _pitch_get == "Adaptive"

					local hide_yaw_1 = _yaw_get == "Default" or _yaw_get == "90 Jitter" or _yaw_get == "Random" or _yaw_get == "Adaptive"
					local hide_yaw_2 = _yaw_get == "Default" or _yaw_get == "Static" or _yaw_get == "90 Jitter" or _yaw_get == "Random" or _yaw_get == "Fake" or _yaw_get == "Adaptive"
					local hide_yaw_switch_time = _yaw_get == "Default" or _yaw_get == "Static" or _yaw_get == "90 Jitter" or _yaw_get == "Spin" or _yaw_get == "Random" or _yaw_get == "Fake" or _yaw_get == "Adaptive"

					aa_ui.defensive_snap[i].p_1:visibility(visible and not hide_pitch_1)
					aa_ui.defensive_snap[i].p_2:visibility(visible and not hide_pitch_2)
					aa_ui.defensive_snap[i].p_switch_time:visibility(visible and not hide_pitch_switch_time)

					aa_ui.defensive_snap[i].y_1:visibility(visible and not hide_yaw_1)
					aa_ui.defensive_snap[i].y_2:visibility(visible and not hide_yaw_2)
					aa_ui.defensive_snap[i].y_switch_time:visibility(visible and not hide_yaw_switch_time)
				end
			end)
		end

		local fakelag do
			for i, v in ipairs(_condition) do
				aa_ui.fakelag[i] = {
					override = group.select:switch(string.format("\a{Link Active}[%s]\aDEFAULT Override", v)),

			        fl_enabled = group.fakelag:switch(string.format("\a{Link Active}[%s]\aDEFAULT Fake Lag", v)),
			        mode = group.fakelag:combo("Mode", {"Default", "Dynamic", "Maximum", "Jitter", "Flicker"}),
			        limit_1 = group.fakelag:slider("> Limit", 1, 15, 1, 1, "t"),
			        limit_2 = group.fakelag:slider("> Limit \a{Link Active}Override\aDEFAULT", 1, 15, 1, 1, "t"),
			        limit_switch_timer = group.fakelag:slider("> Switch Timer", 1, 50, 1, 1, "t"),
			        variability = group.fakelag:slider("> Variability", 0, 100, 0, 1, "%"),
			        slient_shots = group.fakelag:switch("Slient Shots"),
				}
			end 

			local refs = {
				enabled = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Enabled"),
				limit = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Limit"),
				variability = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Variability"),
				slient_shots = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Slient Shots"),
			}

			local last_enabled = false
			local main = function ()
				local current = check_condition(localplayer_.ent)
				for i, v in ipairs(_condition) do
					if current == v then
						if premium_aa_active then
							if not aa_ui.fakelag[i].override:get() then i = 1 end
							local group_ = aa_ui.fakelag[i]
							
							local mode = group_.mode:get()
							local limit_value = group_.limit_1:get()
							if mode == "Dynamic" then
								if current == "Walking" then limit_value = math.min(math.random(5, 6), limit_value)
								elseif current == "In Air" or current == "In Air + Crouching" then limit_value = math.max(math.random(12, 15), limit_value) end
							elseif mode == "Maximum" then
								limit_value = math.max(14, cvar.sv_maxusrcmdprocessticks:int())
							elseif mode == "Jitter" then
								limit_value = math.floor(globals.tickcount / group_.limit_switch_timer:get()) % 2 == 0 and limit_value or group_.limit_2:get()
							elseif mode == "Flicker" then
								limit_value = globals.tickcount % group_.limit_switch_timer:get() == 0 and limit_value or group_.limit_2:get()
							end

							if not silent_shots_active then
								override_if_changed(refs.enabled, group_.fl_enabled:get())
								override_if_changed(refs.limit, air_exploit_state.active and 17 or limit_value)
								override_if_changed(refs.variability, group_.variability:get())
							end
							override_if_changed(refs.slient_shots, group_.slient_shots:get())
							last_enabled = true
						else
							if last_enabled ~= false then
								if not silent_shots_active then
									override_if_changed(refs.enabled, nil)
									override_if_changed(refs.limit, nil)
									override_if_changed(refs.variability, nil)
								end
								override_if_changed(refs.slient_shots, nil)
								last_enabled = false
							end
						end
					end
				end
			end

			events.createmove:set(main)
			events.render:set(function()
				if ui.get_alpha() <= .4 then return end
				local current = condition_index()
				local page_visible = enabled:get() and list_selected == 4

				for i in ipairs(_condition) do
					local visible = page_visible and current == i
					for _, o in ipairs({"fl_enabled", "mode", "limit_1", "variability", "slient_shots"}) do
						aa_ui.fakelag[i][o]:visibility(visible)
					end

					local mode_get = aa_ui.fakelag[i].mode:get()

					aa_ui.fakelag[i].override:visibility(page_visible and current == i and i ~= 1)

					aa_ui.fakelag[i].limit_2:visibility(visible and (mode_get == "Jitter" or mode_get == "Flicker"))
					aa_ui.fakelag[i].limit_switch_timer:visibility(visible and (mode_get == "Jitter" or mode_get == "Flicker"))
				end
			end)
		end

		local config do
			local notify_config = function (title, message)
				print(message)
				print_dev(message)
				common.add_notify(title, message)
			end

			local safe_set = function (item, value)
				if item == nil or value == nil then return end
				pcall(function() item:set(value) end)
			end

			local export_aa_config = function ()
				local config = {
					version = version_,
					antiaim = {},
					defensive_snap = {},
					fakelag = {},
				}

				for i, name in ipairs(_condition) do
					local global = aa_ui.globals[i]
					local yaw = aa_ui.yaw_desync[i]
					local defensive = aa_ui.defensive_snap[i]
					local fakelag = aa_ui.fakelag[i]
					local delta = yaw.desync_delta:get()

					config.antiaim[name] = {
						override = global.override:get(),
						pitch = global.pitch:get(),
						yaw = global.yaw:get(),
						yaw_s = {
							override = yaw.override:get(),
							base = yaw.at_target:get() and "At target" or "Local View",
							offset = yaw.l:get(),
							offset_right = yaw.r:get(),
							mode = yaw.offset:get(),
							switch_time = yaw.switch_time:get(),
							avoid_backstab = global.avoid_backstab:get(),
							fs_options = global.fs_options:get(),
						},
						modifier = yaw.modifiers:get(),
						modifier_s = {
							offset = yaw.modifiers_offset:get(),
						},
						bodyyaw = yaw.desync:get(),
						bodyyaw_s = {
							mode = yaw.desync_mode:get(),
							inverter = delta > 0,
							left = math.abs(delta),
							right = math.abs(delta),
							delta = delta,
							options = yaw.desync_options:get(),
							fs = yaw.desync_fs:get(),
						},
						extend_angles = false,
						extend_angles_s = {pitch = 89, roll = 45},
					}

					config.defensive_snap[name] = {
						override = defensive.override:get(),
						defensive = defensive.lc:get() ~= "Disabled",
						defensive_s = {
							snap_mode = "Orignal",
							mode = defensive.lc:get(),
							guard_ticks = defensive.guard_ticks:get(),
							pitch = defensive.pitch:get(),
							pitch_offset = defensive.p_1:get(),
							pitch_offset_2 = defensive.p_2:get(),
							pitch_switch_time = defensive.p_switch_time:get(),
							yaw = defensive.yaw:get(),
							yaw_offset = defensive.y_1:get(),
							jitter_offset = defensive.y_2:get(),
							yaw_switch_time = defensive.y_switch_time:get(),
						},
					}

					config.fakelag[name] = {
						override = fakelag.override:get(),
						enabled = fakelag.fl_enabled:get(),
						limit = fakelag.limit_1:get(),
						variability = fakelag.variability:get(),
						slient_shots = fakelag.slient_shots:get(),
						mode = fakelag.mode:get(),
						limit_2 = fakelag.limit_2:get(),
						limit_switch_timer = fakelag.limit_switch_timer:get(),
					}
				end

				return json.stringify(config)
			end

			local function import_aa_config(json_string)
				local success, config = pcall(function() return json.parse(json_string) end)
				if not success or type(config) ~= "table"
					or type(config.antiaim) ~= "table" or type(config.fakelag) ~= "table" then
					notify_config("Import failed", "Invalid JSON file or NOT Better Neverlose config")
					return false
				end

				if config.version ~= version_ then
					local warning = string.format(
						"Warning: config version not match (%s vs %s)",
						tostring(config.version or "unknown"), version_
					)
					print(warning)
					print_dev(warning)
				end

				for i, name in ipairs(_condition) do
					-- 5.3 did not have In Air + Crouching; if importing 5.3, inherit
					-- its In Air values for the new condition.
					local source_name = name
					if name == "In Air + Crouching" and config.antiaim[name] == nil then
						source_name = "In Air"
					end

					local data = config.antiaim[source_name]
					if type(data) == "table" then
						local global = aa_ui.globals[i]
						local yaw = aa_ui.yaw_desync[i]

						safe_set(global.override, data.override)
						safe_set(global.pitch, data.pitch)
						safe_set(global.yaw, data.yaw)

						local yaw_s = data.yaw_s
						if type(yaw_s) == "table" then
							-- Older configs used the globals override for yaw/desync too.
							safe_set(yaw.override, yaw_s.override ~= nil and yaw_s.override or data.override)
							safe_set(yaw.at_target, yaw_s.base == "At target" or yaw_s.base == "At Target")
							safe_set(yaw.offset, yaw_s.mode or "Static")
							safe_set(yaw.l, yaw_s.offset)
							safe_set(yaw.r, yaw_s.offset_right or yaw_s.offset)
							safe_set(yaw.switch_time, yaw_s.switch_time)
							safe_set(global.avoid_backstab, yaw_s.avoid_backstab)
							safe_set(global.fs_options, yaw_s.fs_options)
						end

						safe_set(yaw.modifiers, data.modifier)
						if type(data.modifier_s) == "table" then
							safe_set(yaw.modifiers_offset, data.modifier_s.offset)
						end

						safe_set(yaw.desync, data.bodyyaw)
						safe_set(yaw.desync_mode, data.desync_mode)
						local bodyyaw_s = data.bodyyaw_s
						if type(bodyyaw_s) == "table" then
							local delta = bodyyaw_s.delta
							if delta == nil then
								delta = bodyyaw_s.left or bodyyaw_s.right
								if bodyyaw_s.inverter == false then delta = -math.abs(delta or 0) end
							end
							safe_set(yaw.desync_delta, delta)
							safe_set(yaw.desync_options, bodyyaw_s.options)
							safe_set(yaw.desync_fs, bodyyaw_s.fs)
						end

					end

					local defensive_source = name
					if name == "In Air + Crouching"
						and (type(config.defensive_snap) ~= "table" or config.defensive_snap[name] == nil) then
						defensive_source = "In Air"
					end

					local defensive_data = type(config.defensive_snap) == "table"
						and config.defensive_snap[defensive_source] or nil
					-- Backward compatibility: defensive settings used to live in antiaim[name].
					if type(defensive_data) ~= "table" then
						defensive_data = data
					end

					if type(defensive_data) == "table" then
						local defensive = aa_ui.defensive_snap[i]
						local defensive_s = defensive_data.defensive_s
						local defensive_override = defensive_data.override
						if defensive_data == data then defensive_override = data and data.override end

						safe_set(defensive.override, defensive_override)
						if type(defensive_s) == "table" then
							safe_set(defensive.lc, defensive_s.mode or (defensive_data.defensive and "Always On" or "Disabled"))
							safe_set(defensive.guard_ticks, defensive_s.guard_ticks)
							safe_set(defensive.pitch, defensive_s.pitch)
							safe_set(defensive.p_1, defensive_s.pitch_offset)
							safe_set(defensive.p_2, defensive_s.pitch_offset_2 or defensive_s.pitch_offset)
							safe_set(defensive.p_switch_time, defensive_s.pitch_switch_time)
							safe_set(defensive.yaw, defensive_s.yaw)
							safe_set(defensive.y_1, defensive_s.yaw_offset)
							safe_set(defensive.y_2, defensive_s.jitter_offset or defensive_s.yaw_offset)
							safe_set(defensive.y_switch_time, defensive_s.yaw_switch_time)
						elseif defensive_data.defensive ~= nil then
							safe_set(defensive.lc, defensive_data.defensive and "Always On" or "Disabled")
						end
					end

					local fl_source = name
					if name == "In Air + Crouching" and config.fakelag[name] == nil then
						fl_source = "In Air"
					end
					local fl_data = config.fakelag[fl_source]
					if type(fl_data) == "table" then
						local fakelag = aa_ui.fakelag[i]
						local legacy_override = type(data) == "table" and data.override or nil
						safe_set(fakelag.override, fl_data.override ~= nil and fl_data.override or legacy_override)
						safe_set(fakelag.fl_enabled, fl_data.enabled)
						safe_set(fakelag.mode, fl_data.mode or "Default")
						safe_set(fakelag.limit_1, fl_data.limit)
						safe_set(fakelag.limit_2, fl_data.limit_2 or fl_data.limit)
						safe_set(fakelag.limit_switch_timer, fl_data.limit_switch_timer)
						safe_set(fakelag.variability, fl_data.variability)
						safe_set(fakelag.slient_shots, fl_data.slient_shots)
					end
				end

				notify_config("Config", "Anti-Aim config loaded")
				return true
			end

			import = group.config:button("Import AA", function()
				import_aa_config(clipboard.get())
			end, true)
			export = group.config:button("Export AA", function()
				clipboard.set(export_aa_config())
				notify_config("Copied", "Config has been copied to clipboard.")
			end, true)
		end
		
		-- group.select:switch("Angles")
		-- group.fakelag:switch("Fakelag")
		-- group.test:switch("Test")

		local items_visibility = function ()
			if ui.get_alpha() <= .4 then return end
            group.misc:visibility(enabled:get())
		    group.select:visibility(enabled:get())
			group.fakelag:visibility(enabled:get())
			group.config:visibility(enabled:get())

			group.globals_:visibility(enabled:get() and list_selected == 1)
			group.yaw_desync:visibility(enabled:get() and list_selected == 2)
			group.defensive:visibility(enabled:get() and list_selected == 3)
			group.fakelag:visibility(enabled:get() and list_selected == 4)

			ref.misc:visibility(not enabled:get())
			ref.angles:visibility(not enabled:get())
			ref.fakelag:visibility(not enabled:get())
		end

		local shutdown = function ()
			group.misc:visibility(false)
		    group.select:visibility(false)
			group.fakelag:visibility(false)
			group.config:visibility(false)

			ref.misc:visibility(true)
			ref.angles:visibility(true)
			ref.fakelag:visibility(true)
		end

		events.render:set(items_visibility)
		events.shutdown:set(shutdown)
	end

	local items_visible = function ()
		local is_wip = string.find(version_, "WIP", 1, true) ~= nil
		local is_alpha = string.find(version_, "Alpha", 1, true) ~= nil
		local is_beta = string.find(version_, "Beta", 1, true) ~= nil

		wip_warning:visibility(is_wip)
		alpha_warning:visibility(is_alpha)
		beta_warning:visibility(is_beta)
	end

	events.render:set(items_visible)
end

teleport_prediction = {records = {}, results = {}, status = "Preview"}
do
	local state = teleport_prediction
	local enabled = ui.find("Visuals", "Players", "Enemies", "ESP"):switch("Predict Teleport")
	local tint = enabled:color_picker(color(100, 180, 255, 210))
	local settings = enabled:create()
	local maximum = settings:slider("Maximum ticks", 1, 32, 16, 1, "t")
	local forecast = settings:switch("Forecast repeated bursts", true):tooltip("Use recently observed simulation-time gaps as a possible next burst length. This does not reveal the enemy's future commands.")

	local debug_group = ui.create("Better Neverlose - Prediction")
	local debug = debug_group:switch("_DEBUG"):tooltip("Experimental command-angle prediction test. Preview by default. Manual predicted shots bypass Ragebot's targeting, HC and damage checks.")
	local debug_settings = debug:create()
	local mode = debug_settings:combo("Mode", {"Preview", "Fire on bind"})
	local fire = debug_settings:switch("Fire predicted shot"):tooltip("Bind this control. Each press can issue one shot; release before trying again. Close the menu before pressing.")
	local hitbox = debug_settings:combo("Target hitbox", {"Chest", "Stomach", "Head"})
	local fov = debug_settings:slider("Maximum FOV", 1, 30, 8, 1, "°")
	local quality = debug_settings:slider("Minimum quality", 0, 100, 70, 1, "%"):tooltip("Heuristic movement quality, not a hit-chance probability.")
	local accuracy = debug_settings:switch("Require low spread", true)
	local camera = debug_settings:switch("Keep camera", true)
	local rage_enabled = ui.find("Aimbot", "Ragebot", "Main", "Enabled")
	local aa_enabled = ui.find("Aimbot", "Anti Aim", "Angles", "Enabled")
	local dt = ui.find("Aimbot", "Ragebot", "Main", "Double Tap")
	local hs = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots")
	local fd = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck")
	local point_ids = {Chest = 5, Stomach = 3, Head = 0}
	local edges = {{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}

	local copy = function(v) return vector(v.x, v.y, v.z) end
	local finite = function(v)
		return v and v.x == v.x and v.y == v.y and v.z == v.z
			and math.abs(v.x) < 10000000 and math.abs(v.y) < 10000000 and math.abs(v.z) < 10000000
	end
	local distance = function(a, b)
		local x, y, z = a.x - b.x, a.y - b.y, a.z - b.z
		return math.sqrt(x*x + y*y + z*z)
	end
	local active = function() return enabled:get() or debug:get() end

	state.restore_command = function()
		if not state.borrowed then return end
		if rage_enabled:get_override() == false then rage_enabled:override(state.borrowed.rage) end
		if aa_enabled:get_override() == false then aa_enabled:override(state.borrowed.aa) end
		if dt:get_override() == false then dt:override(state.borrowed.dt) end
		if hs:get_override() == false then hs:override(state.borrowed.hs) end
		state.borrowed = nil
	end
	state.reset_debug = function()
		state.restore_command()
		state.pending = nil
		state.last_bind = fire:get()
		state.camera_pending = nil
		state.selected = nil
		state.status = "Preview"
	end
	state.reset = function()
		state.reset_debug()
		if next(state.records) then state.records = {} end
		if next(state.results) then state.results = {} end
		state.next_update = nil
		state.input = nil
		state.last_attempt = nil
		state.last_shot_time = nil
	end
	state.begin_command = function(cmd)
		if state.borrowed and state.last_attempt and state.last_attempt.command == cmd.command_number then return end
		state.restore_command()
		state.camera_pending = nil
		state.input = debug:get() and {command = cmd.command_number, angles = copy(cmd.view_angles)} or nil
		if state.last_command and cmd.command_number < state.last_command then state.reset() end
		state.last_command = cmd.command_number
	end

	state.snapshot = function()
		if not active() or not globals.is_in_game then state.reset() return end
		local present = {}
		local interval = globals.tickinterval
		for _, player in ipairs(entity.get_players(true, true)) do
			if player:is_enemy() and not player:is_dormant() and player.m_lifeState == 0 and player_health(player) > 0 then
				local userid = player_identity(player)
				local times = player:get_simulation_time()
				local origin, velocity = player:get_origin(), player.m_vecVelocity
				if times and type(times.current) == "number" and times.current == times.current
					and finite(origin) and finite(velocity) then
					present[userid] = true
					local record = state.records[userid]
					if not record then record = {index = player:get_index(), cadence = 1, burst = 0, bursts = 0, revision = 0} state.records[userid] = record end
					record.index = player:get_index()
					local seed = record.seed
					if seed and times.current < seed.time - interval * 0.5 then
						record.rollback = math.floor((seed.time - times.current) / interval + 0.5)
					elseif seed and math.abs(times.current - seed.time) <= interval * 0.5 then
						record.rollback = 0
					elseif not seed or times.current > seed.time + interval * 0.5 then
						if seed then
							local gap = math.max(1, math.floor((times.current - seed.time) / interval + 0.5))
							record.last_gap = gap
							local moved = distance(origin, seed.origin)
							if gap > 64 or (moved > 128 and gap <= 2) then
								record.cadence, record.burst, record.bursts = 1, 0, 0
								record.burst_at = nil
								state.results[userid] = nil
							else
								record.cadence = math.min(4, record.cadence * 0.75 + gap * 0.25)
								if gap >= 8 or moved > 64 then
									record.burst = record.bursts == 0 and gap - 1 or record.burst * 0.5 + (gap - 1) * 0.5
									record.bursts = record.bursts + 1
									record.burst_at = globals.realtime
								end
							end
							if distance(velocity, seed.velocity) > 80 then record.changed_at = globals.realtime end
						end
						local points = {}
						if type(globals.server_tick) == "number" then
							local offset = globals.server_tick - math.floor(times.current / interval + 0.5)
							if math.abs(offset) <= 128 and (not seed or (record.last_gap or 1) <= 4) then
								local baseline = math.max(0, offset)
								record.clock_base = record.clock_base and math.min(record.clock_base, baseline) or baseline
							end
						end
						for name, id in pairs(point_ids) do
							local point = player:get_hitbox_position(id)
							if finite(point) then points[name] = copy(point) end
						end
						record.seed = {origin = copy(origin), velocity = copy(velocity), flags = player.m_fFlags,
							time = times.current, received = globals.realtime, points = points, duck = player.m_flDuckAmount or 0}
						record.rollback = 0
						record.revision = record.revision + 1
					end
					if record.seed and type(globals.server_tick) == "number" then
						local offset = globals.server_tick - math.floor(record.seed.time / interval + 0.5)
						if not record.clock_base and math.abs(offset) <= 128 then record.clock_base = math.max(0, offset) end
						record.clock_gap = record.clock_base and math.abs(offset) <= 128 and math.max(0, offset - record.clock_base) or 0
					end
				end
			end
		end
		for userid in pairs(state.records) do
			if not present[userid] then state.records[userid] = nil state.results[userid] = nil end
		end
	end

	state.estimate = function(record)
		local seed = record.seed
		if not seed then return end
		local age = math.max(0, math.floor((globals.realtime - seed.received) / globals.tickinterval))
		local missing = math.max(age, record.clock_gap or 0)
		local cap = maximum:get()
		if missing > cap + 8 or distance(seed.velocity, vector()) < 5 then return end
		local ticks, reason
		if record.rollback and record.rollback > 0 then
			ticks, reason = math.max(missing + 1, record.rollback), "ROLLBACK"
		elseif missing > math.ceil(record.cadence) + 1 then
			ticks, reason = missing + 1, (record.clock_gap or 0) > age + 2 and "CLOCK" or "GAP"
		elseif forecast:get() and record.burst_at and globals.realtime - record.burst_at < 0.5 and record.burst >= 2 then
			ticks, reason = math.floor(record.burst + 0.5), "BURST"
		else return end
		local capped = ticks > cap
		ticks = math.max(1, math.min(cap, ticks))
		local score = 0.95 - ticks * 0.012 - age * 0.012
		if reason == "ROLLBACK" then score = score - 0.08 end
		if reason == "BURST" then score = score - (record.bursts >= 2 and 0.05 or 0.12) end
		if record.changed_at and globals.realtime - record.changed_at < 0.2 then score = score - 0.15 end
		if capped then score = score - 0.15 end
		return ticks, reason, math.max(0, math.min(1, score))
	end

	state.update = function(force)
		if not active() or not globals.is_in_game then state.reset() return end
		if not force and state.next_update and globals.realtime < state.next_update then return end
		state.next_update = globals.realtime + 0.05
		local results = {}
		for userid, record in pairs(state.records) do
			local player = entity.get(record.index)
			local ticks, reason, score = state.estimate(record)
			if ticks and player and player_identity(player) == userid and not player:is_dormant() and player.m_lifeState == 0 then
				local seed = record.seed
				local ok, sim = pcall(function()
					local context = player:simulate_movement(copy(seed.origin), copy(seed.velocity), seed.flags)
					context:think(ticks)
					return context
				end)
				if ok and sim and finite(sim.origin) then
					local origin = copy(sim.origin)
					local delta = vector(origin.x - seed.origin.x, origin.y - seed.origin.y, origin.z - seed.origin.z)
					local points = {}
					local duck_delta = ((sim.duck_amount or seed.duck) - seed.duck) * 18
					for name, point in pairs(seed.points) do
						points[name] = vector(point.x + delta.x, point.y + delta.y, point.z + delta.z - duck_delta)
					end
					results[userid] = {index = record.index, userid = userid, origin = origin, from = copy(seed.origin), points = points,
						ticks = ticks, reason = reason, quality = math.max(0, score - (sim.did_hit_collision and 0.1 or 0)),
						mins = finite(sim.obb_mins) and copy(sim.obb_mins) or vector(-16,-16,0),
						maxs = finite(sim.obb_maxs) and copy(sim.obb_maxs) or vector(16,16,72), at = globals.realtime}
				end
			end
		end
		state.results = results
	end

	state.select = function(angles)
		local player = entity.get_local_player()
		if not player or not player:is_alive() then return end
		local eye = player:get_eye_position()
		local best, best_fov
		for userid, result in pairs(state.results) do
			local target = entity.get(result.index)
			local point = result.points[hitbox:get()]
			if target and player_identity(target) == userid and target:is_enemy() and target:is_alive() and not target:is_dormant()
				and result.quality * 100 >= quality:get() and globals.realtime - result.at < 0.15 and finite(point) then
				local delta = vector(point.x - eye.x, point.y - eye.y, point.z - eye.z)
				local aim = delta:angles()
				local pitch_delta = aim.x - angles.x
				local yaw_delta = math.normalize_yaw(aim.y - angles.y)
				local separation = math.sqrt(pitch_delta*pitch_delta + yaw_delta*yaw_delta)
				if separation <= fov:get() and (not best_fov or separation < best_fov) then
					best = {target = target, result = result, point = copy(point), aim = aim, distance = distance(eye, point)}
					best_fov = separation
				end
			end
		end
		return best
	end

	state.try_fire = function(cmd)
		local bind = fire:get()
		if not debug:get() or mode:get() ~= "Fire on bind" then state.pending = nil state.last_bind = bind return end
		if bind and not state.last_bind and ui.get_alpha() <= 0.4 then state.pending = globals.realtime + 0.25 end
		state.last_bind = bind
		if not bind then state.pending = nil end
		if not state.pending then return end
		if globals.realtime > state.pending then state.pending = nil state.status = "No ready shot" return end
		local player = entity.get_local_player()
		if not player or not player:is_alive() or ui.get_alpha() > 0.4 then state.pending = nil return end
		if cmd.in_attack or cmd.in_attack2 or cmd.in_use or cmd.in_reload or cmd.choked_commands ~= 0
			or cmd.force_defensive or get_item_value(fd) or player.m_MoveType == 8 or player.m_MoveType == 9 then return end
		local weapon = player:get_player_weapon()
		local info = weapon and weapon:get_weapon_info()
		if not info or info.weapon_type < 1 or info.weapon_type > 6 or (weapon.m_iClip1 or 0) <= 0 then return end
		local now = player.m_nTickBase * globals.tickinterval
		if (player.m_flNextAttack or 0) > now or (weapon.m_flNextPrimaryAttack or 0) > now then return end
		if state.last_shot_time and globals.realtime - state.last_shot_time < math.max(0.1, info.cycle_time or 0.2) then return end
		local input = state.input and state.input.command == cmd.command_number and state.input.angles or cmd.view_angles
		local selected = state.select(input)
		if not selected then state.status = "No prediction in FOV / quality" return end
		if accuracy:get() and weapon:get_spread() + weapon:get_inaccuracy() > math.atan(6 / math.max(1, selected.distance)) then
			state.status = "Spread too large"
			return
		end
		local trace = utils.trace_line(player:get_eye_position(), selected.point, {player, selected.target}, 0x4600400B)
		if trace.start_solid or trace.all_solid or trace.fraction < 1 then state.status = "Predicted point blocked" return end
		local aim = copy(selected.aim)
		if not finite(aim) then state.status = "Invalid aim" return end
		local punch = player.m_aimPunchAngle
		if punch then
			local scale = cvar.weapon_recoil_scale:float()
			aim.x, aim.y = aim.x - punch.x * scale, aim.y - punch.y * scale
		end
		if not finite(aim) then state.status = "Invalid recoil state" return end
		aim.x, aim.y, aim.z = math.max(-89, math.min(89, aim.x)), math.normalize_yaw(aim.y), 0
		local delta = math.rad(cmd.view_angles.y - aim.y)
		local forward, side = cmd.forwardmove, cmd.sidemove
		cmd.forwardmove = forward * math.cos(delta) + side * math.sin(delta)
		cmd.sidemove = -forward * math.sin(delta) + side * math.cos(delta)
		cmd.move_yaw = aim.y
		state.borrowed = {rage = rage_enabled:get_override(), aa = aa_enabled:get_override(), dt = dt:get_override(), hs = hs:get_override()}
		rage_enabled:override(false)
		aa_enabled:override(false)
		dt:override(false)
		hs:override(false)
		cmd.view_angles = aim
		cmd.in_attack = true
		cmd.no_choke, cmd.send_packet = true, true
		state.pending = nil
		state.last_shot_time = globals.realtime
		state.last_attempt = {at = globals.realtime, command = cmd.command_number, point = copy(selected.point), angles = copy(aim), input = copy(input)}
		state.camera_pending = camera:get()
		state.status = "Command sent"
	end

	state.render = function()
		if not active() or not globals.is_in_game then return end
		local draw = tint:get()
		for userid, result in pairs(state.results) do
			local player = entity.get(result.index)
			if player and player_identity(player) == userid and not player:is_dormant() and player.m_lifeState == 0
				and globals.realtime - result.at < 0.15 and enabled:get() then
				local origin = render.world_to_screen(result.origin)
				local from = render.world_to_screen(result.from)
				if origin then
					if from then render.line(from, origin, draw) end
					render.text(2, vector(origin.x, origin.y + 7), draw, "c", string.format("%s %dt / %d%%", result.reason, result.ticks, math.floor(result.quality*100)))
				end
				local corners = {}
				local mins, maxs, pos = result.mins, result.maxs, result.origin
				for _, point in ipairs({{mins.x,mins.y,mins.z},{maxs.x,mins.y,mins.z},{maxs.x,maxs.y,mins.z},{mins.x,maxs.y,mins.z},
					{mins.x,mins.y,maxs.z},{maxs.x,mins.y,maxs.z},{maxs.x,maxs.y,maxs.z},{mins.x,maxs.y,maxs.z}}) do
					corners[#corners+1] = render.world_to_screen(vector(pos.x+point[1],pos.y+point[2],pos.z+point[3])) or false
				end
				for _, edge in ipairs(edges) do if corners[edge[1]] and corners[edge[2]] then render.line(corners[edge[1]],corners[edge[2]],draw) end end
			end
		end
		if debug:get() then
			if state.selected then
				local point = render.world_to_screen(state.selected.point)
				if point then render.circle(point, draw, 6, 0, 1) render.text(2,vector(point.x,point.y-14),draw,"c","DEBUG POINT") end
			end
			render.text(1,vector(12,render.screen_size().y-85),draw,nil,"PREDICT DEBUG: " .. state.status)
		end
	end

	enabled:set_callback(function() if not active() then state.reset() end end)
	debug:set_callback(function() state.reset_debug() if not active() then state.reset() end end)
	mode:set_callback(state.reset_debug)
	events.net_update_end:set(function() state.snapshot() state.update() end)
	events.round_start:set(state.reset)
	events.level_init:set(state.reset)
	events.cs_game_disconnected:set(state.reset)
	events.shutdown:set(state.reset)
	events.render:set(function()
		if state.last_attempt and state.status == "Command sent" and globals.realtime - state.last_attempt.at > 0.25 then state.status = "No weapon_fire confirmation" end
		state.render()
	end)
	events.override_view:set(function(event)
		local attempt = state.last_attempt
		if state.camera_pending and attempt and globals.realtime - attempt.at <= globals.tickinterval * 2
			and math.abs(event.view.x - attempt.angles.x) < 0.01 and math.abs(math.normalize_yaw(event.view.y - attempt.angles.y)) < 0.01 then
			event.view = copy(attempt.input)
			state.camera_pending = nil
		end
	end)
	events.weapon_fire:set(function(event)
		if state.last_attempt and globals.realtime - state.last_attempt.at < 0.25
			and entity.get(event.userid, true) == entity.get_local_player() then state.status = "weapon_fire observed" end
	end)
	state.run_command = function(cmd)
		if not active() then return end
		state.update()
		if debug:get() then
			state.selected = state.select(state.input and state.input.command == cmd.command_number and state.input.angles or cmd.view_angles)
			state.try_fire(cmd)
		end
	end
end

events.createmove:set(defensive_controller.apply)
events.createmove:set(slow_walk_controller.apply)
events.createmove:set(function() update_health_override() end)
events.createmove:set(teleport_prediction.run_command)
events.net_update_end:set(function() update_health_override() end)
events.render:set(function()
	local localplayer = entity.get_local_player()
	if not localplayer or not localplayer:is_alive() then update_health_override(true) end
end)

-- Final ownership cleanup: no addon override may survive script unload.
events.shutdown:set(function()
	local paths = {
		{"Aimbot", "Ragebot", "Safety", "Global", "Body Aim"},
		{"Aimbot", "Ragebot", "Safety", "Global", "Safe Points"},
		{"Aimbot", "Ragebot", "Selection", "Global", "Hitboxes"},
		{"Aimbot", "Ragebot", "Selection", "Global", "Multipoint"},
		{"Aimbot", "Ragebot", "Main", "Hide Shots"},
		{"Aimbot", "Ragebot", "Main", "Hide Shots", "Options"},
		{"Aimbot", "Ragebot", "Main", "Peek Assist"},
		{"Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"},
		{"Miscellaneous", "Main", "Movement", "Air Strafe"},
		{"Miscellaneous", "Main", "In-Game", "Clan Tag"},
		{"Miscellaneous", "Main", "Other", "Log Events"},
		{"Aimbot", "Anti Aim", "Misc", "Fake Duck"},
		{"Aimbot", "Anti Aim", "Misc", "Leg Movement"},
		{"Aimbot", "Anti Aim", "Misc", "Manual Yaw"},
		{"Aimbot", "Anti Aim", "Misc", "Custom Slow Walk"},
		{"Aimbot", "Anti Aim", "Misc", "Custom Slow Walk", "Mode"},
		{"Aimbot", "Anti Aim", "Misc", "Custom Slow Walk", "Speed"},
		{"Aimbot", "Anti Aim", "Misc", "Custom Slow Walk", "Speed #2"},
		{"Aimbot", "Anti Aim", "Misc", "Custom Slow Walk", "Tick(s)"},
		{"Aimbot", "Anti Aim", "Misc", "Air Exploit"},
		{"Aimbot", "Anti Aim", "Misc", "Air Exploit", "Tick(s)"},
		{"Aimbot", "Anti Aim", "Angles", "Pitch"},
		{"Aimbot", "Anti Aim", "Angles", "Yaw"},
		{"Aimbot", "Anti Aim", "Angles", "Yaw", "Offset"},
		{"Aimbot", "Anti Aim", "Angles", "Yaw", "Base"},
		{"Aimbot", "Anti Aim", "Angles", "Yaw", "Avoid Backstab"},
		{"Aimbot", "Anti Aim", "Angles", "Yaw", "Hidden"},
		{"Aimbot", "Anti Aim", "Angles", "Freestanding"},
		{"Aimbot", "Anti Aim", "Angles", "Freestanding", "Disable Yaw Modifiers"},
		{"Aimbot", "Anti Aim", "Angles", "Freestanding", "Body Freestanding"},
		{"Aimbot", "Anti Aim", "Angles", "Yaw Modifier"},
		{"Aimbot", "Anti Aim", "Angles", "Yaw Modifier", "Offset"},
		{"Aimbot", "Anti Aim", "Angles", "Body Yaw"},
		{"Aimbot", "Anti Aim", "Angles", "Body Yaw", "Left Limit"},
		{"Aimbot", "Anti Aim", "Angles", "Body Yaw", "Right Limit"},
		{"Aimbot", "Anti Aim", "Angles", "Body Yaw", "Inverter"},
		{"Aimbot", "Anti Aim", "Angles", "Body Yaw", "Options"},
		{"Aimbot", "Anti Aim", "Angles", "Body Yaw", "Freestanding"},
		{"Aimbot", "Anti Aim", "Fake Lag", "Enabled"},
		{"Aimbot", "Anti Aim", "Fake Lag", "Limit"},
		{"Aimbot", "Anti Aim", "Fake Lag", "Variability"},
	}

	for _, path in ipairs(paths) do
		local item = ui.find(table.unpack(path))
		if item ~= nil then item:override() end
	end

	ui.find("Miscellaneous", "Main", "In-Game", "Clan Tag"):visibility(true)
	ui.find("Miscellaneous", "Main", "Other", "Log Events"):visibility(true)
	common.set_clan_tag("")

	cvar.cl_lagcompensation:int()
	cvar.sv_maxusrcmdprocessticks:int()
	cvar.r_modelAmbientMin:float()
	cvar["sv_cheats"]:int()
	cvar["sv_pure"]:int()
	cvar["mat_queue_mode"]:int()
	cvar["fps_max"]:int()
	cvar["fps_max_menu"]:int()
	cvar["@panorama_disable_blur"]:int()
end)
