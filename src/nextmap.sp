/**
 * vim: set ts=4 :
 * =============================================================================
 * Sourcemod Next Map plugin, extended by ./Moriss
 * Basic Next Map functions with extended features.
 *
 * Copyright (C) 2013 István Telek
 * =============================================================================
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * For SourceMod License see <http://www.sourcemod.net/license.php>.
 *
 */

#pragma semicolon 1

#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <mapchooser>
#define REQUIRE_PLUGIN
#include <chat>

public Plugin:myinfo = 
{
	name = "Nextmap",
	author = "AlliedModders LLC, ./Moriss",
	description = "Provides commands with map management",
	version = SOURCEMOD_VERSION,
	url = "http://www.sourcemod.net/"
};
 
new g_MapPos = -1;
new Handle:g_MapList = INVALID_HANDLE;
new g_MapListSerial = -1;
new bool:g_bMapChooser;

public OnPluginStart()
{	
	LoadTranslations("common.phrases");
	LoadTranslations("nextmap.phrases");

	g_MapList = CreateArray(32);

	decl String:currentMap[64];
	GetCurrentMap(currentMap, 64);
	SetNextMap(currentMap);

	RegAdminCmd("sm_setnextmap", Command_SetNextMap, ADMFLAG_GENERIC, "Sets the next map");
	RegConsoleCmd("nextmap", Command_Nextmap);
	
	AddCommandListener(Command_Say, "say");
	AddCommandListener(Command_Say, "say2");
	AddCommandListener(Command_Say, "say_team");
	
	g_bMapChooser = LibraryExists("mapchooser");
}

public OnConfigsExecuted()
{
	decl String:lastMap[64], String:currentMap[64];
	GetNextMap(lastMap, sizeof(lastMap));
	GetCurrentMap(currentMap, 64);
	
	if (strcmp(lastMap, currentMap) == 0)
	{
		FindAndSetNextMap();
	}
}

public OnLibraryRemoved(const String:name[])
{
	if (StrEqual(name, "mapchooser"))
	{
		g_bMapChooser = false;
	}
}
 
public OnLibraryAdded(const String:name[])
{
	if (StrEqual(name, "mapchooser"))
	{
		g_bMapChooser = true;
	}
}

public FindAndSetNextMap()
{
	if (ReadMapList(g_MapList, g_MapListSerial, "nextmap", MAPLIST_FLAG_CLEARARRAY) == INVALID_HANDLE)
	{
		if (g_MapListSerial == -1)
		{
			LogError("FATAL: Cannot load map cycle. Nextmap not loaded.");
			SetFailState("Mapcycle Not Found");
		}
	}
	
	new mapCount = GetArraySize(g_MapList);
	decl String:mapName[32];
	
	if (g_MapPos == -1)
	{
		decl String:current[64];
		GetCurrentMap(current, 64);

		for (new i = 0; i < mapCount; i++)
		{
			GetArrayString(g_MapList, i, mapName, sizeof(mapName));
			if (strcmp(current, mapName, false) == 0)
			{
				g_MapPos = i;
				break;
			}
		}
		
		if (g_MapPos == -1)
			g_MapPos = 0;
	}
	
	g_MapPos++;
	if (g_MapPos >= mapCount)
		g_MapPos = 0;	
 
 	GetArrayString(g_MapList, g_MapPos, mapName, sizeof(mapName));
	SetNextMap(mapName);
}

public Action:Command_SetNextMap(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: sm_setnextmap <mapname>");
		return Plugin_Handled;
	}

	decl String:szMapName[64];
	GetCmdArg(1, szMapName, sizeof(szMapName));

	if (SetNextMap(szMapName))
		ReplyToCommand(client, "[SM] %t", "Set next map to", szMapName);
	else
		ReplyToCommand(client, "[SM] %t", "Failed to set next map", szMapName);

	return Plugin_Handled;
}

public Action:Command_Say(client, const String:command[], argc)
{
	decl String:text[192];
	new startidx = 0;
	if (GetCmdArgString(text, sizeof(text)) < 1)
	{
		return Plugin_Continue;
	}
	
	if (text[strlen(text)-1] == '"')
	{
		text[strlen(text)-1] = '\0';
		startidx = 1;
	}

	if (strcmp(command, "say2", false) == 0)
		startidx += 4;

	if (strcmp(text[startidx], "nextmap", false) == 0)
	{
		decl String:map[32];
		GetNextMap(map, sizeof(map));
			
		if (g_bMapChooser && EndOfMapVoteEnabled() && !HasEndOfMapVoteFinished())
		{
			ChatAll(MsgType_Info, "%t", "Pending Vote");			
		}
		else
		{
			ChatAll(MsgType_Info, "%t", "Next Map", map);
		}
	}
	else if (strcmp(text[startidx], "currentmap", false) == 0)
	{
		decl String:map[64];
		GetCurrentMap(map, sizeof(map));
		
		ChatAll(MsgType_Info, "%t", "Current Map Name", map);
	}
	
	return Plugin_Continue;
}

public Action:Command_Nextmap(client, args)
{
	if (client && !IsClientInGame(client))
		return Plugin_Handled;
	
	decl String:map[64];
	
	GetNextMap(map, sizeof(map));
	
	if (g_bMapChooser && EndOfMapVoteEnabled() && !HasEndOfMapVoteFinished())
	{
		Chat(MsgType_Info, client, "%t", "Pending Vote");			
	}
	else
	{
		Chat(MsgType_Info, client, "%t", "Next Map", map);
	}
	
	return Plugin_Handled;
}