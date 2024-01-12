/*
 * Just4Fun by sfwidde ([R3V]Kelvin) and [VU]Alpays
 * 2024-01-10
 */

function GetPlayer(text)
{
	return FindPlayer(IsNum(text) ? text.tointeger() : text);
}

function InfoMessage(message, player)
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

function IncreasePlayerKillingSpree(player)
{
	local playerData = GetPlayerData(player);
	if ((++playerData.spree) % 5 == 0)
	{
		local reward = playerData.spree * 100;
		Message(player.Name + " is on a killing spree of " + playerData.spree + "! ($" + reward + ")");
		player.Cash += reward;
		Announce("~o~killing spree!", player, 1);
	}
}

function EndPlayerKillingSpree(player, killer = null)
{
	local playerData = GetPlayerData(player);
	if (playerData.spree >= 5)
	{
		Message(killer ?
			(player.Name + "'s killing spree of " + playerData.spree + " has been ended by " + killer.Name + "!") :
			(player.Name + "'s killing spree of " + playerData.spree + " has been ended!"));
	}
	playerData.spree = 0;
}

function TimerCallback_DisplayNewsreelMessage()
{
	if (newsreelIndex > (newsreelText.len() - 1))
	{
		newsreelIndex = 0;
	}

	InfoMessage(newsreelText[newsreelIndex++], null);
}
