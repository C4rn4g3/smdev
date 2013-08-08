#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define JUMP_DISTANCE_MULTIPLIER 1.0
#define JUMP_HEIGHT_MULTIPLIER 1.0


public Events_OnPluginStart()
{
	HookEvent("player_jump", Events_PlayerJump);
}

public Action:Events_PlayerJump(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!client || !IsClientInGame(client))
		return Plugin_Continue;
		
	OnPlayerJump(client);
	return Plugin_Continue;
}


public OnPlayerJump(client)
{
	if (IsPlayerAlive(client))
		CreateTimer(0.0, OnPlayerJumpPost, client);
}

public Action:OnPlayerJumpPost(Handle:timer, any:client)
{
	if(!client)
		return Plugin_Stop;
	
	decl Float:fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fVelocity);

	if (!JumpBoostIsBHop(fVelocity))
    {
		fVelocity[0] *= JUMP_DISTANCE_MULTIPLIER;
		fVelocity[1] *= JUMP_DISTANCE_MULTIPLIER;
		fVelocity[2] *= JUMP_HEIGHT_MULTIPLIER;
	}

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);	
	
	return Plugin_Stop;
}

stock bool:JumpBoostIsBHop(const Float:vecVelocity[])
{    
	new Float:magnitude = SquareRoot(Pow(vecVelocity[0], 2.0) + Pow(vecVelocity[1], 2.0));
	return (magnitude > 200.0);
}