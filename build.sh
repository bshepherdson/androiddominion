#!/bin/sh

rm dominion.jar
rm dominion/*.class
./deps.sh
mirahc game/*.mirah
jar cf dominion.jar dominion/*.class

