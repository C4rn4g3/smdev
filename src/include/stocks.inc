#if defined _stocks_included
 #endinput
#endif
#define _stocks_included

#define CVAR_LENGTH 128

#define MAX_CVARS 64

enum CVAR_TYPE
{
	TYPE_INT = 0,
	TYPE_FLOAT,
	TYPE_STRING,
	TYPE_FLAG
}

enum CVAR_CACHE
{
	Handle:hCvar,
	CVAR_TYPE:eType,
	any:aCache,
	String:sCache[CVAR_LENGTH],
	Function:fnCallback
}

new g_eCvars[MAX_CVARS][CVAR_CACHE];

new g_iCvars = 0;

stock RegisterConVar(String:name[], String:value[], String:description[], CVAR_TYPE:type, Function:callback=INVALID_FUNCTION, flags=0, bool:hasMin=false, Float:min=0.0, bool:hasMax=false, Float:max=0.0)
{
	new Handle:cvar = CreateConVar(name, value, description, flags, hasMin, min, hasMax, max);
	HookConVarChange(cvar, GlobalConVarChanged);
	g_eCvars[g_iCvars][hCvar] = cvar;
	g_eCvars[g_iCvars][eType] = type;
	g_eCvars[g_iCvars][fnCallback] = callback;
	CacheCvarValue(g_iCvars);
	return g_iCvars++;
}

public GlobalConVarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	for(new i=0;i<g_iCvars;++i)
		if(g_eCvars[i][hCvar]==convar)
		{
			CacheCvarValue(i);
		
			if(g_eCvars[i][fnCallback]!=INVALID_FUNCTION)
			{
				Call_StartFunction(INVALID_HANDLE, g_eCvars[i][fnCallback]);
				Call_PushCell(i);
				Call_Finish();
			}
		
			return;
		}
	
}

public CacheCvarValue(index)
{
	if(g_eCvars[index][eType]==TYPE_INT)
		g_eCvars[index][aCache] = GetConVarInt(g_eCvars[index][hCvar]);
	else if(g_eCvars[index][eType]==TYPE_FLOAT)
		g_eCvars[index][aCache] = GetConVarFloat(g_eCvars[index][hCvar]);
	else if(g_eCvars[index][eType]==TYPE_STRING)
		GetConVarString(g_eCvars[index][hCvar], g_eCvars[index][sCache], CVAR_LENGTH);
	else if(g_eCvars[index][eType]==TYPE_FLAG)
	{
		GetConVarString(g_eCvars[index][hCvar], g_eCvars[index][sCache], CVAR_LENGTH);
		g_eCvars[index][aCache] = ReadFlagString(g_eCvars[index][sCache]);
	}
}

public SQLCallback_Void(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(hndl==INVALID_HANDLE)
		LogError("SQL error happened. Error: %s", error);
}

stock GetClientBySteamID(String:steamid[])
{
	new String:authid[32];
	for(new i=1;i<=MaxClients;++i)
	{
		if(!IsClientInGame(i))
			continue;
		if(!IsClientAuthorized(i))
			continue;
		GetClientAuthString(i, authid, sizeof(authid));
		if(strcmp(authid, steamid)==0)
			return i;
	}
	return 0;
}

stock GetClientByIP(String:ip[])
{
	new String:client_ip[16];
	for(new i=1;i<=MaxClients;++i)
	{
		if(!IsClientInGame(i))
			continue;
		GetClientIP(i, client_ip, sizeof(client_ip));
		if(strcmp(client_ip, ip)==0)
			return i;
	}
	return 0;
}

stock GetClientPrivilege(client, flag, flags=-1)
{
	if(flags==-1)
		flags = GetUserFlagBits(client);
	
	if(flags & flag || flags & ADMFLAG_ROOT)
		return true;
	return false;
}

public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
	if(entity == data)
		return false;
	return true;
}

public bool:TraceRayDontHitPlayers(entity, mask, any:data)
{
	if(0 < entity <= MaxClients)
		return false;
	return true;
}

public CreateCountdown(client, seconds, String:format[])
{
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, GetClientUserId(client));
	WritePackCell(pack, seconds);
	WritePackString(pack, format);
	ResetPack(pack);

	CreateTimer(0.0, Timer_Countdown, pack);
}

public CreateCountdownAll(seconds, String:format[])
{
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, 0);
	WritePackCell(pack, seconds);
	WritePackString(pack, format);
	ResetPack(pack);

	CreateTimer(0.0, Timer_Countdown, pack);
}

public Action:Timer_Countdown(Handle:timer, any:pack)
{
	new userid = ReadPackCell(pack);
	decl client;
	if(userid!=0)
	{
		client = GetClientOfUserId(userid);
		if(!client)
		{
			CloseHandle(pack);
			return Plugin_Stop;
		}
	}

	new seconds = ReadPackCell(pack);
	decl String:format[192];
	ReadPackString(pack, format, sizeof(format));

	if(userid != 0)
		PrintCenterText(client, "%t", format, seconds);
	else
		PrintCenterTextAll("%t", format, seconds);

	if(seconds != 1)
	{
		ResetPack(pack);
		ReadPackCell(pack);
		WritePackCell(pack, seconds-1);
		ResetPack(pack);

		CreateTimer(1.0, Timer_Countdown, pack);
	}
	else
		CloseHandle(pack);

	return Plugin_Stop;
}

stock bool:AddMenuItemEx(Handle:menu, style, String:info[], String:display[], any:...)
{
	new String:m_display[256];
	VFormat(m_display, sizeof(m_display), display, 5);
	return (AddMenuItem(menu, info, m_display, style)?true:false);
}