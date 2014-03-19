##

##########################################################################
# Rotating VS knob
var adjust_vs_factor = func {
if (getprop("/autopilot/internal/VNAV-VS") == 1) {
	var vs_knob = getprop("/autopilot/settings/vertical-speed-knob");
	vs = vs_knob * 50;

	if (vs_knob >  20) vs = vs + (vs_knob - 20) * 50;
	if (vs_knob < -20) vs = vs + (vs_knob + 20) * 50;

	setprop ("/autopilot/settings/vertical-speed-fpm", vs);
}
if (getprop("/autopilot/internal/VNAV-VS-ARMED")) {
	setprop("/autopilot/internal/VNAV-VS-ARMED", 0);
	setprop("/autopilot/internal/VNAV-ALT", 0);
	setprop("/autopilot/display/pitch-armed-mode", "");
	settimer(func {setprop("/autopilot/switches/VS-button", 1);}, 0.05);
}
}

setprop("/autopilot/internal/VNAV-VS", 1);
adjust_vs_factor(); # first run to create properties
setprop("/autopilot/internal/VNAV-VS", 0);
setlistener( "/autopilot/settings/vertical-speed-knob", adjust_vs_factor, 0, 0);

##########################################################################
# VS button
var vs_button_press = func {
if (getprop("/autopilot/switches/VS-button") == 1) {
	setprop("/autopilot/switches/VS-button", 0);
	setprop("/autopilot/internal/VNAV-VS-ARMED", 0);
	setprop("/autopilot/internal/VNAV-ALT", 0);
	setprop("/autopilot/internal/VNAV-ALT-ACQ", 0);
	setprop("/autopilot/internal/LVLCHG", 0);

	var vs_fpm_current = getprop("/velocities/vertical-speed-fps") * 60;

	if (vs_fpm_current < 1000 and vs_fpm_current > -1000) {
		round_value = 50;
	} else {
		round_value = 100;
	}
	vs_fpm_current = math.round(vs_fpm_current, round_value);

	if (vs_fpm_current < -7900) vs_fpm_current = -7900;
	if (vs_fpm_current > 6000) vs_fpm_current = 6000;

	vs_knob = vs_fpm_current / 50;
	if (vs_fpm_current >  1000) vs_knob = vs_knob - (vs_fpm_current - 1000) / 100;
	if (vs_fpm_current < -1000) vs_knob = vs_knob - (vs_fpm_current + 1000) / 100;
	setprop("/autopilot/internal/VNAV-VS", 1);

	setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/pitch-mode", "V/S");

	speed_engage();

	setprop("/autopilot/settings/vertical-speed-knob", vs_knob);
}
}
setlistener( "/autopilot/switches/VS-button", vs_button_press, 0, 0);

##########################################################################
# MCP ALT change while in ALT ACQ
var mcp_alt_change = func {
	mcp_alt = getprop("/autopilot/settings/target-altitude-ft");
	diff_acq = math.abs(getprop("/autopilot/settings/alt-acq-target-alt") - mcp_alt);
	diff_hld = math.abs(getprop("/instrumentation/altimeter/indicated-altitude-ft") - mcp_alt);

	if (getprop("/autopilot/internal/VNAV-ALT-ACQ") and diff_acq > 100) {
		setprop("/autopilot/switches/VS-button", 1);
	}
	if (getprop("/autopilot/internal/VNAV-ALT") and diff_hld > 100) {
		setprop("/autopilot/internal/VNAV-VS-ARMED", 1);
		setprop("/autopilot/display/pitch-armed-mode", "V/S");
	}
}
setlistener( "/autopilot/settings/target-altitude-ft", mcp_alt_change, 0, 0);

