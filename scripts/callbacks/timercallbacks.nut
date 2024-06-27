/*
 * Just4Fun Vice City: Multiplayer (VC:MP) 0.3z R2 server
 * Authors: sfwidde ([R3V]Kelvin) and [VU]Alpays
 * 2024-06-20
 */

function TimerCallback_DisplayNewsreelMessage()
{
	// Does newsreel need to be rewound?
	if (newsreelIndex > (newsreelTexts.len() - 1))
	{
		newsreelIndex = 0;
	}

	InfoMessage(newsreelTexts[newsreelIndex++]);
}

function TimerCallback_PlayerDataCleanup()
{
	local currentTimestamp = time();
	local deletedDataCount = 0;
	foreach (lowerPlayerName, playerData in playerDataPool)
	{
		if (playerData.lastActiveTimestamp && // Data is not active (in use)
			((currentTimestamp - playerData.lastActiveTimestamp) >= 3600 /* 1 hour */))
		{
			playerDataPool.rawdelete(lowerPlayerName);
			++deletedDataCount;
		}
	}

	if (deletedDataCount)
	{
		print("Deleted " + deletedDataCount + " inactive " +
			((deletedDataCount != 1) ? "players" : "player") + " data.");
	}
}

function TimerCallback_HealPlayer(playerId, initialPosX, initialPosY, initialPosZ)
{
	local player = FindPlayer(playerId);
	if (!player) { return; }

	local playerData = GetPlayerData(player);
	playerData.processTimer = null;

	if (!player.IsSpawned)
	{
		ErrorMessage("Healing process has been aborted - you are no longer spawned.", player);
		return;
	}

	if (!player.IsAlive())
	{
		ErrorMessage("Healing process has been aborted - you are no longer alive.", player);
		return;
	}

	if (player.Vehicle)
	{
		ErrorMessage("Healing process has been aborted - you are no longer on foot.", player);
		return;
	}

	if (player.Health >= 100)
	{
		ErrorMessage("Healing process has been aborted - you don't need to be healed anymore.", player);
		return;
	}

	local playerPos = player.Pos;
	if ((playerPos.x.tointeger() != initialPosX) ||
		(playerPos.y.tointeger() != initialPosY) ||
		(playerPos.z.tointeger() != initialPosZ))
	{
		ErrorMessage("Healing process has been aborted - you moved from your initial position.", player);
		return;
	}

	player.Health = 100;
	Message(player.Name + " has healed.");
}

function TimerCallback_FixPlayerVehicle(playerId, vehicleId, initialPosX, initialPosY, initialPosZ)
{
	local player = FindPlayer(playerId);
	if (!player) { return; }

	local playerData = GetPlayerData(player);
	playerData.processTimer = null;

	if (!player.IsSpawned)
	{
		ErrorMessage("Vehicle repair process has been aborted - you are no longer spawned.", player);
		return;
	}

	local playerVehicle = player.Vehicle;
	if (!playerVehicle)
	{
		ErrorMessage("Vehicle repair process has been aborted - you are no longer in a vehicle.", player);
		return;
	}

	if (playerVehicle.ID != vehicleId)
	{
		ErrorMessage("Vehicle repair process has been aborted - you are no longer driving the vehicle " +
			"you initially attempted to fix.", player);
		return;
	}

	local vehicleHealth = playerVehicle.Health;
	if (vehicleHealth >= 1000.0)
	{
		ErrorMessage("Vehicle repair process has been aborted - vehicle does not need to be fixed anymore.", player);
		return;
	}

	if (vehicleHealth < 250.0)
	{
		ErrorMessage("Vehicle repair process has been aborted - vehicle is now on fire.", player);
		return;
	}

	local vehiclePos = playerVehicle.Pos;
	if ((vehiclePos.x.tointeger() != initialPosX) ||
		(vehiclePos.y.tointeger() != initialPosY) ||
		(vehiclePos.z.tointeger() != initialPosZ))
	{
		ErrorMessage("Vehicle repair process has been aborted - vehicle moved from its initial position.", player);
		return;
	}

	playerVehicle.Fix();
	Message(player.Name + " repaired their vehicle.");
}

function TimerCallback_TeleportPlayerToPlayer(playerId, targetPlayerName, initialPosX, initialPosY, initialPosZ)
{
	local player = FindPlayer(playerId);
	if (!player) { return; }

	local playerData = GetPlayerData(player);
	playerData.processTimer = null;

	if (!player.IsSpawned)
	{
		ErrorMessage("Teleportation process has been aborted - you are no longer spawned.", player);
		return;
	}

	if (!player.IsAlive())
	{
		ErrorMessage("Teleportation process has been aborted - you are no longer alive.", player);
		return;
	}

	if (player.Vehicle)
	{
		ErrorMessage("Teleportation process has been aborted - you are no longer on foot.", player);
		return;
	}

	local targetPlayer = FindPlayer(targetPlayerName);
	if (!targetPlayer)
	{
		ErrorMessage("Teleportation process has been aborted - the player you attempted " +
			"to teleport to is no longer online.", player);
		return;
	}

	if (!targetPlayer.IsSpawned)
	{
		ErrorMessage("Teleportation process has been aborted - " + targetPlayer.Name + " is no longer spawned.", player);
		return;
	}

	local playerPos = player.Pos;
	if ((playerPos.x.tointeger() != initialPosX) ||
		(playerPos.y.tointeger() != initialPosY) ||
		(playerPos.z.tointeger() != initialPosZ))
	{
		ErrorMessage("Teleportation process has been aborted - you moved from your initial position.", player);
		return;
	}

	player.Pos = targetPlayer.Pos;
	Message(player.Name + " teleported to " + targetPlayer.Name + ".");
}
