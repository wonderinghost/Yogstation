//Command

/obj/item/circuitboard/computer/aiupload
	name = "AI Upload (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/upload/ai

/obj/item/circuitboard/computer/borgupload
	name = "Cyborg Upload (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/upload/borg

/obj/item/circuitboard/computer/bsa_control
	name = "Bluespace Artillery Controls (Computer Board)"
	build_path = /obj/machinery/computer/bsa_control

/obj/item/circuitboard/computer/card
	name = "ID Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/card

/obj/item/circuitboard/computer/card/centcom
	name = "CentCom ID Console (Computer Board)"
	build_path = /obj/machinery/computer/card/centcom

/obj/item/circuitboard/computer/card/minor
	name = "Department Management Console (Computer Board)"
	build_path = /obj/machinery/computer/card/minor
	var/target_dept = 1
	var/list/dept_list = list("General","Security","Medical","Science","Engineering")

/obj/item/circuitboard/computer/card/minor/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		target_dept = (target_dept == dept_list.len) ? 1 : (target_dept + 1)
		to_chat(user, span_notice("You set the board to \"[dept_list[target_dept]]\"."))
	else
		return ..()

/obj/item/circuitboard/computer/card/minor/examine(user)
	. = ..()
	. += "Currently set to \"[dept_list[target_dept]]\"."

/obj/item/circuitboard/computer/ai_ship
	name = "AI Ship Shuttle (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/shuttle/ai_ship


//obj/item/circuitboard/computer/shield
//	name = "Shield Control (Computer Board)"
//	greyscale_colors = CIRCUIT_COLOR_COMMAND
//	build_path = /obj/machinery/computer/stationshield

//Engineering

/obj/item/circuitboard/computer/apc_control
	name = "\improper Power Flow Control Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/apc_control

/obj/item/circuitboard/computer/atmos_alert
	name = "Atmospheric Alert (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/atmos_alert

/obj/item/circuitboard/computer/atmos_control
	name = "Atmospheric Monitor (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/atmos_control

/obj/item/circuitboard/computer/atmos_control/tank
	name = "Tank Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank

/obj/item/circuitboard/computer/atmos_control/tank/oxygen_tank
	name = "Oxygen Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/oxygen_tank

/obj/item/circuitboard/computer/atmos_control/tank/toxin_tank
	name = "Plasma Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/toxin_tank

/obj/item/circuitboard/computer/atmos_control/tank/air_tank
	name = "Mixed Air Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/air_tank

/obj/item/circuitboard/computer/atmos_control/tank/mix_tank
	name = "Gas Mix Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/mix_tank

/obj/item/circuitboard/computer/atmos_control/tank/nitrous_tank
	name = "Nitrous Oxide Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/nitrous_tank

/obj/item/circuitboard/computer/atmos_control/tank/nitrogen_tank
	name = "Nitrogen Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/nitrogen_tank

/obj/item/circuitboard/computer/atmos_control/tank/carbon_tank
	name = "Carbon Dioxide Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/carbon_tank

/obj/item/circuitboard/computer/atmos_control/tank/incinerator
	name = "Incinerator Air Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/incinerator

/obj/item/circuitboard/computer/auxiliary_base
	name = "Auxiliary Base Management Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/auxiliary_base

/obj/item/circuitboard/computer/base_construction
	name = "circuit board (Aux Mining Base Construction Console)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/camera_advanced/base_construction

/obj/item/circuitboard/computer/comm_monitor
	name = "Telecommunications Monitor (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/telecomms/monitor

/obj/item/circuitboard/computer/comm_server
	name = "Telecommunications Server Monitor (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/telecomms/server

/obj/item/circuitboard/computer/communications
	name = "Communications (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/communications

/obj/item/circuitboard/computer/message_monitor
	name = "Message Monitor (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/message_monitor

/obj/item/circuitboard/computer/powermonitor
	name = "Power Monitor (Computer Board)"  //name fixed 250810
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/monitor

/obj/item/circuitboard/computer/powermonitor/secret
	name = "Outdated Power Monitor (Computer Board)" //Variant used on ruins to prevent them from showing up on PDA's.
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/monitor/secret

