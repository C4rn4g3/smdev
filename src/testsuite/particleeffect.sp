/**
 * vim: set ts=4 :
 * =============================================================================
 * Zombie vomit plugin
 * Enables vomit for specified classes
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
#include <sdktools>
#include <zombiereloaded>

#define CVAR_LENGTH 128
#define MAX_CVARS 64

#define OVERLAY_PATH "overlays/zrvomit/zmblyvot"
#define CONFIG_PATH "cfg/sourcemod/vomit_classes.cfg"
#define MAX_CLASSNAME_LENGTH 128

#define VOMIT_MAX "2"
#define VOMIT_DELAY "1.0"
#define VOMIT_DURATION "5.0"
#define VOMIT_EFFECT_DURATION "6.0"
#define VOMIT_RANGE "80.0"
#define VOMIT_COOLDOWN "30.0"

public Plugin:myinfo = 
{
	name = "Zombie Vomit",
	author = "./Moriss",
	description = "Enables vomit for specified zombie classes",
	version = "0.1",
	url = "http://moriss.adjustmentbeaver.com"
};

enum CVarType
{
	TYPE_INT = 0,
	TYPE_FLOAT,
	TYPE_STRING
}

enum CVarCache
{
	Handle:hCvar,
	CVarType:eType,
	any:aCache,
	String:sCache[CVAR_LENGTH],
	Function:fnCallback
}

new g_eCvars[MAX_CVARS][CVarCache];
new g_iCvars = 0;

new g_cvarVomitMax = -1;
new g_cvarVomitDelay = -1;
new g_cvarVomitDuration = -1;
new g_cvarVomitEffectDuration = -1;
new g_cvarVomitRange = -1;
new g_cvarVomitCooldown = -1;
new g_cvarVomitOverlay = -1;
new g_cvarClassConfig = -1;

new bool:g_bClientCheck[MAXPLAYERS+1] = {false, ...};
new bool:g_bClientVomited[MAXPLAYERS+1] = {false, ...};

new bool:g_bClientCooldown[MAXPLAYERS+1] = {false, ...};
new bool:g_bClientMessageCooldown[MAXPLAYERS+1] = {false, ...};

new g_iClientVomits[MAXPLAYERS+1] = {0, ...};

new Handle:g_hClassList = INVALID_HANDLE;
new g_iClassListSize;

new g_iVomits[MAXPLAYERS+1];

public OnPluginStart()
{
	HookEvent("player_spawn", Event_PlayerSpawn);

	g_cvarVomitMax = RegConVar("sm_vomit_max", VOMIT_MAX, "Maximum vomits per player", TYPE_INT);
	g_cvarVomitDelay = RegConVar("sm_vomit_delay", VOMIT_DELAY, "Time between player vomit and blinding", TYPE_FLOAT);
	g_cvarVomitDuration = RegConVar("sm_vomit_duration", VOMIT_DURATION, "Duration of vomit", TYPE_FLOAT);
	g_cvarVomitEffectDuration = RegConVar("sm_vomit_effect_duration", VOMIT_EFFECT_DURATION,"Duration of vomit effect (blind time)", TYPE_FLOAT);
	g_cvarVomitRange = RegConVar("sm_vomit_range", VOMIT_RANGE, "Vomit range", TYPE_FLOAT);
	g_cvarVomitCooldown = RegConVar("sm_vomit_cooldown", VOMIT_COOLDOWN, "Vomit cooldown time", TYPE_FLOAT);
	g_cvarVomitOverlay = RegConVar("sm_vomit_overlay", OVERLAY_PATH, "Vomit overlay path", TYPE_STRING);
	g_cvarClassConfig = RegConVar("sm_vomit_class_config", CONFIG_PATH, "Vomit class config path", TYPE_STRING);

	AutoExecConfig(true, "plugin.vomit");
	LoadTranslations("vomit.phrases");
}

public OnClientPostAdminCheck(client)
{
	g_iVomits[client] = 0;
}

public OnConfigsExecuted()
{
	decl String:szBuffer[PLATFORM_MAX_PATH];
	Format(szBuffer, PLATFORM_MAX_PATH, "%s.vmt", g_eCvars[g_cvarVomitOverlay][sCache]);
	PrecacheDecal(szBuffer, true);
	Format(szBuffer, PLATFORM_MAX_PATH, "materials/%s.vmt", g_eCvars[g_cvarVomitOverlay][sCache]);
	AddFileToDownloadsTable(szBuffer);
	Format(szBuffer, PLATFORM_MAX_PATH, "materials/%s.vtf", g_eCvars[g_cvarVomitOverlay][sCache]);
	AddFileToDownloadsTable(szBuffer);

	ReadConfigFile(g_eCvars[g_cvarClassConfig][sCache]);
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon, &subtype, &cmdnum, &tickcount, &seed, mouse[2])
{
	if ((buttons & IN_RELOAD) && g_bClientCooldown[client] && !g_bClientMessageCooldown[client])
	{
		PrintToChat(client, "\x04[ZR] \x01%t", "Wait some seconds", g_eCvars[g_cvarClassConfig][sCache]);
		g_bClientMessageCooldown[client] = true;
	}

	if  (!(buttons & IN_RELOAD) || g_bClientCooldown[client])
	{
		return Plugin_Continue;
	}

	Command_Vomit(client);

	return Plugin_Continue;
}

public Action:Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	g_iVomits[client] = 0;

	return Plugin_Continue;
}

public Action:Command_Vomit(client)
{
	if (g_bClientCheck[client])
		return Plugin_Continue;

	if (!ZR_IsClientZombie(client))
		return Plugin_Continue;

	if (!IsPlayerClassValid(client))
		return Plugin_Continue;

	new particle = CreateEntityByName("info_particle_system");

	if (IsValidEntity(particle) && IsValidEdict(particle))
	{
		decl String:szClientTargetName[32];
		Format(szClientTargetName, sizeof(szClientTargetName), "Client%d", client);
		DispatchKeyValue(client, "targetname", szClientTargetName);

		new Float:vecOrigin[3];
		new Float:vecAngles[3];
		new Float:vecView[3];
		
		GetClientAbsOrigin(client, vecOrigin);
		GetClientAbsAngles(client, vecAngles);
		
		vecView[0] = Cosine(vecAngles[1] / (180 / FLOAT_PI));
		vecView[1] = Sine(vecAngles[1] / (180 / FLOAT_PI));
		vecView[2] = -Sine(vecAngles[0] / (180 / FLOAT_PI));

		vecView[0] = vecView[0] * 10 + vecOrigin[0];
		vecView[1] = vecView[1] * 10 + vecOrigin[1];
		vecView[2] = vecView[2] * 10 + vecOrigin[2];

		vecView[2] += 60;

		TeleportEntity(particle, vecView, vecAngles, NULL_VECTOR);
		DispatchKeyValue(particle, "targetname", "vomitptcl");
		DispatchKeyValue(particle, "effect_name", "blood_advisor_shrapnel_spurt_2");
		DispatchSpawn(particle);
		SetVariantString(szClientTargetName);
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		SetVariantString("forward");
		AcceptEntityInput(particle, "SetParentAttachment", particle, particle, 0);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");

		g_bClientCheck[client] = true;
		g_bClientCooldown[client] = true;
		g_iClientVomits[client]++;

		CreateTimer(g_eCvars[g_cvarVomitDelay][aCache], Timer_CheckVomit, client);
		CreateTimer(g_eCvars[g_cvarVomitDuration][aCache], Timer_RemoveParticleSystem, particle);
		CreateTimer(g_eCvars[g_cvarVomitDuration][aCache], Timer_DisableVomit, client);
		CreateTimer(g_eCvars[g_cvarVomitCooldown][aCache], Timer_EnableVomit, client);
	}

	return Plugin_Continue;
}

public bool:IsPlayerClassValid(client)
{
	decl String:szClassNameBuf[MAX_CLASSNAME_LENGTH];

	new iClientClass = ZR_GetActiveClass(client);
	ZR_GetClassDisplayName(iClientClass, szClassNameBuf, MAX_CLASSNAME_LENGTH);

	for (new i=0; i<g_iClassListSize; i++)
	{
		decl String:szCfgBuf[MAX_CLASSNAME_LENGTH];
		GetArrayString(g_hClassList, i, szCfgBuf, MAX_CLASSNAME_LENGTH);
		if (StrEqual(szCfgBuf, szClassNameBuf, false))
			return true;
	}
	
	return false;
}

public Action:Timer_CheckVomit(Handle:timer, any:client)
{
	new Float:vClientOrigin[3];
	new Float:vClientAngles[3];
	new Float:vPos[3];
	GetClientAbsOrigin(client, vClientOrigin);
	vClientOrigin[2] += 60;
	GetClientEyeAngles(client, vClientAngles);

	new Handle:trace = TR_TraceRayFilterEx(vClientOrigin, vClientAngles, MASK_SOLID, RayType_Infinite, FilterPlayer, client);

	if (TR_DidHit(trace))
	{
		new i = TR_GetEntityIndex(trace);
		TR_GetEndPosition(vPos, trace);

		if (i != 0)
		{
			if (GetVectorDistance(vClientOrigin, vPos) <= g_eCvars[g_cvarVomitRange][aCache])
				BlindVomited(client, i, g_eCvars[g_cvarVomitEffectDuration][aCache]);
		}
	}

	CloseHandle(trace);

	if (g_bClientCheck[client])
		CreateTimer(0.1, Timer_CheckVomit, client);
}

public bool:FilterPlayer(entity, contentsMask, any:data)
{
	if ((data != entity) && (0 < entity <= MaxClients))
	{
		if (IsPlayerAlive(entity))
			return (!g_bClientVomited[entity] && ZR_IsClientHuman(entity));
		else
			return false;
	}
	else
		return false;
}

public Action:Timer_RemoveParticleSystem(Handle:timer, any:entity)
{
	if (IsValidEntity(entity) && IsValidEdict(entity))
	{
		new String:szClassname[64];
		GetEdictClassname(entity, szClassname, sizeof(szClassname));
		if (StrEqual(szClassname, "info_particle_system", false))
		AcceptEntityInput(entity, "kill");
	}
}

public Action:Timer_DisableVomit(Handle:timer, any:client)
{
	if (!IsClientInGame(client) || !IsPlayerClassValid(client))
		return Plugin_Stop;

	g_bClientCheck[client] = false;

	return Plugin_Stop;
}

public Action:Timer_EnableVomit(Handle:timer, any:client)
{
	if (!IsClientInGame(client))
		return Plugin_Stop;

	if (g_iClientVomits[client] < g_eCvars[g_cvarVomitMax][aCache])
	{
		PrintToChat(client, "\x04[ZR] \x01%t", "Vomit Enabled");
	}

	g_bClientCooldown[client] = false;
	g_bClientMessageCooldown[client] = false;

	return Plugin_Stop;
}

public BlindVomited(attacker, victim, const Float:time)
{
	if (IsClientInGame(victim))
	{
		g_bClientVomited[victim] = true;
		ClientCommand(victim, "r_screenoverlay \"%s\"", g_eCvars[g_cvarVomitOverlay][sCache]);
		PrintToChat(victim, "\x04[ZR] \x01%t", "Blinded By", attacker);
		PrintToChat(attacker, "\x04[ZR] \x01%t", "Blinded Player", victim);
		CreateTimer(time, Timer_UnBlind, victim);
	}
}

public Action:Timer_UnBlind(Handle:timer, any:client)
{
	if (IsClientInGame(client))
	{
		ClientCommand(client, "r_screenoverlay \"\"");
		g_bClientVomited[client] = false;
	}
}

public ReadConfigFile(const String:szFile[])
{	
	if (g_hClassList != INVALID_HANDLE)
	{
		CloseHandle(g_hClassList);
		g_hClassList = INVALID_HANDLE;
	}

	g_hClassList = CreateArray(PLATFORM_MAX_PATH, 0);
	
	new Handle:hFile = OpenFile(szFile, "r");

	if (hFile == INVALID_HANDLE)
	{
		SetFailState("Cannot open config file \"%s\". Maybe file doesn't exist.", szFile);
	}

	decl String:szBuffer[MAX_CLASSNAME_LENGTH];
	Format(szBuffer, MAX_CLASSNAME_LENGTH, "");

	while (!IsEndOfFile(hFile))
	{
		ReadFileLine(hFile, szBuffer, MAX_CLASSNAME_LENGTH);
		TrimString(szBuffer);
		if ((strlen(szBuffer) > 0) && (StrContains(szBuffer, "//") == -1))
		{
			StripQuotes(szBuffer);
			PushArrayString(g_hClassList, szBuffer);
		}
	}

	CloseHandle(hFile);

	g_iClassListSize = GetArraySize(g_hClassList);
	if (g_iClassListSize < 1)
	{
		SetFailState("The file \"%s\" doesn't contain valid data.", szFile);
	}
}

stock RegConVar(String:name[], String:value[], String:description[], CVarType:type, Function:callback=INVALID_FUNCTION, flags=0, bool:hasMin=false, Float:min=0.0, bool:hasMax=false, Float:max=0.0)
{
	new Handle:cvar = CreateConVar(name, value, description, flags, hasMin, min, hasMax, max);
	HookConVarChange(cvar, OnConVarChanged);
	g_eCvars[g_iCvars][hCvar] = cvar;
	g_eCvars[g_iCvars][eType] = type;
	g_eCvars[g_iCvars][fnCallback] = callback;
	CacheCvarValue(g_iCvars);
	return g_iCvars++;
}

public OnConVarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	for (new i=0; i<g_iCvars; ++i)
	{
		if (g_eCvars[i][hCvar]==convar)
		{
			CacheCvarValue(i);
		
			if (g_eCvars[i][fnCallback]!=INVALID_FUNCTION)
			{
				Call_StartFunction(INVALID_HANDLE, g_eCvars[i][fnCallback]);
				Call_PushCell(i);
				Call_Finish();
			}
		
			return;
		}
	}
}

public CacheCvarValue(index)
{
	switch (g_eCvars[index][eType])
	{
		case TYPE_INT:
		{
			g_eCvars[index][aCache] = GetConVarInt(g_eCvars[index][hCvar]);
		}
		case TYPE_FLOAT:
		{
			g_eCvars[index][aCache] = GetConVarFloat(g_eCvars[index][hCvar]);
		}
		case TYPE_STRING:
		{
			GetConVarString(g_eCvars[index][hCvar], g_eCvars[index][sCache], CVAR_LENGTH);
		}
	}
}

public ZR_OnClientInfected(client, attacker, bool:motherInfect, bool:respawnOverride, bool:respawn)
{
	if (IsPlayerClassValid(client))
	{
		PrintToChat(client, "\x04[ZR] \x01%t", "Vomit Usage");
	}
}