##########################################################################
# LVL CHG button
var lvlchg_button_press = func {
if (getprop("/autopilot/switches/LVLCHG-button") == 1) {
	setprop("/autopilot/switches/LVLCHG-button", 0);
	setprop("/autopilot/internal/VNAV-ALT", 0);
	setprop("/autopilot/internal/VNAV-GS", 0);
	setprop("/autopilot/internal/VNAV-VS", 0);
	setprop("/autopilot/internal/VNAV-VS-ARMED", 0);

	if (getprop("/autopilot/internal/LVLCHG") == 1) {
		setprop("/autopilot/internal/LVLCHG", 0);

	} else {
		setprop("/autopilot/internal/SPD-SPEED", 0);
		setprop("/autopilot/internal/LVLCHG", 1);

		setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/pitch-mode", "MCP SPD");

		alt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		alt_target = getprop("/autopilot/settings/target-altitude-ft");
		if (alt < alt_target) {
			setprop("/controls/engines/engine[0]/throttle", 0.9); ## REPLACE IT WITH N1 MODE ENGAGE!!!
			setprop("/controls/engines/engine[1]/throttle", 0.9); ## REPLACE IT WITH N1 MODE ENGAGE!!!
			setprop("/autopilot/settings/min-lvlchg-vs", 0);
			setprop("/autopilot/settings/max-lvlchg-vs", 6000);
		} else {
			setprop("/controls/engines/engine[0]/throttle", 0); ## REPLACE IT WITH RETARD MODE ENGAGE!!!
			setprop("/controls/engines/engine[1]/throttle", 0); ## REPLACE IT WITH RETARD MODE ENGAGE!!!
			setprop("/autopilot/settings/min-lvlchg-vs", -7800);
			setprop("/autopilot/settings/max-lvlchg-vs", 0);
		}
	}
	

}
}
setlistener( "/autopilot/switches/LVLCHG-button", lvlchg_button_press, 0, 0);

##########################################################################
# Changeover button
var changeover_button_press = func {
if (getprop("/autopilot/switches/CO-button") == 1) {
	setprop("/autopilot/switches/CO-button", 0);

}
}
setlistener( "/autopilot/switches/CO-button", changeover_button_press, 0, 0);

##########################################################################
# N1 button
var n1_button_press = func {
if (getprop("/autopilot/switches/N1-button") == 1) {
	setprop("/autopilot/switches/N1-button", 0);

}
}
setlistener( "/autopilot/switches/N1-button", n1_button_press, 0, 0);

##########################################################################
# SPEED button
var speed_button_press = func {
if (getprop("/autopilot/switches/SPEED-button") == 1) {
	setprop("/autopilot/switches/SPEED-button", 0);

	speed_engage();
}
}
setlistener( "/autopilot/switches/SPEED-button", speed_button_press, 0, 0);

##########################################################################
# VNAV button
var vnav_button_press = func {
if (getprop("/autopilot/switches/VNAV-button") == 1) {
	setprop("/autopilot/switches/VNAV-button", 0);

}
}
setlistener( "/autopilot/switches/VNAV-button", vnav_button_press, 0, 0);

##########################################################################
# ALT HOLD button
var althld_button_press = func {
if (getprop("/autopilot/switches/ALTHLD-button") == 1) {
	setprop("/autopilot/switches/ALTHLD-button", 0);
	GS = getprop("/autopilot/internal/VNAV-GS");

	if (!GS) {
		setprop("/autopilot/internal/max-vs-fpm", 2000);
		setprop("/autopilot/internal/min-vs-fpm", -2000);

		alt_hold_engage();
	}
}
}
setlistener( "/autopilot/switches/ALTHLD-button", althld_button_press, 0, 0);

##########################################################################
# ALT HOLD button light switch
var alt_hold_light = func {
	mcp_alt = getprop("/autopilot/settings/target-altitude-ft");
	diff_hld = math.abs(getprop("/instrumentation/altimeter/indicated-altitude-ft") - mcp_alt);
	alt_hld = getprop("/autopilot/internal/VNAV-ALT");

	if (alt_hld and diff_hld > 50) {
		setprop("/autopilot/internal/VNAV-ALT-light", 1);
	} else {
		setprop("/autopilot/internal/VNAV-ALT-light", 0);
	}

	if (alt_hld) settimer(alt_hold_light,0.5);
}
setlistener( "/autopilot/internal/VNAV-ALT", alt_hold_light, 0, 0);

