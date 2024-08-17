/atom
	/// Last appearance of the atom for demo saving purposes
	var/image/demo_last_appearance

/atom/movable
	/// Last location of the atom for demo recording purposes
	var/atom/demo_last_loc

/*
/mob/Login()
	. = ..()
	SSdemo.write_event_line("setmob [client.ckey] \ref[src]") 
* handled in code\modules\mob.dm 
*/

/client/New()
	SSdemo.write_event_line("login [ckey]")
	. = ..()

/client/Del()
	. = ..()
	SSdemo.write_event_line("logout [ckey]")

/turf/setDir()
	. = ..()
	SSdemo.mark_turf(src)

/atom/movable/setDir(newdir, forced = FALSE)
	. = ..()
	SSdemo.mark_dirty(src)
