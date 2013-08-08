#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1

public Plugin:myinfo =
{
	name = "SetTransmit Hook Test",
	author = "./Moriss",
	description = "testing only",
	version = "1.0",
	url = ""
};


public OnPluginStart()
{
	RegConsoleCmd("sm_togglestuff", Command_ToggleStuff, "Toggles SetTransmitHook");
}

public Action:Hook_SetTransmit(entity, client)
{
	if (!ShowClientEffects(client))
	{
		return Plugin_Handled;
	}

	new hat = g_iHatIndex[client];
	if( hat && EntRefToEntIndex(hat) == entity )
		return Plugin_Handled;

	return Plugin_Continue;
}

RemoveHat(client)
{
	new ent = g_iHatIndex[client];
	g_iHatIndex[client] = 0;

	if( ent && EntRefToEntIndex(ent) != INVALID_ENT_REFERENCE )
		AcceptEntityInput(ent, "kill");
}

CreateHat(client, index = -1)
{
	if((g_iHatIndex[client] != 0 && EntRefToEntIndex(g_iHatIndex[client]) != INVALID_ENT_REFERENCE) || !IsValidClient(client) )
		return;

	new i;
	if( index == -1 ) // Random hat
		i = GetRandomInt(0, g_iCount -1);
	else if( index == -2 ) // Previous hat
		i = g_iSelected[client];
	else // Specified hat
		i = index;

	new entity = CreateEntityByName("prop_dynamic_override");
	if( entity != -1 )
	{
		SetEntityModel(entity, g_sModels[i]);
		PrintToChat(client, "%sYou are now wearing the \x05[%s] \x03hat.", CHAT_TAG, g_sNames[i]);
		DispatchSpawn(entity);

		decl String:sTemp[64];
		Format(sTemp, sizeof(sTemp), "hat%d%d", entity, client);
		DispatchKeyValue(client, "targetname", sTemp);
		SetVariantString(sTemp);
		AcceptEntityInput(entity, "SetParent", entity, entity, 0);
		SetVariantString("forward");
		AcceptEntityInput(entity, "SetParentAttachment");
		TeleportEntity(entity, g_vPos[i], g_vAng[i], NULL_VECTOR);

		if( GetConVarInt(g_hCvarOpaq) )
		{
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
			SetEntityRenderColor(entity, 255, 255, 255, GetConVarInt(g_hCvarOpaq));
		}

		g_iSelected[client] = i;
		g_iHatIndex[client] = EntIndexToEntRef(entity);
		if( !g_bHatView[client] )
			SDKHook(entity, SDKHook_SetTransmit, Hook_SetTransmit);
	}
}