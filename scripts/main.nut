/*
 * Just4Fun Vice City: Multiplayer (VC:MP) 0.3z R2 server
 * Authors: sfwidde ([SS]Kelvin) and [VU]Alpays
 * 2024-01-08
 */

// -----------------------------------------------------------------------------

/* Server settings */
const SERVER_NAME = "Just4Fun";
const MAX_PLAYERS = 32;

/* Interiors */
const INTERIOR_MANSION = 2;

/* Player command permission flags */
const PLAYERCMD_FLAG_NONE      = 0x00; // 0000
const PLAYERCMD_FLAG_SPAWNED   = 0x01; // 0001
const PLAYERCMD_FLAG_ALIVE     = 0x02; // 0010
const PLAYERCMD_FLAG_ONFOOT    = 0x04; // 0100
const PLAYERCMD_FLAG_INVEHICLE = 0x08; // 1000

// -----------------------------------------------------------------------------

/* Globals */
shootInAir      <- false;
quakeMode       <- false;
playerDataPool  <- {}; // {"lowerplayername" = ::PlayerData(), ...}
playerCmdPool   <- [];
newsreelTexts   <-
[
	"Type /c cmds to display a list of commands.",
	"Commands can be prefixed with '!' too, try !cmds instead of /c cmds.",
	"Don't want to spawn where you last died anymore? Type /c diepos to toggle this feature on or off.",
	"Low on health? Type /c heal to heal yourself.",
	"Type /c fix to repair a wrecked vehicle.",
	"Type /c wep to acquire any weapon(s) you want at any time!",
	"Remove whatever weapons you have in hand with /c disarm.",
	"Stuck in a flipped vehicle? Type /c eject to eject yourself from it.",
	"Tired of typing /c wep every time you spawn? /c spawnwep allows you to spawn with any weapons you choose!",
	"Type /c goto to teleport to a desired player.",
	"Find and spawn any existing vehicle to your position with /c vehicle."
];
newsreelIndex   <- 0;
commonLocations <- // Could use a class for this
[
//  Names                         Pos
	[["hotel", "oceanbeach"],     Vector(229.76, -1281.61, 12.07)],
	[["malibu"],                  Vector(497.91, -71.47, 11.48)],
	[["golf", "leaflinks"],       Vector(85.85, 241.79, 21.58)],
	[["mall", "vicepoint"],       Vector(530.14, 1272.56, 17.85)],
	[["prawn", "cinema", "film"], Vector(19.98, 1018.25, 10.97)],
	[["stadium"],                 Vector(-1026.52, 1331.09, 8.74)],
	[["police", "downtown"],      Vector(-679.50, 756.33, 11.08)],
	[["bank"],                    Vector(-888.71, -334.94, 13.54)],
	[["sunshine"],                Vector(-1010.08, -916.18, 14.61)],
	[["docks", "viceport"],       Vector(-732.06, -1293.92, 11.81)],
	[["escobar", "airport"],      Vector(-1435.83, -837.47, 14.87)],
	[["army"],                    Vector(-1732.53, -303.72, 14.87)],
	[["duel1", "bf"],             Vector(-939.73, 364.06, 11.26)],
	[["duel2"],                   Vector(-1726.64, -156.31, 14.87)],
	[["duel3"],                   Vector(-550.75, 773.79, 187.70)],
	[["duel4", "s96"],            Vector(-1084.28, -1317.57, 11.43)],
	[["duel5"],                   Vector(-1536.89, -1173.85, 14.87)],
	[["duel6"],                   Vector(132.44, -1064.22, 45.77)]
];

// -----------------------------------------------------------------------------

