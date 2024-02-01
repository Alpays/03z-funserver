class quakeHook {
    function onPlayerSpawn(player) {
        if(quakeMode) {
            player.ShootInAir = ::shootInAir;
            player.SetWeapon(::WEP_FIST, 0);
            player.SetWeapon(30, 15000);
        }
    }
}

quake <- quakeHook();

quakeMode <- false;
disableSpawnWeps <- false;
shootInAir <- false;

function SetShootInAir(toggle) {
    shootInAir = !shootInAir;
    for(local i = 0; i < GetMaxPlayers(); ++i) {
        local p = FindPlayer(i);
        if(p) {
            p.ShootInAir = shootInAir;
        }
    }
}

function SetWeapons() {
    for(local i = 0; i < GetMaxPlayers(); ++i) {
        local p = FindPlayer(i);
        if(p) {
            p.SetWeapon(WEP_FIST, 0);
            p.SetWeapon(30, 15000);
        }
    }    
}

function toggleQuakeMode() {
    if(quakeMode) {
        quakeMode = false;
        SetGravity(0.008);
        SetShootInAir(false);
        disableSpawnWeps = false;
    }
    else {
        quakeMode = true;
        SetGravity(0.00060);
        SetShootInAir(true);
        SetWeapons();
        disableSpawnWeps = true;
    }
}