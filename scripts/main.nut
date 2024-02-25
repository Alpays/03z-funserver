/*
 * Just4Fun by sfwidde ([R3V]Kelvin) and [VU]Alpays
 * 2024-01-08
 */

const SERVER_NAME = "Just4Fun";

const CMD_FLAG_NONE      = 0x00;
const CMD_FLAG_SPAWNED   = 0x01;
const CMD_FLAG_ALIVE     = 0x02;
const CMD_FLAG_ONFOOT    = 0x04;
const CMD_FLAG_INVEHICLE = 0x08;

// Not actually pools but meh.
playerDataPool <- null;
playerCmdPool  <- null;
newsreelText   <- null;
newsreelIndex  <- 0;

function onScriptLoad()
{
	/* Include required files */
	dofile("scripts/functions.nut", true);
	dofile("scripts/player.nut", true);
	dofile("scripts/playercmd.nut", true);
	dofile("scripts/playercmdcallbacks.nut", true);
	dofile("scripts/quake_mode.nut", true);

	/* Initialize our containers */
	playerDataPool = array(GetMaxPlayers());
	playerCmdPool  = [];
	newsreelText   =
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

	/* Set up player commands */
	AddPlayerCmd(["cmds", "commands"],                    CmdCallback_Cmds);
	AddPlayerCmd(["credits", "server", "script", "info"], CmdCallback_Credits);
	AddPlayerCmd(["pos"],                                 CmdCallback_Pos, CMD_FLAG_SPAWNED);
	AddPlayerCmd(["spree"],                               CmdCallback_Spree);
	AddPlayerCmd(["diepos"],                              CmdCallback_DiePos);
	AddPlayerCmd(["heal"],                                CmdCallback_Heal,   (CMD_FLAG_SPAWNED | CMD_FLAG_ALIVE));
	AddPlayerCmd(["fix", "repair"],                       CmdCallback_Fix,    (CMD_FLAG_SPAWNED | CMD_FLAG_INVEHICLE));
	AddPlayerCmd(["disarm"],                              CmdCallback_Disarm, (CMD_FLAG_SPAWNED | CMD_FLAG_ALIVE));
	AddPlayerCmd(["eject"],                               CmdCallback_Eject,  (CMD_FLAG_SPAWNED | CMD_FLAG_ALIVE | CMD_FLAG_INVEHICLE));
	AddPlayerCmd(["wep", "we"],                           CmdCallback_Wep,    (CMD_FLAG_SPAWNED | CMD_FLAG_ALIVE));
	AddPlayerCmd(["spawnwep"],                            CmdCallback_SpawnWep);
	AddPlayerCmd(["hp", "health"],                        CmdCallback_HP);
	AddPlayerCmd(["arm", "armour"],                       CmdCallback_Arm);
	AddPlayerCmd(["loc"],                                 CmdCallback_Loc);
	AddPlayerCmd(["ping"],                                CmdCallback_Ping);
	AddPlayerCmd(["car"],                                 CmdCallback_Car);
	AddPlayerCmd(["goto", "tp"],                          CmdCallback_GoTo,   (CMD_FLAG_SPAWNED | CMD_FLAG_ALIVE | CMD_FLAG_ONFOOT));
	AddPlayerCmd(["ann"],                                 CmdCallback_Ann);
	AddPlayerCmd(["weather", "w"],                        CmdCallback_Weather);
	AddPlayerCmd(["time", "t"],                           CmdCallback_Time);
	AddPlayerCmd(["timerate", "tr"],                      CmdCallback_TimeRate);
	AddPlayerCmd(["gamespeed", "gs"],                     CmdCallback_Speed);
	AddPlayerCmd(["gravity", "grav", "g"],                CmdCallback_Gravity);
	AddPlayerCmd(["waterlevel", "wl"],                    CmdCallback_WaterLevel);
	AddPlayerCmd(["driveonwater", "dow"],                 CmdCallback_DriveOnWater);
	AddPlayerCmd(["fastswitch", "fs"],                    CmdCallback_FastSwitch);
	AddPlayerCmd(["flyingcars", "fc"],                    CmdCallback_FlyingCars);
	AddPlayerCmd(["quake", "quakemode", "qm"],			  CmdCallback_QuakeMode);
	AddPlayerCmd(["shootinair", "sia"],                   CmdCallback_ShootInAir);

	NewTimer(TimerCallback_DisplayNewsreelMessage, 60000, 0);

	SetWeatherLock(true);

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
		PrivMessage("Server error: " + error + ".", player);
		KickPlayer(player);
		return;
	}

	player.ShootInAir = shootInAir;
	InfoMessage("Welcome to " + SERVER_NAME + ", " + player.Name + "!", player);
	InfoMessage("View a list of commands with /c cmds.", player);
}

function onPlayerPart(player, reason)
{
	EndPlayerKillingSpree(player);

	DeletePlayerData(player);
}

function onPlayerSpawn(player)
{
	local playerData = GetPlayerData(player);

	// Diepos
	if (playerData.diePosEnabled && playerData.lastDeathPos)
	{
		player.Pos = playerData.lastDeathPos;
	}

	// Spawn weapons
	if (playerData.spawnWeapons.len() && !disableSpawnWeps)
	{
		// Disarm player.
		player.SetWeapon(WEP_FIST, 0);
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

	local playerPos = player.Pos;
	playerData.lastDeathPos = (reason != WEP_DROWNED) ? playerPos : null;

	EndPlayerKillingSpree(player);
}

function onPlayerKill(killer, player, reason, bodypart) {
	//local killerData = GetPlayerData(killer);
	local playerData = GetPlayerData(player);

	killer.Cash += 500;
	if (player.Cash > 250) {
		player.Cash -= 250;
	} else {
		player.Cash = 0;
	}

	playerData.lastDeathPos = player.Pos;

	IncreasePlayerKillingSpree(killer);
	EndPlayerKillingSpree(player, killer);
}

function onPlayerCommand(player, cmdText, arguments)
{
	local cmd = FindPlayerCmd(cmdText);
	if (!cmd)
	{
		ErrorMessage("\"" + cmdText + "\" is an invalid command. Type /c cmds to display a list of commands.", player);
		return;
	}

	if ((cmd.permissionFlags & CMD_FLAG_SPAWNED) && !player.IsSpawned)
	{
		ErrorMessage("You must be spawned to use this command.", player);
		return;
	}

	if ((cmd.permissionFlags & CMD_FLAG_ALIVE) && (player.Health <= 0))
	{
		ErrorMessage("You cannot use this command while dying.", player);
		return;
	}

	if ((cmd.permissionFlags & CMD_FLAG_ONFOOT) && player.Vehicle)
	{
		ErrorMessage("You must be on foot to use this command.", player);
		return;
	}

	if ((cmd.permissionFlags & CMD_FLAG_INVEHICLE) && !player.Vehicle)
	{
		ErrorMessage("You must be in a vehicle to use this command.", player);
		return;
	}

	cmd.callback.call(getroottable(), player, cmdText, arguments);
}