/obj/item/circuitboard/computer/sat_control
	name = "Satellite Network Control (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/sat_control

/obj/item/circuitboard/computer/solar_control
	name = "Solar Control (Computer Board)"  //name fixed 250810
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/solar_control

/obj/item/circuitboard/computer/stationalert
	name = "Station Alerts (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/station_alert

/obj/item/circuitboard/computer/teleporter
	name = "Teleporter (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/teleporter

/obj/item/circuitboard/computer/turbine_computer
	name = "Turbine Computer (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/turbine_computer

/obj/item/circuitboard/computer/turbine_control
	name = "Turbine control (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/turbine_computer

//Generic

/obj/item/circuitboard/computer/arcade/amputation
	name = "Mediborg's Amputation Adventure (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/computer/arcade/amputation

/obj/item/circuitboard/computer/arcade/battle
	name = "Arcade Battle (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/computer/arcade/battle

/obj/item/circuitboard/computer/arcade/orion_trail
	name = "Orion Trail (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/computer/arcade/orion_trail

/obj/item/circuitboard/computer/holodeck// Not going to let people get this, but it's just here for future
	name = "Holodeck Control (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/computer/holodeck

/obj/item/circuitboard/computer/libraryconsole
	name = "Library Visitor Console (Computer Board)"
	build_path = /obj/machinery/computer/libraryconsole

/obj/item/circuitboard/computer/libraryconsole/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(build_path == /obj/machinery/computer/libraryconsole/bookmanagement)
			name = "Library Visitor Console (Computer Board)"
			build_path = /obj/machinery/computer/libraryconsole
			to_chat(user, span_notice("Defaulting access protocols."))
		else
			name = "Book Inventory Management Console (Computer Board)"
			build_path = /obj/machinery/computer/libraryconsole/bookmanagement
			to_chat(user, span_notice("Access protocols successfully updated."))
	else
		return ..()

/obj/item/circuitboard/computer/monastery_shuttle
	name = "Monastery Shuttle (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/computer/shuttle/monastery_shuttle

/obj/item/circuitboard/computer/olddoor
	name = "DoorMex (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/computer/pod/old

/obj/item/circuitboard/computer/pod
	name = "Massdriver control (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/computer/pod

/obj/item/circuitboard/computer/slot_machine
	name = "Slot Machine (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/computer/slot_machine

/obj/item/circuitboard/computer/swfdoor
	name = "Magix (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/computer/pod/old/swf

/obj/item/circuitboard/computer/syndicate_shuttle
	name = "Syndicate Shuttle (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/computer/shuttle/syndicate
	var/challenge = FALSE
	var/moved = FALSE

/obj/item/circuitboard/computer/syndicate_shuttle/Initialize(mapload)
	. = ..()
	GLOB.syndicate_shuttle_boards += src

/obj/item/circuitboard/computer/syndicate_shuttle/Destroy()
	GLOB.syndicate_shuttle_boards -= src
	return ..()

/obj/item/circuitboard/computer/syndicatedoor
	name = "ProComp Executive (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/computer/pod/old/syndicate

/obj/item/circuitboard/computer/white_ship
	name = "White Ship (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/computer/shuttle/white_ship

/obj/item/circuitboard/computer/white_ship/pod
	name = "Salvage Pod (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/white_ship/pod

/obj/item/circuitboard/computer/white_ship/pod/recall
	name = "Salvage Pod Recall (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/white_ship/pod/recall

//Medical

/obj/item/circuitboard/computer/cloning
	name = "Cloning (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/cloning

/obj/item/circuitboard/computer/crew
	name = "Crew Monitoring Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/crew

/obj/item/circuitboard/computer/med_data
	name = "Medical Records Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/med_data

/obj/item/circuitboard/computer/operating
	name = "Operating Computer (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/operating

/obj/item/circuitboard/computer/pandemic
	name = "PanD.E.M.I.C. 2200 (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/pandemic

