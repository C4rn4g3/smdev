#if defined _chat_included
#endinput
#endif
#define _chat_included

#define CHAT_TAG "[Nem.]"

#define CHAT_NORMAL "\x01"
#define CHAT_HIGHLIGHT "\x04"
#define CHAT_TEAM "\x03"

#define COLOR_TEAM_SPECTATOR "\x07CCCCCC"
#define COLOR_TEAM_T "\x07FF4040"
#define COLOR_TEAM_CT "\x0799CCFF"

#define COLOR_HUDYELLOW "\x07FFB000"
#define COLOR_HUDGREEN "\x0700A000"
#define COLOR_HUDRED "\x07A00000"

#define COLOR_WHITE		"\x07FFFFFF"
#define COLOR_LIGHTBLUE	"\x077FC9FF"
#define COLOR_BLUE		"\x070094FF"
#define COLOR_DARKBLUE	"\x070026FF"
#define COLOR_RED		"\x07FF0000"
#define COLOR_ORANGE	"\x07FF6A00"
#define COLOR_YELLOW	"\x07FFD800"
#define COLOR_CYAN		"\x0700FFFF"
#define COLOR_GREEN		"\x0742D114"
#define COLOR_LIME		"\x0700FF00"
#define COLOR_PURPLE	"\x07B200FF"
#define COLOR_PINK		"\x07FF00DC"

#define MSG_LENGTH 512

enum MessageType
{
	MsgType_Info,
	MsgType_Error,
	MsgType_Msg,
	MsgType_Advert,
	MsgType_Hint
}

stock ColorizeString(String:string[], length)
{
	ReplaceString(string, length, "{NORMAL}", CHAT_NORMAL);
	ReplaceString(string, length, "{HIGHLIGHT}", CHAT_HIGHLIGHT);
	ReplaceString(string, length, "{TEAM}", CHAT_TEAM);

	ReplaceString(string, length, "{TEAM_SPEC}", COLOR_TEAM_SPECTATOR);
	ReplaceString(string, length, "{TEAM_T}", COLOR_TEAM_T);
	ReplaceString(string, length, "{TEAM_CT}", COLOR_TEAM_CT);

	ReplaceString(string, length, "{HUDYELLOW}", COLOR_HUDYELLOW);
	ReplaceString(string, length, "{HUDGREEN}", COLOR_HUDGREEN);
	ReplaceString(string, length, "{HUDRED}", COLOR_HUDRED);

	ReplaceString(string, length, "{WHITE}", COLOR_WHITE);
	ReplaceString(string, length, "{LIGHTBLUE}", COLOR_LIGHTBLUE);
	ReplaceString(string, length, "{BLUE}", COLOR_BLUE);
	ReplaceString(string, length, "{DARKBLUE}", COLOR_DARKBLUE);
	ReplaceString(string, length, "{RED}", COLOR_RED);
	ReplaceString(string, length, "{ORANGE}", COLOR_ORANGE);
	ReplaceString(string, length, "{YELLOW}", COLOR_YELLOW);
	ReplaceString(string, length, "{CYAN}", COLOR_CYAN);
	ReplaceString(string, length, "{GREEN}", COLOR_GREEN);
	ReplaceString(string, length, "{LIME}", COLOR_LIME);
	ReplaceString(string, length, "{PURPLE}", COLOR_PURPLE);
	ReplaceString(string, length, "{PINK}", COLOR_PINK);
}

