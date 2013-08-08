#pragma semicolon 1

#include <sourcemod>
#include <clientprefs>
#include <stocks>

public Plugin:myinfo = 
{
	name = "Client Time Test",
	author = "./Moriss",
	description = "Testing client time",
	version = "1.0",
	url = ""
};

new Handle:g_hKillCookie = INVALID_HANDLE;
new Handle:g_hInfectionCookie = INVALID_HANDLE;
new Handle:g_hDeathCookie = INVALID_HANDLE;
new Handle:g_hTimeCookie = INVALID_HANDLE;

new g_iClientTime[MAXPLAYERS+1];

new g_bClientConnected[MAXPLAYERS+1];
new g_iClientResetTime[MAXPLAYERS+1];

public OnPluginStart()
{
	RegConsoleCmd("sm_purgetime", Command_PurgeTime, "Purge stored time");
	RegConsoleCmd("sm_stats", Command_Stats, "Show stats menu");
	RegConsoleCmd("sm_rank", Command_Rank, "Show rank menu");
	RegConsoleCmd("sm_top", Command_Top, "Show top 10 players");

	HookEvent("player_disconnect", Event_PlayerDisconnect);

	g_hKillCookie = RegClientCookie("TestKill1", "", CookieAccess_Private);
	g_hInfectionCookie = RegClientCookie("TestInfection1", "", CookieAccess_Private);
	g_hDeathCookie = RegClientCookie("TestDeaths1", "", CookieAccess_Private);
	g_hTimeCookie = RegClientCookie("TestTime1", "", CookieAccess_Private);

	for (new i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			if (AreClientCookiesCached(i))
			{
				new String:szBuffer[128];
				GetClientCookie(i, g_hTimeCookie, szBuffer, sizeof(szBuffer));
				g_iClientTime[i] = StringToInt(szBuffer);

				g_bClientConnected[i] = true;
				g_iClientResetTime[i] = 0;
			}
		}
	}
}

public OnClientCookiesCached(client)
{
	g_bClientConnected[client] = true;

	new String:szBuffer[128];
	GetClientCookie(client, g_hTimeCookie, szBuffer, sizeof(szBuffer));
	g_iClientTime[client] = StringToInt(szBuffer);
	g_iClientResetTime[client] = 0;
}

public Action:Event_PlayerDisconnect(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if ((0 < client <= MaxClients) && IsClientInGame(client) && !IsFakeClient(client) && g_bClientConnected[client])
	{
		new iTime = RoundFloat(GetClientTime(client));
		new String:szBuffer[128];

		Format(szBuffer, sizeof(szBuffer), "%d", g_iClientTime[client]+iTime);

		SetClientCookie(client, g_hTimeCookie, szBuffer);

		g_bClientConnected[client] = false;
	}
}

public Action:Command_Stats(client, args)
{
	new String:szBuffer[256];
	new iHours, iMinutes, iSeconds;
	new iTime = RoundFloat(GetClientTime(client));

	new Handle:hMenu = CreateMenu(MenuHandler_Stats);
	SetMenuExitButton(hMenu, true);
	SetMenuExitBackButton(hMenu, true);

	// Menu Title
	Format(szBuffer, sizeof(szBuffer), "Poison Statistics:\n ");
	SetMenuTitle(hMenu, szBuffer);

	// Kills
	Format(szBuffer, sizeof(szBuffer), "Rank: 0\n ");
	AddMenuItem(hMenu, "player_rank", szBuffer, ITEMDRAW_DISABLED);

	// Points
	Format(szBuffer, sizeof(szBuffer), "Points: 0\nKills: 0\nKnife kills: 0\nInfections: 0\nEscapes: 0\n ");
	AddMenuItem(hMenu, "player_points", szBuffer, ITEMDRAW_DISABLED);

	// KDR
	Format(szBuffer, sizeof(szBuffer), "KDR: 0\n ");
	AddMenuItem(hMenu, "player_kdr", szBuffer, ITEMDRAW_DISABLED);
	
	// Player time
	GetClientCookie(client, g_hTimeCookie, szBuffer, sizeof(szBuffer));
	GetClientTimeEx(client, iTime+g_iClientTime[client]-g_iClientResetTime[client], iHours, iMinutes, iSeconds);

	Format(szBuffer, sizeof(szBuffer), "Time played: %ih %im %is\n ", iHours, iMinutes, iSeconds);
	AddMenuItem(hMenu, "player_time", szBuffer, ITEMDRAW_DISABLED);

	// Purge Stats
	Format(szBuffer, sizeof(szBuffer), "Top 10 Player\n ");
	AddMenuItem(hMenu, "show_rank", szBuffer);

	// Purge Stats
	Format(szBuffer, sizeof(szBuffer), "Reset Stats");
	AddMenuItem(hMenu, "reset_stats", szBuffer);

	DisplayMenu(hMenu, client, 30);
	return Plugin_Handled;
}


