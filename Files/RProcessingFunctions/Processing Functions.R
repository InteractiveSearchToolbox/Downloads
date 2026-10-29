library(data.table)
library(jsonlite)


# NOTE THAT ALL THESE FUNCTIONS EXPECT YOUR COLUMN NAMES TO BE X_POS,Y_POS,Z_POS,X_ROT,Y_ROT,Z_ROT,W_ROT,EVENT
# THEY ALSO EXPECT EVERY ROW TO BE A NEW SAMPLE

calculateFirstInteraction = function(dt, by=NULL){
  result <- unique(dt[EVENT == 'START_OF_INTERACTION' & INTERACTION_COUNT == 1,list(TIMESTAMP, CURRENT_OBJECT, INTERACTION_COUNT),by = by])
  print(result)
  
}

calculateLastInteraction = function(dt, by=NULL){
  dt[, MAX_IC := max(INTERACTION_COUNT, na.rm = TRUE), by = by]
  result <- unique(dt[EVENT == 'END_OF_INTERACTION' & INTERACTION_COUNT == MAX_IC,list(TIMESTAMP, CURRENT_OBJECT,INTERACTION_COUNT),by = by])
  dt[,MAX_IC:=NULL,]
  print(result)
  
}

calculateTotalInteractionTime = function(dt, by = NULL){
  tempDT = dt[,list(TIMESTAMP, EVENT, INTERACTION_COUNT),by = by]
  tempDT[,TIME_DIFF:=0,by = by]
  tempDT[,TIME_DIFF:=TIMESTAMP-shift(TIMESTAMP),by = by]
  tempDT[EVENT == 'START_OF_INTERACTION',TIME_DIFF:=0,by = by]
  tempDT[,TOTAL_INTERACTION_TIME:=sum(TIME_DIFF),by = by]
  result <- tempDT[,list(TOTAL_TIME_SPENT_INTERACTING=sum(TIME_DIFF)),by = by]
  print(result)
}

# dt = interaction_data
# by = c("IST_TRIAL_INDEX")
# by = NULL
calculateTotalIdleTime = function(dt, by = NULL){
  tempDT = dt[,list(TIMESTAMP, EVENT, INTERACTION_COUNT, rt),by = by]
  tempDT[,TIME_DIFF:=0,by = by]
  tempDT[,TIME_DIFF:=TIMESTAMP-shift(TIMESTAMP),by = by]
  tempDT[EVENT == 'START_OF_INTERACTION',TIME_DIFF:=0,by = by]
  tempDT[TIMESTAMP < shift(TIMESTAMP),TIME_DIFF:=0,by = by]
  
  tempDT[,TOTAL_INTERACTION_TIME:=sum(TIME_DIFF),by = by]
  
  if(is.null(by)){
    endTime = sum(unique(tempDT$rt,na.rm=T))
    
    if(is.na(endTime)){
      tempDT[,listEND_TIME:=0,by = by]
    }else{
      tempDT[,END_TIME:=endTime,by = by]
    }
    
  }else{
    tempDT[,END_TIME:=max(rt,na.rm=T),by = by]
  }
  
  tempDT[,TOTAL_IDLE_TIME := END_TIME - TOTAL_INTERACTION_TIME,by = by]
  
  result <- unique(tempDT[,TOTAL_IDLE_TIME,by=by], by = by)
  
  result
}

calculateProportionInteracting = function(dt, by = NULL){
  tempDT = dt[,list(TIMESTAMP, EVENT, INTERACTION_COUNT, rt),by = by]
  tempDT[,TIME_DIFF:=0,by = by]
  tempDT[,TIME_DIFF:=TIMESTAMP-shift(TIMESTAMP),by = by]
  tempDT[EVENT == 'START_OF_INTERACTION',TIME_DIFF:=0,by = by]
  tempDT[TIMESTAMP < shift(TIMESTAMP),TIME_DIFF:=0,by = by]
  
  
  tempDT = dt[,list(TIMESTAMP, EVENT, INTERACTION_COUNT, rt),by = by]
  tempDT[,TIME_DIFF:=0,by = by]
  tempDT[,TIME_DIFF:=TIMESTAMP-shift(TIMESTAMP),by = by]
  tempDT[EVENT == 'START_OF_INTERACTION',TIME_DIFF:=0,by = by]
  tempDT[,TOTAL_INTERACTION_TIME:=sum(TIME_DIFF),by = by]
  
  
  if(is.null(by)){
    endTime = sum(unique(tempDT$rt,na.rm=T))
    
    if(is.na(endTime)){
      tempDT[,listEND_TIME:=0,by = by]
    }else{
      tempDT[,END_TIME:=endTime,by = by]
    }
    
  }else{
    tempDT[,END_TIME:=max(rt,na.rm=T),by = by]
  }
  
  tempDT[,TOTAL_IDLE_TIME := END_TIME - TOTAL_INTERACTION_TIME,by = by]
  
  tempDT[,PROP_TIME_INTERACTING := TOTAL_INTERACTION_TIME/END_TIME,by = by]
  
  
  result <- unique(tempDT[,PROP_TIME_INTERACTING,by=by], by = by)
  
  print(result)
}

