#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define HUD_NOTIFY 1
#define HUD_CONSOLE 2
#define HUD_TALK 3
#define HUD_CENTER 4

#define LENGTH_TYPE 256
#define LENGTH_MESSAGE 256

public Plugin:myinfo = 
{
	name = "textmsg test",
	author = "./Moriss",
	description = "test textmsg user message",
	version = "1.0",
	url = ""
};

public OnPluginStart()
{
	RegConsoleCmd("say", Command_Say);
	RegConsoleCmd("say_team", Command_Say);
	//HookUserMessage(GetUserMessageId("TextMsg"), Hook_TextMsg, true);
}

public Action:Hook_TextMsg(UserMsg:MsgId, Handle:hBitBuffer, const iPlayers[], iNumPlayers, bool:bReliable, bool:bInit)
{
	new client = BfReadByte(hBitBuffer);
	new bChat = BfReadByte(hBitBuffer);
	decl String:szType[LENGTH_TYPE];
	decl String:szAuthor[MAX_NAME_LENGTH];
	decl String:szMessage[LENGTH_MESSAGE];
	BfReadString(hBitBuffer, szType, LENGTH_TYPE);
	BfReadString(hBitBuffer, szAuthor, MAX_NAME_LENGTH);
	BfReadString(hBitBuffer, szMessage, LENGTH_MESSAGE);

	PrintToServer("C: %d, bC: %d, T: %s, A: %s, M: %s", client, bChat, szType, szAuthor, szMessage);

	return Plugin_Continue;
}

public Action:Command_Say(client, args)
{
	decl String:szMessage[256];
	GetCmdArgString(szMessage, sizeof(szMessage));
	StripQuotes(szMessage);
	PrintToChatAll("fired %d", strlen(szMessage));

	PrintToChatAll(szMessage);
	return Plugin_Continue;
}