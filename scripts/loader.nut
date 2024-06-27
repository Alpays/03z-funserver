/*
 * Just4Fun Vice City: Multiplayer (VC:MP) 0.3z R2 server
 * Authors: sfwidde ([R3V]Kelvin) and [VU]Alpays
 * 2024-06-20
 */

function ApplyServerSettings()
{
	SetWeatherLock(true);

	print("Applied server settings.");
}

function AddPlayerCommands()
{
	AddPlayerCommand(
		PlayerCmdHandler_Cmds,
		PLAYERCMD_FLAG_NONE,
		"cmds", "commands"
	);
	AddPlayerCommand(
		PlayerCmdHandler_Credits,
		PLAYERCMD_FLAG_NONE,
		"credits", "server", "script", "info"
	);
	AddPlayerCommand(
		PlayerCmdHandler_Pos,
		PLAYERCMD_FLAG_SPAWNED,
		"pos"
	);
	AddPlayerCommand(
		PlayerCmdHandler_Spree,
		PLAYERCMD_FLAG_NONE,
		"spree"
	);
	AddPlayerCommand(
		PlayerCmdHandler_DiePos,
		PLAYERCMD_FLAG_NONE,
		"diepos"
	);
	AddPlayerCommand(
		PlayerCmdHandler_Heal,
		PLAYERCMD_FLAG_SPAWNED | PLAYERCMD_FLAG_ALIVE | PLAYERCMD_FLAG_ONFOOT,
		"heal"
	);
	AddPlayerCommand(
		PlayerCmdHandler_Fix,
		PLAYERCMD_FLAG_SPAWNED | PLAYERCMD_FLAG_INVEHICLE,
		"fix", "repair"
	);
	AddPlayerCommand(
		PlayerCmdHandler_Disarm,
		PLAYERCMD_FLAG_SPAWNED | PLAYERCMD_FLAG_ALIVE,
		"disarm"
	);
	AddPlayerCommand(
		PlayerCmdHandler_Eject,
		PLAYERCMD_FLAG_SPAWNED | PLAYERCMD_FLAG_ALIVE | PLAYERCMD_FLAG_INVEHICLE,
		"eject"
	);
	AddPlayerCommand(
		PlayerCmdHandler_Wep,
		PLAYERCMD_FLAG_SPAWNED | PLAYERCMD_FLAG_ALIVE,
		"wep", "we"
	);
	AddPlayerCommand(
		PlayerCmdHandler_SpawnWep,
		PLAYERCMD_FLAG_NONE,
		"spawnwep"
	);
	AddPlayerCommand(
		PlayerCmdHandler_HP,
		PLAYERCMD_FLAG_NONE,
		"hp", "health"
	);
	AddPlayerCommand(
		PlayerCmdHandler_Arm,
		PLAYERCMD_FLAG_NONE,
		"arm", "armour"
	);
	AddPlayerCommand(
		PlayerCmdHandler_Loc,
		PLAYERCMD_FLAG_NONE,
		"loc"
	);
	AddPlayerCommand(
		PlayerCmdHandler_Ping,
		PLAYERCMD_FLAG_NONE,
		"ping"
	);
	AddPlayerCommand(
		PlayerCmdHandler_Car,
		PLAYERCMD_FLAG_NONE,
		"car"
	);
	AddPlayerCommand(
		PlayerCmdHandler_GoTo,
		PLAYERCMD_FLAG_SPAWNED | PLAYERCMD_FLAG_ALIVE | PLAYERCMD_FLAG_ONFOOT,
		"goto", "tp"
	);
	AddPlayerCommand(
		PlayerCmdHandler_Ann,
		PLAYERCMD_FLAG_NONE,
		"ann"
	);
	AddPlayerCommand(
		PlayerCmdHandler_Weather,
		PLAYERCMD_FLAG_NONE,
		"weather", "w"
	);
	AddPlayerCommand(
		PlayerCmdHandler_Time,
		PLAYERCMD_FLAG_NONE,
		"time", "t"
	);
	AddPlayerCommand(
		PlayerCmdHandler_TimeRate,
		PLAYERCMD_FLAG_NONE,
		"timerate", "tr"
	);
	AddPlayerCommand(
		PlayerCmdHandler_GameSpeed,
		PLAYERCMD_FLAG_NONE,
		"gamespeed", "gs"
	);
	AddPlayerCommand(
		PlayerCmdHandler_Gravity,
		PLAYERCMD_FLAG_NONE,
		"gravity", "grav", "g"
	);
	AddPlayerCommand(
		PlayerCmdHandler_WaterLevel,
		PLAYERCMD_FLAG_NONE,
		"waterlevel", "wl"
	);
	AddPlayerCommand(
		PlayerCmdHandler_FastSwitch,
		PLAYERCMD_FLAG_NONE,
		"fastswitch", "fs"
	);
	AddPlayerCommand(
		PlayerCmdHandler_ShootInAir,
		PLAYERCMD_FLAG_NONE,
		"shootinair", "sia"
	);
	AddPlayerCommand(
		PlayerCmdHandler_PerfectHandling,
		PLAYERCMD_FLAG_NONE,
		"perfecthandling", "ph"
	);
	AddPlayerCommand(
		PlayerCmdHandler_DriveOnWater,
		PLAYERCMD_FLAG_NONE,
		"driveonwater", "dow"
	);
	AddPlayerCommand(
		PlayerCmdHandler_FlyingCars,
		PLAYERCMD_FLAG_NONE,
		"flyingcars", "fc"
	);
	AddPlayerCommand(
		PlayerCmdHandler_QuakeMode,
		PLAYERCMD_FLAG_NONE,
		"quake", "quakemode", "qm"
	);

	print("Added player commands.");
}

function LoadServerTimers()
{
	NewTimer(TimerCallback_DisplayNewsreelMessage, 60000 /* 1 minute */, 0);
	NewTimer(TimerCallback_PlayerDataCleanup, 600000 /* 10 minutes */, 0);

	print("Loaded server timers.");
}
