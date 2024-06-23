/*
 * Just4Fun Vice City: Multiplayer (VC:MP) 0.3z R2 server
 * Authors: sfwidde ([R3V]Kelvin) and [VU]Alpays
 * 2024-01-08
 */

/* Server settings */
const SERVER_NAME = "Just4Fun";
const MAX_PLAYERS = 32;

/* Player command permission flags */
const PLAYERCMD_FLAG_NONE      = 0x00; // 0000
const PLAYERCMD_FLAG_SPAWNED   = 0x01; // 0001
const PLAYERCMD_FLAG_ALIVE     = 0x02; // 0010
const PLAYERCMD_FLAG_ONFOOT    = 0x04; // 0100
const PLAYERCMD_FLAG_INVEHICLE = 0x08; // 1000

/* Containers */
playerDataPool     <- null;
playerCmdPool      <- null;
playerSpawnWeapons <- null;
newsreelTexts      <- null;
newsreelIndex      <- 0;
shootInAir         <- false;

// Implicitly prepends "scripts/" directory.
function LoadMultipleScriptFiles(...)
{
	foreach (scriptFileName in vargv)
	{
		dofile("scripts/" + scriptFileName, true);
	}
}

function onScriptLoad()
{
	print("Initializing " + SERVER_NAME + "...\n________________________________\n");

	/* Include required script files */
	LoadMultipleScriptFiles(
		"functions.nut",
		"loader.nut",
		"player.nut",
		"playercmd.nut",
		"quake_mode.nut",
		"callbacks/timercallbacks.nut",
		"callbacks/playercmdhandlers.nut"
	);

	InitializeGlobals();
	ApplyServerSettings();
	AddPlayerCommands();
	LoadServerTimers();

	print("\n_________________________________");
	print(SERVER_NAME + " has initialized.");
}

function onPlayerJoin(player)
{
	local playerData;
	try
	{
		playerData = NewPlayerData(player);
	}
	catch (error)
	{
		print(error);
		ErrorMessage("Server error: " + error + ".", player);
		KickPlayer(player);
		return;
	}

	player.ShootInAir = shootInAir;

	local playerName = player.Name;
	local lowerPlayerName = playerName.tolower();
	if (playerSpawnWeapons.rawin(lowerPlayerName))
	{
		playerData.spawnWeapons = playerSpawnWeapons.rawget(lowerPlayerName);
	}
	else
	{
		playerSpawnWeapons.rawset(lowerPlayerName, playerData.spawnWeapons = []);
	}

	InfoMessage("Welcome to " + SERVER_NAME + ", " + playerName + "!", player);
	InfoMessage("Type /c cmds to view a list of commands.", player);
	if (playerName.tolower() == "[r3v]kelvin")
	{
		AnnounceAll("Money Success Fame Glamour", 0);
	}
}

function onPlayerPart(player, reason)
{
	local playerData = GetPlayerData(player);

	player.EndKillingSpree();
	if (playerData.processTimer) { playerData.processTimer.Delete(); }

	DeletePlayerData(player);
}

function onPlayerSpawn(player)
{
	local playerData = GetPlayerData(player);

	/* Diepos */
	if (playerData.diePosEnabled && playerData.lastDeathPos)
	{
		player.Pos = playerData.lastDeathPos;
	}

	/* Spawn weapons */
	if (playerData.spawnWeapons.len() && !disableSpawnWeps)
	{
		// Disarm player.
		player.SetWeapon(WEP_FIST, 0);
		// Give spawn weapons.
		foreach (weaponId in playerData.spawnWeapons)
		{
			player.SetWeapon(weaponId, 1000);
		}
	}

	quake.onPlayerSpawn(player);
}

function onPlayerDeath(player, reason)
{
	local playerData = GetPlayerData(player);

	// Update player's last death position.
	playerData.lastDeathPos = (reason != WEP_DROWNED) ? player.Pos : null;

	player.EndKillingSpree();
}

function onPlayerKill(killer, player, reason, bodypart)
{
	//local killerData = GetPlayerData(killer);
	local playerData = GetPlayerData(player);

	// Update player's last death position.
	playerData.lastDeathPos = player.Pos;

	// (Cosmetic only)
	local playerCash = player.Cash;
	killer.Cash += 500;
	player.Cash = (playerCash > 250) ? (playerCash - 250) : 0;

	killer.IncreaseKillingSpree();
	player.EndKillingSpree(killer);
}

function onPlayerCommand(player, cmdText, arguments)
{
	local cmd = FindPlayerCommand(cmdText);
	if (!cmd)
	{
		ErrorMessage("\"" + cmdText + "\" is an invalid command. Type /c cmds to display a list of commands.", player);
		return;
	}

	if ((cmd.permissionFlags & PLAYERCMD_FLAG_SPAWNED) && !player.IsSpawned)
	{
		ErrorMessage("You must be spawned to use this command.", player);
		return;
	}

	if ((cmd.permissionFlags & PLAYERCMD_FLAG_ALIVE) && !player.IsAlive())
	{
		ErrorMessage("You cannot use this command while dying.", player);
		return;
	}

	if ((cmd.permissionFlags & PLAYERCMD_FLAG_ONFOOT) && player.Vehicle)
	{
		ErrorMessage("You must be on foot to use this command.", player);
		return;
	}

	if ((cmd.permissionFlags & PLAYERCMD_FLAG_INVEHICLE) && !player.Vehicle)
	{
		ErrorMessage("You must be in a vehicle to use this command.", player);
		return;
	}

	cmd.handler.call(this, player, cmdText, arguments);
}

// Driving voodoos cause a game crash for other players in 0.3z R2.
function onPlayerEnterVehicle(player, vehicle, isPassenger)
{
	if(vehicle.Model == VEH_VOODOO) {
		local playerPos = player.Pos;
		player.Pos = Vector(playerPos.x, playerPos.y, playerPos.z + 10.0);
		ErrorMessage("Entering voodoo is prohibited.", player);
	}
}