calculateProportionIdle = function(dt, by = NULL){
  tempDT = dt[,list(TIMESTAMP, EVENT, INTERACTION_COUNT, rt),by = by]
  tempDT[,TIME_DIFF:=0,by = by]
  tempDT[,TIME_DIFF:=TIMESTAMP-shift(TIMESTAMP),by = by]
  tempDT[EVENT == 'START_OF_INTERACTION',TIME_DIFF:=0,by = by]
  tempDT[TIMESTAMP < shift(TIMESTAMP),TIME_DIFF:=0,by = by]
  
  tempDT[,TOTAL_INTERACTION_TIME:=sum(TIME_DIFF),by = by]
  
  
  if(is.null(by)){
    endTime = sum(unique(tempDT$rt,na.rm=T))
    
    if(is.na(endTime)){
      tempDT[,listEND_TIME:=0,by = by]
    }else{
      tempDT[,END_TIME:=endTime,by = by]
    }
    
  }else{
    tempDT[,END_TIME:=max(rt,na.rm=T),by = by]
  }
  
  tempDT[,TOTAL_IDLE_TIME := END_TIME - TOTAL_INTERACTION_TIME,by = by]
  
  tempDT[,PROP_TIME_IDLE := TOTAL_IDLE_TIME/END_TIME,by = by]
  
  
  result <- unique(tempDT[,PROP_TIME_IDLE,by=by], by = by)
  
  print(result)
}

calculateLinearVelocity = function(dt, by=NULL){
  tempDT = dt[,list(TIMESTAMP, X_POS,Y_POS,Z_POS),by = by]
  tempDT[,`:=`(
    X_DIFF = X_POS - shift(X_POS),
    Y_DIFF = Y_POS - shift(Y_POS),
    Z_DIFF = Z_POS - shift(Z_POS),
    TIME_DIFF = TIMESTAMP - shift(TIMESTAMP)
  ),by = by]
  
  tempDT[,`:=`(
    X_VEL = X_DIFF/TIME_DIFF,
    Y_VEL = X_DIFF/TIME_DIFF,
    Z_VEL = X_DIFF/TIME_DIFF
  ),by = by]
  
  result <- tempDT[,list(TIMESTAMP,X_VEL,Y_VEL,Z_VEL),by = by]
  
  print(result)
  
}



calculateTotalInteractions = function(dt, by=NULL){
  if(!is.null(by)){
    all_groups <- unique(dt[, ..by])
    result <- dt[EVENT == 'START_OF_INTERACTION', .(TOTAL_INTERACTIONS = .N), by = by]
    result <- result[all_groups, on = by]
    result[is.na(TOTAL_INTERACTIONS), TOTAL_INTERACTIONS := 0]
    print(result) 
  } else {
    result <- dt[EVENT == 'START_OF_INTERACTION', .(TOTAL_INTERACTIONS = .N)]
    print(result)
  }
}

