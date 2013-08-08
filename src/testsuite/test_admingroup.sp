#include <sourcemod>

#pragma semicolon 1

enum PlayerData
{
	iUserId,
	AdminId:iAdminId,
	iFlags,
	iHumanClass,
	iZombieClass,
	bool:bInfected,
	bool:bMother
}

new g_ePlayerData[MAXPLAYERS+1][PlayerData];

public Plugin:myinfo = 
{
	name = "***TEST*** admingroup test",
	author = "./Moriss",
	description = "test admin group handling",
	version = "1.0",
	url = ""
};

public OnPluginStart()
{
	RegAdminCmd("sm_testgrp", Command_TestGroup, ADMFLAG_ROOT, "test admin group");
	
	for(new i=1;i<=MaxClients;++i)
	{
		if(!IsClientInGame(i))
			continue;
		OnClientPostAdminCheck(i);
	}

	LoadTranslations("admincmds.phrases");
}

public OnClientPostAdminCheck(client)
{
	g_ePlayerData[client][iAdminId] = GetUserAdmin(client);
}

public Action:Command_TestGroup(client, args)
{
	decl String:szPattern[MAX_NAME_LENGTH];
	decl String:szGroup[MAX_NAME_LENGTH];
	
	GetCmdArg(1, szPattern, sizeof(szPattern));
	GetCmdArg(2, szGroup, sizeof(szGroup));
	
	new aiTargets[MAXPLAYERS];
	new iTargets = ProcessTarget(client, szPattern, aiTargets, sizeof(aiTargets), COMMAND_FILTER_CONNECTED);

	if (iTargets == -1)
		return Plugin_Handled;

	for (new i = 0; i < iTargets; i++)
	{
		if (GetAdminGroupMembership(g_ePlayerData[aiTargets[i]][iAdminId], szGroup) > -1)
		{
			PrintToChat(client, "%d true", aiTargets[i]);
		}
		else
		{
			PrintToChat(client, "%d false", aiTargets[i]);
		}
	}

	return Plugin_Handled;
}

public ProcessTarget(client, const String:szPattern[], aiTargets[], size, flags)
{
	new iTargets;
	new bool:ml;
	decl String:szBuffer[MAX_NAME_LENGTH];
	iTargets = ProcessTargetString(szPattern, client, aiTargets, size, flags, szBuffer, sizeof(szBuffer), ml);

	if (iTargets < 0)
		ReplyToCommand(client, "%T", "Bad target", client, szPattern);
		
	if (iTargets == 0)
		ReplyToCommand(client, "%T", "No target", client, szPattern);

	if (iTargets < 1)
		return -1;
	else
		return iTargets;
}

public GetAdminGroupMembership(AdminId:iAdminID, const String:szGroup[])
{
	if (iAdminID == INVALID_ADMIN_ID)
		return -1;

	new iGroupCount;
	new String:szBuffer[128];

	iGroupCount = GetAdminGroupCount(iAdminID);

	for (new i=0; i<iGroupCount; i++)
	{
		GetAdminGroup(iAdminID, i, szBuffer, sizeof(szBuffer));
		if (StrEqual(szBuffer, szGroup, false))
			return i;
	}

	return -1;
}