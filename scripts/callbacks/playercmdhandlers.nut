/*
 * Just4Fun Vice City: Multiplayer (VC:MP) 0.3z R2 server
 * Authors: sfwidde ([R3V]Kelvin) and [VU]Alpays
 * 2024-01-08
 */

function PlayerCmdHandler_Cmds(player, cmdText, arguments)
{
	local cmdList = "";
	//PrivMessage("'/c'-prefixed commands:", player);
	foreach (i, cmd in playerCmdPool)
	{
		cmdList += cmdList.len() ? (", " + cmd.identifiers[0]) : cmd.identifiers[0];
		// Output what we have every 10 commands so the server doesn't crash on long messages.
		if (!((i + 1) % 10))
		{
			PrivMessage(cmdList, player);
			cmdList = "";
		}
	}
	// In case we still have something to output.
	if (cmdList.len())
	{
		PrivMessage(cmdList, player);
	}
}

function PlayerCmdHandler_Credits(player, cmdText, arguments)
{
	Message(SERVER_NAME + " by [R3V]Kelvin and [VU]Alpays");
	Message("Special credits: Hanney (hosting)");
	Message("Requested by " + player.Name + ".");
}

function PlayerCmdHandler_Pos(player, cmdText, arguments)
{
	local msg = "(" + player.Pos + "), " + player.Angle;
	MessagePlayer(msg, player);
	print(player.Name + "'s position: " + msg);
}

function PlayerCmdHandler_Spree(player, cmdText, arguments) {
	local playerlist = "";
	local count = 0;
	for(local i = 0; i < MAX_PLAYERS; ++i) {
		local p = FindPlayer(i)
		if(p)
		{
			local playerData = GetPlayerData(p)
			if(playerData.spree >= 5) {
				playerlist += p.Name + " (" + playerData.spree + ") ";
				++count;
			}
		}
	}
	if(count == 0) {
		ErrorMessage("No players are on spree!", player);
	}

	else {
		Message("[SPREE] " + playerlist);
		Message("Requested by " + player.Name + ".");
	}
}

function PlayerCmdHandler_DiePos(player, cmdText, arguments)
{
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "on/off");
		return;
	}

	local playerData = GetPlayerData(player);
	switch (arguments.tolower())
	{
	case "on":
		if (playerData.diePosEnabled)
		{
			ErrorMessage("You already spawn where you last died.", player);
			return;
		}

		playerData.diePosEnabled = true;
		PrivMessage("You will spawn where you last died from now on.", player);
		return;

	case "off":
		if (!playerData.diePosEnabled)
		{
			ErrorMessage("You already spawn at your class' spawn position.", player);
			return;
		}

		playerData.diePosEnabled = false;
		PrivMessage("You will spawn at your class' spawn position from now on.", player);
		return;

	default:
		ErrorMessage("Invalid option.", player);
		return;
	}
}

function PlayerCmdHandler_Heal(player, cmdText, arguments)
{
	if (player.Health >= 100)
	{
		ErrorMessage("You don't need to be healed!", player);
		return;
	}

	local playerData = GetPlayerData(player);
	// Suppress any process our player is waiting for to finish...
	if (playerData.processTimer) { playerData.processTimer.Delete(); }

	local playerPos = player.Pos;
	playerData.processTimer = NewTimer(TimerCallback_HealPlayer, 3000, 1,
		player.ID, playerPos.x.tointeger(), playerPos.y.tointeger(), playerPos.z.tointeger());
	PrivMessage("Stand still for 3 seconds for healing process to be successful. If you move, " +
		"you won't be healed.", player);
}

