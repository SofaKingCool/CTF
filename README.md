# Capture the Flag
A map mode for race maps in the multiplayer modification MTA (Multi Theft Auto). The point of the mode is to gather points by capturing enemy flags while keeping the own flag in the home base. In the end the team with the most points wins the match. Each dedicated CTF map should guarantee the balance for flag carrier and base defender.

## Gameflow
If a compatible map starts, the map mode analyzes the element environment and creates the teams based on the available base markers on the map (see further information under **Mapping**). The script will try to give each team the nearest spawnpoint to the base marker, add each participating player to a team and start the match.

Each time has the task to capture the enemies flag and bring it to their own base to gain points. You are only allowed to gain these points, when your own flag is in your base. When a player dies, the script will decide either to drop the flag on the ground surrounded by a rescue marker or move it back to the respective base to avoid mid-round glitches.

After the round ends (as of the current state of the writing) the team with the most points wins.

## Gameplay Screenshot
![CTF Gameplay Screenshot](http://i.imgur.com/qSONZSC.jpg)
*(The radar and logo are not included)*

## Mapping
The map mode works with the default race resource. 

To create compatible maps you are forced to add regular **MTA markers** to your map with the specific **size 5**. The marker type is not specified, but **"cylinder"** is recommended. 

To automatically start the resource on map start you have to add the following line to your **meta.xml** in the map:
```XML
<include resource="ctf-mode"/>
```

## Development
This map mode is in active development and there might be minor changes to gameflow. Furthermore, there are no feedback events for statistic resources in the current build (out-commented). There is also no point cap for the maps (e.g. reach 3 points to win the map). The maps will run until the time runs out.

**Note:** The map mode is not finished

## License
This project uses the GPL Version 3 license. For further information we recommend to investigate the [LICENSE.md](LICENSE.md)
