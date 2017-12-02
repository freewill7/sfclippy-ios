# sfclippy

This is the iOS version of *sfclippy* - an app designed to be useful for people playing the local "versus" mode of SF5.

The primary motivation for *sfclippy* was a better way of randomly selecting characters (e.g. blacklisting, favouring...). However it soon evolved into a tool capable of storing results and generating interesting statistics.

For storage we use the Firebase database ( [firebase.google.com] ) as it provides an easy way of storing data across devices and allows for some interesting features down the line.

## firebase schema

Each user of the app has their own area in the database

```
/users/USER_ID
```

Within this area we store `characters`, `results` and `statistics`.

```
$USER/characters/
$USER/results/
$USER/statistics/
```

### characters
The `characters` area stores character preferences for the user.

Each character is identified by a unique identifier (e.g. `XXY`, `XXZ`) in case the user wants to change the associated name at a later date.

```
$CHARACTERS/XXY
 - name: "Ryu"
 - p1Rating: 3
 - p2Rating: 5
$CHARACTERS/XXZ
 - name: "Ken"
 - p1Rating: 1
 - p2Rating: 3
```

In the above example the `XXY` character has a name of "Ryu", the first local player has given him a score of `3` (out of 5) while the second local player has given him a score of `5` (out of 5).

### results
The `results` section stores the results of battles for the user.

Each result has a unique identifier.

```
$RESULTS/ZZA
 - date: "2017-11-18 20:45:30"
 - p1Character: XXY
 - p2Character: XXZ
 - p1Won: true
$RESULTS/ZZB
 - date: "2017-11-18 20:49:10"
 - p1Character: XXY
 - p2Character: XXY
 - p1Won: false
```

In the above example we see that `ZZA` describes a battle that took place on 18th November (ISO 8601 format), between character id "XXY" ("Ryu") and "XXZ" ("Ken"), with the winner being the first local player ( `p1Won: true` ).

The second result `ZZB` described a battle between "XXY" ("Ryu") and XXY ("Ryu") with the winner being the second local player ( `p1Won: false`).

### statistics
(not yet implemented)
