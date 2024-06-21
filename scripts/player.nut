/*
 * Just4Fun Vice City: Multiplayer (VC:MP) 0.3z R2 server
 * Authors: sfwidde ([R3V]Kelvin) and [VU]Alpays
 * 2024-01-08
 */

class PlayerData
{
	diePosEnabled = true;
	lastDeathPos  = null;
	spawnWeapons  = null;
	spree         = 0;
}

function PlayerData::constructor()
{
	spawnWeapons = [];
}

// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------

function IncreasePlayerKillingSpree(player)
{
	local playerData = GetPlayerData(player);
	local hpAddon;
	if ((++playerData.spree) % 5 == 0)
	{
		local reward = playerData.spree * 100;
		player.Cash += reward;
		hpAddon = 40;
		Message(player.Name + " is on a killing spree of " + playerData.spree + "! ($" + reward + ")");
		Announce("~o~killing spree!", player, 1);
	}
	else { hpAddon = 25; }

	local playerHealth = player.Health;
	if (player.IsSpawned && (playerHealth > 0))
	{
		local newPlayerHealth = (playerHealth + hpAddon);
		player.Health = (newPlayerHealth < 100) ? newPlayerHealth : 100;
	}
}

function EndPlayerKillingSpree(player, killer = null)
{
	local playerData = GetPlayerData(player);
	if (playerData.spree >= 5)
	{
		Message(player.Name + "'s killing spree of " + playerData.spree + " has been ended by " +
			(killer ? killer.Name : "themselves") + "!");
	}
	playerData.spree = 0;
}
