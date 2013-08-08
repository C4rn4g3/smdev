#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define MAX_CMD_LENGTH 128
#define SIZE_OF_INT 2147483647

public Plugin:myinfo = {
	name = "Random Command",
	author = "./Moriss",
	description = "Random Command Picker",
	version = "1.0",
	url = "http://moriss.adjustmentbeaver.com"
}

public OnPluginStart()
{
	RegAdminCmd("sm_testlol122", Command_RandomCmd, ADMFLAG_GENERIC);
}

public Action:Command_RandomCmd(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_random <filename>");
		return Plugin_Handled;
	}

	decl String:szFile[PLATFORM_MAX_PATH];
	GetCmdArgString(szFile, PLATFORM_MAX_PATH);
	StripQuotes(szFile);

	new Handle:hFile = OpenFile(szFile, "r");

	if (hFile == INVALID_HANDLE)
	{
		ReplyToCommand(client, "[SM] Cannot open file \"%s\". Maybe file doesn't exist.", szFile);
		return Plugin_Handled;
	}

	decl String:szBuffer[MAX_CMD_LENGTH];
	Format(szBuffer, MAX_CMD_LENGTH, "");

	while (!IsEndOfFile(hFile))
	{
		ReadFileLine(hFile, szBuffer, MAX_CMD_LENGTH);
		TrimString(szBuffer);
		PrintToServer(szBuffer);
	}

	CloseHandle(hFile);

	return Plugin_Handled;
}