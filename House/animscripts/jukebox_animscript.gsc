#include maps\_utility;
#include maps\_zombiemode_utility; 
#include common_scripts\utility; 
#include animscripts\Utility;

#using_animtree ("_jukebox");

main()
{
	self UseAnimTree( "_jukebox" );
	while(1)
	{
		self clearanim(%root, 0.1);
		self SetAnim(%jukebox_anim);
		wait(3);
		dev_print("jukebox anim reset");
		self DumpAnims();
	}

}