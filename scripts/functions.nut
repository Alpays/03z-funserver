/*
 * Just4Fun by sfwidde ([R3V]Kelvin) and [VU]Alpays
 * 2024-01-10
 */

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

function TimerCallback_DisplayNewsreelMessage()
{
	if (newsreelIndex > (newsreelText.len() - 1))
	{
		newsreelIndex = 0;
	}

	InfoMessage(newsreelText[newsreelIndex++], null);
}