function onScriptLoad()
{
	print("Initializing " + SERVER_NAME + "...\n________________________________\n");

	// Include required script files
	dofile("scripts/functions.nut");
	dofile("scripts/loader.nut");
	dofile("scripts/player.nut");
	dofile("scripts/playercmd.nut");
	dofile("scripts/callbacks/timercallbacks.nut");
	dofile("scripts/callbacks/playercmdhandlers.nut");

	ApplyServerSettings();
	AddPlayerCommands();
	LoadServerTimers();

	print("\n_____________________________");
	print(SERVER_NAME + " initialized.");
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

	// Apply ShootInAir global setting to this client
	player.ShootInAir = GetShootInAir();

	// Create player data if non-existent, otherwise just retrieve whatever data
	// belonged to this player previously and make it active
	player.SetActiveStatus(true);

	InfoMessage("Welcome to " + SERVER_NAME + ", " + playerName + "!", player);
	InfoMessage("Type /c cmds to view a list of commands.", player);

	// Fuck u Alpays
	if (playerName.tolower().find("kelvin") != null)
	{
		AnnounceAll("Money Success Fame Glamour!", 0);
	}
}

function onPlayerPart(player, reason)
{
	player.EndSpree();
	player.ClearProcessTimer();
	player.SetActiveStatus(false);

	// Server is now empty
	if ((GetPlayers() - 1) <= 0)
	{
		ResetWorldSettings();
		print("No players left in the server. Some world settings have been restored.");
	}
}

function onPlayerRequestClass(player, classId, teamId, skinId)
{
	Announce((teamId == 255) ? "~h~free team" : "", player, 1);
}

function onPlayerSpawn(player)
{
	Announce("", player, 1);

	local lastDeathPos = player.GetLastDeathPos();
	/* DiePos */
	if (player.GetLastDeathPosEnabled() && lastDeathPos)
	{
		player.Pos = lastDeathPos;
	}
	/* Default spawn */
	else if (player.Skin == 95 /* Vercetti Guy #1 */)
	{
		player.SetInterior(INTERIOR_MANSION);
	}

	if (GetQuakeMode())
	{
		player.SetWeapon(WEP_FIST, 0);
		player.SetWeapon(WEP_ROCKETLAUNCHER, 15000);
	}
	else { player.GiveSpawnWeapons(); }
}

function onPlayerDeath(player, reason)
{
	// Update player's last death position
	player.SetLastDeathPos((reason != WEP_DROWNED) ? player.Pos : null);
	player.EndSpree();
}

function onPlayerKill(killer, player, reason, bodypart)
{
	// Update player's last death position
	player.SetLastDeathPos(player.Pos);

	// (Cosmetic only)
	local playerCash = player.Cash;
	killer.Cash += 500;
	player.Cash = (playerCash > 250) ? (playerCash - 250) : 0;

	killer.IncreaseSpree();
	player.EndSpree(killer);
}

function onPlayerChat(player, message)
{
	switch (message[0])
	{
	// '!'-prefixed commands, needs to simulate '/c'-prefixed commands for consistent behavior
	case '!':
		// Remove leading whitespaces from command
		local cmdText = lstrip(message.slice(1));
		if (!cmdText.len()) { break; }

		// Attempt to find command-argument separator (whitespace)
		local argsPos = cmdText.find(" ");
		local args = null; // The argument(s)
		// Arguments were provided for this command
		if (argsPos != null)
		{
			args = cmdText.slice(argsPos + 1);
			cmdText = cmdText.slice(0, argsPos);
			// Whatever, just keep simulating '/c''s behavior
			if (!lstrip(args).len()) { args = null; }
		}

		onPlayerCommand(player, cmdText, args);
		break;
	}

	return 1;
}

function onPlayerCommand(player, cmdText, arguments)
{
	local cmd = FindPlayerCmd(cmdText);
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

function onPlayerEnterVehicle(player, vehicle, isPassenger)
{
	local vehicleModel = vehicle.Model;
	local vehicleName = GetVehicleNameFromModel(vehicleModel);
	switch (vehicleModel)
	{
	case VEH_VOODOO: // Driving voodoos cause a game crash for other players in 0.3z R2.
		local playerPos = player.Pos;
		player.Pos = Vector(playerPos.x, playerPos.y, playerPos.z + 10.0);
		ErrorMessage("Entering " + vehicleName + " is prohibited.", player);
		break;

	default:
		PrivMessage("You entered " + GetAOrAn(vehicleName) + " " + vehicleName + " (ID: " + vehicle.ID + ").", player);
	}
}

// -----------------------------------------------------------------------------
