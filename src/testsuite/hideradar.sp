#pragma semicolon 1
#include <sourcemod>

public Plugin:myinfo = 
{
	name = "Test Radar",
	author = "./Moriss",
	description = "Radar Test",
	version = "1.0",
	url = ""
};

public OnPluginStart()
{
	AddCommandListener(Command_ShowRadar, "drawradar");

	HookEvent("player_spawn", Events_PlayerSpawn);
}

public Action:Command_ShowRadar(client, const String:command[], argc)
{
	return Plugin_Handled;
}

public Action:Events_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	FakeClientCommand(client, "hideradar");
	FakeClientCommandEx(client, "hideradar");

	return Plugin_Continue;
}