#filepath = "interactionData_13_8_2026.json"
parse_IST_data <- function(filepath, unlistExtraColumns = T) {
  aDT <- jsonlite::read_json(filepath)
  
  extracted_top_level <- c("IST_TRIAL_INDEX", "SCENE_INFO", "INTERACTION_DATA", "JS_PSYCH_DATA")
  remaining_top_level <- setdiff(names(aDT), extracted_top_level)
  

  
  # JSPSYCH DATA
  jsPsych = data.table(fromJSON(aDT$JS_PSYCH_DATA)[[1]]) #data.table(fromJSON(unlist(aDT$JS_PSYCH_DATA))$trials)
  
  jsPsych[!is.na(IST_TRIAL_INDEX),IST_TRIAL_INDEX := IST_TRIAL_INDEX - 1,] # REMOVE AFTER UPDATING IST
  
  
  # --- SCENE INFO ---
  # Parse the starting scene information - returns a single data table with all starting info
  parse_start_info <- function(trial_index, scene_info) {
    extracted_names <- c("TYPE", "NAME", "POSITION", "QUATERNION")
    
    list_of_tables <- lapply(scene_info, function(s) {
      remaining_names <- setdiff(names(s), extracted_names)
      data.table(
        IST_TRIAL_INDEX = trial_index,
        TYPE = s$TYPE,
        NAME = s$NAME,
        X_POS = s$POSITION$x,
        Y_POS = s$POSITION$y,
        Z_POS = s$POSITION$z,
        X_ROT = s$QUATERNION$x,
        Y_ROT = s$QUATERNION$y,
        Z_ROT = s$QUATERNION$z,
        W_ROT = s$QUATERNION$w,
        OTHER_META_DATA = jsonlite::toJSON(s[remaining_names], auto_unbox = TRUE)
      )
    })
    
    rbindlist(list_of_tables, fill = TRUE)
  }
  
  
  # Map calls parse_start_info for each trial and binds all returned tables (one per trial) into a single table
  start_scene_info <- Map(
    parse_start_info,
    aDT$IST_TRIAL_INDEX,
    aDT$SCENE_INFO
  ) |> rbindlist(fill = TRUE)
  
  # --- INTERACTION DATA ---
  parse_interaction_data <- function(trial_index, interaction_data) {
    extracted_names <- c("TIMESTAMP", "INTERACTION_TIME", "CURRENT_OBJECT",
                         "X_POS", "Y_POS", "Z_POS", "X_ROT", "Y_ROT", "Z_ROT", "W_ROT", "MOUSE_X_POS", "MOUSE_Y_POS")
    remaining_names <- setdiff(names(interaction_data), extracted_names)
    
    TIMESTAMP <- round(as.numeric(unlist(interaction_data$TIMESTAMP)))
    CURRENT_OBJECT <- unlist(interaction_data$CURRENT_OBJECT)
    
    if (!is.null(CURRENT_OBJECT)) {
      INTERACTION_TIMESTAMP <- round(as.numeric(unlist(interaction_data$INTERACTION_TIME)))
      
      time_table <- data.table(TIMESTAMP)
      
      interaction_table <- data.table(
        TIMESTAMP = INTERACTION_TIMESTAMP,
        CURRENT_OBJECT = CURRENT_OBJECT,
        X_POS  = as.numeric(unlist(interaction_data$X_POS)),
        Y_POS  = as.numeric(unlist(interaction_data$Y_POS)),
        Z_POS  = as.numeric(unlist(interaction_data$Z_POS)),
        X_ROT  = as.numeric(unlist(interaction_data$X_ROT)),
        Y_ROT  = as.numeric(unlist(interaction_data$Y_ROT)),
        Z_ROT  = as.numeric(unlist(interaction_data$Z_ROT)),
        W_ROT  = as.numeric(unlist(interaction_data$W_ROT)),
        MOUSE_X_POS = as.numeric(unlist(interaction_data$MOUSE_X_POS)),
        MOUSE_Y_POS = as.numeric(unlist(interaction_data$MOUSE_Y_POS)),
        EVENT  = "INTERACTING"
      )
      
      if(nrow(time_table) > 0){
        dt <- merge(time_table, interaction_table, all.x = TRUE, by = "TIMESTAMP")
      }else{
        dt <- interaction_table
      }
      
      dt[,IST_TRIAL_INDEX:=trial_index,]
      
      
      # Tag start/end of each interaction bout
      dt[
        EVENT == "INTERACTING" & (is.na(shift(CURRENT_OBJECT)) | shift(CURRENT_OBJECT) != CURRENT_OBJECT),
        EVENT := "START_OF_INTERACTION"
      ]
      
      # if the next row after START_OF_INTERACTION is NA, then don't count as a true interaction - it is impossible to get the start and end from only a single sample.
      # the likelihood of this happening is extremely low, someone would need to click and re-click within a single refresh of the screen - but need to check for it anyway
      dt[
        EVENT == "START_OF_INTERACTION" & (is.na(shift(CURRENT_OBJECT, type = 'lead')) | shift(CURRENT_OBJECT, type = 'lead') != CURRENT_OBJECT),
        EVENT := "NOT_ENOUGH_SAMPLES"
      ]
      
      # Rerun detection
      dt[
        EVENT == "INTERACTING" & (is.na(shift(CURRENT_OBJECT)) | shift(CURRENT_OBJECT) != CURRENT_OBJECT),
        EVENT := "START_OF_INTERACTION"
      ]
      
      dt[
        EVENT == "INTERACTING" & (is.na(shift(CURRENT_OBJECT, type = "lead")) | shift(CURRENT_OBJECT, type = "lead") != CURRENT_OBJECT),
        EVENT := "END_OF_INTERACTION"
      ]
      
      dt[EVENT == 'START_OF_INTERACTION',INTERACTION_COUNT:=1,]
      dt[EVENT == 'START_OF_INTERACTION',INTERACTION_COUNT:=cumsum(INTERACTION_COUNT),]
      dt[!is.na(EVENT),INTERACTION_COUNT := nafill(INTERACTION_COUNT, type = "locf"),]
      
    } else {
      if (is.null(TIMESTAMP) | length(TIMESTAMP) == 0) TIMESTAMP <- 0L
      dt <- data.table(
        IST_TRIAL_INDEX    = trial_index,
        TIMESTAMP      = TIMESTAMP,
        CURRENT_OBJECT = NA, X_POS = NA, Y_POS = NA, Z_POS = NA,
        X_ROT = NA, Y_ROT = NA, Z_ROT = NA, W_ROT = NA, MOUSE_X_POS = NA, MOUSE_Y_POS = NA,
        EVENT  = NA, INTERACTION_COUNT = 0
      )
      
    }
    
    setcolorder(dt, c("IST_TRIAL_INDEX", "TIMESTAMP", "CURRENT_OBJECT", "X_POS", "Y_POS", "Z_POS", "X_ROT", "Y_ROT", "Z_ROT", "W_ROT","INTERACTION_COUNT","EVENT"))
    
    for (col in remaining_names) {
      value <- if (unlistExtraColumns) unlist(interaction_data[[col]]) else interaction_data[[col]]
      dt[, (col) := value]
    }
    
    
    dt
  }
  
  
  final_interaction_table <- Map(
    parse_interaction_data,
    aDT$IST_TRIAL_INDEX,
    aDT$INTERACTION_DATA
  ) |> rbindlist(fill = TRUE)
  
  
  # jsPsych rows should line up 1:1 with the IST trials, in order
  RTs <- jsPsych[!is.na(IST_TRIAL_INDEX),list(rt),list(IST_TRIAL_INDEX)]
  
  
  final_interaction_table <- merge(
    final_interaction_table,
    RTs,
    by = "IST_TRIAL_INDEX",
    all.x = TRUE
  )
  
  
  # Handle any extra global data
  extra <- lapply(remaining_top_level, function(col) {
    if (unlistExtraColumns) unlist(aDT[[col]]) else aDT[[col]]
  })
  names(extra) <- remaining_top_level
  
  c(
    list(
      SCENE_INFO = start_scene_info,
      INTERACTION_DATA = final_interaction_table,
      JS_PSYCH_DATA = jsPsych
    ),
    extra
  )
}




