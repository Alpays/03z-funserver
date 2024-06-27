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
playerDataPool <- {}; // {"lowerplayername" = ::PlayerData(), ...}
playerCmdPool  <- [];
newsreelTexts  <-
[
	"Type /c cmds to display a list of commands.",
	"Don't want to spawn where you last died anymore? Type /c diepos to toggle this feature on or off.",
	"Low on health? Type /c heal to heal yourself.",
	"Type /c fix to repair a wrecked vehicle.",
	"Type /c wep to acquire any weapon(s) you want at any time!",
	"Remove whatever weapons you have in hand with /c disarm.",
	"Stuck in a flipped vehicle? Type /c eject to eject yourself from it.",
	"Tired of typing /c wep every time you spawn? /c spawnwep allows you to spawn with any weapons you choose!",
	"Type /c goto to teleport to a desired player."
];
newsreelIndex <- 0;
shootInAir    <- false;

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

	ApplyServerSettings();
	AddPlayerCommands();
	LoadServerTimers();

	print("\n_________________________________");
	print(SERVER_NAME + " has initialized.");
}

function onPlayerJoin(player)
{
	local playerName = player.Name;
	if (!player.IsNameValid())
	{
		Message("Kicking out " + playerName + " for invalid nickname.");
		KickPlayer(player);
		return;
	}

	// Create player data if non-existent, otherwise just retrieve
	// whatever data belonged to this player previously.
	local playerData = GetPlayerData(player);
	// (Existing-data-only) Now active.
	playerData.lastActiveTimestamp = null;

	player.ShootInAir = shootInAir;

	InfoMessage("Welcome to " + SERVER_NAME + ", " + playerName + "!", player);
	InfoMessage("Type /c cmds to view a list of commands.", player);
	if (playerName.tolower().find("kelvin") != null)
	{
		AnnounceAll("Money Success Fame Glamour", 0);
	}
}

function onPlayerPart(player, reason)
{
	player.EndKillingSpree();

	local playerData = GetPlayerData(player);
	if (playerData.processTimer)
	{
		playerData.processTimer.Delete();
		playerData.processTimer = null;
	}
	playerData.lastActiveTimestamp = time(); // Data is now inactive.
}

function onPlayerRequestClass(player, classId, teamId, skinId)
{
	Announce((teamId == 255) ? "~h~free team" : "", player, 1);
}

function onPlayerSpawn(player)
{
	Announce("", player, 1);

	local playerData = GetPlayerData(player);

	// Diepos
	if (playerData.diePosEnabled && playerData.lastDeathPos)
	{
		player.Pos = playerData.lastDeathPos;
	}
	// Default spawn
	else if (player.Skin == 95 /* Vercetti Guy #1 */)
	{
		player.SetInterior(2); // Mansion
	}

	/* Spawn weapons */
	if (!disableSpawnWeps && playerData.spawnWeapons.len())
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