##########################################################################
# APP button
var app_button_press = func {
if (getprop("/autopilot/switches/APP-button") == 1) {
	setprop("/autopilot/switches/APP-button", 0);

	GS  = getprop("/autopilot/internal/VNAV-GS");
	LOC = getprop("/autopilot/internal/LNAV-NAV");
	if (!GS) {
		setprop("/autopilot/internal/VNAV-GS-armed", 1);
		setprop("/autopilot/display/pitch-mode-armed", "GS");
		if (!LOC) {
			setprop("/autopilot/internal/LNAV-NAV-armed", 1);
			setprop("/autopilot/display/roll-mode-armed", "VOR/LOC");
		}
	}
}
}
setlistener( "/autopilot/switches/APP-button", app_button_press, 0, 0);

##########################################################################
# LNAV button
var lnav_button_press = func {
if (getprop("/autopilot/switches/LNAV-button") == 1) {
	setprop("/autopilot/switches/LNAV-button", 0);

}
}
setlistener( "/autopilot/switches/LNAV-button", lnav_button_press, 0, 0);

##########################################################################
# HDG button
var hdg_button_press = func {
if (getprop("/autopilot/switches/HDG-button") == 1) {
	setprop("/autopilot/switches/HDG-button", 0);

	GS  = getprop("/autopilot/internal/VNAV-GS");
	if (!GS) {
		hdg_mode_engage();
	}
}
}
setlistener( "/autopilot/switches/HDG-button", hdg_button_press, 0, 0);

##########################################################################
# VORLOC button
var vorloc_button_press = func {
if (getprop("/autopilot/switches/VORLOC-button") == 1) {
	setprop("/autopilot/switches/VORLOC-button", 0);

	GS  = getprop("/autopilot/internal/VNAV-GS");
	if (!GS) {
		setprop("/autopilot/internal/LNAV-NAV-armed", 1);
		setprop("/autopilot/display/roll-mode-armed", "VOR/LOC");
	}
}
}
setlistener( "/autopilot/switches/VORLOC-button", vorloc_button_press, 0, 0);

##########################################################################
# CMDA button
var cmda_button_press = func {
if (getprop("/autopilot/switches/CMDA-button") == 1) {
	setprop("/autopilot/switches/CMDA-button", 0);

	ailerons = getprop("/controls/flight/aileron");
	elevator = getprop("/controls/flight/elevator");
	if (ailerons < 0.15 and ailerons > -0.15 and elevator < 0.15 and elevator > -0.15) {
		setprop("/autopilot/internal/CMDA", 1);
		setprop("/autopilot/internal/CMDB", 0);
	}
}
}
setlistener( "/autopilot/switches/CMDA-button", cmda_button_press, 0, 0);

##########################################################################
# CMDB button
var cmdb_button_press = func {
if (getprop("/autopilot/switches/CMDB-button") == 1) {
	setprop("/autopilot/switches/CMDB-button", 0);

	ailerons = getprop("/controls/flight/aileron");
	elevator = getprop("/controls/flight/elevator");
	if (ailerons < 0.15 and ailerons > -0.15 and elevator < 0.15 and elevator > -0.15) {
		setprop("/autopilot/internal/CMDA", 0);
		setprop("/autopilot/internal/CMDB", 1);
	}
}
}
setlistener( "/autopilot/switches/CMDB-button", cmdb_button_press, 0, 0);

##########################################################################
# CWSA button
var cwsa_button_press = func {
if (getprop("/autopilot/switches/CWSA-button") == 1) {
	setprop("/autopilot/switches/CWSA-button", 0);

}
}
setlistener( "/autopilot/switches/CWSA-button", cwsa_button_press, 0, 0);

