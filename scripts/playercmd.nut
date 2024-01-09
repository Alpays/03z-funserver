class PlayerCmd
{
	identifiers     = null;
	callback        = null;
	permissionFlags = null;
}

function PlayerCmd::constructor(identifiers, callback, permissionFlags)
{
	this.identifiers     = identifiers;
	this.callback        = callback;
	this.permissionFlags = permissionFlags;
}

// ----------------------------------------------------------------------------

function AddPlayerCmd(identifiers, callback, permissionFlags = CMD_FLAG_NONE)
{
	foreach (identifier in identifiers)
	{
		if (FindPlayerCmd(identifier))
		{
			throw "player command '" + identifier + "' already exists";
		}
	}

	foreach (cmd in playerCmdPool)
	{
		if (callback == cmd.callback)
		{
			throw "callback " + callback + " is already associated with a player command";
		}
	}

	playerCmdPool.append(PlayerCmd(identifiers, callback, permissionFlags));
}

function FindPlayerCmd(identifier)
{
	identifier = identifier.tolower();
	foreach (cmd in playerCmdPool)
	{
		foreach (cmdIdentifier in cmd.identifiers)
		{
			if (identifier == cmdIdentifier.tolower())
			{
				return cmd;
			}
		}
	}
	return null;
}