function PlayerCmdHandler_Fix(player, cmdText, arguments)
{
	local vehicle = player.Vehicle;
	local vehicleHealth = vehicle.Health;
	if (vehicleHealth >= 1000.0)
	{
		ErrorMessage("This vehicle does not need to be repaired.", player);
		return;
	}

	if (vehicleHealth < 250.0)
	{
		ErrorMessage("You cannot repair a vehicle that is on fire.", player);
		return;
	}

	local playerData = GetPlayerData(player);
	// Suppress any process our player is waiting for to finish...
	if (playerData.processTimer) { playerData.processTimer.Delete(); }

	local vehiclePos = vehicle.Pos;
	playerData.processTimer = NewTimer(TimerCallback_FixPlayerVehicle, 5000, 1,
		player.ID, vehicle.ID, vehiclePos.x.tointeger(), vehiclePos.y.tointeger(), vehiclePos.z.tointeger());
	PrivMessage("Vehicle must stand still for 5 seconds for repair process to be successful. " +
		"If it moves, it won't be repaired.", player);
}

function PlayerCmdHandler_Disarm(player, cmdText, arguments)
{
	player.SetWeapon(WEP_FIST, 0);
	PrivMessage("You have been disarmed.", player);
}

function PlayerCmdHandler_Eject(player, cmdText, arguments)
{
	local playerPos = player.Pos;
	player.Pos = Vector(playerPos.x, playerPos.y, playerPos.z + 10.0);
	Message(player.Name + " has ejected themselves from their vehicle.");
}

function PlayerCmdHandler_Wep(player, cmdText, arguments)
{
	if(quakeMode) {
		ErrorMessage("You cannot use this command in quake mode.", player);
		return;
	}

	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "weapon list");
		return;
	}

	local weaponId;
	local givenWeaponCount = 0;
	foreach (inputWeapon in split(arguments, " "))
	{
		// Convert input weapon to int.
		weaponId = IsNum(inputWeapon) ? inputWeapon.tointeger() : GetWeaponID(inputWeapon);
		// Make sure we are processing a valid weapon...
		if ((weaponId < WEP_BRASSKNUCKLES) || (weaponId == 13) || (weaponId > WEP_MINIGUN))
		{
			ErrorMessage("\"" + inputWeapon + "\" is an invalid weapon.", player);
			continue;
		}

		player.SetWeapon(weaponId, 1000);
		++givenWeaponCount;
	}
	if (givenWeaponCount)
	{
		PrivMessage("Weapon" + ((givenWeaponCount != 1) ? "s" : "") + " received.", player);
	}
}

function PlayerCmdHandler_SpawnWep(player, cmdText, arguments)
{
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "weapon list/off");
		return;
	}

	local playerData = GetPlayerData(player);
	arguments = arguments.tolower();
	if (arguments == "off")
	{
		if (!playerData.spawnWeapons.len())
		{
			ErrorMessage("You have not set your spawn weapons yet.", player);
			return;
		}

		playerData.spawnWeapons.clear();
		PrivMessage("Your spawn weapons have been cleared.", player);
		return;
	}

	local weaponId;
	local canGiveWeapons = (player.IsAlive() && !quakeMode);
	local addedWeaponCount = 0;
	foreach (inputWeapon in split(arguments, " "))
	{
		// Convert input weapon to int.
		weaponId = IsNum(inputWeapon) ? inputWeapon.tointeger() : GetWeaponID(inputWeapon);
		// Make sure we are processing a valid weapon...
		if ((weaponId < WEP_BRASSKNUCKLES) || (weaponId == 13) || (weaponId > WEP_MINIGUN))
		{
			ErrorMessage("\"" + inputWeapon + "\" is an invalid weapon.", player);
			continue;
		}

		// We are processing a valid weapon now, so clear previous
		// spawn weapons if we haven't yet.
		if (!addedWeaponCount)
		{
			playerData.spawnWeapons.clear();
			// Disarm player.
			if (canGiveWeapons)
			{
				player.SetWeapon(WEP_FIST, 0);
			}
		}

		playerData.spawnWeapons.append(weaponId);
		++addedWeaponCount;
		// Give just added weapon to player's hand, if allowed to.
		if (canGiveWeapons)
		{
			player.SetWeapon(weaponId, 1000);
		}
	}
	if (addedWeaponCount)
	{
		PrivMessage("Weapon" + ((addedWeaponCount != 1) ? "s" : "") + " added to your spawn weapons list.", player);
	}
}

