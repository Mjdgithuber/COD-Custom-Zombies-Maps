#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility; 

main()
{
	thread sealDoors();
}

cancelSealing( trig, masterTrig )
{
	trig waittill("trigger");
	masterTrig delete();
}

sealWallOne()
{
	wall_one = getEnt("seal_wall_one", "targetname");
	wall_one MoveZ(136,2);
}

sealWallTwo()
{
	wall_two = getEnt("seal_wall_two", "targetname");
	wall_two MoveZ(120,2);
}

revealShotgun()
{
	shotgun_trig = 0;
	shotgun_model = 0;
	shotgun_chalk = 0;
	
	weap_trigs = getEntArray("weapon_upgrade", "targetname");
	for( i = 0; i < weap_trigs.size; i++ )
	{
		if(isDefined(weap_trigs[i].script_string))
		{
			if(weap_trigs[i].script_string == "double_shotgun_trig")
			{
				shotgun_trig = weap_trigs[i];
				break;
			}
		}

	}
	
	weap_models = getEntArray("shotgun", "targetname");
	for( i = 0; i < weap_models.size; i++ )
	{
		if(isDefined(weap_models[i].name))
		{
			if(weap_models[i].name == "double_shotgun_model")
			{
				shotgun_model = weap_models[i];
				break;
			}
		}
	}
	
	weap_chalks = getEntArray("shotgun_chalk", "targetname");
	for( i = 0; i < weap_chalks.size; i++ )
	{
		if(isDefined(weap_chalks[i].name))
		{
			if(weap_chalks[i].name == "double_shotgun_chalk")
			{
				shotgun_chalk = weap_chalks[i];
				break;
			}
		}
	}
	
	shotgun_trig.origin += ( 0, 0, 88 );
	shotgun_model MoveZ(88, .001);
	shotgun_chalk MoveZ(88, .001);
}

init_walls()
{
	wall_one = getEnt("seal_wall_one", "targetname");
	wall_one MoveZ(-136,.001);
	wall_one ConnectPaths();
	wall_two = getEnt("seal_wall_two", "targetname");
	wall_two MoveZ(-120,.001);
	wall_two ConnectPaths();
}

sealDoors()
{
	thread init_walls();
	flag_wait("all_players_connected");
	exits = getEntArray("zombie_debris", "targetname");
	exits_2 = getEntArray("rotating_door", "targetname");
	done = false;
	
	for( i = 0; i < exits.size; i++ )
	{
		if(isDefined(exits[i].name))
		{
			if(exits[i].name == "door_one")
			{
				leave_door_one = exits[i];
				
				for( j = 0; j < exits_2.size; j++ )
				{
					if(isDefined(exits_2[j].name)){
						if(exits_2[j].name == "door_two")
						{
							leave_door_two = exits_2[j];
							
							seal_trigger = getEnt("seal_trigger", "targetname");
							seal_trigger setCursorHint("HINT_NOICON");
							seal_trigger UseTriggerRequireLookAt();
							seal_trigger SetHintString("Press &&1 to activate the first room challenge");
							
							thread cancelSealing( leave_door_one, seal_trigger );
							thread cancelSealing( leave_door_two, seal_trigger );
			
							seal_trigger waittill("trigger");
							{
								leave_door_one delete();
								leave_door_two delete();
								seal_trigger delete();
								
								thread sealWallOne();
								thread sealWallTwo();
								thread revealShotgun();
								level notify( "Pack_A_Punch_on" );

								iprintln("First Room Challenge Started");
								wait 1;
								done = true;
								break;
							}
						}
					}
				}
			}
			if(done)
			{
				break;
			}
		}
	}
}