/*
 * Create stats table
 */
#define CMD_CREATETABLE "CREATE TABLE IF NOT EXISTS playerstats (steamid TEXT NOT NULL default '', name TEXT NOT NULL default '', score INTEGER NOT NULL default 0, credits INTEGER NOT NULL default 0, infections INTEGER NOT NULL default 0, kills INTEGER NOT NULL default 0, knifekills INTEGER NOT NULL default 0, escapes INTEGER NOT NULL default 0, deaths INTEGER NOT NULL default 0, time_played INTEGER NOT NULL default 0 );"

/*
 * Delete stats table
 */
#define CMD_DELETETABLE "DROP TABLE IF EXISTS 'playerstats'; VACUUM;"

/*
 * Create player
 * param1: String:steamid
 * param2: String:name
 */
#define CMD_CREATEPLAYER "INSERT INTO playerstats (steamid, name, score, credits, infections, kills, knifekills, escapes, deaths, time_played ) VALUES ( '%s', '%s', 0, 0, 0, 0, 0, 0, 0, 0)"

/*
 * Save player
 * param1: String:name
 * param2: score
 * param3: credits
 * param4: infections
 * param5: kills
 * param6: knife kills
 * param6: escapes
 * param7: deaths
 * param8: time_played
 * param9: String:steamid
 */
#define CMD_SAVEPLAYER "UPDATE playerstats SET name = '%s', score = %i, credits = %i, infections = %i, kills = %i, knifekills = %i, escapes = %i, deaths = %i, time_played = %i WHERE steamid = '%s'"

/*
 * Delete player
 * param1: String:steamid
 */
#define CMD_DELETEPLAYER "DELETE FROM playerstats WHERE steamid = '%s';"

/*
 * Get player count
 */
#define CMD_PLAYERCOUNT "SELECT * FROM playerstats;"

/*
 * Select player
 * param1: String:steamid
 */
#define CMD_SELECTPLAYER "SELECT * FROM playerstats WHERE steamid = '%s';"

/*
 * Get player
 * param1: String:steamid
 */
#define CMD_GETPLAYER "SELECT steamid, name, score, credits, infections, kills, knifekills, escapes, deaths, time_played FROM playerstats WHERE steamid = '%s'"

/*
 * Get top player
 * param1: start point (i.e. 1)
 * param2: offset (i.e. 10)
 */
#define CMD_GETTOP "SELECT steamid, name, credits, infections, kills, knifekills, escapes, deaths, time_played FROM playerstats ORDER BY score DESC LIMIT %i OFFSET %i"

/*
 * Get player rank
 * param1: score
 */
#define CMD_GETRANK "SELECT DISTINCT score FROM playerstats WHERE score >= %i ORDER BY score ASC;"


#define AUTH_LENGTH 128

#define KILL_SCORE 1
#define INFECTION_SCORE 1
#define KNIFE_SCORE 1
#define ESCAPE_SCORE 1
#define TIME_SCORE 1