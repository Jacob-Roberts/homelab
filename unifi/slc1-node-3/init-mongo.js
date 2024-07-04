// Before running, change the `MONGO_PASS` to the same value as in .env
db.getSiblingDB("unifi").createUser({user: "unifi", pwd: "MONGO_PASS", roles: [{role: "dbOwner", db: "unifi"}]});
db.getSiblingDB("unifi_stat").createUser({user: "unifi", pwd: "MONGO_PASS", roles: [{role: "dbOwner", db: "unifi_stat"}]});
