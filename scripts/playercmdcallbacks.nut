/*
 * Just4Fun by sfwidde ([R3V]Kelvin) and [VU]Alpays
 * 2024-01-08
 */

function CmdCallback_Cmds(player, cmdText, arguments)
{
	PrivMessage("'/c'-prefixed commands:", player);
	local cmdList = "";
	foreach (i, cmd in playerCmdPool)
	{
		if (cmdList.len())
		{
			cmdList += ", ";
		}

		foreach (j, identifier in cmd.identifiers)
		{
			cmdList += j ? ("/" + identifier) : identifier;
		}

		// Output what we have every 5 commands so the server doesn't crash on long messages.
		if (!((i + 1) % 5))
		{
			PrivMessage(cmdList, player);
			cmdList = "";
		}
	}
	if (cmdList.len())
	{
		PrivMessage(cmdList, player);
	}
}

function CmdCallback_Credits(player, cmdText, arguments)
{
	Message(">>> " + SERVER_NAME + " by [R3V]Kelvin and [VU]Alpays <<<");
	Message("Requested by " + player.Name + ".");
}

function CmdCallback_Diepos(player, cmdText, arguments)
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

function CmdCallback_Heal(player, cmdText, arguments)
{
	if (player.Health >= 100)
	{
		ErrorMessage("You don't need to be healed!", player);
		return;
	}

	player.Health = 100;
	Message(player.Name + " has healed.");
}

function CmdCallback_Disarm(player, cmdText, arguments)
{
	player.SetWeapon(WEP_FIST, 0);
	PrivMessage("You have been disarmed.", player);
}

function CmdCallback_Wep(player, cmdText, arguments)
{
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "weapon list");
		return;
	}

	local weaponId;
	local givenWeaponCount = 0;
	foreach (inputWeapon in split(arguments, " "))
	{
		weaponId = IsNum(inputWeapon) ? inputWeapon.tointeger() : GetWeaponID(inputWeapon);
		if ((weaponId < WEP_BRASSKNUCKLES) || (weaponId == 13) || (weaponId > WEP_MINIGUN))
		{
			ErrorMessage("\"" + inputWeapon + "\" is an invalid weapon.", player);
			continue;
		}

		player.SetWeapon(weaponId, 9999);
		++givenWeaponCount;
	}
	if (givenWeaponCount)
	{
		PrivMessage("Weapon" + ((givenWeaponCount != 1) ? "s" : "") + " received.", player);
	}
}

function CmdCallback_SpawnWep(player, cmdText, arguments)
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
	local canGiveWeapons = player.IsSpawned && (player.Health > 0);
	local addedWeaponCount = 0;
	foreach (inputWeapon in split(arguments, " "))
	{
		weaponId = IsNum(inputWeapon) ? inputWeapon.tointeger() : GetWeaponID(inputWeapon);
		if ((weaponId < WEP_BRASSKNUCKLES) || (weaponId == 13) || (weaponId > WEP_MINIGUN))
		{
			ErrorMessage("\"" + inputWeapon + "\" is an invalid weapon.", player);
			continue;
		}

		if (!addedWeaponCount)
		{
			playerData.spawnWeapons.clear();
			if (canGiveWeapons)
			{
				player.SetWeapon(WEP_FIST, 0);
			}
		}

		playerData.spawnWeapons.append(weaponId);
		++addedWeaponCount;
		if (canGiveWeapons)
		{
			player.SetWeapon(weaponId, 9999);
		}
	}
	if (addedWeaponCount)
	{
		PrivMessage("Weapon" + ((addedWeaponCount != 1) ? "s" : "") + " added to your spawn weapons list.", player);
	}
}

function CmdCallback_GoTo(player, cmdText, arguments)
{
	if (!arguments)
	{
		CmdSyntaxMessage(player, cmdText, "player");
		return;
	}

	local targetPlayer = FindPlayer(IsNum(arguments) ? arguments.tointeger() : arguments);
	if (!targetPlayer)
	{
		ErrorMessage("No such player was found online.", player);
		return;
	}

	if (targetPlayer.ID == player.ID)
	{
		ErrorMessage("You cannot teleport to yourself.", player);
		return;
	}

	if (!targetPlayer.IsSpawned)
	{
		ErrorMessage(targetPlayer.Name + " is not spawned.", player);
		return;
	}

	player.Pos = targetPlayer.Pos;
	Message(player.Name + " has teleported to " + targetPlayer.Name + ".");
}

function CmdCallback_Weather(player, cmdText, arguments)
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

function CmdCallback_Time(player, cmdText, arguments)
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
		ErrorMessage("Time is already set to " + newHour + ":" + newMinute + ".", player);
		return;
	}

	SetTime(newHour, newMinute);
	Message(player.Name + " has changed the time to " + newHour + ":" + newMinute + ".");
}

function CmdCallback_TimeRate(player, cmdText, arguments)
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

function CmdCallback_Speed(player, cmdText, arguments)
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

function CmdCallback_Gravity(player, cmdText, arguments)
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

function CmdCallback_WaterLevel(player, cmdText, arguments)
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

function CmdCallback_DriveOnWater(player, cmdText, arguments)
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

function CmdCallback_FlyingCars(player, cmdText, arguments)
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

function CmdCallback_Spree(player, cmdText, arguments) {
	local playerlist = "";
	local count = 0;
	for(local i = 0; i < 32; ++i) {
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
