#pragma semicolon 1

#include <sourcemod>
#include "constants"

new Handle:g_hDatabase = INVALID_HANDLE;

enum PlayerData
{
	String:tSteamID[AUTH_LENGTH],
	String:tName[MAX_NAME_LENGTH],
	tScore,
	tCredits,
	tInfections,
	tKills,
	tKnifeKills,
	tEscapes,
	tDeaths,
	tTime
}

new g_PlayerData[MAXPLAYERS+1][PlayerData];
new g_bClientConnected[MAXPLAYERS+1];
new g_iClientResetTime[MAXPLAYERS+1];

public Plugin:myinfo = 
{
	name = "sql test",
	author = "./Moriss",
	description = "test sql handling",
	version = "1.0",
	url = ""
};

public OnPluginStart()
{
	decl String:szError[256];
	g_hDatabase = SQL_Connect("test1", false, szError, sizeof(szError));
	
	if(g_hDatabase == INVALID_HANDLE)
	{
		LogError("Unable to connect to the local database. Reason: \"%s\"", szError);
		return;
	}

	SQL_LockDatabase(g_hDatabase);

	if (!SQL_FastQuery(g_hDatabase, CMD_CREATETABLE))
	{
		LogError("Unable to create players table.");
		return;
	}

	SQL_UnlockDatabase(g_hDatabase);

	HookEvent("player_disconnect", Event_PlayerDisconnect);
	HookEvent("player_death", Event_PlayerDeath);

	RegConsoleCmd("sm_rank", Command_Rank, "Get player rank");
	RegConsoleCmd("sm_stats", Command_Stats, "Show stats menu");
	RegConsoleCmd("sm_top", Command_Top, "Show top 10 players");
	RegConsoleCmd("sm_resetstats", Command_ResetStats, "Reset player stats");

	decl String:szAuth[AUTH_LENGTH];

	for (new i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i) && IsClientAuthorized(i) && !IsFakeClient(i))
		{
			GetClientAuthString(client, szAuth, AUTH_LENGTH)
			RefreshClientData(i, szAuth);
		}
	}
}

public Action:Command_Rank(client, args)
{
	decl String:query[192];
	Format(query, sizeof(query), CMD_GETRANK, g_PlayerData[client][tScore]);
	
	new Handle:hQuery = SQL_Query(g_hDatabase, query);
	new iRank = SQL_GetRowCount(hQuery);
	
	decl String:szName[MAX_NAME_LENGTH];
	GetClientName(client, szName, MAX_NAME_LENGTH);

	PrintToChatAll("(ID: %d) Player's rank is %d", client, iRank);
	
	if(SQL_HasResultSet(hQuery) && SQL_FetchRow(hQuery))
	{
		new iCurrentScore = SQL_FetchInt(hQuery, 0);
		new iNextScore = SQL_FetchInt(hQuery, 1);
		PrintToChatAll("Additional info: current score: %d, next score: %d", iCurrentScore, iNextScore);
	}
	
	return Plugin_Handled;
}

public Action:Command_Stats(client, args)
{
	
}

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (victim == attacker)
		return Plugin_Continue;

	decl String:szWeapon[128];
	GetEventString(event, "weapon", szWeapon, sizeof(szWeapon));

	if (StrContains(szWeapon, "knife", false) != -1)
	{
		++g_PlayerData[attacker][tKnifeKills] ;
		g_PlayerData[attacker][tScore]+=KNIFE_SCORE;
		PrintToChat(attacker, "Got %d points for knife kill", KNIFE_SCORE);
	}
	else if (StrContains(szWeapon, "zombie_claws_of_death", false) != -1)
	{
		++g_PlayerData[attacker][tInfections];
		g_PlayerData[attacker][tScore]+=INFECTION_SCORE;
		PrintToChat(attacker, "Got %d points for infection", INFECTION_SCORE);
	}
	else
	{
		++g_PlayerData[attacker][tKills];
		g_PlayerData[attacker][tScore]+=KILL_SCORE;
		PrintToChat(attacker, "Got %d points for kill", KILL_SCORE);
	}

	++g_PlayerData[victim][tDeaths];

	UpdateClientData(victim);
	UpdateClientData(attacker);

	return Plugin_Continue;
}

public OnClientAuthorized(client, const String:auth[])
{
	if (!IsFakeClient(client))
	{
		Format(g_PlayerData[client][tSteamID], AUTH_LENGTH, auth);
		RefreshClientData(client, auth);
	}
}

public RefreshClientData(client, const String:auth[])
{
	decl String:szQuery[256];
	Format(szQuery, sizeof(szQuery), CMD_GETPLAYER, auth);

	new Handle:hQuery = SQL_Query(g_hDatabase, szQuery);

	if(hQuery == INVALID_HANDLE)
	{
		LogError("Invalid query handle on client authorization");
		return;
	}

	if (SQL_HasResultSet(hQuery) && SQL_FetchRow(hQuery))
	{
		g_PlayerData[client][tScore] = SQL_FetchInt(hQuery, 2);
		g_PlayerData[client][tCredits] = SQL_FetchInt(hQuery, 3);
		g_PlayerData[client][tInfections] = SQL_FetchInt(hQuery, 4);
		g_PlayerData[client][tKills] = SQL_FetchInt(hQuery, 5);
		g_PlayerData[client][tKnifeKills] = SQL_FetchInt(hQuery, 6);
		g_PlayerData[client][tEscapes] = SQL_FetchInt(hQuery, 7);
		g_PlayerData[client][tDeaths] = SQL_FetchInt(hQuery, 8);
		g_PlayerData[client][tTime] = SQL_FetchInt(hQuery, 9);
	}
	else
	{
		decl String:szName[MAX_NAME_LENGTH];
		GetClientName(client, szName, MAX_NAME_LENGTH);

		Format(szQuery, sizeof(szQuery), CMD_CREATEPLAYER, auth, szName);

		new Handle:hQuery2 = SQL_Query(g_hDatabase, szQuery);

		if(hQuery2 == INVALID_HANDLE)
		{
			LogError("Invalid query handle on new player creation");
			return;
		}
	}
}

public UpdateClientData(client)
{
	if (IsFakeClient(client))
		return;

	decl String:szName[MAX_NAME_LENGTH];
	decl String:szAuth[AUTH_LENGTH];

	GetClientName(client, szName, MAX_NAME_LENGTH);
	GetClientAuthString(client, szAuth, AUTH_LENGTH);

	decl String:szQuery[256];
	Format(szQuery, sizeof(szQuery), CMD_SAVEPLAYER, szName, g_PlayerData[client][tScore], g_PlayerData[client][tCredits], g_PlayerData[client][tInfections], g_PlayerData[client][tKills], g_PlayerData[client][tKnifeKills], g_PlayerData[client][tEscapes], g_PlayerData[client][tDeaths], g_PlayerData[client][tTime], szAuth);

	new Handle:hQuery = SQL_Query(g_hDatabase, szQuery);

	if(hQuery == INVALID_HANDLE)
	{
		LogError("Invalid query handle on updating client data");
		return;
	}
}