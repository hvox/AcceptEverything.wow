--[[
## Interface: 30300
## Title: AcceptEverything
## Version: 1.0.0
## Author: hvox
## Notes: Testing the thing, no notes.
]]

local AddonFrame = CreateFrame("Frame")

local function trim(s)
	return s:match("^%s*(.-)%s*$")
end

local function mount()
	for i = 1, GetNumCompanions("MOUNT") do
		local id, name, spell, icon, summoned, type = GetCompanionInfo("MOUNT", i)
		if IsFlyableArea() and (type == 15 or type == 31) then
			CallCompanion("MOUNT", i)
			return
		end
	end
	for i = 1, GetNumCompanions("MOUNT") do
		local id, name, spell, icon, summoned, type = GetCompanionInfo("MOUNT", i)
		if type == nil or type == 12 or type == 29 then
			CallCompanion("MOUNT", i)
			return
		end
	end
	UIErrorsFrame:AddMessage("No mount found", 1.0, 0.0, 0.0, 123, 30)
end

local function handle_chat_event(message, sender)
	local cmd, arg = trim(message):match("^(%S+)%s*(.*)")
	cmd = cmd:lower()
	if cmd == "follow" and (arg == "" or arg == "me") then
		FollowUnit(sender)
	elseif cmd == "follow" and arg ~= "" then
		-- TODO: fuzy search in party
		FollowUnit(arg)
	elseif (cmd == "unfollow" or cmd == "stop") and arg == "" then
		FollowUnit("player")
	elseif cmd == "mount" and arg == "" then
		mount()
	elseif (cmd == "dismount" or cmd == "unmount") and arg == "" then
		Dismount()
	elseif cmd == "lets" or cmd == "let's" then
		-- TODO: check if emote exists
		DoEmote(arg, "none")
	end
end

local function handle_event(self, event, ...)
	if event == "CHAT_MSG_PARTY"
		or event == "CHAT_MSG_PARTY_LEADER"
		or event == "CHAT_MSG_RAID"
		or event == "CHAT_MSG_RAID_LEADER"
		or event == "CHAT_MSG_WHISPER" then
		local message, sender = ...
		handle_chat_event(message, sender)
	elseif event == "PARTY_INVITE_REQUEST" then
		local leader = ...
		for i = 1, GetNumFriends() do
			local name, lvl, class, location, online, status, note = GetFriendInfo(i)
			if name == leader then
				AcceptGroup()
				return
			end
		end
	end
end

local function initialize_handlers(self, event)
	AddonFrame:UnregisterEvent("PLAYER_LOGIN")
	AddonFrame:SetScript("OnEvent", handle_event)
	AddonFrame:RegisterEvent("CHAT_MSG_PARTY")
	AddonFrame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
	AddonFrame:RegisterEvent("CHAT_MSG_RAID")
	AddonFrame:RegisterEvent("CHAT_MSG_RAID_LEADER")
	AddonFrame:RegisterEvent("CHAT_MSG_WHISPER")
	AddonFrame:RegisterEvent("PARTY_INVITE_REQUEST")
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
