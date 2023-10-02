ON INIT {
 SET_WORLD_COLLISION OFF
 INVENTORY ADD_FROM_SCENE "KEY_BASE_0044"
 SET £key_carried "KEY_BASE_0044"
 ACCEPT
}

ON AGRESSION {
 SET_WORLD_COLLISION ON
 ACCEPT
}

ON INITEND {
 IF (£friend != "NONE") SETGROUP -r £friend
 SET £friend "NONE"
 SET £thief [Human_male_thief]
 TWEAK HEAD "human_villager_head2"
 TWEAK SKIN "npc_human_villager2_carlo" "npc_human_villager2_anon"
 TWEAK TORSO "human_villager_chest2"
 ATTACH POLE_0013 "action point" SELF "primary_attach"
 SET £attached_object "POLE_0013"
 SETWEAPON DAGGER
 SENDEVENT -ir DURABILITY 100 "65"
 SET_NPC_STAT damages 10
 SET_NPC_STAT aimtime 800
 PHYSICAL OFF
 LOADANIM ACTION2 "Human_misc_fishing"
 LOADANIM ACTION1 "rat_walk_test"
 SET §frozen 1
 PLAYANIM -l ACTION2 
 ACCEPT
}

ON _ELOAD {
  IF (#TROLL_QUEST == 2) {
    DESTROY SEAT_STOOL1_0018
    DESTROY BUCKET_0024
    IF (^POSSESS_FOOD_FISH_0048 == 0) DESTROY FOOD_FISH_0048
    IF (^POSSESS_FOOD_FISH_0049 == 0) DESTROY FOOD_FISH_0049
    IF (^POSSESS_FOOD_FISH_0050 == 0) DESTROY FOOD_FISH_0050
    TELEPORT MARKER_0425
    PLAYANIM NONE
    SET §frozen 0
    PHYSICAL ON
    BEHAVIOR MOVE_TO
    SETTARGET MARKER_0056   
    DETACH POLE_0013 SELF
    SET £attached_object "NONE"
    ACCEPT
  }  
  IF (#PLAYER_ON_QUEST == 4) {
    TWEAK LEGS "human_villager_legs2"
    PLAYANIM NONE
    TELEPORT MARKER_0860
    SET §frozen 0
    PHYSICAL ON
    BEHAVIOR WANDER_AROUND 300
    SETTARGET NONE
    ACCEPT
  }
  IF (#PLAYER_ON_QUEST == 6) {
    OBJECT_HIDE SELF ON
    SET §reflection_mode 0
    ACCEPT
  }
  IF (#PLAYER_ON_QUEST == 7) {
    SET §reflection_mode 1
    OBJECT_HIDE SELF OFF
    TWEAK LEGS "human_villager_legs2"
    TELEPORT MARKER_0327
    BEHAVIOR MOVE_TO
    SETTARGET MARKER_0427
    ACCEPT
  }
 ACCEPT
}

ON REACHEDTARGET {
  IF (^TARGET == MARKER_0056) {
    BEHAVIOR FRIENDLY
    SETTARGET HUMAN_BASE_0095
    TIMERleave 1 5 GOTO GO_HOME
    ACCEPT
  }
  IF (^TARGET == MARKER_0427) {
    SENDEVENT CUSTOM LIGHT_DOOR_0121 "UNLOCK"
    BEHAVIOR WANDER_AROUND 200
    SETTARGET NONE
    ACCEPT
  }
 ACCEPT
}

ON CUSTOM {
  IF (^$PARAM1 == "thief") {
    SENDEVENT CUSTOM DOG_0011 "ATTACK"
    SPEAK -o [human_male_thief] SENDEVENT ATTACK_PLAYER SELF ""
    ACCEPT
  }
 ACCEPT
}

//#behavior

// ---------------------------------------------------------------------------------
// BEHAVIOR INCLUDE START ----------------------------------------------------------
// ---------------------------------------------------------------------------------
>>CLEAR_MICE_TARGET
 // if we care about mice : clear current mice target and listen to other mice
 IF ( §care_about_mice == 1 )
 {
  SET £targeted_mice "NOMOUSE"
  SETGROUP MICECARE // listen to other mice
 }
RETURN

>>SAVE_BEHAVIOR
 TIMERcolplayer OFF 
// to avoid TIMERcolplayer to restore the behavior 1 sec later
 IF (§main_behavior_stacked == 0) 
 {
  IF (§frozen == 1)
  { 
// frozen anim -> wake up !
    SET §frozen 0
    PLAYANIM NONE
    PLAYANIM -2 NONE
    PHYSICAL ON
    COLLISION ON
    BEHAVIOR FRIENDLY
    SETTARGET PLAYER
  }
  SET §main_behavior_stacked 1
  HEROSAY -d "STACK"
  BEHAVIOR STACK
 }
 ELSE
 { // behavior already saved : clear mice target if one
  GOSUB CLEAR_MICE_TARGET
 }
