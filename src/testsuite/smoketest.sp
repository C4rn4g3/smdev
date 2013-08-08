/**
 * vim: set ts=4 :
 * =============================================================================
 * Chicken Hegrenades
 * Turns hegrenades into chicken grenades.
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

#define NADE_MODEL "models/chicken/chicken.mdl"
#define DEATH_SOUND "ambient/creatures/chicken_death_02.wav"
#define FLY_SOUND "ambient/creatures/chicken_fly_long.wav"

public Plugin:myinfo =
{
	name = "Chicken Hegrenades",
	author = "./Moriss",
	description = "Turns hegrenades into chicken grenades.",
	version = "1.0",
	url = "http://moriss.adjustmentbeaver.com"
}

public OnPluginStart()
{
	HookEvent("hegrenade_detonate", Event_HEGDetonate);
}

public OnMapStart()
{
	PrecacheModel(NADE_MODEL);
	PrecacheSound(DEATH_SOUND, true);
	PrecacheSound(FLY_SOUND, true);
}

public OnEntityCreated(entity, const String:classname[])
{
	if (IsValidEntity(entity) && IsValidEdict(entity) && (strcmp(classname, "hegrenade_projectile") == 0))
	{
		decl String:szOutput[64];
		Format(szOutput, sizeof(szOutput), "OnUser1 !self:FireUser2::0.1:-1");

		HookSingleEntityOutput(entity, "OnUser2", Event_MissileInit, true);
		SetVariantString(szOutput);

		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");

		EmitSoundToAll(FLY_SOUND, entity, SNDCHAN_AUTO, 90);
	}
}

public Event_MissileInit(const String:output[], entity, activator, Float:delay)
{
	if (!IsValidEntity(entity))
		return;

	SetEntityModel(entity, NADE_MODEL);

	SetVariantString("flap_falling");
	AcceptEntityInput(entity, "SetAnimation", -1, -1, 0);
}

public Event_HEGDetonate(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new Float:vDetonatedOrigin[3];
	vDetonatedOrigin[0] = GetEventFloat(event, "x");
	vDetonatedOrigin[1] = GetEventFloat(event, "y");
	vDetonatedOrigin[2] = GetEventFloat(event, "z");
	
	new tempent = MaxClients+1;
	new entity;

	decl Float:vTempOrigin[3];
	while ((tempent = FindEntityByClassname(tempent, "hegrenade_projectile")) != -1)
	{
		GetEntPropVector(tempent, Prop_Send, "m_vecOrigin", vTempOrigin);
		if (vTempOrigin[0] == vDetonatedOrigin[0] && vTempOrigin[1] == vDetonatedOrigin[1] && vTempOrigin[2] == vDetonatedOrigin[2])
			entity = tempent;
	}

	new particle = CreateEntityByName("info_particle_system");

	if (IsValidEntity(particle) && IsValidEdict(particle))
	{
		TeleportEntity(particle, vDetonatedOrigin, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(particle, "targetname", "vomitptcl");
		DispatchKeyValue(particle, "effect_name", "chicken_gone");
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
	}

	CreateTimer(5.0, Timer_DeleteParticleEffect, particle);
	
	EmitSoundToAll(DEATH_SOUND, entity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 1.0);
}

public Action:Timer_DeleteParticleEffect(Handle:timer, any:entity)
{
	if (IsValidEntity(entity))
		AcceptEntityInput(entity, "Kill");
}