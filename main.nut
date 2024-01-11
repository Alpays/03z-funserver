/*
 * Just4Fun by sfwidde ([R3V]Kelvin) and [VU]Alpays
 * 2024-01-08
 */

const SERVER_NAME = "Just4Fun";

const CMD_FLAG_NONE    = 0x00;
const CMD_FLAG_SPAWNED = 0x01;
const CMD_FLAG_ALIVE   = 0x02;
const CMD_FLAG_ONFOOT  = 0x04;

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

	/* Initialize our containers */
	playerDataPool = array(GetMaxPlayers());
	playerCmdPool  = [];
	newsreelText   =
	[
		"Type /c cmds to display a list of commands.",
		"Don't want to spawn where you last died anymore? Type /c diepos to toggle this feature on or off.",
		"Low on health? Type /c heal to heal yourself!",
		"Get yourself some weapons with /c wep!",
		"Remove whatever weapons you have in hand with /c disarm.",
		"Tired of typing /c wep every time you spawn? /c spawnwep allows you to spawn with any weapons you choose!",
		"Type /c goto to teleport to any player you desire."
	];

	/* Set up player commands */
	AddPlayerCmd(["cmds", "commands"],                    CmdCallback_Cmds);
	AddPlayerCmd(["credits", "server", "script", "info"], CmdCallback_Credits);
	AddPlayerCmd(["diepos"],                              CmdCallback_DiePos);
	AddPlayerCmd(["heal"],                                CmdCallback_Heal,   (CMD_FLAG_SPAWNED | CMD_FLAG_ALIVE));
	AddPlayerCmd(["disarm"],                              CmdCallback_Disarm, (CMD_FLAG_SPAWNED | CMD_FLAG_ALIVE));
	AddPlayerCmd(["wep", "we"],                           CmdCallback_Wep,    (CMD_FLAG_SPAWNED | CMD_FLAG_ALIVE));
	AddPlayerCmd(["spawnwep"],                            CmdCallback_SpawnWep);
	AddPlayerCmd(["goto", "tp"],                          CmdCallback_GoTo,   (CMD_FLAG_SPAWNED | CMD_FLAG_ALIVE | CMD_FLAG_ONFOOT));
	AddPlayerCmd(["weather", "w"],                        CmdCallback_Weather);
	AddPlayerCmd(["time", "t"],                           CmdCallback_Time);
	AddPlayerCmd(["timerate", "tr"],                      CmdCallback_TimeRate);
	AddPlayerCmd(["gamespeed", "gs"],                     CmdCallback_Speed);
	AddPlayerCmd(["gravity", "grav", "g"],                CmdCallback_Gravity);
	AddPlayerCmd(["waterlevel", "wl"],                    CmdCallback_WaterLevel);
	AddPlayerCmd(["driveonwater", "dow"],                 CmdCallback_DriveOnWater);
	AddPlayerCmd(["flyingcars", "fc"],                    CmdCallback_FlyingCars);
	AddPlayerCmd(["pos"],                                 CmdCallback_Pos, CMD_FLAG_SPAWNED);
	AddPlayerCmd(["spree"],                               CmdCallback_Spree);

	NewTimer(TimerCallback_DisplayNewsreelMessage, 60000, 0);

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

	InfoMessage("Welcome to " + SERVER_NAME + ", " + player.Name + "!", player);
	InfoMessage("View a list of commands with /c cmds.", player);
}

function onPlayerPart(player, reason)
{
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
	if (playerData.spawnWeapons.len())
	{
		// Disarm player.
		player.SetWeapon(WEP_FIST, 0);
		foreach (weaponId in playerData.spawnWeapons)
		{
			player.SetWeapon(weaponId, 9999);
		}
	}
}

function onPlayerDeath(player, reason)
{
	local playerData = GetPlayerData(player);

	local playerPos = player.Pos;
	playerData.lastDeathPos = (reason != WEP_DROWNED) ? playerPos : null;

	if(playerData.spree >= 5) 
	{
		Message(player.Name + "'s killing spree of " + playerData.spree + " has been ended!")
	}
	playerData.spree = 0;
}

function onPlayerKill(killer, player, reason, bodypart) {
	local killerData = GetPlayerData(killer);
	local playerData = GetPlayerData(player);

	killerData.spree += 1;

	killer.Cash += 500;
	player.Cash -= 250;

	playerData.lastDeathPos = player.Pos;

	if(killerData.spree % 5 == 0)
	{
		local reward = killerData.spree * 100;
		Message(killer.Name + " is on a killing spree of " + killerData.spree + "! ($" + reward + ")" )
		killer.Cash += reward;
		Announce("~o~Killing spree!", killer, 1)
	}

	if(playerData.spree >= 5) 
	{
		Message(player.Name + "'s killing spree of " + playerData.spree + " has been ended by " + killer.Name + "!")
	}
	playerData.spree = 0;
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

	cmd.callback.call(getroottable(), player, cmdText, arguments);
}
