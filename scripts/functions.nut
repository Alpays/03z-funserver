/*
 * Just4Fun Vice City: Multiplayer (VC:MP) 0.3z R2 server
 * Authors: sfwidde ([R3V]Kelvin) and [VU]Alpays
 * 2024-01-10
 */

function SetShootInAir(toggle) {
    shootInAir = toggle;
    for(local i = 0; i < MAX_PLAYERS; ++i) {
        local p = FindPlayer(i);
        if(p) {
            p.ShootInAir = shootInAir;
        }
    }
}

function GetPlayer(text)
{
	return FindPlayer(IsNum(text) ? text.tointeger() : text);
}

function InfoMessage(message, player = null)
{
	if (player)
	{
		ClientMessage("** pm >> " + message, player, 255, 150, 225);
	}
	else
	{
		ClientMessageToAll(message, 255, 150, 225);
	}
}

function ErrorMessage(message, player)
{
	ClientMessage("** pm >> " + message, player, 255, 0, 0);
}

function CmdSyntaxMessage(player, cmdText, ...)
{
	local paramList = "";
	foreach (param in vargv)
	{
		paramList += paramList.len() ? ", <" + param + ">" : "<" + param + ">";
	}
	PrivMessage("Command syntax: /c " + cmdText.tolower() + " " + paramList, player);
}
