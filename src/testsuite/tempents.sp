#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

public Plugin:myinfo = 
{
	name = "TempEnt Test",
	author = "./Moriss",
	description = "Testing temp ents",
	version = "1.0",
	url = "http://moriss.adjustmentbeaver.com"
};

public OnPluginStart()
{
	// AddTempEntHook("BSP Decal", TEHook);
	AddTempEntHook("Blood Sprite", TEHook);
	AddTempEntHook("Blood Stream", TEHook);
	// AddTempEntHook("Bomb Plant", TEHook);
	// AddTempEntHook("Dust", TEHook);
	// AddTempEntHook("EffectDispatch", TEHook);
	// AddTempEntHook("Footprint Decal", TEHook);
	AddTempEntHook("Impact", TEHook);
	// AddTempEntHook("KillPlayerAttachments", TEHook);
	// AddTempEntHook("Large Funnel", TEHook);
	AddTempEntHook("Player Decal", TEHook);
	// AddTempEntHook("PlayerAnimEvent", TEHook);
	AddTempEntHook("Projected Decal", TEHook);
	// AddTempEntHook("RadioIcon", TEHook);
	AddTempEntHook("Shotgun Shot", TEHook);
	// AddTempEntHook("Smoke", TEHook);
	// AddTempEntHook("Sprite", TEHook);
	// AddTempEntHook("Sprite Spray", TEHook);
	// AddTempEntHook("Surface Shatter", TEHook);
	// AddTempEntHook("World Decal", TEHook);
	// AddTempEntHook("breakmodel", TEHook);
}

public Action:TEHook(const String:te_name[], const Players[], numclients, Float:delay)
{
	return Plugin_Handled;

 // -Member: m_vecOrigin (offset 16)
 // -Member: m_vecAngles[0] (offset 28)
 // -Member: m_vecAngles[1] (offset 32)
 // -Member: m_iWeaponID (offset 40)
 // -Member: m_iMode (offset 44)
 // -Member: m_iSeed (offset 48)
 // -Member: m_iPlayer (offset 12)
 // -Member: m_flSpread (offset 52)
}