##########################################################################
# CWSB button
var cwsb_button_press = func {
if (getprop("/autopilot/switches/CWSB-button") == 1) {
	setprop("/autopilot/switches/CWSB-button", 0);

}
}
setlistener( "/autopilot/switches/CWSB-button", cwsb_button_press, 0, 0);

##########################################################################
# APDSNG button
var apdsng_button_press = func {
if (getprop("/autopilot/switches/APDSNG-button") == 1) {
	setprop("/autopilot/switches/APDSNG-button", 0);

}
}
setlistener( "/autopilot/switches/APDSNG-button", apdsng_button_press, 0, 0);

##########################################################################
##########################################################################
# Engaging ALT ACQ mode
var alt_acq_engage = func {
	if (getprop("/autopilot/internal/VNAV-VS") or getprop("/autopilot/internal/LVLCHG") or getprop("/autopilot/internal/VNAV")) {
		alt_diff = getprop("/b733/helpers/alt-diff-ft");
		current_vs = getprop("/autopilot/settings/vertical-speed-fpm");
		possible_engage_alt =  math.abs(current_vs * 0.15);


		if (alt_diff < 300 or alt_diff < possible_engage_alt) {
			setprop("/autopilot/internal/VNAV-VS", 0);
			setprop("/autopilot/internal/LVLCHG", 0);

			setprop("/autopilot/internal/VNAV-ALT-ACQ", 1);
			setprop("/autopilot/settings/alt-acq-target-alt", getprop("/autopilot/settings/target-altitude-ft"));

			setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
			setprop("/autopilot/display/pitch-mode", "ALT ACQ");

			speed_engage();
			if (current_vs > 0) {
				setprop("/autopilot/internal/max-vs-fpm", current_vs);
				setprop("/autopilot/internal/min-vs-fpm", -300);
			} else {
				setprop("/autopilot/internal/max-vs-fpm", 300);
				setprop("/autopilot/internal/min-vs-fpm", current_vs);
			}
		}
	}
	if (getprop("/autopilot/internal/VNAV-ALT-ACQ")) {
		if (getprop("/b733/helpers/alt-diff-ft") < 5) {
			alt_hold_engage();
		}
	}
}
setlistener( "/b733/helpers/alt-diff-ft", alt_acq_engage, 0, 0);

##########################################################################
# Engaging ALT HOLD mode
var alt_hold_engage = func {
	alt_current = getprop("/instrumentation/altimeter/pressure-alt-ft");
	setprop("/autopilot/internal/VNAV-ALT-ACQ", 0);
	setprop("/autopilot/internal/VNAV-VS", 0);
	setprop("/autopilot/internal/VNAV", 0);
	setprop("/autopilot/internal/LVLCHG", 0);
	setprop("/autopilot/settings/target-alt-hold-ft", alt_current);
	setprop("/autopilot/internal/VNAV-ALT", 1);

	setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/pitch-mode", "ALT HOLD");

	speed_engage();
}

##########################################################################
# Engaging SPEED mode
var speed_engage = func {
	setprop("/autopilot/internal/SPD-N1", 0);
	setprop("/autopilot/internal/SPD-SPEED", 1);

	setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/throttle-mode", "MCP SPD");
}

##########################################################################
# Engaging HDG SEL mode
var hdg_mode_engage = func {
	setprop("/autopilot/internal/LNAV", 0);
	setprop("/autopilot/internal/LNAV-NAV", 0);
	setprop("/autopilot/internal/LNAV-HDG", 1);

	setprop("/autopilot/display/roll-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/roll-mode", "HDG SEL");
}

##########################################################################
# Armed VOR/LOC mode behaviour
var vorloc_armed = func {
if (getprop("/autopilot/internal/LNAV-NAV-armed")){
	deflection = getprop("/instrumentation/nav[0]/heading-needle-deflection-norm");
	course = getprop("/instrumentation/nav[0]/radials/target-radial-deg");
	delta_target_heading = getprop("/autopilot/internal/target-heading-shift-nav1");
	delta_current_heading = geo.normdeg180(getprop("/orientation/heading-deg") - course);
	if((deflection < 0.2 and deflection > -0.2) or (deflection < 0.99 and deflection > -0.99 and math.abs(delta_target_heading) < math.abs(delta_current_heading))){
		vorloc_mode_engage();
	}

	settimer(vorloc_armed, 0.5);
}
}

