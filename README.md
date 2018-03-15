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
 - p1Statistics: {...}
 - p2Statistics: {...}
$CHARACTERS/XXZ
 - name: "Ken"
 - p1Rating: 1
 - p2Rating: 3
 - p1Statistics: {...}
 - p2Statistics: {...}
```

In the above example the `XXY` character has a name of "Ryu", the first local player has given him a score of `3` (out of 5) while the second local player has given him a score of `5` (out of 5).

The `statistics` member is discussed later.

### results
The `results` section stores the results of battles for the user.

Each result has a unique identifier.

```
$RESULTS/ZZA
 - date: "2017-11-18 20:45:30"
 - p1Id: XXY
 - p1Name: "Ryu"
 - p2Id: XXZ
 - p2Name : "Ken"
 - p1Won: true
$RESULTS/ZZB
 - date: "2017-11-18 20:49:10"
 - p1Character: XXY
 - p2Character: XXY
 - p1Won: false
```

In the above example we see that `ZZA` describes a battle that took place on 18th November (ISO 8601 format), between character id "XXY" (name "Ryu") and "XXZ" (name "Ken"), with the winner being the first local player ( `p1Won: true` ).

The important parts of the result are the character identifiers (`p1Id`, `p2Id`) which should never change. Conversely the `p1Name` and `p2Name` are simply convenience fields that have been included to simplify the application. These could be updated if a user decides to rename a character.

The second result `ZZB` described a battle between "XXY" ("Ryu") and XXY ("Ryu") with the winner being the second local player ( `p1Won: false`).

### statistics
The recommendation from Firebase is to design data schemas for efficient fetching at the cost of redundancy. With this is mind we cache statistics throughout the app and can regenerate them through processing the contents of the `results` section.

The schema for a statistic is

```json
{
  "qtyBattles" : 2,
  "qtyWins" : 1,
  "lastBattle" : "2018-02-24 21:00:00",
  "lastWin" : "2018-02-20 09:00:00"
}
```

We store the following statistics

- Globally
- Per character
- Per character combination

### Globally

We cache the overall statistics for battles from the perspective of player 1 in `$STATISTICS/p1Statistics/overall`.

### Per character

We cache the overall statistics for player 1 usage of a character with the character info (`$CHARACTERS/$CHARACTER_ID/p1Statistics`).

The overall statistics for player 2 usage of a character is also stored with the character info (`$CHARACTERS/$CHARACTER_ID/p2Statistics  `).

### Per character combination

We cache statistics for a given player 1/player 2 character combination in `$STATISTICS/p1Statistics/character/$P1_ID/$P2_ID`.

The equivalent for player 2/player 1 is `$STATISTICS/p2Statistics/character/$P2_ID/$P1_ID`.