RETURN

>>RESTORE_BEHAVIOR
 IF (§main_behavior_stacked == 1) 
 {
  GOSUB CLEAR_MICE_TARGET
  HEROSAY -d "UNSTACK"
  BEHAVIOR UNSTACK
  SET §main_behavior_stacked 0
  RETURN
 }
IF (£init_marker != "NONE")
  { 
   BEHAVIOR MOVE_TO
   SETTARGET -a ~£init_marker~
   SETMOVEMODE WALK
   RETURN
  }
HEROSAY -d "go_home"
BEHAVIOR GO_HOME
SETTARGET PLAYER
RETURN

// ---------------------------------------------------------------------------------
// BEHAVIOR INCLUDE END ------------------------------------------------------------
// ---------------------------------------------------------------------------------

//#
//#LocalChat
// ---------------------------------------------------------------------------------
// LocalChat INCLUDE START ---------------------------------------------------------
// ---------------------------------------------------------------------------------
>>START_CHAT
 // save misc reflection mode
 SET §saved_reflection §reflection_mode
 // no more stupid reflections !
 SET §reflection_mode 0
 // fo not change behavior if frozen
 IF ( §frozen == 1 ) RETURN
 // save behavior (if not saved)
 GOSUB SAVE_BEHAVIOR
 // look at player
 BEHAVIOR FRIENDLY
 SETTARGET PLAYER
RETURN

>>END_CHAT
 SET_EVENT COLLIDE_NPC ON
 SET §collided_player 0
 // restor behavior only if not in fighting mode
 IF ( §fighting_mode == 0 )
 {
  // restore misc reflection mode
  SET §reflection_mode §saved_reflection
  // if frozen : don't restore behavior
  IF ( §frozen == 1 ) RETURN
  // restore behavior
  GOSUB RESTORE_BEHAVIOR
 }
RETURN
// ---------------------------------------------------------------------------------
// LocalChat INCLUDE END -----------------------------------------------------------
// ---------------------------------------------------------------------------------

//#

ON CHAT {
  IF (^SPEAKING == 1) ACCEPT
  IF (§chatpos == 0) {
    GOSUB START_CHAT
    SETNAME "Giorgio"
    SPEAK [giorgio-speech] GOSUB DANCE_START SPEAK [giorgio-music] GOSUB DANCE_STOP GOSUB END_CHAT
    ACCEPT
  }
 ACCEPT
}

>>DANCE_START {
  SET_SPEED 3
  PLAYANIM -l ACTION1
  RETURN
}

>>DANCE_STOP {
  SET_SPEED 1
  PLAYANIM -l ACTION2
  RETURN
}

>>GO_HOME
 BEHAVIOR MOVE_TO
 SETTARGET MARKER_0427
 ACCEPT

ON RELOAD {
  IF (#TROLL_QUEST == 2) {
    DESTROY SEAT_STOOL1_0018
    DESTROY BUCKET_0024
    IF (^POSSESS_FOOD_FISH_0048 == 0) DESTROY FOOD_FISH_0048
    IF (^POSSESS_FOOD_FISH_0049 == 0) DESTROY FOOD_FISH_0049
    IF (^POSSESS_FOOD_FISH_0050 == 0) DESTROY FOOD_FISH_0050
    TELEPORT MARKER_0425
    PLAYANIM NONE
    SET §frozen 0
    PHYSICAL ON
    BEHAVIOR MOVE_TO
    SETTARGET MARKER_0056   
    DETACH POLE_0013 SELF
    SET £attached_object "NONE"
    ACCEPT
  }  
  IF (#PLAYER_ON_QUEST == 4) {
    TWEAK LEGS "human_villager_legs2"
    PLAYANIM NONE
    TELEPORT MARKER_0860
    SET §frozen 0
    PHYSICAL ON
    BEHAVIOR WANDER_AROUND 300
    SETTARGET NONE
    ACCEPT
  }
  IF (#PLAYER_ON_QUEST == 5) {
    TELEPORT MARKER_0860
    SET §frozen 0
    BEHAVIOR WANDER_AROUND 300
    SETTARGET NONE
    ACCEPT
  }
  IF (#PLAYER_ON_QUEST == 6) {
    OBJECT_HIDE SELF ON
    SET §reflection_mode 0
    ACCEPT
  }
  IF (#PLAYER_ON_QUEST == 7) {
    SET §reflection_mode 1
    OBJECT_HIDE SELF OFF
    TWEAK LEGS "human_villager_legs2"
    TELEPORT MARKER_0327
    BEHAVIOR MOVE_TO
    SETTARGET MARKER_0427
    ACCEPT
  }
 ACCEPT
}
