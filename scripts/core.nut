// --------------------------------------------------

core <- {
    db = null
};

// --------------------------------------------------

function core::OpenServerDatabase() {
    db = ::ConnectSQL("databases/database.db");
    if (!db) {
        throw "unable to open server database";
    }
    print("Opened server database.");
}

// --------------------------------------------------

function core::CloseServerDatabase() {
    if (!::DisconnectSQL(db)) {
        throw "unable to close server database";
    }
    
    db = null;
    print("Closed server database.");
}

// --------------------------------------------------