/obj/item/circuitboard/computer/prototype_cloning
	name = "Prototype Cloning (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/prototype_cloning

/obj/item/circuitboard/computer/scan_consolenew
	name = "DNA Machine (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/scan_consolenew

//Science

/obj/item/circuitboard/computer/aifixer
	name = "AI Integrity Restorer (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/aifixer

/obj/item/circuitboard/computer/launchpad_console
	name = "Launchpad Control Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/launchpad

/obj/item/circuitboard/computer/mech_bay_power_console
	name = "Mech Bay Power Control Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/mech_bay_power_console

/obj/item/circuitboard/computer/mecha_control
	name = "Exosuit Control Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/mecha

/obj/item/circuitboard/computer/nanite_chamber_control
	name = "Nanite Chamber Control (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/nanite_chamber_control

/obj/item/circuitboard/computer/nanite_cloud_controller
	name = "Nanite Cloud Control (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/nanite_cloud_controller

/obj/item/circuitboard/computer/rdconsole
	name = "R&D Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/rdconsole/core
	var/unlocked = FALSE

/obj/item/circuitboard/computer/rdconsole/ruin
	name = "Experimental R&D Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/rdconsole/nolock/ruin

/obj/item/circuitboard/computer/rdconsole/production
	name = "R&D Console Production Only (Computer Board)"
	build_path = /obj/machinery/computer/rdconsole/production
	
/obj/item/circuitboard/computer/rdconsole/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	user.visible_message(span_notice("[user] fiddles with [src]."), span_notice( "You fiddle with [src]."))
	if(I.use_tool(src, user, 2 SECONDS, volume = 75))
		if(build_path == /obj/item/circuitboard/computer/rdconsole/production)
			to_chat(user, span_danger("[src] sparks! That isn't right."))
			var/datum/effect_system/spark_spread/p = new /datum/effect_system/spark_spread
			p.set_up(6, 1, user)
			p.start()
		if(build_path == /obj/machinery/computer/rdconsole/core)
			name = "R&D Console - Robotics (Computer Board)"
			build_path = /obj/machinery/computer/rdconsole/robotics
			to_chat(user, span_notice("Access protocols successfully updated."))
		else
			name = "R&D Console (Computer Board)"
			build_path = /obj/machinery/computer/rdconsole/core
			to_chat(user, span_notice("Defaulting access protocols."))

/obj/item/circuitboard/computer/rdconsole/screwdriver_act(mob/living/user, obj/item/I)
	if(build_path == /obj/machinery/computer/rdconsole/production)
		to_chat(user, span_danger("[src] sparks! That isn't right."))
		var/datum/effect_system/spark_spread/p = new /datum/effect_system/spark_spread
		p.set_up(6, 1, user)
		p.start()
		return TRUE
	if(unlocked)
		to_chat(user, span_notice("It seems to have a deep groove cutting some traces. Maybe welding it will help?"))
		return TRUE
	if(I.use_tool(src, user, 2 SECONDS, volume = 75))
		unlocked = TRUE
		to_chat(user, span_notice("You scrape a deep groove into some of the traces, severing them."))


/obj/item/circuitboard/computer/rdconsole/welder_act(mob/living/user, obj/item/I)
	if(build_path == /obj/machinery/computer/rdconsole/production)
		return
	if(!unlocked)
		return TRUE
	if(!I.tool_start_check(user, amount=0))
		return TRUE
	if(I.use_tool(src, user, 2 SECONDS, volume = 75))
		unlocked = FALSE
		to_chat(user, span_notice("You melt the solder back into place, restoring the connections in the traces."))	
	

/obj/item/circuitboard/computer/rdservercontrol
	name = "R&D Server Control (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/rdservercontrol

/obj/item/circuitboard/computer/research
	name = "Research Monitor (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/security/research

/obj/item/circuitboard/computer/robotics
	name = "Robotics Control (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/robotics

/obj/item/circuitboard/computer/xenobiology
	name = "Xenobiology Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/camera_advanced/xenobio

