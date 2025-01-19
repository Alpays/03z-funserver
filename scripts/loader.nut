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
	AddPlayerCmd(PlayerCmd_Cmds, PLAYERCMD_FLAG_NONE, "cmds", "commands");
	AddPlayerCmd(PlayerCmd_Credits, PLAYERCMD_FLAG_NONE, "credits", "server", "script", "info");
	AddPlayerCmd(PlayerCmd_Pos, PLAYERCMD_FLAG_SPAWNED, "pos");
	AddPlayerCmd(PlayerCmd_Spree, PLAYERCMD_FLAG_NONE, "spree");
	AddPlayerCmd(PlayerCmd_DiePos, PLAYERCMD_FLAG_NONE, "diepos");
	AddPlayerCmd(PlayerCmd_Heal, PLAYERCMD_FLAG_SPAWNED | PLAYERCMD_FLAG_ALIVE | PLAYERCMD_FLAG_ONFOOT, "heal");
	AddPlayerCmd(PlayerCmd_Fix, PLAYERCMD_FLAG_SPAWNED | PLAYERCMD_FLAG_INVEHICLE, "fix", "repair");
	AddPlayerCmd(PlayerCmd_Disarm, PLAYERCMD_FLAG_SPAWNED | PLAYERCMD_FLAG_ALIVE, "disarm");
	AddPlayerCmd(PlayerCmd_Eject, PLAYERCMD_FLAG_SPAWNED | PLAYERCMD_FLAG_ALIVE | PLAYERCMD_FLAG_INVEHICLE, "eject");
	AddPlayerCmd(PlayerCmd_Wep, PLAYERCMD_FLAG_SPAWNED | PLAYERCMD_FLAG_ALIVE, "wep", "we");
	AddPlayerCmd(PlayerCmd_SpawnWep, PLAYERCMD_FLAG_NONE, "spawnwep");
	AddPlayerCmd(PlayerCmd_Vehicle, PLAYERCMD_FLAG_SPAWNED, "vehicle", "veh", "v");
	AddPlayerCmd(PlayerCmd_HP, PLAYERCMD_FLAG_NONE, "hp", "health");
	AddPlayerCmd(PlayerCmd_Arm, PLAYERCMD_FLAG_NONE, "arm", "armor", "armour");
	AddPlayerCmd(PlayerCmd_Loc, PLAYERCMD_FLAG_NONE, "loc");
	AddPlayerCmd(PlayerCmd_Ping, PLAYERCMD_FLAG_NONE, "ping");
	AddPlayerCmd(PlayerCmd_Car, PLAYERCMD_FLAG_NONE, "car");
	AddPlayerCmd(PlayerCmd_CommonLoc, PLAYERCMD_FLAG_SPAWNED | PLAYERCMD_FLAG_ALIVE | PLAYERCMD_FLAG_ONFOOT, "commonloc", "cl");
	AddPlayerCmd(PlayerCmd_GoTo, PLAYERCMD_FLAG_SPAWNED | PLAYERCMD_FLAG_ALIVE | PLAYERCMD_FLAG_ONFOOT, "goto", "tp");
	AddPlayerCmd(PlayerCmd_Ann, PLAYERCMD_FLAG_NONE, "ann");
	AddPlayerCmd(PlayerCmd_Weather, PLAYERCMD_FLAG_NONE, "weather", "w");
	AddPlayerCmd(PlayerCmd_Time, PLAYERCMD_FLAG_NONE, "time", "t");
	AddPlayerCmd(PlayerCmd_TimeRate, PLAYERCMD_FLAG_NONE, "timerate", "tr");
	AddPlayerCmd(PlayerCmd_GameSpeed, PLAYERCMD_FLAG_NONE, "gamespeed", "gs");
	AddPlayerCmd(PlayerCmd_Gravity, PLAYERCMD_FLAG_NONE, "gravity", "grav", "g");
	AddPlayerCmd(PlayerCmd_WaterLevel, PLAYERCMD_FLAG_NONE, "waterlevel", "wl");
	AddPlayerCmd(PlayerCmd_FastSwitch, PLAYERCMD_FLAG_NONE, "fastswitch", "fs");
	AddPlayerCmd(PlayerCmd_ShootInAir, PLAYERCMD_FLAG_NONE, "shootinair", "sia");
	AddPlayerCmd(PlayerCmd_PerfectHandling, PLAYERCMD_FLAG_NONE, "perfecthandling", "ph");
	AddPlayerCmd(PlayerCmd_DriveOnWater, PLAYERCMD_FLAG_NONE, "driveonwater", "dow");
	AddPlayerCmd(PlayerCmd_FlyingCars, PLAYERCMD_FLAG_NONE, "flyingcars", "fc");
	AddPlayerCmd(PlayerCmd_QuakeMode, PLAYERCMD_FLAG_NONE, "quakemode", "quake", "qm");

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
