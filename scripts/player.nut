/*
 * Just4Fun Vice City: Multiplayer (VC:MP) 0.3z R2 server
 * Authors: sfwidde ([SS]Kelvin) and [VU]Alpays
 * 2024-01-08
 */

// -----------------------------------------------------------------------------

class PlayerData
{
	lastActiveTimestamp = null;
	lastDeathPos        = null;
	lastDeathPosEnabled = true;
	spawnWeapons        = null;
	ownedVehicle        = null;
	processTimer        = null;
	spree               = 0;
}

function PlayerData::constructor()
{
	spawnWeapons = [];
}

// -----------------------------------------------------------------------------

function Player::GetData()
{
	local lowerName = Name.tolower();
	// Existing data
	if (::playerDataPool.rawin(lowerName))
	{
		return ::playerDataPool.rawget(lowerName);
	}

	// New data
	local newData = ::PlayerData();
	::playerDataPool.rawset(lowerName, newData);
	return newData;
}

// -----------------------------------------------------------------------------

function Player::SetActiveStatus(status)
{
	GetData().lastActiveTimestamp = (status ? null : ::time());
}

// -----------------------------------------------------------------------------

function Player::SetLastDeathPos(pos)
{
	GetData().lastDeathPos = pos;
}

function Player::GetLastDeathPos()
{
	return GetData().lastDeathPos;
}

function Player::SetLastDeathPosEnabled(enable)
{
	GetData().lastDeathPosEnabled = enable;
}

function Player::GetLastDeathPosEnabled()
{
	return GetData().lastDeathPosEnabled;
}

// -----------------------------------------------------------------------------

function Player::AddSpawnWeapon(weaponId)
{
	GetData().spawnWeapons.append(weaponId);
}

function Player::ClearSpawnWeapons()
{
	GetData().spawnWeapons.clear();
}

function Player::HasSpawnWeaponsSet()
{
	return !!GetData().spawnWeapons.len();
}

function Player::GiveSpawnWeapons()
{
	// Player does not have any spawn weapons set so do nothing
	if (!HasSpawnWeaponsSet()) { return; }

	// Disarm player
	SetWeapon(::WEP_FIST, 0);
	// Give them weapons
	foreach (weaponId in GetData().spawnWeapons)
	{
		SetWeapon(weaponId, 1000);
	}
}

// -----------------------------------------------------------------------------

function Player::SetProcessTimer(timer)
{
	ClearProcessTimer(); // Suppress any process player may be waiting for to finish...
	GetData().processTimer = timer;
}

function Player::ClearProcessTimer()
{
	local playerData = GetData();
	if (!playerData.processTimer) { return; }

	playerData.processTimer.Delete();
	playerData.processTimer = null;
}

// -----------------------------------------------------------------------------

function Player::IncreaseSpree()
{
	local playerData = GetData();
	local hpAddon;
	if (((++playerData.spree) % 5) == 0)
	{
		local reward = playerData.spree * 100;
		hpAddon = 40;
		Cash += reward;
		::Message(Name + " is on a killing spree of " + playerData.spree + "! ($" + reward + ")");
		::Announce("~o~killing spree!", this, 1);
	}
	else { hpAddon = 25; }

	if (IsAlive())
	{
		local newPlayerHealth = (Health + hpAddon);
		Health = (newPlayerHealth < 100) ? newPlayerHealth : 100;
	}
}

function Player::EndSpree(killer = null)
{
	local playerData = GetData();
	if (playerData.spree >= 5)
	{
		if (killer) { ::Message(killer.Name + " ended " + Name + "'s killing spree of " + playerData.spree + "!"); }
		else { ::Message(Name + " ended their own killing spree of " + playerData.spree + "!"); }
	}
	playerData.spree = 0;
}

// -----------------------------------------------------------------------------

function Player::IsNameValid()
{
	local lowerName = Name.tolower();
	return !::IsNum(lowerName) &&
		(lowerName != "off") &&
		(lowerName != "no") &&
		(lowerName != "false") &&
		(lowerName != "on") &&
		(lowerName != "yes") &&
		(lowerName != "true") &&
		(lowerName != "clear");
}

function Player::IsAlive()
{
	return IsSpawned && (Health > 0);
}

// -----------------------------------------------------------------------------