function PlayerCmdHandler_HP(player, cmdText, arguments)
{
	local playerId = player.ID;
	if (!arguments)
	{
		arguments = playerId.tostring();
	}

	local targetPlayer = GetPlayer(arguments);
	if (!targetPlayer)
	{
		ErrorMessage("No such player was found online.", player);
		return;
	}

	local isSelf = (targetPlayer.ID == playerId);
	if (!targetPlayer.IsSpawned)
	{
		ErrorMessage(isSelf ? "You are not spawned." : (targetPlayer.Name + " is not spawned."), player);
		return;
	}

	if (targetPlayer.Vehicle)
	{
		ErrorMessage(isSelf ? "You cannot check your own health because you are in a vehicle." :
			("You cannot check " + targetPlayer.Name + "'s health because they are in a vehicle."), player);
		return;
	}

	Message(targetPlayer.Name + "'s health: " + targetPlayer.Health + "%. Requested by " +
		(isSelf ? "themselves" : player.Name) + ".");
}

function PlayerCmdHandler_Arm(player, cmdText, arguments)
{
	local playerId = player.ID;
	if (!arguments)
	{
		arguments = playerId.tostring();
	}

	local targetPlayer = GetPlayer(arguments);
	if (!targetPlayer)
	{
		ErrorMessage("No such player was found online.", player);
		return;
	}

	local isSelf = (targetPlayer.ID == playerId);
	if (!targetPlayer.IsSpawned)
	{
		ErrorMessage(isSelf ? "You are not spawned." : (targetPlayer.Name + " is not spawned."), player);
		return;
	}

	if (targetPlayer.Vehicle)
	{
		ErrorMessage(isSelf ? "You cannot check your own armour because you are in a vehicle." :
			("You cannot check " + targetPlayer.Name + "'s armour because they are in a vehicle."), player);
		return;
	}

	Message(targetPlayer.Name + "'s armour: " + targetPlayer.Armour + "%. Requested by " +
		(isSelf ? "themselves" : player.Name) + ".");
}

function PlayerCmdHandler_Loc(player, cmdText, arguments)
{
	local playerId = player.ID;
	if (!arguments)
	{
		arguments = playerId.tostring();
	}

	local targetPlayer = GetPlayer(arguments);
	if (!targetPlayer)
	{
		ErrorMessage("No such player was found online.", player);
		return;
	}

	local targetPlayerId = targetPlayer.ID;
	local isSelf = (targetPlayerId == playerId);
	if (!targetPlayer.IsSpawned)
	{
		ErrorMessage(isSelf ? "You are not spawned." : (targetPlayer.Name + " is not spawned."), player);
		return;
	}

	local targetPlayerName = targetPlayer.Name;
	local targetPlayerPos  = targetPlayer.Pos;
	local districtName     = GetDistrictName(targetPlayerPos.x, targetPlayerPos.y);
	local requestedBy      = isSelf ? "themselves" : player.Name;
	// Message for everyone, but with relative distances.
	for (local i = 0, plr, plrPos; i < MAX_PLAYERS; ++i)
	{
		plr = FindPlayer(i);
		if (!plr) { continue; }

		// Exclude distance if
		// - target player is the one receiving message, because for them distance will always be zero, or
		// - current player to send message to is unspawned, because it doesn't make any sense
		// to measure distance for unspawned players.
		if ((i == targetPlayerId) || !plr.IsSpawned)
		{
			MessagePlayer(targetPlayerName + "'s location: " + districtName +
				". Requested by " + requestedBy + ".", plr);
		}
		else
		{
			plrPos = plr.Pos;
			MessagePlayer(targetPlayerName + "'s location: " + districtName + " (" +
				DistanceFromPoint(plrPos.x, plrPos.y, targetPlayerPos.x, targetPlayerPos.y) +
				"m). Requested by " + requestedBy + ".", plr);
		}
	}
}