# Note that this expects quaternions in the following format...
  # Quat1 = c(W,X,Y,Z), Quat2 = c(W,X,Y,Z)

quat_multiply <- function(Quat1, Quat2) {
  c(
    Quat1[1]*Quat2[1] - Quat1[2]*Quat2[2] - Quat1[3]*Quat2[3] - Quat1[4]*Quat2[4],  # w
    Quat1[1]*Quat2[2] + Quat1[2]*Quat2[1] + Quat1[3]*Quat2[4] - Quat1[4]*Quat2[3],  # x
    Quat1[1]*Quat2[3] - Quat1[2]*Quat2[4] + Quat1[3]*Quat2[1] + Quat1[4]*Quat2[2],  # y
    Quat1[1]*Quat2[4] + Quat1[2]*Quat2[3] - Quat1[3]*Quat2[2] + Quat1[4]*Quat2[1]   # z
  )
}

normalise_quat <- function(quat) {
  quat <- quat / sqrt(sum(quat^2))
}

get_quat_conjugate <- function(quat) {
  conj <- c(quat[1], -quat[2], -quat[3], -quat[4])
}

negate_quat  <- function(quat) {
  negated_quat <- -quat
}

extract_angle_from_quat <- function(quat){
  # Clamp W component between -1 and 1 since acos will fail if it exceeds that.
  # It should not exceed it, but floating point errors may cause it to do so - e.g., 1.0000001
  clamped_w = max(-1, min(1, quat[1]))
  
  # Extract angle (clamp w for numerical safety)
  angle <- 2 * acos(clamped_w)
}

