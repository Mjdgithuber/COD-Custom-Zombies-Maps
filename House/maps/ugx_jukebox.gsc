//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
//|||| Name   : ugx_jukebox.gsc 
//|||| Info   : Script for ugx music player in bar and other maps
//|||| Site   : www.ugx-mods.com
//|||| Author : [UGX] treminaor
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\_anim;
#include maps\_vehicle;

jukebox_settings()
{
	level.jukebox["youtube_safe"] = false; //PLEASE CHANGE THIS TO FALSE IF YOU INCLUDE ANY SONGS WHICH ARE NOT COPYRIGHT FREE! THIS VARIABLE CONTROLS THE VISIBILITY OF THE "YOUTUBE SAFE" TEXT ON THE JUKEBOX MENU!
	level.jukebox["power_needed"] = true; //Does the Jukebox wait until power switch is flipped on map (true), or is it on from game start (false)?
	level.jukebox["cost"] = 250;
	add_song("Acting Up", "acting_up"); add_song("Bit the Beat", "bit_the_beat"); add_song("Bring Me to Life", "bring_me_to_life"); add_song("Destroy It", "destroy_it"); add_song("Martyrs", "martyrs"); add_song("Mexican", "mexican"); add_song("When We Ride", "when_we_ride");
}

add_song(display_name, soundalias_name)
{
	level.jukebox["songs"][display_name]["name"] = soundalias_name;
	level.jukebox["keys"] = getSongKeys();
	players = getPlayers(); for(i=0;i<players.size;i++) players[i] SetClientDvar("ugx_jukebox_s" + (level.jukebox["songs"].size - 1), display_name);
}

#using_animtree ("_jukebox");
jukebox_precache()
{
	precacheMenu("ugx_jukebox");
	precacheModel("jukebox_on");
	PrecacheItem( "jukebox_button_press" );
	level._effect["jukebox_idle"] = loadFX("ugx/jukebox_idle");
	level.scr_anim["jukebox_start"] = %jukebox_start_anim;
	level.scr_anim["jukebox_loop"] = %jukebox_loop_anim;
	level.scr_anim["jukebox_end"] = %jukebox_end_anim;
}

jukebox_init()
{
	players = getPlayers(); for(i=0;i<players.size;i++) for(j=0;j<10;j++) players[i] SetClientDvar("ugx_jukebox_s" + j, " "); //reset the dvars if this is a game restart and any songs were added dynamically
	jukebox_settings();
	players = getPlayers();
	for(i=0;i<players.size;i++)
	{
		if(level.jukebox["youtube_safe"]) players[i] SetClientDvar("ugx_jukebox_youtube", "1");
		else players[i] SetClientDvar("ugx_jukebox_youtube", "0");
	}
	level.jukebox["playing"] = false;
	level.jukebox["keys"] = getSongKeys();
	level.jukebox["trigs"] = getEntArray("jukebox","targetname");
	for(i=0;i<level.jukebox["trigs"].size;i++) level.jukebox["trigs"][i] thread jukebox_main();
}

getSongKeys()
{
	revkeys = getArrayKeys(level.jukebox["songs"]);
	keys = [];
	for(i=0;i<revkeys.size;i++)	keys[i] = revkeys[revkeys.size - (i+1)];
	return keys;
}

jukebox_main()
{
	self.jukebox = getEnt(self.target,"targetname");
	self setHintString("Power must be on.");
	self setCursorHint("HINT_NOICON");
	if(level.jukebox["power_needed"]) flag_wait( "electricity_on" );
	self.jukebox setModel("jukebox_on");
	self setHintString("Press &&1 to use the Jukebox [Cost: "+level.jukebox["cost"]+"]");
	self.jukebox thread create_jukebox_fx("jukebox_idle");
	while(1)
	{
		self waittill("trigger",player);
		menu = "ugx_jukebox";
		if(level.jukebox["cost"] <= player.score && !level.jukebox["playing"])
		{
			player freezeControls(true);
			player disableWeapons();
			player openMenu(menu);
			player jukebox_menu(menu,self);
		}
		else
			player playsound("no_cha_ching");
		wait 0.5;
	}
}

