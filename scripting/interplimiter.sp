#pragma semicolon 1
#include <sourcemod>
#include <morecolors>
#undef REQUIRE_PLUGIN
#define PLUGIN_VERSION "1.0.1"
#define CVAR_MAXLEN 64
#define MAX_URL_LENGTH 256

public Plugin myinfo = {
	name		= "Interp Limiter",
	author		= "Miggy, Mizx, Dr.McKay, and Stephanie",
	description = "Plugin that prevents interp above default TF2 values",
	version		= PLUGIN_VERSION,
	url		= "https://github.com/stephanieLGBT/IntegriTF2/tree/InterpLimiter"
};

float g_CheckClientConVarsMin = 15.0;
float g_CheckClientConVarsMax = 60.0;


public void OnPluginStart()
{	
	HookEvent("player_spawn", Event_Player_Spawn);

	CreateTimer(5.0, Timer_CheckClientConVars);
}

public Action Event_Player_Spawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	QueryClientConVar(client, "cl_interp", ConVarQueryFinished:ClientConVar1);
	return Plugin_Continue;
}

public void ClientConVar1(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if (client == 0 || !IsClientInGame(client))
		return;

	if (result != ConVarQuery_Okay)
		CPrintToChatAll("{hotpink}[InterpLimiter]{white} Unable to check CVar %s on player %N.", cvarName, client);
	else if (StringToFloat(cvarValue) > 0.100000)
		{
		KickClient(client, "CVar %s = %s, outside reasonable bounds. Try changing it to something sane", cvarName, cvarValue);
		LogMessage("[InterpLimiter] Player %N is using CVar %s = %s, kicked from server.", client, cvarName, cvarValue);
		CPrintToChatAll("{hotpink}[InterpLimiter]{white} Player %N was using CVar %s = %s, kicked from server.", client, cvarName, cvarValue);
		}
}

public Action:Timer_CheckClientConVars(Handle:timer)
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client))
		{
			QueryClientConVar(client, "cl_interp", ConVarQueryFinished:ClientConVar1);
		}
	}

	CreateTimer(GetRandomFloat(g_CheckClientConVarsMin, g_CheckClientConVarsMax), Timer_CheckClientConVars);
}
