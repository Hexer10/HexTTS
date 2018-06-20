#include <sourcemod>
#include <sdktools>
#include <System2>
#include <latedl>

#define PLUGIN_AUTHOR "Hexah"
#define PLUGIN_VERSION "1.00"

#pragma newdecls required
#pragma semicolon 1


char sPath[PLATFORM_MAX_PATH];
bool bProcessing;

public Plugin myinfo = 
{
	name = "Hex Text To Speech", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "github.com/Hexer10"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_getSound", Cmd_TTS, ADMFLAG_ROOT);
	RegAdminCmd("sm_playLast", Cmd_Play, ADMFLAG_ROOT);
}


public Action Cmd_TTS(int client, int args)
{
	if (bProcessing)
	{
		ReplyToCommand(client, "The previus request hasn't finished yet");
		return Plugin_Handled;
	}
	
	if (args < 3)
	{
		ReplyToCommand(client, "Command usage: getSound <Lang> <File> <Text>");
		return Plugin_Handled;
	}
	
	char sLang[16];
	char sFile[32];
	char sText[128];
	
	//Get Args
	GetCmdArg(1, sLang, sizeof(sLang));
	GetCmdArg(2, sFile, sizeof(sFile));

	if (strlen(sLang) != 2 )
	{
		ReplyToCommand(client, "You must provied a country code 2 (maxlen: 2)");
		return Plugin_Handled;
	}
	
	//Get ArgString & Remove the first two args
	GetCmdArgString(sText, sizeof(sText));
	ReplaceStringEx(sText, sizeof(sText), sLang, "");
	ReplaceStringEx(sText, sizeof(sText), sFile, "");

	//Encode the url
	System2_URLEncode(sText, sizeof(sText), sText);
	
	//Set the file
	Format(sPath, sizeof(sPath), "sound/tts/%s.mp3", sFile);
	
	//Create Request
	System2HTTPRequest httpRequest = new System2HTTPRequest(HttpResponseCallback, "http://translate.google.com/translate_tts?ei=UTF-8&client=tw-ob&q=%s&tl=%s", sText, sLang);
	
	//Set header
	httpRequest.SetHeader("Referer", "http://translate.google.com/");
	httpRequest.SetHeader("User-Agent", "stagefright/1.2 (Linux;Android 5.0)");
	
	//Set output file
	httpRequest.SetOutputFile(sPath);
	
	//Perform request
	httpRequest.GET();
	
	return Plugin_Handled;
}

public Action Cmd_Play(int client, int args)
{
	if (bProcessing)
	{
		ReplyToCommand(client, "[SM] The last sound still in process!");
		return Plugin_Handled;
	}
	
	PrecacheSound(sPath);
	ReplaceStringEx(sPath, sizeof(sPath), "sound/", "");
	PrecacheSound(sPath);
		
	EmitSoundToAll(sPath);
	return Plugin_Handled;
}

public void HttpResponseCallback(bool success, const char[] error, System2HTTPRequest request, System2HTTPResponse response, HTTPRequestMethod method) {
    if (success) 
    {
        char sFullPath[512 + PLATFORM_MAX_PATH];
        char sSampledPath[512 + PLATFORM_MAX_PATH];
        char sGame[512];
        
        //Get Game Dir
        System2_GetGameDir(sGame, sizeof(sGame));
        Format(sFullPath, sizeof(sFullPath), "%s/%s", sGame, sPath);
        
        strcopy(sSampledPath, sizeof(sSampledPath), sFullPath);
        
        ReplaceString(sSampledPath, sizeof(sSampledPath), ".mp3", "Sampled.mp3");
        ReplaceString(sPath, sizeof(sPath), ".mp3", "Sampled.mp3");
        
       	//We need to change the sample rate of our mp3
        System2_ExecuteFormattedThreaded(ExecuteCallback, 0, "lame --mp3input --resample 11.025 -b 192 \"%s\" \"%s\"", sFullPath, sSampledPath);
    } 
    else 
    {
        PrintToServer("Error on request: %s", error);
    }
}  

public void ExecuteCallback(bool success, const char[] command, System2ExecuteOutput output, any data) {
    if (!success || output.ExitStatus != 0) 
    {
        PrintToServer("Couldn't execute commands %s successfully", command);
    } 
    else 
    {
    	//Make client download the sound
        AddLateDownload(sPath);
        PrintToServer("DlPath: %s", sPath);
    }
}  

public void OnDownloadSuccess(int client, char[] filename) 
{ 
    if (client > 0) 
        return; 
     
    PrintToServer("All players successfully downloaded file '%s'!", filename); 
    bProcessing = false;
} 