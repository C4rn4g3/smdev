#pragma semicolon 1
#include <sourcemod>

public Plugin:myinfo = 
{
	name = "Roll the dice",
	author = "./Moriss",
	description = "Math homework",
	version = "1.0",
	url = ""
};

public OnPluginStart()
{
	RegConsoleCmd("sm_rtd", Command_RTD, "Roll the dice");
}

public Action:Command_RTD(client, args)
{
	new iFaces[6], rn;

	for (new i=1; i<=100; i++)
	{
		rn = GetRandomInt(0,5);
		iFaces[rn]++;
	}

	for (new j=0; j<=5; j++)
		PrintToChat(client, "Face: %d, value: %d", j+1, iFaces[j]);

	return Plugin_Handled;
}