/obj/item/circuitboard/computer/xenobiology/syndicateicemoon
	name = "Syndicate Xenobiology Console (Computer Board)"
	build_path = /obj/machinery/computer/camera_advanced/xenobio/syndicateicemoon
	
/obj/item/circuitboard/computer/shuttle/flight_control
	name = "Shuttle Flight Control (Computer Board)"
	build_path = /obj/machinery/computer/custom_shuttle

/obj/item/circuitboard/computer/shuttle/docker
	name = "Shuttle Navigation Computer (Computer Board)"
	build_path = /obj/machinery/computer/camera_advanced/shuttle_docker/custom


/obj/item/circuitboard/computer/ai_server_overview
	name = "AI Server Overview Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/ai_server_console


//Security

/obj/item/circuitboard/computer/labor_shuttle
	name = "Labor Shuttle (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/shuttle/labor

/obj/item/circuitboard/computer/labor_shuttle/one_way
	name = "Prisoner Shuttle Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/shuttle/labor/one_way

/obj/item/circuitboard/computer/gulag_teleporter_console
	name = "Labor Camp teleporter console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/gulag_teleporter_computer

/obj/item/circuitboard/computer/prisoner
	name = "Prisoner Management Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/prisoner

/obj/item/circuitboard/computer/secure_data
	name = "Security Records Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/secure_data

/obj/item/circuitboard/computer/warrant
	name = "Security Warrant Viewer (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/warrant

/obj/item/circuitboard/computer/security
	name = "Security Cameras (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/security

/obj/item/circuitboard/computer/security/labor
	name = "Labor Security Cameras (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/security/labor

/obj/item/circuitboard/computer/security/hos
	name = "HOS Security Cameras (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/security/hos

/obj/item/circuitboard/computer/security/qm
	name = "QM Security Cameras (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/security/qm

//Service

//Supply

/obj/item/circuitboard/computer/bounty
	name = "Nanotrasen Bounty Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/bounty

/obj/item/circuitboard/computer/cargo
	name = "Supply Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/cargo
	var/contraband = FALSE

/obj/item/circuitboard/computer/cargo/multitool_act(mob/living/user)
	if(!(obj_flags & EMAGGED))
		contraband = !contraband
		to_chat(user, span_notice("Receiver spectrum set to [contraband ? "Broad" : "Standard"]."))
	else
		to_chat(user, span_notice("The spectrum chip is unresponsive."))

/obj/item/circuitboard/computer/cargo/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	contraband = TRUE
	obj_flags |= EMAGGED
	to_chat(user, span_notice("You adjust [src]'s routing and receiver spectrum, unlocking special supplies and contraband."))
	return TRUE
	
/obj/item/circuitboard/computer/cargo/express
	name = "Express Supply Console (Computer Board)"
	build_path = /obj/machinery/computer/cargo/express

/obj/item/circuitboard/computer/cargo/express/multitool_act(mob/living/user)
	if (!(obj_flags & EMAGGED))
		to_chat(user, span_notice("Routing protocols are already set to: \"factory defaults\"."))
	else
		to_chat(user, span_notice("You reset the routing protocols to: \"factory defaults\"."))
		obj_flags &= ~EMAGGED

/obj/item/circuitboard/computer/cargo/express/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	to_chat(user, span_notice("You change the routing protocols, allowing the Drop Pod to land anywhere on the station."))
	return TRUE

/obj/item/circuitboard/computer/cargo/request
	name = "Supply Request Console (Computer Board)"
	build_path = /obj/machinery/computer/cargo/request

/obj/item/circuitboard/computer/ferry
	name = "Transport Ferry (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/shuttle/ferry

/obj/item/circuitboard/computer/ferry/request
	name = "Transport Ferry Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/shuttle/ferry/request

/obj/item/circuitboard/computer/mining
	name = "Outpost Status Display (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/security/mining

/obj/item/circuitboard/computer/mining_shuttle
	name = "Mining Shuttle (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/shuttle/mining


//Miscellaneous/ruin exclusive

/obj/item/circuitboard/computer/terminal
	name = "Data Terminal (Computer Board)"
	build_path = /obj/machinery/computer/terminal
