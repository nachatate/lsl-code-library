﻿
integer sit = FALSE;
integer sitterlinknum = 9;
 
key avatar;

float mass;

float SIT_DROP = 0.05;          //  Looks cool when you jump on
float ROTATION_RATE = 7.0;      //  Rate of turning  
float TIMER_DELAY = 0.1;
float JUMP_FORCE = 75.0;
float JUMP_ROTATE = 50.0;       //  Force to rotate on jump
float JUMP_PITCH = 0.0;         //  Force to pitch nose upward during a jump 
float THRUST_PITCH = 0.0;       //  Force to pitch nose upward on thrusting fwd/back
float LAND_ROTATE = 0.0;       //  Nose tips on landing
float HOVER_HEIGHT = 3;       //  How high to hover while flying
float PRE_JUMP = 0.1;           //  How far to come down when readying for jump 
float MAX_JUMP_TIME = 1.0;      //  Max secs to accumulate energy for jump 
float FWD_THRUST = 50.0;        //  Forward thrust motor force 
float BACK_THRUST = 30.0;       //  Backup thrust
float FOLLOW_SCALE = 20.0;      //  Extra boost to push upward for upcoming hills
float FOLLOW_THRESHOLD = 0.35;  //  Threshold for when to apply extra force 
float AUTO_JUMP_THRESHOLD = 5.0; 
float STUMBLE = -0.0;           //  Z-vel on landing that triggers stumble
 
float TRICK_RATE = 15.0;

vector PUSH_OFF = <0, 2.5, 3>;  //was 0, 25, 75
float MAX_JUMP_DURATION = 15.0;   //  Jumps longer than this will be ended (like if you land on a house!)

vector LINEAR_FRICTION_RIDE = <10.0, 5.0, 1000.0>;      //  Friction while riding
vector LINEAR_FRICTION_BRAKE = <0.5, 0.5, 1000.0>;      //  Friction while braking
 
float jump_timer = 0.0;
float height_agl = 0.0;
float ground_height = 0.0;
float water_height = 0.0;
integer timer_count = 0;
vector pos;
vector vel;
rotation rot;
float vel_mag;
float follow_diff;
float cur_time; 

integer is_jumping = FALSE;
integer left_toggle = FALSE;
integer right_toggle = FALSE; 
integer up_toggle = FALSE;
integer fwd_toggle = FALSE;
integer back_toggle = FALSE;
integer down_toggle = FALSE;

integer over_water = FALSE; 

reset_keys()
{
    up_toggle = FALSE; 
    fwd_toggle = FALSE;
    back_toggle = FALSE;
    left_toggle = FALSE;
    right_toggle = FALSE;
    down_toggle = FALSE;
}

start_jump(float mag)
{
    // 
    //  This function is called to start a jump 
    // 
    vector imp = <0, 0, JUMP_FORCE> * mass * mag; 
    llApplyImpulse(imp, FALSE);
    jump_timer = llGetTime();
    //llApplyRotationalImpulse(<0,-JUMP_ROTATE*mag,0>, TRUE);
    llMessageLinked(LINK_SET, 0, "jump", "");
    //llTriggerSound("jump", 0.25 + mag);
    //llLoopSound("jumping", 0.3);
    llSetVehicleFloatParam(VEHICLE_HOVER_HEIGHT, HOVER_HEIGHT);
    llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <0,0,0>);
//    llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, <0,-JUMP_PITCH,0>);
    is_jumping = TRUE;
}
stop_jump()
{
    is_jumping = FALSE;
       llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, <0.0, 8.0, 7.0> ); // Required for mouselook
    llApplyRotationalImpulse(<0,-LAND_ROTATE*mass,0>, TRUE);
    llMessageLinked(LINK_SET, 0, "landing", "");
    vel = llGetVel();
    llTriggerSound("land", 0.5);
    //llStopSound();
    if (vel.z < STUMBLE)
    {
        //llStartAnimation("hello");
    }
}
trick()
{  
    //llStartAnimation("backflip");
    //llTriggerSound("trick", 0.5);
    //llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, <0,TRICK_RATE,0>);
    //llSleep(1.0);
    //llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, <0,-JUMP_PITCH,0>);
}

