/**
 * vim: set ts=4 :
 * =============================================================================
 * Clan Tag Checker
 * Monitors players' clantags and kicks them if they use banned clantags.
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
#include <cstrike>

public Plugin:myinfo = 
{
	name = "Clan Tag Checker",
	author = "./Moriss",
	description = "Kicks players with banned clantags",
	version = "1.0",
	url = "http://moriss.adjustmentbeaver.com"
};

new String:g_szClanTags[][] =
{
	"PoisonElites",
	"PoisonElite"
};

public OnPluginStart()
{
	LoadTranslations("clantagcheck.phrases");
}

public OnClientSettingsChanged(client)
{
	if (IsClientInGame(client))
	{
		decl String:szClanTag[64];
		CS_GetClientClanTag(client, szClanTag, sizeof(szClanTag));

		for (new i=0; i<sizeof(g_szClanTags); i++)
		{
			if (StrEqual(szClanTag, g_szClanTags[i], false))
				KickClient(client, "%t", "Banned clan tag");
		}

		CS_SetClientClanTag(client, "");
	}
}