function PlayerCmdHandler_Ping(player, cmdText, arguments)
{
	local playerId = player.ID;
	if (!arguments)
	{
		arguments = playerId.tostring();
	}

	local targetPlayer = GetPlayer(arguments);
	if (!targetPlayer)
	{
		ErrorMessage("No such player was found online.", player);
		return;
	}

	Message(targetPlayer.Name + "'s ping: " + targetPlayer.Ping + ". Requested by " +
		((targetPlayer.ID != playerId) ? player.Name : "themselves") + ".");
}

function PlayerCmdHandler_Car(player, cmdText, arguments)
{
	local playerId = player.ID;
	if (!arguments)
	{
		arguments = playerId.tostring();
	}

	local targetPlayer = GetPlayer(arguments);
	if (!targetPlayer)
	{
		ErrorMessage("No such player was found online.", player);
		return;
	}

	local isSelf = (targetPlayer.ID == playerId);
	if (!targetPlayer.IsSpawned)
	{
		ErrorMessage(isSelf ? "You are not spawned." : (targetPlayer.Name + " is not spawned."), player);
		return;
	}

	local vehicle = targetPlayer.Vehicle;
	if (!vehicle)
	{
		ErrorMessage(isSelf ? "You are not driving a vehicle." :
			(targetPlayer.Name + " is not driving a vehicle."), player);
		return;
	}

	Message(targetPlayer.Name + "'s vehicle: " + GetVehicleNameFromModel(vehicle.Model) +
		". Requested by " + (isSelf ? "themselves" : player.Name) + ".");
}

function PlayerCmdHandler_GoTo(player, cmdText, arguments)
{
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "player");
		return;
	}

	local targetPlayer = GetPlayer(arguments);
	if (!targetPlayer)
	{
		ErrorMessage("No such player was found online.", player);
		return;
	}

	local playerId = player.ID;
	if (targetPlayer.ID == playerId)
	{
		ErrorMessage("You cannot teleport to yourself.", player);
		return;
	}

	if (!targetPlayer.IsSpawned)
	{
		ErrorMessage(targetPlayer.Name + " is not spawned.", player);
		return;
	}

	local playerData = GetPlayerData(player);
	// Suppress any process our player is waiting for to finish...
	if (playerData.processTimer) { playerData.processTimer.Delete(); }

	local playerPos = player.Pos;
	local targetPlayerName = targetPlayer.Name; // Using name rather than ID is 'safer' in this case.
	playerData.processTimer = NewTimer(TimerCallback_TeleportPlayerToPlayer, 3000, 1,
		playerId, targetPlayerName, playerPos.x.tointeger(), playerPos.y.tointeger(), playerPos.z.tointeger());
	PrivMessage("Stand still for 3 seconds to teleport to " + targetPlayerName + ". If you move, " +
		"you won't be teleported.", player);
}

function PlayerCmdHandler_Ann(player, cmdText, arguments)
{
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "message");
		return;
	}

	local message = "";
	local niceTry = false;
	foreach (char in arguments)
	{
		// Unfortunately, I am too lazy to determine whether our player tried to send a colored
		// message or actually wanted to fuck up the whole server with a crashy announcement.
		if (char == '~')
		{
			niceTry = true;
			continue;
		}

		message += char.tochar();
	}

	if (niceTry)
	{
		ErrorMessage("Don't even think about it, you fucking idiot.", player);
	}
	AnnounceAll(message, 0);
	Message(player.Name + " announced: " + message);
}