default
{
    state_entry()
    {
        
       mass = llGetMass();
       
       llSitTarget(<0.8, 0.0, -0.3>, <0.0, 0.00100, -0.00288, 0.70641>);                //  Set seating location. Change for different height AVs
       llSetVehicleType(VEHICLE_TYPE_SLED);

       
       llRemoveVehicleFlags(-1);
       llSetVehicleFlags(VEHICLE_FLAG_HOVER_UP_ONLY);
       llSetVehicleFlags(VEHICLE_FLAG_NO_FLY_UP);
       llSetVehicleFlags(VEHICLE_FLAG_MOUSELOOK_STEER);
       llSetVehicleFlags(VEHICLE_FLAG_CAMERA_DECOUPLED);
       
       llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, 0.0);
       llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, 0.0);
       llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, 0.0);
       llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_TIMESCALE, 0.0);
       
       llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, 0.0);
       llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE, 0.0);
       llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_TIMESCALE, 0.0);
       llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE, 0.0);
       
        llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, LINEAR_FRICTION_RIDE);
       
//        llSetVehicleVectorParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, <10.0, 100.0, 100.0>);
        llSetVehicleVectorParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, <0, 0, 0>);
       
       llSetVehicleFloatParam(VEHICLE_HOVER_HEIGHT, HOVER_HEIGHT);
       llSetVehicleFloatParam(VEHICLE_HOVER_EFFICIENCY, 0.5);
       llSetVehicleFloatParam(VEHICLE_HOVER_TIMESCALE, 0.1);
       
       llSetVehicleFloatParam(VEHICLE_BUOYANCY, 0.0);    
       llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 0.1);
       llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 1.0);
       
       llSetVehicleFloatParam(VEHICLE_BANKING_EFFICIENCY, 1.0);
       llSetVehicleFloatParam(VEHICLE_BANKING_MIX, 0.75);
       llSetVehicleFloatParam(VEHICLE_BANKING_TIMESCALE, 0.05);
       
       llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, <0.0, 8.0, 7.0> ); // Required for mouselook
       llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_TIMESCALE, 0.0);

       
       
       llSetCameraEyeOffset(<-10.0, 1.0, 3.0>);
       llSetSitText("Ride");
       llSetCameraAtOffset(<0, 1.0, 0>);
       llCollisionSound("", 0.0);
       llSetTimerEvent(TIMER_DELAY);
      
    }
    touch_start(integer num)
    {
        if(llDetectedKey(0) != llGetOwner())
        {
//           llWhisper(0, "*Free* Mini Hoverpod designed by Cubey Terra. To see more hovercraft and aircraft, Visit Abbotts Aerodrome.");
            
        }
        else
        {
            llTriggerSound("hover_whoosh", 1);
//            llWhisper(0, "To ride the *Free* Mini Hoverpod, right-click it and choose 'Ride' from the menu.");
        
        }
    }
    on_rez(integer param)
    {
        // Preload sounds so they are ready for use
        //llTriggerSound("takeout", 1.0);
        llPreloadSound("speeder");
        llPreloadSound("stop");
        llPreloadSound("hover_whoosh");
 //       llPreloadSound("stop");
        llPreloadSound("land");
        llPreloadSound("hover_idle");
    }
    
    changed(integer change)
    {
        avatar = llAvatarOnSitTarget();
       if(change & CHANGED_LINK)
       {
           if(avatar == NULL_KEY)
           {
               //
               //  You have gotten off your bike 
               // 
               llMessageLinked(LINK_SET, 0, "idle", "");
               llStopSound();
               llPlaySound("stop",1);
               llSetStatus(STATUS_PHYSICS, FALSE);
               llReleaseControls();
               //llStopAnimation("surf");
               llStopAnimation("driving");
               sit = FALSE;
               llSetTimerEvent(0.0);
               llMessageLinked(LINK_SET, 0, "pilot", NULL_KEY);
            llMessageLinked(LINK_SET,0,"rundown",NULL_KEY);               
               llPushObject(llGetOwner(), PUSH_OFF, <0,0,0>, TRUE);      //  Help you off the bike 
//               llSay(0,"Thanks for riding the FREE mini hoverpod by Cubey Terra. To see more hovercraft and aircraft visit Abbotts Aerodrome.");
           }
           else if(avatar == llGetOwner())
           {
               //  
               // You have gotten on your bike
               //
               llMessageLinked(LINK_SET, 0, "get_on", "");
               llMessageLinked(LINK_SET,0,"runup",NULL_KEY);               
               llPlaySound("speeder", 1);
               llSetStatus(STATUS_PHYSICS | STATUS_BLOCK_GRAB, TRUE);
               sit = TRUE;
               llRequestPermissions(avatar, PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION);
               reset_keys();
               llSetTimerEvent(TIMER_DELAY);
               llLoopSound("hover_idle", 1.0);
               llMessageLinked(1, 0, "pilot", avatar); // Tell the main script who;s piloting 
               llMessageLinked(LINK_SET,0,"runloop",NULL_KEY);              
            }
            else
            {
                llUnSit(avatar);
            }
           
        }
    }
    
    run_time_permissions(integer perms)
    {
        if(perms & (PERMISSION_TAKE_CONTROLS))
        {
            //llStopAnimation("sit");
            //llStartAnimation("surf");
            llStartAnimation("driving");
            llOwnerSay("Switch to mouselook mode to pilot!  Up and down keys move forward and back, pageup to jump, pagedown for the break!");
            llOwnerSay("PCS is the primary combat system for this vehicle. It also takes damage from Sabers and Ground Guns. It also supports DCS and CCC");
            llOwnerSay("Say \"pcs on\" to turn on PCS combat system");
            llOwnerSay("Say \"dcs on\" to turn on DCS combat system");
            llOwnerSay("Say \"ccc on\" to turn on CCC combat system"); 
            llOwnerSay("Say \"pcs off\", \"dcs off\" or \"ccc off\" to turn off combat");
            llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_RIGHT | CONTROL_LEFT | CONTROL_ROT_RIGHT | CONTROL_ROT_LEFT | CONTROL_UP | CONTROL_DOWN | CONTROL_ML_LBUTTON, TRUE, FALSE);
            llSetVehicleFloatParam(VEHICLE_HOVER_HEIGHT, HOVER_HEIGHT - SIT_DROP);
            llSleep(0.5);
            llSetVehicleFloatParam(VEHICLE_HOVER_HEIGHT, HOVER_HEIGHT);
        }
        else
        {
            llUnSit(avatar);
        }
    }
    
    control(key id, integer level, integer edge)
    {
        if ( ( level & CONTROL_ML_LBUTTON ) && ( edge & CONTROL_ML_LBUTTON ) )
        {
            llMessageLinked(LINK_SET, 0, "fire", "");
        }
        else if ( !( level & CONTROL_ML_LBUTTON ) && ( edge & CONTROL_ML_LBUTTON ) )
        {
            llMessageLinked(LINK_SET, 0, "cease fire", "");
        }
        
        if(((edge) & CONTROL_LEFT) | ((edge) & CONTROL_ROT_LEFT))
        {
            left_toggle  = !left_toggle;
            if(left_toggle)
            {
                llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, <-ROTATION_RATE,0,ROTATION_RATE/2.0>);
            }
            else
            {
           llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, <0.0, 4.0, 3.5> ); // Required for mouselook
            }
        }
        if ((level & CONTROL_LEFT) | (level & CONTROL_ROT_LEFT)) left_toggle = TRUE;    
        
        if(((edge) & CONTROL_RIGHT) | ((edge) & CONTROL_ROT_RIGHT))
        {
            right_toggle = !right_toggle;
            if(right_toggle)
            {
                llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, <ROTATION_RATE,0,-ROTATION_RATE/2.0>);
            }
            else
            {
               llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, <0.0, 4.0, 3.5> ); // Required for mouselook
            }
        }
        if ((level & CONTROL_RIGHT) | (level & CONTROL_ROT_RIGHT)) right_toggle = TRUE;

        if(edge & CONTROL_FWD)
        {
            fwd_toggle = !fwd_toggle;
            if (fwd_toggle && !is_jumping)
            {
                llTriggerSound("hover_whoosh",1);
                llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <FWD_THRUST,0,0>);
                llApplyRotationalImpulse(<0,-THRUST_PITCH*mass,0>, TRUE);
                llMessageLinked(LINK_SET, 0, "burst", "");
            }
            else
            {
                llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <0,0,0>);
            }
        }

        if(edge & CONTROL_BACK)
        {
            back_toggle = !back_toggle;
            if (back_toggle)
            {
                if (!is_jumping)
                {
                    llTriggerSound("stop", 0.3);
                    llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, LINEAR_FRICTION_BRAKE);
                    llApplyRotationalImpulse(<0,THRUST_PITCH*mass,0>, TRUE);
                }
                else
                {
                    trick();
                }     
            }
            else
            {
                llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <0,0,0>);
                llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, LINEAR_FRICTION_RIDE);
            }
        }
       
        if (level & CONTROL_FWD)
        {
            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <FWD_THRUST,0,0>);
            llMessageLinked(LINK_SET, 0, "drive", "");
            fwd_toggle = TRUE;
        }
        if (level & CONTROL_BACK)
        {
            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <-BACK_THRUST,0,0>);
            back_toggle = TRUE;
        }

        
        if(edge & CONTROL_UP)
        {
            up_toggle = !up_toggle;
            //
            if (!up_toggle)
            {
                //  Key released so jump!
                float mag = (llGetTime() - jump_timer)/MAX_JUMP_TIME;
                if (mag > 1.0) mag = 1.0;
//                llStartAnimation("motorcycle_sit");
                start_jump(mag);
            }
            else
            {
                //  Key pressed so get ready 
                jump_timer = llGetTime();
                //llStartAnimation("hello");
                llApplyRotationalImpulse(<0,-THRUST_PITCH*mass,0>, TRUE); 
                llSetVehicleFloatParam(VEHICLE_HOVER_HEIGHT, HOVER_HEIGHT - PRE_JUMP);
                llTriggerSound("hover_whoosh", 1.0); 
                
            }
        }  
        
        if (edge & CONTROL_DOWN)
        {
            down_toggle = !down_toggle; 
            if (down_toggle)
            {
                llTriggerSound("stop", 0.3);
                llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, LINEAR_FRICTION_BRAKE);
            }
            else
            {
                llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, LINEAR_FRICTION_RIDE);
            }
        }
        
    }
    timer()
    {
        //  check for ground and do stuff 
        timer_count++;
        cur_time = llGetTime() - jump_timer;
        if (is_jumping && (cur_time > 0.5))
        {
            pos = llGetPos();
            water_height = llWater(<0,0,0>);
            ground_height = llGround(<0,0,0>); 
            if (water_height > ground_height) 
            {   
                height_agl = pos.z - water_height - 0.5;
            }
            else
            {
                height_agl = pos.z - ground_height - 0.5;
            }
            if ((height_agl < HOVER_HEIGHT) || (cur_time > MAX_JUMP_DURATION))
            {
                stop_jump();
            }
        }
        else
        {
            //
            //  On ground, so follow contour
            //
            pos = llGetPos();
            vel = llGetVel();
            vel_mag = llVecMag(vel);
            water_height = llWater(llGetVel()*TIMER_DELAY);
            ground_height = llGround(llGetVel()*TIMER_DELAY);
            if (water_height > ground_height) 
            {   
                follow_diff = pos.z - water_height - HOVER_HEIGHT + 0.45;
                if (!over_water)
                {
                    over_water = TRUE;
                    llMessageLinked(LINK_SET, 0, "over_water", "");
                } 
            }
            else
            {
                if (over_water)
                {
                    over_water = FALSE;
                    llMessageLinked(LINK_SET, 0, "over_ground", "");
                } 

                follow_diff = pos.z - ground_height - HOVER_HEIGHT + 0.45;
            }
            if ((follow_diff < -FOLLOW_THRESHOLD) && (vel_mag > 2.0))
            {
                llApplyImpulse(<0,0,-follow_diff*FOLLOW_SCALE>, TRUE);
                //llSay(0, "push " + (string) follow_diff);
            }
            if (!is_jumping && (follow_diff > AUTO_JUMP_THRESHOLD))
            {
                //llSay(0,"jump!");
                start_jump(0.1);
            }
            
        }
        
    }
}