jukebox_menu(menu, trig)
{
	self waittill("menuresponse", menu, response);
	response = int(response);
	self enableWeapons();
	if(response != 10 && isDefined(level.jukebox["songs"][level.jukebox["keys"][response]]))
	{
		level.jukebox["playing"] = true;
		self thread do_button_press();
		wait 0.7; //syncs the finger press to the anim start
		self freezeControls(false);
		self maps\_zombiemode_score::minus_to_player_score(level.jukebox["cost"]);
		trig.jukebox playanim("jukebox_start");
		for(i=0;i<level.jukebox["trigs"].size;i++) level.jukebox["trigs"][i] setHintString("Currently playing a song.");
		wait 4;
		trig.jukebox playanim("jukebox_loop");
		players = get_players();
		for(i=0;i<players.size;i++)
			players[i] playsound(level.jukebox["songs"][level.jukebox["keys"][response]]["name"]);
		trig.jukebox thread create_jukebox_fx("jukebox_active");
		trig.jukebox playsound(level.jukebox["songs"][level.jukebox["keys"][response]]["name"], "sound_done"); //since using a sound notify on a player is unreliable i use an ent
		trig.jukebox waittill("sound_done");
		trig.jukebox stopAnimScripted();
		trig.jukebox playanim("jukebox_end");
		trig.jukebox thread create_jukebox_fx("jukebox_idle");
		wait 4;
		level.jukebox["playing"] = false;
		for(i=0;i<level.jukebox["trigs"].size;i++) level.jukebox["trigs"][i] setHintString("Press &&1 to use the Jukebox [Cost: "+level.jukebox["cost"]+"]");
	}
	self freezeControls(false);
}

playanim(animname)
{
	 self useanimtree(#animtree);
	 self animscripted("test_anim", self.origin, self.angles, level.scr_anim[animname]);
}

create_jukebox_fx(fx)
{
	fx = "jukebox_idle"; //Decided not to use a color fx for playing.
	if(isDefined(self.fx)) self.fx delete();
	fxtag = "tag_origin";
    self.fx = Spawn( "script_model", self getTagOrigin("tag_fx"));
    self.fx SetModel( "tag_origin" );
    self.fx.angles = self.angles;
    self.fx LinkTo( self, fxTag );
	PlayFXOnTag(level._effect[fx], self.fx, fxTag);
}

do_button_press()
{
	self button_press_begin();
	self.is_drinking = 1; //might as well keep this, means i dont have to add functionality for this anywhere else
	self waittill_any("fake_death", "death", "player_downed", "weapon_change_complete");
	self button_press_end();
	self.is_drinking = undefined;
}

button_press_begin()
{
	self DisableOffhandWeapons();
	self DisableWeaponCycling();
	self AllowLean(false);
	self AllowAds(false);
	self AllowSprint(false);
	self AllowProne(false);		
	self AllowMelee(false);
	if(self GetStance() == "prone") self SetStance("crouch");
	primaries = self GetWeaponsListPrimaries();
	weapon = "jukebox_button_press";
	self maps\_laststand::laststand_take_player_weapons();
	self GiveWeapon(weapon);
	self SwitchToWeapon(weapon);
}

button_press_end(gun)
{
	self EnableOffhandWeapons();
	self EnableWeaponCycling();
	self AllowLean(true);
	self AllowAds(true);
	self AllowSprint(true);
	self AllowProne(true);		
	self AllowMelee(true);
	weapon = "jukebox_button_press";
	if (self maps\_laststand::player_is_in_laststand())
	{
		self TakeWeapon(weapon);
		return;
	}
	self TakeWeapon(weapon);
	self maps\_laststand::laststand_giveback_player_weapons();
}