function PlayerCmdHandler_Weather(player, cmdText, arguments)
{
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "weather ID");
		return;
	}

	if (!IsNum(arguments))
	{
		ErrorMessage("Weather ID must be a number.", player);
		return;
	}

	local newWeather = arguments.tointeger();
	if (newWeather < 0/* || newWeather > 5*/)
	{
		ErrorMessage("Invalid weather ID.", player);
		return;
	}

	if (newWeather == GetWeather())
	{
		ErrorMessage("Weather " + newWeather + " is already set.", player);
		return;
	}

	SetWeather(newWeather);
	Message(player.Name + " has changed weather to " + newWeather + ".");
}

function PlayerCmdHandler_Time(player, cmdText, arguments)
{
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "hour", "minute");
		return;
	}

	local tokens = split(arguments, " ");

	if (!IsNum(tokens[0]))
	{
		ErrorMessage("Hour must be a number.", player);
		return;
	}

	local newHour = tokens[0].tointeger();
	if (newHour < 0 || newHour > 23)
	{
		ErrorMessage("Invalid hour.", player);
		return;
	}

	if (tokens.len() < 2)
	{
		ErrorMessage("Please provide a minute.", player);
		return;
	}

	if (!IsNum(tokens[1]))
	{
		ErrorMessage("Minute must be a number", player);
		return;
	}

	local newMinute = tokens[1].tointeger();
	if (newMinute < 0 || newMinute > 59)
	{
		ErrorMessage("Invalid minute.", player);
		return;
	}

	if ((newHour == GetHour()) && (newMinute == GetMinute()))
	{
		ErrorMessage(format("Time is already set to %02d:%02d.", newHour, newMinute), player);
		return;
	}

	SetTime(newHour, newMinute);
	Message(format("%s has changed time to %02d:%02d.", player.Name, newHour, newMinute));
}

function PlayerCmdHandler_TimeRate(player, cmdText, arguments)
{
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "time rate");
		return;
	}

	if (!IsNum(arguments))
	{
		ErrorMessage("Time rate must be a number.", player);
		return;
	}

	local newTimeRate = arguments.tointeger();
	if (newTimeRate == GetTimeRate())
	{
		ErrorMessage("Time rate is already set to " + newTimeRate + ".", player);
		return;
	}

	SetTimeRate(newTimeRate);
	Message(player.Name + " has changed time rate to " + newTimeRate + ".");
}

function PlayerCmdHandler_Speed(player, cmdText, arguments)
{
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "game speed");
		PrivMessage("Default game speed is 1.", player);
		return;
	}

	local newGameSpeed;
	try
	{
		newGameSpeed = arguments.tofloat();
	}
	catch (x)
	{
		ErrorMessage("Game speed must be convertible to float.", player);
		return;
	}

	if (newGameSpeed == GetGamespeed())
	{
		ErrorMessage("Game speed is already set to " + newGameSpeed + ".", player);
		return;
	}

	SetGamespeed(newGameSpeed);
	Message(player.Name + " has changed game speed to " + newGameSpeed + ".");
}

function PlayerCmdHandler_Gravity(player, cmdText, arguments)
{
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "gravity");
		PrivMessage("Default gravity is 0.008.", player);
		return;
	}

	local newGravity;
	try
	{
		newGravity = arguments.tofloat();
	}
	catch (x)
	{
		ErrorMessage("Gravity must be convertible to float.", player);
		return;
	}

	if (newGravity == GetGravity())
	{
		ErrorMessage("Gravity is already set to " + newGravity + ".", player);
		return;
	}

	SetGravity(newGravity);
	Message(player.Name + " has changed gravity to " + newGravity + ".");
}

function PlayerCmdHandler_WaterLevel(player, cmdText, arguments)
{
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "water level");
		PrivMessage("Default water level is 6.", player);
		return;
	}

	local newWaterLevel;
	try
	{
		newWaterLevel = arguments.tofloat();
	}
	catch (x)
	{
		ErrorMessage("Water level must be convertible to float.", player);
		return;
	}

	if (newWaterLevel == GetWaterLevel())
	{
		ErrorMessage("Water level is already set to " + newWaterLevel + ".", player);
		return;
	}

	SetWaterLevel(newWaterLevel);
	Message(player.Name + " has changed water level to " + newWaterLevel + ".");
}

