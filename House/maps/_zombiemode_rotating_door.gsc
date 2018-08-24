#include maps\_utility; 
#include common_scripts\utility; 
#include maps\_zombiemode_utility;

/*
DuaLVII's Rotating Door Script v1
 - Standard Zombie Cost doors
 - Electric doors
 - Electric doors with zombie cost (players must get the electric on then pay to open it)
 - Runs on script_vector for easier use (x,y,z) = (rotate like normal, like a garage door, like a sliding door but it rolls to the side)
 - Like all other doors, Uses script_flag for zone setting
*/

config()
{
	level.rotating_door_hint = "Press &&1 to open the door"; // Cost area will be added after by the script
	level.rotating_door_electric_hint = "You need to turn the power on";
}

init()
{
	config();
	rotating_doors = GetEntArray("rotating_door", "targetname");
	array_thread(rotating_doors,::rotating_door_init);
}

rotating_door_init()
{
	iTarget = GetEntArray(self.target, "targetname");
	for(i = 0; i < iTarget.size; i++)
	{
		iTarget[i] rotating_door_setup();
	}
	if( isDefined(self.script_flag) && !IsDefined( level.flag[self.script_flag] )) 
	{
		flag_init( self.script_flag ); 
	}
	if(isDefined(self.script_noteworthy) && self.script_noteworthy == "electric_door")
	{
		self setHintString(level.rotating_door_electric_hint);
	}
	else
	{
		self setHintString( level.rotating_door_hint + " [Cost:" + self.zombie_cost + "]" );
	}
	self SetCursorHint( "HINT_NOICON" );
	self thread rotating_door_think();
}

rotating_door_think()
{
	iTarget = GetEntArray(self.target, "targetname");
	while(1)
	{
		if(isDefined(self.script_noteworthy) && self.script_noteworthy == "electric_door" && !isDefined(self.zombie_cost))
		{
			flag_wait( "electricity_on" );
		}
		else
		{
			if(isDefined(self.script_noteworthy) && self.script_noteworthy == "electric_door")
			{
				flag_wait( "electricity_on" );
				self setHintString( level.rotating_door_hint + " [Cost:" + self.zombie_cost + "]" );
			}
			self waittill( "trigger", player);
			if(player in_revive_trigger())
			{
				continue;
			}
			if(is_player_valid(player))
			{
				if(player.score >= (self.zombie_cost - 1)) // -1 to remove the horrible glitch where a player needs 10 points more than the exact total needed
				{
					player maps\_zombiemode_score::minus_to_player_score( self.zombie_cost );
				}
				else
				{
					play_sound_at_pos( "no_purchase", self.origin);
					continue;
				}
			}
		}
		for(i = 0; i < iTarget.size; i++)
		{
			if(isDefined(iTarget[i].script_sound))
			{
				play_sound_at_pos( iTarget[i].script_sound, self.origin );
			}
			else
			{
				play_sound_at_pos( "door_slide_open", self.origin );
			}
			if(!isDefined(iTarget[i].script_transition_time))
			{
				iTarget[i].script_transition_time = 1;
			}
			if(isDefined(iTarget[i].script_vector))
			{
				if(iTarget[i].script_vector[0] != 0) // DuaLVII :: script_vector = an array? huh
				{
					iTarget[i] RotateYaw( iTarget[i].script_vector[0], iTarget[i].script_transition_time, ( iTarget[i].script_transition_time * 0.5 ) );
				}
				if(iTarget[i].script_vector[1] != 0)
				{
					iTarget[i] RotatePitch( iTarget[i].script_vector[1], iTarget[i].script_transition_time, ( iTarget[i].script_transition_time * 0.5 ) );
				}
				if(iTarget[i].script_vector[2] != 0)
				{
					iTarget[i] RotateRoll( iTarget[i].script_vector[2], iTarget[i].script_transition_time, ( iTarget[i].script_transition_time * 0.5 ) );
				}
			}
			iTarget[i] NotSolid();
			array_thread(iTarget,::rotating_door_connect);
		}
		if( IsDefined( self.script_flag ) )
		{
			flag_set( self.script_flag );
		}
		triggers_related = GetEntArray(self.target, "target");
		for(i = 0; i<triggers_related.size; i++)
		{
			triggers_related[i] disable_trigger();
		}
		break;
	}
}

rotating_door_setup()
{
	iTarget = GetEntArray(self.target, "targetname");
	for(i = 0; i < iTarget.size; i++)
	{
		iTarget[i] linkto(self);
		iTarget[i] disconnectpaths();
	}
}

rotating_door_connect()
{
	iTarget = GetEntArray(self.target, "targetname");
	for(i = 0; i < iTarget.size; i++)
	{
		iTarget[i] NotSolid();
		iTarget[i] connectpaths();
	}
}