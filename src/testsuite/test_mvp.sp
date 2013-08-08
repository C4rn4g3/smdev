#pragma semicolon 1

#include <sourcemod>
#include <cstrike>

public Plugin:myinfo = 
{
	name = "test mvp",
	author = "./Moriss",
	description = "testing fake mvp",
	version = "1.0",
	url = "moriss.adjustmentbeaver.com"
};

public OnPluginStart()
{
	RegAdminCmd("sm_testmvp", Command_TestMVP, ADMFLAG_KICK);
	HookEvent("round_mvp", Event_RoundMVP);
}

public Action:Command_TestMVP(client, args)
{
	CS_TerminateRound(5.0, CSRoundEnd_TerroristWin);

	new Handle:event = CreateEvent("round_mvp");
	if (event != INVALID_HANDLE)
	{
		SetEventInt(event, "userid", GetClientUserId(client));
		SetEventInt(event, "reason", 2);
		FireEvent(event, false);
		PrintToChat(client, "Fired event round_mvp");
	}

	return Plugin_Handled;
}

public Action:Event_RoundMVP(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	decl String:szReason[64];
	GetEventString(event, "reason", szReason, sizeof(szReason));

	PrintToChatAll("Event Round MVP user: %d, reason: %s", client, szReason);

	return Plugin_Continue;
}