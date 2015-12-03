#!/bin/bash

RS01=`mktemp`; mv $RS01 $RS01.js
RS02=`mktemp`; mv $RS02 $RS02.js
SHARD=`mktemp`; mv $SHARD $SHARD.js
mkdir -p ~/data/s1-a ~/data/s1-b ~/data/s1-c
mkdir -p ~/data/s2-a ~/data/s2-b ~/data/s2-c
mkdir -p ~/data/cfg-a ~/data/cfg-b ~/data/cfg-c
mkdir -p ./logs/


echo "config = { \"_id\" : \"s1\", \"members\" : [
{ \"_id\" : 0, \"host\" : \"localhost:37017\"  },
    { \"_id\" : 1, \"host\" : \"localhost:37018\"  },
        { \"_id\" : 2, \"host\" : \"localhost:37019\"  } 
]
}

rs.initiate(config)" > $RS01.js

echo "config = { \"_id\" : \"s2\", \"members\" : [
{ \"_id\" : 0, \"host\" : \"localhost:47017\"  },
    { \"_id\" : 1, \"host\" : \"localhost:47018\"  },
        { \"_id\" : 2, \"host\" : \"localhost:47019\"  } 
]
}
rs.initiate(config)" > $RS02.js

echo "db.adminCommand( { \"addshard\" : \"s1/localhost:37017\"  }  ) ;
db.adminCommand( { \"addshard\" : \"s2/localhost:47017\"  }  ) ;
db.adminCommand( { \"enablesharding\" : \"test\"  }  ) ;
db.adminCommand( { \"shardcollection\" : \"test.users\", \"key\" : { \"_id\" : 1  }  }  ) ;" > $SHARD.js

mongod --replSet s1 --logpath "./logs/s1-a.log" --dbpath ~/data/s1-a --port 37017 --shardsvr --fork --oplogSize 50 --smallfiles --logappend --rest
mongod --replSet s1 --logpath "./logs/s1-b.log" --dbpath ~/data/s1-b --port 37018 --shardsvr --fork --oplogSize 50 --smallfiles --logappend --rest
mongod --replSet s1 --logpath "./logs/s1-c.log" --dbpath ~/data/s1-c --port 37019 --shardsvr --fork --oplogSize 50 --smallfiles --logappend --rest
sleep 5
echo "SET UP FIRST REPLICA SET NOW"
mongo --port 37017 $RS01.js

mongod --replSet s2 --logpath "./logs/s2-a.log" --dbpath ~/data/s2-a --port 47017 --shardsvr --fork --oplogSize 50 --smallfiles --logappend --rest
mongod --replSet s2 --logpath "./logs/s2-b.log" --dbpath ~/data/s2-b --port 47018 --shardsvr --fork --oplogSize 50 --smallfiles --logappend --rest
mongod --replSet s2 --logpath "./logs/s2-c.log" --dbpath ~/data/s2-c --port 47019 --shardsvr --fork --oplogSize 50 --smallfiles --logappend --rest
sleep 5
echo "SET UP SECOND REPLICA SET NOW"
mongo --port 47017 $RS02.js

mongod --logpath "./logs/cfg-a.log" --dbpath ~/data/cfg-a --port 57017 --configsvr --fork --oplogSize 50 --smallfiles --logappend --rest
mongod --logpath "./logs/cfg-b.log" --dbpath ~/data/cfg-b --port 57018 --configsvr --fork --oplogSize 50 --smallfiles --logappend --rest
mongod --logpath "./logs/cfg-c.log" --dbpath ~/data/cfg-c --port 57019 --configsvr --fork --oplogSize 50 --smallfiles --logappend --rest

sleep 5
echo "SET UP MONGOS NOW"
mongos --port 61017 --fork --logpath "./logs/mongos-1.log" --logappend --configdb localhost:57017,localhost:57018,localhost:57019

sleep 5
echo "SET UP SHARDS NOW"
mongo --port 61017 $SHARD.js


echo "PAUSING WHILE THE SHARDS ALL SETUP (10S)"
sleep 10
mongo --port 61017 --eval "sh.status()"
