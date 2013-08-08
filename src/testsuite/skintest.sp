#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <cstrike>

#define MODEL_NAME_LENGTH 128

#define MAX_SKINS 64

public Plugin:myinfo =
{
	name = "Skin Test",
	author = "./Moriss",
	description = "Skin test",
	version = "1.0",
	url = "http://moriss.adjustmentbeaver.com"
};

enum SkinInfo {
	String:tszModelPath[PLATFORM_MAX_PATH],
	String:tszModelName[MODEL_NAME_LENGTH],
	tiTeam
}

new g_Skins[MAX_SKINS][SkinInfo];
new g_iSkinCount;

public OnPluginStart()
{
	RegConsoleCmd("sm_skins", Command_Skins);
}

public OnMapStart()
{
	g_iSkinCount = 0;

	decl String:szPathBuffer[PLATFORM_MAX_PATH];
	decl String:szNameBuffer[MODEL_NAME_LENGTH];
	BuildPath(Path_SM, szPathBuffer, PLATFORM_MAX_PATH, "configs/skinlist.cfg");

	new Handle:hKv = CreateKeyValues("SkinList");
	FileToKeyValues(hKv, szPathBuffer);

	KvRewind(hKv);
	if (KvJumpToKey(hKv, "Terrorists"))
	{
		if (KvGotoFirstSubKey(hKv))
		{
			do
			{
				g_iSkinCount++;

				KvGetSectionName(hKv, szNameBuffer, sizeof(szNameBuffer));
				Format(g_Skins[g_iSkinCount][tszModelName], MODEL_NAME_LENGTH, szNameBuffer);

				KvGetString(hKv, "Path", szPathBuffer, MODEL_NAME_LENGTH);
				Format(g_Skins[g_iSkinCount][tszModelPath], PLATFORM_MAX_PATH, szPathBuffer);
				PrecacheModel(g_Skins[g_iSkinCount][tszModelPath], true);

				g_Skins[g_iSkinCount][tiTeam] = CS_TEAM_T;
			}
			while (KvGotoNextKey(hKv));

			KvGoBack(hKv);
		}
	}

	KvRewind(hKv);
	if (KvJumpToKey(hKv, "Counter-Terrorists"))
	{
		if (KvGotoFirstSubKey(hKv))
		{
			do
			{
				g_iSkinCount++;

				KvGetSectionName(hKv, szNameBuffer, sizeof(szNameBuffer));
				Format(g_Skins[g_iSkinCount][tszModelName], MODEL_NAME_LENGTH, szNameBuffer);

				KvGetString(hKv, "Path", szPathBuffer, MODEL_NAME_LENGTH);
				Format(g_Skins[g_iSkinCount][tszModelPath], PLATFORM_MAX_PATH, szPathBuffer);
				PrecacheModel(g_Skins[g_iSkinCount][tszModelPath], true);

				g_Skins[g_iSkinCount][tiTeam] = CS_TEAM_CT;
			}
			while (KvGotoNextKey(hKv));

			KvGoBack(hKv);
		}
	}

	CloseHandle(hKv);
}

public Action:Command_Skins(client, args)
{
	new Handle:hMenu = CreateMenu(MenuHandler_Skins);

	SetMenuExitButton(hMenu, true);

	SetMenuTitle(hMenu, "Choose a skin category:\n ");

	AddMenuItem(hMenu, "tskins", "Terrorist Skins");
	AddMenuItem(hMenu, "ctskins", "CT Skins");

	DisplayMenu(hMenu, client, 0);

	return Plugin_Handled;
}

public MenuHandler_Skins(Handle:menu, MenuAction:action, client, param2)
{
	new String:szInfo[256];
	new String:szName[256];

	GetMenuItem(menu, param2, szInfo, sizeof(szInfo), _, szName, sizeof(szName));

	if (action == MenuAction_Select)
	{
		if (StrEqual(szInfo, "tskins", false))
		{
			Command_TSkins(client, 0);
		}
		else if (StrEqual(szInfo, "ctskins", false))
		{
			Command_CTSkins(client, 0);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:Command_TSkins(client, args)
{
	new Handle:hMenu = CreateMenu(MenuHandler_SkinSelect);

	SetMenuExitButton(hMenu, true);
	SetMenuExitBackButton(hMenu, true);

	SetMenuTitle(hMenu, "Choose a Terrorist skin:\n ");
	
	for (new i=1; i<=g_iSkinCount; i++)
	{
		if (g_Skins[i][tiTeam] == CS_TEAM_T)
			AddMenuItem(hMenu, g_Skins[i][tszModelPath], g_Skins[i][tszModelName]);
	}

	DisplayMenu(hMenu, client, 0);
	
	return Plugin_Handled;
}

public Action:Command_CTSkins(client, args)
{
	new Handle:hMenu = CreateMenu(MenuHandler_SkinSelect);

	SetMenuExitButton(hMenu, true);
	SetMenuExitBackButton(hMenu, true);

	SetMenuTitle(hMenu, "Choose a CT skin:\n ");
	
	for (new i=1; i<=g_iSkinCount; i++)
	{
		if (g_Skins[i][tiTeam] == CS_TEAM_CT)
			AddMenuItem(hMenu, g_Skins[i][tszModelPath], g_Skins[i][tszModelName]);
	}

	DisplayMenu(hMenu, client, 0);
	
	return Plugin_Handled;
}

public MenuHandler_SkinSelect(Handle:menu, MenuAction:action, client, param2)
{
	new String:szInfo[256];
	new String:szName[256];

	GetMenuItem(menu, param2, szInfo, sizeof(szInfo), _, szName, sizeof(szName));

	if (action == MenuAction_Select)
	{
		SetEntityModel(client, szInfo);

		PrintToChat(client, "You've changed your skin to \x04%s", szName);
	}
	else if(action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
	{
		Command_Skins(client, 0);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}