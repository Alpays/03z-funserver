/*
 * Just4Fun Vice City: Multiplayer (VC:MP) 0.3z R2 server
 * Authors: sfwidde ([SS]Kelvin) and [VU]Alpays
 * 2024-01-08
 */

// -----------------------------------------------------------------------------

class PlayerCmd
{
	identifiers     = null;
	handler         = null;
	permissionFlags = null;
}

function PlayerCmd::constructor(identifiers, handler, permissionFlags)
{
	this.identifiers = identifiers;
	this.handler = handler;
	this.permissionFlags = permissionFlags;
}

// -----------------------------------------------------------------------------

function AddPlayerCmd(handler, permissionFlags, ...)
{
	if (!vargv.len()) { throw "player command must have at least one identifier"; }

	foreach (identifier in vargv)
	{
		if (FindPlayerCmd(identifier))
		{
			throw "player command \"" + identifier + "\" already exists";
		}
	}

	foreach (cmd in playerCmdPool)
	{
		if (handler == cmd.handler)
		{
			throw "player command handler " + handler + " is already associated with an existing command";
		}
	}

	playerCmdPool.append(PlayerCmd(vargv, handler, permissionFlags));
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

// -----------------------------------------------------------------------------
