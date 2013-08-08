#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

public Plugin:myinfo = 
{
	name = "Test VGUI Panel",
	author = "./Moriss",
	description = "asd",
	version = "1.0",
	url = ""
};

public OnPluginStart()
{
	RegConsoleCmd("sm_testpanel", Command_TestPanel);
}


public Action:Command_TestPanel(client, args)
{
	new Handle:hPanel = CreateKeyValues("data");

	KvSetString(hPanel, "title", "Test MOTD Opener");
	KvSetNum(hPanel, "type", MOTDPANEL_TYPE_URL);
	KvSetString(hPanel, "msg", "http://moriss.adjustmentbeaver.com/testpanel/load.html");
	
	ShowVGUIPanel(client, "info", hPanel, false); 

	return Plugin_Handled;
}