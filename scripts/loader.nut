/*
 * Just4Fun Vice City: Multiplayer (VC:MP) 0.3z R2 server
 * Authors: sfwidde ([SS]Kelvin) and [VU]Alpays
 * 2024-06-20
 */

// -----------------------------------------------------------------------------

function ApplyServerSettings()
{
	SetWeatherLock(true);

	print("Applied server settings.");
}

function AddPlayerCommands()
{
	AddPlayerCmd(PlayerCmd_Cmds, CMD_FLAG_NONE, "cmds", "cmd", "commands", "command", "help");
	AddPlayerCmd(PlayerCmd_Credits, CMD_FLAG_NONE, "credits", "server", "script", "info");
	AddPlayerCmd(PlayerCmd_Pos, CMD_FLAG_SPAWNED, "pos");
	AddPlayerCmd(PlayerCmd_Spree, CMD_FLAG_NONE, "spree");
	AddPlayerCmd(PlayerCmd_DiePos, CMD_FLAG_NONE, "diepos");
	AddPlayerCmd(PlayerCmd_Heal, CMD_FLAG_SPAWNED | CMD_FLAG_ALIVE | CMD_FLAG_ONFOOT, "heal");
	AddPlayerCmd(PlayerCmd_Fix, CMD_FLAG_SPAWNED | CMD_FLAG_INVEHICLE, "fix", "repair");
	AddPlayerCmd(PlayerCmd_Disarm, CMD_FLAG_SPAWNED | CMD_FLAG_ALIVE, "disarm");
	AddPlayerCmd(PlayerCmd_Eject, CMD_FLAG_SPAWNED | CMD_FLAG_ALIVE | CMD_FLAG_INVEHICLE, "eject");
	AddPlayerCmd(PlayerCmd_Wep, CMD_FLAG_SPAWNED | CMD_FLAG_ALIVE, "wep", "we");
	AddPlayerCmd(PlayerCmd_SpawnWep, CMD_FLAG_NONE, "spawnwep", "spawnwe");
	AddPlayerCmd(PlayerCmd_Vehicle, CMD_FLAG_SPAWNED, "vehicle", "veh", "v");
	AddPlayerCmd(PlayerCmd_HP, CMD_FLAG_NONE, "hp", "health");
	AddPlayerCmd(PlayerCmd_Arm, CMD_FLAG_NONE, "arm", "armor", "armour");
	AddPlayerCmd(PlayerCmd_Loc, CMD_FLAG_NONE, "loc");
	AddPlayerCmd(PlayerCmd_Ping, CMD_FLAG_NONE, "ping");
	AddPlayerCmd(PlayerCmd_Car, CMD_FLAG_NONE, "car");
	AddPlayerCmd(PlayerCmd_CommonLoc, CMD_FLAG_SPAWNED | CMD_FLAG_ALIVE | CMD_FLAG_ONFOOT, "commonloc", "cl", "gotoloc");
	AddPlayerCmd(PlayerCmd_GoTo, CMD_FLAG_SPAWNED | CMD_FLAG_ALIVE | CMD_FLAG_ONFOOT, "goto", "tp");
	AddPlayerCmd(PlayerCmd_NoGoTo, CMD_FLAG_NONE, "nogoto", "notp");
	AddPlayerCmd(PlayerCmd_Ann, CMD_FLAG_NONE, "ann");
	AddPlayerCmd(PlayerCmd_Weather, CMD_FLAG_NONE, "weather", "w");
	AddPlayerCmd(PlayerCmd_Time, CMD_FLAG_NONE, "time", "t");
	AddPlayerCmd(PlayerCmd_TimeRate, CMD_FLAG_NONE, "timerate", "tr");
	AddPlayerCmd(PlayerCmd_GameSpeed, CMD_FLAG_NONE, "gamespeed", "gs");
	AddPlayerCmd(PlayerCmd_Gravity, CMD_FLAG_NONE, "gravity", "grav", "g");
	AddPlayerCmd(PlayerCmd_WaterLevel, CMD_FLAG_NONE, "waterlevel", "wl");
	AddPlayerCmd(PlayerCmd_FastSwitch, CMD_FLAG_NONE, "fastswitch", "fs");
	AddPlayerCmd(PlayerCmd_ShootInAir, CMD_FLAG_NONE, "shootinair", "sia");
	AddPlayerCmd(PlayerCmd_PerfectHandling, CMD_FLAG_NONE, "perfecthandling", "ph");
	AddPlayerCmd(PlayerCmd_DriveOnWater, CMD_FLAG_NONE, "driveonwater", "dow");
	AddPlayerCmd(PlayerCmd_FlyingCars, CMD_FLAG_NONE, "flyingcars", "fc");
	AddPlayerCmd(PlayerCmd_QuakeMode, CMD_FLAG_NONE, "quakemode", "quake", "qm");

	print("Added player commands.");
}

function LoadServerTimers()
{
	NewTimer(TimerCallback_DisplayNewsreelMessage, 60000 /* 1 minute */, 0);
	NewTimer(TimerCallback_PlayerDataCleanup, 600000 /* 10 minutes */, 0);

	print("Loaded server timers.");
}

// -----------------------------------------------------------------------------

function ResetWorldSettings()
{
	SetTimeRate(18);
	SetGamespeed(1.0);
	SetGravity(0.008);
	SetWaterLevel(6.0);
	SetFastSwitch(true);
	SetShootInAir(false);
	SetPerfectHandling(false);
	SetDriveOnWater(false);
	SetFlyingCars(false);
	SetQuakeMode(false);
}

// -----------------------------------------------------------------------------
