#include <sdktools>
#include <sourcemod>

public Plugin:myinfo = 
{
	name = "SendAudio Tester",
	author = "./Moriss",
	description = "Testing SendAudio User Message",
	version = "1.0",
	url = ""
}

public OnPluginStart()
{
	HookUserMessage(GetUserMessageId("SendAudio"), UserMessageSendAudio, true);
}

public Action:UserMessageSendAudio(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init) 
{
	decl String:szMessage[256];
	BfReadString(bf, szMessage, sizeof(szMessage));

	new Handle:pack;
	CreateDataTimer(0.1, Timer_ChatAll, pack);
	WritePackString(pack, szMessage);
	
	return Plugin_Continue;
}

public Action:Timer_ChatAll(Handle:timer, Handle:pack)
{
	decl String:szMessage[128];

	ResetPack(pack);
	ReadPackString(pack, szMessage, sizeof(szMessage));

	PrintToChatAll(szMessage);
}