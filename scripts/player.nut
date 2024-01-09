/*
 * Just4Fun by sfwidde ([R3V]Kelvin) and [VU]Alpays
 * 2024-01-08
 */

class PlayerData
{
	diePosEnabled = true;
	lastDeathPos  = null;
	spawnWeapons  = null;
	spree = 0;
}

function PlayerData::constructor()
{
	spawnWeapons = [];
}

// ----------------------------------------------------------------------------

function NewPlayerData(player)
{
	local playerId = player.ID;
	if (playerDataPool[playerId])
	{
		throw "player data slot " + playerId + " is already in use";
	}

	return playerDataPool[playerId] = PlayerData();
}

function DeletePlayerData(player)
{
	local playerId = player.ID;
	if (!playerDataPool[playerId])
	{
		throw "unable to delete player data at slot " + playerId + " as there is no data at such index at all";
	}

	playerDataPool[playerId] = null;
}

function GetPlayerData(player)
{
	local playerId = player.ID;
	local playerData = playerDataPool[playerId];
	if (!playerData)
	{
		throw "unable to retrieve player data at slot " + playerId + " as there is no data at such index at all";
	}

	return playerData;
}

// ----------------------------------------------------------------------------

function InfoMessage(message, player)
{
	ClientMessage("** pm >> " + message, player, 0, 255, 0);
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
