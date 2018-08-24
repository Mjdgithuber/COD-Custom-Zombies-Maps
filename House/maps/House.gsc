#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility; 
#include maps\_zombiemode_zone_manager; 
#include maps\_music;
#include maps\dlc3_code;
#include maps\dlc3_teleporter;

main()
{

	level.DLC3 = spawnStruct(); // Leave This Line Or Else It Breaks Everything
	
	// Must Change These To Your Maps
	level.DLC3.createArt = maps\createart\House_art::main;
	level.DLC3.createFX = maps\createfx\House_fx::main;
	level.DLC3.myFX = ::preCacheMyFX;
	
	/*--------------------
	 FX
	----------------------*/
	DLC3_FX();
	
	/*--------------------
	 LEVEL VARIABLES
	----------------------*/	
	
	// Variable Containing Helpful Text For Modders -- Don't Remove
	level.modderHelpText = [];
	
	//
	// Change Or Tweak All Of These LEVEL.DLC3 Variables Below For Your Level If You Wish
	//
	
	// Edit The Value In Mod.STR For Your Level Introscreen Place
	level.DLC3.introString = "House";
	
	// Weapons. Pointer function automatically loads weapons used in Der Riese.
	level.DLC3.weapons = maps\dlc3_code::include_weapons;
	
	// Power Ups. Pointer function automatically loads power ups used in Der Riese.
	level.DLC3.powerUps =  maps\dlc3_code::include_powerups;
	
	// Adjusts how much melee damage a player with the perk will do, needs only be set once. Stock is 1000.
	level.DLC3.perk_altMeleeDamage = 1000; 
	
	// Adjusts barrier search override. Stock is 400.
	level.DLC3.barrierSearchOverride = 400;
	
	// Adjusts power up drop max per round. Stock is 3.
	level.DLC3.powerUpDropMax = 3;
	
	// _loadout Variables
	level.DLC3.useCoopHeroes = true;
	
	// Bridge Feature
	level.DLC3.useBridge = false;
	
	// Hell Hounds
	level.DLC3.useHellHounds = true;
	
	// Mixed Rounds
	level.DLC3.useMixedRounds = true;
	
	// Magic Boxes -- The Script_Noteworthy Value Names On Purchase Trigger In Radiant
	boxArray = [];
	boxArray[ boxArray.size ] = "start_chest";
	boxArray[ boxArray.size ] = "chest1";
	boxArray[ boxArray.size ] = "chest2";
	boxArray[ boxArray.size ] = "chest3";
	boxArray[ boxArray.size ] = "chest4";
	boxArray[ boxArray.size ] = "chest5";
	level.DLC3.PandoraBoxes = boxArray;
	
	// Initial Zone(s) -- Zone(s) You Want Activated At Map Start
	zones = [];
	zones[ zones.size ] = "start_zone";
	level.DLC3.initialZones = zones;
	
	// Electricity Switch -- If False Map Will Start With Power On
	level.DLC3.useElectricSwitch = true;
	
	// Electric Traps
	level.DLC3.useElectricTraps = false;
	
	// _zombiemode_weapons Variables
	level.DLC3.usePandoraBoxLight = true;
	level.DLC3.useChestPulls = true;
	level.DLC3.useChestMoves = true;
	level.DLC3.useWeaponSpawn = true;
	level.DLC3.useGiveWeapon = true;
	
	// _zombiemode_spawner Varibles
	level.DLC3.riserZombiesGoToDoorsFirst = true;
	level.DLC3.riserZombiesInActiveZonesOnly = true;
	level.DLC3.assureNodes = true;
	
	// _zombiemode_perks Variables
	level.DLC3.perksNeedPowerOn = true;
	
	// _zombiemode_devgui Variables
	level.DLC3.powerSwitch = true;
	
	// Snow Feature
	level.DLC3.useSnow = false;
	
	/*--------------------
	 FUNCTION CALLS - PRE _Load
	----------------------*/
	level thread DLC3_threadCalls();	
	
	/*--------------------
	 ZOMBIE MODE
	----------------------*/
	[[level.DLC3.weapons]]();
	[[level.DLC3.powerUps]]();
	
	maps\ugx_jukebox::jukebox_precache();

	thread bwVision(); // changes vision to b&w until power turns on
	
	maps\_zombiemode_firstroom_sealer::main(); // inits first room challenge

	maps\ugx_easy_fx::fx_setup();
	
	maps\_zombiemode::main();

	level thread maps\ugx_easy_fx::fx_start();
	
	thread maps\ugx_jukebox::jukebox_init();
	
	maps\_zombiemode_rotating_door::init();

	/*--------------------
	 FUNCTION CALLS - POST _Load
	----------------------*/
	level.zone_manager_init_func = ::dlc3_zone_init;
	level thread DLC3_threadCalls2();
}

dlc3_zone_init()
{
	/*
	=============
	///ScriptDocBegin
	"Name: add_adjacent_zone( <zone_1>, <zone_2>, <flag>, <one_way> )"
	"Summary: Sets up adjacent zones."
	"MandatoryArg: <zone_1>: Name of first Info_Volume"
	"MandatoryArg: <zone_2>: Name of second Info_Volume"
	"MandatoryArg: <flag>: Flag to be set to initiate zones"
	"OptionalArg: <one_way>: Make <zone_1> adjacent to <zone_2>. Defaults to false."
	"Example: add_adjacent_zone( "receiver_zone",		"outside_east_zone",	"enter_outside_east" );"
	///ScriptDocEnd
	=============
	*/

	// Outside East Door
	//add_adjacent_zone( "receiver_zone",		"outside_east_zone",	"enter_outside_east" );
	
	add_adjacent_zone( "start_zone",	"garage_zone",		"enter_garage_zone" );
	add_adjacent_zone( "start_zone",	"weightroom_zone",	"enter_weightroom_zone" );
}

preCacheMyFX()
{
	// LEVEL SPECIFIC - FEEL FREE TO REMOVE/EDIT
	
	// level._effect["snow_thick"]			= LoadFx ( "env/weather/fx_snow_blizzard_intense" );
}

bwVision()
{
	// This method allows for Ascension like vision before power
	flag_wait("all_players_connected");
	set_all_players_visionset( "cheat_bw", 0.1 );
	flag_wait("electricity_on");
	maps\_utility::set_all_players_visionset( "zombie_factory", 0.1 );
}