setlistener( "/autopilot/internal/LNAV-NAV-armed", vorloc_armed, 0, 0);

##########################################################################
# Armed GS mode behaviour
var app_armed = func {
if (getprop("/autopilot/internal/VNAV-GS-armed")){
	deflection = getprop("/instrumentation/nav[0]/gs-needle-deflection-norm");
	in_range = getprop("/instrumentation/nav[0]/gs-in-range");
	LOC = getprop("/autopilot/internal/LNAV-NAV");
	if(deflection < 0.2 and deflection > -0.2 and LOC and in_range){
		gs_engage();
	}

	settimer(app_armed, 0.5);
}
}

setlistener( "/autopilot/internal/VNAV-GS-armed", app_armed, 0, 0);

##########################################################################
# Engaging VOR/LOC mode
var vorloc_mode_engage = func {
	setprop("/autopilot/internal/LNAV", 0);
	setprop("/autopilot/internal/LNAV-HDG", 0);
	setprop("/autopilot/internal/LNAV-NAV", 1);

	setprop("/autopilot/display/roll-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/roll-mode", "VOR/LOC");
	setprop("/autopilot/display/roll-mode-armed", "");
	setprop("/autopilot/internal/LNAV-NAV-armed", 0);
}

##########################################################################
# Engaging GLIDESLOPE	 mode
var gs_engage = func {
	setprop("/autopilot/internal/VNAV-ALT-ACQ", 0);
	setprop("/autopilot/internal/VNAV-VS", 0);
	setprop("/autopilot/internal/VNAV", 0);
	setprop("/autopilot/internal/LVLCHG", 0);
	setprop("/autopilot/internal/VNAV-ALT", 0);
	setprop("/autopilot/internal/VNAV-GS", 1);

	setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/pitch-mode", "GS");
	setprop("/autopilot/display/pitch-mode-armed", "");
	setprop("/autopilot/internal/VNAV-GS-armed", 0);

	speed_engage();
}

##########################################################################
##########################################################################
# Rectangles for mode change
var roll_mode_change = func {
	last_change = getprop("/autopilot/display/roll-mode-last-change");
	current_time = getprop("/sim/time/elapsed-sec");
	period = current_time - last_change;

	if (period <= 10) {
		setprop("/autopilot/display/roll-mode-rectangle", 1);
		settimer(roll_mode_change, 0.5);
	} else {
		setprop("/autopilot/display/roll-mode-rectangle", 0);
	}
}
var pitch_mode_change = func {
	last_change = getprop("/autopilot/display/pitch-mode-last-change");
	current_time = getprop("/sim/time/elapsed-sec");
	period = current_time - last_change;

	if (period <= 10) {
		setprop("/autopilot/display/pitch-mode-rectangle", 1);
		settimer(pitch_mode_change, 0.5);
	} else {
		setprop("/autopilot/display/pitch-mode-rectangle", 0);
	}
}
var throttle_mode_change = func {
	last_change = getprop("/autopilot/display/throttle-mode-last-change");
	current_time = getprop("/sim/time/elapsed-sec");
	period = current_time - last_change;

	if (period <= 10) {
		setprop("/autopilot/display/throttle-mode-rectangle", 1);
		settimer(throttle_mode_change, 0.5);
	} else {
		setprop("/autopilot/display/throttle-mode-rectangle", 0);
	}
}
setlistener( "/autopilot/display/roll-mode", roll_mode_change, 0, 0);
setlistener( "/autopilot/display/pitch-mode", pitch_mode_change, 0, 0);
setlistener( "/autopilot/display/throttle-mode", throttle_mode_change, 0, 0);
