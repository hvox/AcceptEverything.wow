--[[
## Interface: 30300
## Title: AcceptEverything
## Version: 1.0.0
## Author: hvox
## Notes: Testing the thing, no notes.
]]

local AddonFrame = CreateFrame("Frame")
local AddonName = "AcceptEverything"

local function trim(s)
	return s:match("^%s*(.-)%s*$")
end

local function log_accept(action_name)
	local message = action_name .. " auto-accepted by " .. AddonName
	UIErrorsFrame:AddMessage(message, 1.0, 1.0, 1.0, 132, 5)
end

local function mount()
	local slow_ground = nil
	local fast_ground = nil
	local slow_flying = nil
	local fast_flying = nil
	for i = 1, GetNumCompanions("MOUNT") do
		local id, name, spell, icon, summoned, type = GetCompanionInfo("MOUNT", i)
		name = name:lower()
		if name:find("drake") then
			fast_flying = i
		elseif name:find("wind") or name:find("gryphon") then
			slow_flying = i
		elseif name:find("swift") then
			fast_ground = i
		else
			slow_ground = i
		end
	end
	local mount = fast_flying or slow_flying or fast_ground or slow_ground
	if not IsFlyableArea() then
		mount = fast_ground or slow_ground
	end
	if mount ~= nil then
		local id, name, spell, icon, summoned, type = GetCompanionInfo("MOUNT", mount)
		log_accept("Mounting on " .. name)
		CallCompanion("MOUNT", mount)
	else
		UIErrorsFrame:AddMessage("No mount found", 1.0, 0.0, 0.0, 123, 30)
	end
end

local function handle_chat_event(message, sender)
	local cmd, arg = trim(message):match("^(%S+)%s*(.*)")
	cmd = cmd:lower()
	if cmd == "follow" and (arg == "" or arg == "me") then
		FollowUnit(sender)
		log_accept("Follow request")
	elseif cmd == "follow" and arg ~= "" then
		-- TODO: fuzy search in party
		FollowUnit(arg)
		log_accept("Follow request")
	elseif (cmd == "unfollow" or cmd == "stop") and arg == "" then
		FollowUnit("player")
		log_accept("Stop request")
	elseif cmd == "mount" and arg == "" then
		mount()
	elseif (cmd == "dismount" or cmd == "unmount" or cmd == "umount") and arg == "" then
		Dismount()
		log_accept("Dismount")
	elseif cmd == "lets" or cmd == "let's" then
		-- TODO: check if emote exists
		DoEmote(arg, "none")
		log_accept("Emote")
	end
end

local function handle_event(self, event, ...)
	if event == "RESURRECT_REQUEST" then
		local inviter = ...
		AcceptResurrect(UnitName("player"))
		log_accept("Resurrection by " .. inviter)
	elseif event == "TRADE_REQUEST" then
		print("Trade requested by " .. ...)
	elseif event == "CHAT_MSG_PARTY"
		or event == "CHAT_MSG_PARTY_LEADER"
		or event == "CHAT_MSG_RAID"
		or event == "CHAT_MSG_RAID_LEADER"
		or event == "CHAT_MSG_WHISPER" then
		local message, sender = ...
		handle_chat_event(message, sender)
	elseif event == "PARTY_INVITE_REQUEST" then
		local leader = ...
		for i = 1, GetNumFriends() do
			local friend, lvl, class, location, online, status, note = GetFriendInfo(i)
			if leader == friend then
				AcceptGroup()
				log_accept("Party invite by " .. leader)
				print("Invited into party by " .. leader)
				return
			end
		end
	end
end

local function initialize_handlers(self, event)
	AddonFrame:UnregisterEvent("PLAYER_LOGIN")
	AddonFrame:SetScript("OnEvent", handle_event)
	AddonFrame:RegisterEvent("RESURRECT_REQUEST")
	AddonFrame:RegisterEvent("CHAT_MSG_PARTY")
	AddonFrame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
	AddonFrame:RegisterEvent("CHAT_MSG_RAID")
	AddonFrame:RegisterEvent("CHAT_MSG_RAID_LEADER")
	AddonFrame:RegisterEvent("CHAT_MSG_WHISPER")
	AddonFrame:RegisterEvent("PARTY_INVITE_REQUEST")
	AddonFrame:RegisterEvent("TRADE_REQUEST")
	-- message("AcceptEverything addon loaded")
	local message = "AcceptEverything addon has been successfully loaded"
	local message_id = 12345 -- message_id can be any number, right?
	local message_duration = 60 -- I think this parameter is just ignored
	UIErrorsFrame:AddMessage(
		message,
		1.0, 1.0, 1.0,
		message_id,
		message_duration
	)
end

AddonFrame:SetScript("OnEvent", initialize_handlers)
AddonFrame:RegisterEvent("PLAYER_LOGIN")
