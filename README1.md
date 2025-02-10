(Put this in a MD renderer)

Battleship
====

A simple game made with Java

### Class Structure

- `Game`: main controller and game loop
- `Board`: manages grid and combat game logic
- `Ship`: ship state& refs management and hit detection
- `Point`: plain 2D transform coordinate data
- `AIPlayer`: computer logic

### Design

When I started planning to make this game to meet the specified requirements which are 2 players, ships, grid combat. I chose 10x10 for the grid size on 2D array with cell class to track the state and reference of each ships. 

#### AI

Originally I used a single random targeting with `Random()` but later switched to hunt and target system because it takes too much time to shoot something and players usually have clustered ships.

#### Points

The first implementation I made used objects for everything which is inefficient and eat too much memory. I later switched from objects to primitive types and POD. The results are faster ship placement and 60% memory reduction (profiled in IntelliJ).