extract_axis_from_quat <- function(quat){
  angle <- extract_angle_from_quat(quat)
  
  if (abs(angle) < 1e-10) {
    return(NA)
  } else {
    sin_half <- sin(angle/ 2)
    axis <- quat[2:4] / sin_half
    return(axis)
  }
}


calculateAngularVelocity <- function(dt, by = NULL, local = TRUE){
  
  tempDT <- copy(dt)
  
  # CREATE PREV_ROTs
  tempDT[,`:=`(
    PREV_X_ROT = shift(X_ROT),
    PREV_Y_ROT = shift(Y_ROT),
    PREV_Z_ROT = shift(Z_ROT),
    PREV_W_ROT = shift(W_ROT),
    TIME_DIFF = TIMESTAMP - shift(TIMESTAMP)
  ),by = by]
  
  
  # Apply row-wise angular velocity calculation
  tempDT[, c("ANG_VEL_X", "ANG_VEL_Y", "ANG_VEL_Z") := {
    results <- mapply(
      function(W, X, Y, Z, PREV_W, PREV_X, PREV_Y, PREV_Z, TIME_DIFF) {
        
        # Skip rows with any missing quaternion component or missing time diff
        if (any(is.na(c(W, X, Y, Z, PREV_W, PREV_X, PREV_Y, PREV_Z))) || is.na(TIME_DIFF)) {
          return(c(NA, NA, NA))
        }
        
        q1 <- normalise_quat(c(PREV_W, PREV_X, PREV_Y, PREV_Z))
        q2 <- normalise_quat(c(W, X, Y, Z))
        
        # Guard against NaN
        if (any(is.na(q1)) || any(is.na(q2))) {
          return(c(NA, NA, NA))
        }
        
        q1_conj <- get_quat_conjugate(q1)
        
        if (local == TRUE) {
          dq <- quat_multiply(q1_conj, q2)
        } else {
          dq <- quat_multiply(q2, q1_conj)
        }
        
        if (dq[1] < 0) dq <- negate_quat(dq)
        
        angle <- extract_angle_from_quat(dq)
        axis  <- extract_axis_from_quat(dq)
        
        if (abs(angle) < 1e-10) {
          return(c(0, 0, 0))
        }
        
        axis * angle / TIME_DIFF
      },
      W_ROT, X_ROT, Y_ROT, Z_ROT,
      PREV_W_ROT, PREV_X_ROT, PREV_Y_ROT, PREV_Z_ROT,
      TIME_DIFF,
      SIMPLIFY = TRUE
    )
    list(results[1, ], results[2, ], results[3, ])
  }, by = by]
  
  result = tempDT[,list(TIMESTAMP, ANG_VEL_X,ANG_VEL_Y,ANG_VEL_Z),by = by]
  return(result)
}

calculateAngularSpeed <- function(dt, by = NULL){
  tempDT = calculateAngularVelocity(dt, by)
  tempDT[, list(TIMESTAMP, ANGULAR_SPEED= sqrt(ANG_VEL_X^2 + ANG_VEL_Y^2 + ANG_VEL_Z^2)), by = by]
}

calculateLinearSpeed <- function(dt, by = NULL){
  tempDT = calculateLinearVelocity(dt, by)
  tempDT[, list(TIMESTAMP, LINEAR_SPEED= sqrt(X_VEL^2 + Y_VEL^2 + Z_VEL^2)), by = by]
}
# ANG_VEL_X, Y, and Z combined tells us the direction of the rotation and the individual values describe the rate at which they are rotating around each of it's local X,Y,Z axeses.
# It is easier to understand angular speed instead (all of the components combined)
# Then we can see, the object is rotating around the axis, at a speed of X rad/s


ms_to_seconds <- function(ms){ms / 1000}
ms_to_minutes <- function(ms) {ms / 60000}
ms_to_hours <- function(ms){ms / 3600000}

seconds_to_ms <- function(s){s * 1000}
seconds_to_minutes <- function(s){s / 60}
seconds_to_hours <- function(s){s / 3600}

minutes_to_ms <- function(m){m * 60000}
minutes_to_seconds <- function(m){m * 60}  
minutes_to_hours   <- function(m){m / 60}

hours_to_ms <- function(h){h * 3600000}
hours_to_seconds <- function(h){h * 3600}
hours_to_minutes <- function(h){h * 60} 