function PlayerCmdHandler_FastSwitch(player, cmdText, arguments)
{
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "on/off");
		return;
	}

	switch (arguments.tolower())
	{
	case "on":
		if (GetFastSwitch())
		{
			ErrorMessage("FastSwitch is already enabled.", player);
			return;
		}

		SetFastSwitch(true);
		Message(player.Name + " has enabled FastSwitch.");
		return;

	case "off":
		if (!GetFastSwitch())
		{
			ErrorMessage("FastSwitch is already disabled.", player);
			return;
		}

		SetFastSwitch(false);
		Message(player.Name + " has disabled FastSwitch.");
		return;

	default:
		ErrorMessage("Invalid option.", player);
		return;
	}
}

function PlayerCmdHandler_ShootInAir(player, cmdText, arguments) {
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "on/off");
		return;
	}
	switch (arguments.tolower())
	{
	case "on":
		if (shootInAir)
		{
			ErrorMessage("ShootInAir is already enabled.", player);
			return;
		}

		SetShootInAir(true);
		Message(player.Name + " has enabled ShootInAir.");
		return;

	case "off":
		if (!shootInAir)
		{
			ErrorMessage("ShootInAir is already disabled.", player);
			return;
		}

		SetShootInAir(false);
		Message(player.Name + " has disabled ShootInAir.");
		return;

	default:
		ErrorMessage("Invalid option.", player);
		return;
	}
}

function PlayerCmdHandler_PerfectHandling(player, cmdText, arguments)
{
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "on/off");
		return;
	}

	switch (arguments.tolower())
	{
	case "on":
		if (GetPerfectHandling())
		{
			ErrorMessage("PerfectHandling is already enabled.", player);
			return;
		}

		SetPerfectHandling(true);
		Message(player.Name + " has enabled PerfectHandling.");
		return;

	case "off":
		if (!GetPerfectHandling())
		{
			ErrorMessage("PerfectHandling is already disabled.", player);
			return;
		}

		SetPerfectHandling(false);
		Message(player.Name + " has disabled PerfectHandling.");
		return;

	default:
		ErrorMessage("Invalid option.", player);
		return;
	}
}

function PlayerCmdHandler_DriveOnWater(player, cmdText, arguments)
{
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "on/off");
		return;
	}

	switch (arguments.tolower())
	{
	case "on":
		if (GetDriveOnWater())
		{
			ErrorMessage("DriveOnWater is already enabled.", player);
			return;
		}

		SetDriveOnWater(true);
		Message(player.Name + " has enabled DriveOnWater.");
		return;

	case "off":
		if (!GetDriveOnWater())
		{
			ErrorMessage("DriveOnWater is already disabled.", player);
			return;
		}

		SetDriveOnWater(false);
		Message(player.Name + " has disabled DriveOnWater.");
		return;

	default:
		ErrorMessage("Invalid option.", player);
		return;
	}
}

function PlayerCmdHandler_FlyingCars(player, cmdText, arguments)
{
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "on/off");
		return;
	}

	switch (arguments.tolower())
	{
	case "on":
		if (GetFlyingCars())
		{
			ErrorMessage("FlyingCars is already enabled.", player);
			return;
		}

		SetFlyingCars(true);
		Message(player.Name + " has enabled FlyingCars.");
		return;

	case "off":
		if (!GetFlyingCars())
		{
			ErrorMessage("FlyingCars is already disabled.", player);
			return;
		}

		SetFlyingCars(false);
		Message(player.Name + " has disabled FlyingCars.");
		return;

	default:
		ErrorMessage("Invalid option.", player);
		return;
	}
}

function PlayerCmdHandler_QuakeMode(player, cmdText, arguments) {
	toggleQuakeMode();

	if(quakeMode) {
		Message(player.Name + " activated Quake Mode.");
	}
	else {
		Message(player.Name + " stopped Quake Mode.");
	}
}