public Action:Command_Rank(client, args)
{
	decl String:szClientName[MAX_NAME_LENGTH];
	GetClientName(client, szClientName, sizeof(szClientName));

	ChatAll("{HIGHLIGHT}%s {NORMAL}is ranked at {HIGHLIGHT}%d {NORMAL}with {HIGHLIGHT}%d {NORMAL}points", szClientName, 0, 0);

	return Plugin_Handled;
}

public Action:Command_Top(client, args)
{
	new String:szBuffer[256];

	new Handle:hMenu = CreateMenu(MenuHandler_Top);
	SetMenuExitButton(hMenu, true);
	SetMenuExitBackButton(hMenu, true);

	Format(szBuffer, sizeof(szBuffer), "Top 10 players:\n ");
	SetMenuTitle(hMenu, szBuffer);

	Format(szBuffer, sizeof(szBuffer), "<EMPTY>");
	AddMenuItem(hMenu, "player_rank", szBuffer, ITEMDRAW_DISABLED);

	Format(szBuffer, sizeof(szBuffer), "<EMPTY>");
	AddMenuItem(hMenu, "player_rank", szBuffer, ITEMDRAW_DISABLED);

	Format(szBuffer, sizeof(szBuffer), "<EMPTY>");
	AddMenuItem(hMenu, "player_rank", szBuffer, ITEMDRAW_DISABLED);

	Format(szBuffer, sizeof(szBuffer), "<EMPTY>");
	AddMenuItem(hMenu, "player_rank", szBuffer, ITEMDRAW_DISABLED);

	Format(szBuffer, sizeof(szBuffer), "<EMPTY>");
	AddMenuItem(hMenu, "player_rank", szBuffer, ITEMDRAW_DISABLED);

	Format(szBuffer, sizeof(szBuffer), "<EMPTY>");
	AddMenuItem(hMenu, "player_rank", szBuffer, ITEMDRAW_DISABLED);

	Format(szBuffer, sizeof(szBuffer), "<EMPTY>\n8. <EMPTY>\n9. <EMPTY>\n10. <EMPTY>");
	AddMenuItem(hMenu, "player_rank", szBuffer, ITEMDRAW_DISABLED);

	DisplayMenu(hMenu, client, 30);
	return Plugin_Handled;
}

public MenuHandler_Stats(Handle:menu, MenuAction:action, client, param2)
{
	new String:info[256];
	new String:name[256];

	GetMenuItem(menu, param2, info, sizeof(info), _, name, sizeof(name));
	if (action == MenuAction_Select)
	{
		if (StrEqual(info, "show_rank", false))
		{
			FakeClientCommandEx(client, "sm_rank");
		}
		else if (StrEqual(info, "reset_stats", false))
		{
			FakeClientCommandEx(client, "sm_purgetime");
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if(action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
	{
		FakeClientCommandEx(client, "sm_menu");
	}
}

public MenuHandler_Top(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if(action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
	{
		FakeClientCommandEx(client, "sm_stats");
	}
}
public Action:Command_PurgeTime(client, args)
{
	new iTime = RoundFloat(GetClientTime(client));

	g_iClientResetTime[client] = iTime;

	g_iClientTime[client] = 0;
	SetClientCookie(client, g_hTimeCookie, "0");
	
	Chat(client, "Purged your time");

	return Plugin_Handled;
}

public GetClientTimeEx(client, iTime, &iHours, &iMinutes, &iSeconds)
{
	iHours = iTime/3600;
	iMinutes = (iTime/60) - (iHours*60);
	iSeconds = (iTime) - (iMinutes*60) - (iHours*3600);
}