stock Chat(MessageType:msgtype = MsgType_Info, client, const String:format[], any:...) 
{
	new String:msg[MSG_LENGTH];
	new String:msg2[MSG_LENGTH];

	SetGlobalTransTarget(client);

	if (msgtype == MsgType_Info)
		Format(msg, MSG_LENGTH, "{LIGHTBLUE}%t {WHITE}%s", "Info", format);
	else if (msgtype == MsgType_Error)
		Format(msg, MSG_LENGTH, "{ORANGE}%t {WHITE}%s", "Error", format);
	else if (msgtype == MsgType_Msg)
		Format(msg, MSG_LENGTH, "{GREEN}%t {WHITE}%s", "Message", format);
	else if (msgtype == MsgType_Hint)
		Format(msg, MSG_LENGTH, "{YELLOW}%t {WHITE}%s", "Hint", format);
	else if (msgtype == MsgType_Advert)
		Format(msg, MSG_LENGTH, "{ORANGE}%t {YELLOW}%s", "Advert", format);
	else
		Format(msg, MSG_LENGTH, "{WHITE}%s", format);

	VFormat(msg2, MSG_LENGTH, msg, 4);

	ColorizeString(msg2, MSG_LENGTH);

	new Handle:hBf;
	hBf = StartMessageOne("SayText2", client);
	if (hBf != INVALID_HANDLE)
	{
		if (GetUserMessageType() == UM_Protobuf)
		{
			PbSetBool(hBf, "chat", true);
			PbSetInt(hBf, "ent_idx", client);
			PbSetString(hBf, "msg_name", msg2);
			PbAddString(hBf, "params", "");
			PbAddString(hBf, "params", "");
			PbAddString(hBf, "params", "");
			PbAddString(hBf, "params", "");
		}
		else
		{        
			BfWriteByte(hBf, client);
			BfWriteByte(hBf, true);
			BfWriteString(hBf, msg2);
		}

		EndMessage();
	}
} 

stock ChatAll(MessageType:msgtype = MsgType_Info, String:format[], any:...)
{
	decl String:msg[MSG_LENGTH];

	Format(msg, MSG_LENGTH, "{WHITE}%s", format);

	decl String:msg2[MSG_LENGTH];

	VFormat(msg2, MSG_LENGTH, msg, 3);
	ColorizeString(msg2, MSG_LENGTH);
	SetGlobalTransTarget(0);
	PrintToServer(msg2);

	for (new client=1; client<=MaxClients; client++)
	{
		if (!IsClientInGame(client))
		continue;
		
		// Translate to all client
		SetGlobalTransTarget(client);

		VFormat(msg2, MSG_LENGTH, msg, 3);

		if (msgtype == MsgType_Info)
			Format(msg2, MSG_LENGTH, "{LIGHTBLUE}%t {WHITE}%s", "Info", msg2);
		else if (msgtype == MsgType_Error)
			Format(msg2, MSG_LENGTH, "{ORANGE}%t {WHITE}%s", "Error", msg2);
		else if (msgtype == MsgType_Msg)
			Format(msg2, MSG_LENGTH, "{GREEN}%t {WHITE}%s", "Message", msg2);
		else if (msgtype == MsgType_Hint)
			Format(msg2, MSG_LENGTH, "{YELLOW}%t {WHITE}%s", "Hint", msg2);
		else if (msgtype == MsgType_Advert)
			Format(msg2, MSG_LENGTH, "{ORANGE}%t {YELLOW}%s", "Advert", msg2);

		ColorizeString(msg2, MSG_LENGTH);

		new Handle:hBf;

		hBf = StartMessageOne("SayText2", client);
		if (hBf != INVALID_HANDLE)
		{
			if (GetUserMessageType() == UM_Protobuf)
			{
				PbSetBool(hBf, "chat", true);
				PbSetInt(hBf, "ent_idx", client);
				PbSetString(hBf, "msg_name", msg2);
				PbAddString(hBf, "params", "");
				PbAddString(hBf, "params", "");
				PbAddString(hBf, "params", "");
				PbAddString(hBf, "params", "");
			}
			else
			{        
				BfWriteByte(hBf, client);
				BfWriteByte(hBf, true);
				BfWriteString(hBf, msg2);
			}

			EndMessage();
		}
	}
}

stock ServerChat(const String:format[], any:...) 
{
	new String:msg[MSG_LENGTH];
	new String:msg2[MSG_LENGTH];

	SetGlobalTransTarget(0);
	Format(msg, MSG_LENGTH, "%s %s", format); //%s
	VFormat(msg2, MSG_LENGTH, msg, 2);

	ColorizeString(msg2, MSG_LENGTH);

	PrintToServer(msg2);
} 
