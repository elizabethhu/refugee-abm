#!/bin/bash
#conducts param sweep
TOTAL_POP=1000 
COST_WEIGHT_VALUE=0.100
RISK_WEIGHT_VALUE=0.100
POP_WEIGHT_VALUE=0.100
DISTANCE_WEIGHT_VALUE=0.100
SPEED_WEIGHT_VALUE=0.100
HEU_WEIGHT_VALUE=0.00000005
 
PARAM1=POP_WEIGHT
PARAM1_START=0.10
PARAM1_INTERVAL=0.10
PARAM1_COUNT=10
PARAM1_VALUE=POP_WEIGHT_VALUE
 
PARAM2=RISK_WEIGHT
PARAM2_START=0.10
PARAM2_INTERVAL=0.10
PARAM2_COUNT=10
PARAM2_VALUE=RISK_WEIGHT_VALUE

 
TRIALS=3
#num of trials to complete before going to the next one
TRIAL_STEPS=3
 
#echo "s/$PARAM1 = 0.0000/$PARAM1 = $PARAM1_START/g"
#set param file to initial vaules
#sed -i "s/$PARAM1 = 0.0000/$PARAM1 = $PARAM1_START/g" ~/refugee-abm/src/Parameters.java
#sed -i "s/$PARAM2 = 0.00/$PARAM2 = $PARAM2_START/g" ~/refugee-abm/src/Parameters.java
 
 
for m in $(seq 1 1 $TRIALS)
do
        COUNTER1=0
        #check if the progress file is here
        if [ ! -f ~/assip/paramsweeps/paramsweep1/progress_cost ]; then
                echo 0 > ~/assip/paramsweeps/progress_cost
        fi
        COUNTER1=$(cat ~/assip/paramsweeps/progress_cost)
 
        while [ $COUNTER1 -lt $PARAM1_COUNT ]; do
 
                #update to new param
                NEW_VALUE1=$(python -c "print \"%.4f\" % ($PARAM1_START - ($PARAM1_INTERVAL*$COUNTER1)) ")
                #sed -i "s/$PARAM1 = $PARAM1_VALUE/$PARAM1 = $NEW_VALUE1/g" ~/assip/ebola-abm/src/Parameters.java
                PARAM1_VALUE=$NEW_VALUE1
                echo "$PARAM1 = $PARAM1_VALUE"
 
                COUNTER2=0
                #check if the progress file is here
                if [ ! -f ~/assip/paramsweeps/progress_risk ]; then
                        echo 0 > ~/assip/paramsweeps/progress_risk
                fi
                COUNTER2=$(cat ~/assip/paramsweeps/progress_risk)
 
                while [ $COUNTER2 -lt $PARAM2_COUNT ]; do
                         #update to new param
                        NEW_VALUE2=$(python -c "print \"%.2f\" % ($PARAM2_START + ($PARAM2_INTERVAL*$COUNTER2)) ")
                        #sed -i "s/$PARAM2 = $PARAM2_VALUE/$PARAM2 = $NEW_VALUE2/g" ~/assip/ebola-abm/src/Parameters.java
                        PARAM2_VALUE=$NEW_VALUE2
                        echo "$PARAM2 = $PARAM2_VALUE"
                        mkdir ~/assip/paramsweeps/run${COUNTER1}${COUNTER2}-${PARAM1_VALUE}-${PARAM2_VALUE}
 
                        #check if the progress file is here
                        if [ ! -f ~/assip/paramsweeps/run${COUNTER1}${COUNTER2}-${PARAM1_VALUE}-${PARAM2_VALUE}/progress ]; then
                                echo 0 > ~/assip/paramsweeps/run${COUNTER1}${COUNTER2}-${PARAM1_VALUE}-${PARAM2_VALUE}/progress
                        fi
                        PROGRESS=$(cat ~/assip/paramsweeps/run${COUNTER1}${COUNTER2}-${PARAM1_VALUE}-${PARAM2_VALUE}/progress)
                        let PROGRESS=PROGRESS+1
                        #do each trial here
                        TEMP=0
                        let TEMP=PROGRESS+TRIAL_STEPS
                        for i in $(seq $PROGRESS 1 $TEMP)
                        do
                                echo "Trial #${i}"
                                #run each in a seperate terminal
                                mkdir ~/assip/paramsweeps/run${COUNTER1}${COUNTER2}-${PARAM1_VALUE}-${PARAM2_VALUE}/trial${i}
                                cd ~/assip/refugee-abm/
                                #set new parameter values
                                POP_WEIGHT_VALUE=$PARAM1_VALUE
                                RISK_WEIGHT_VALUE=$PARAM2_VALUE
                                java -Xmx12288M -jar refugee.jar ${COUNTER1}${COUNTER2}${i} ${COST_WEIGHT_VALUE} ${RISK_WEIGHT_VALUE} ${POP_WEIGHT_VALUE} ${DISTANCE_WEIGHT_VALUE} ${SPEED_WEIGHT_VALUE} ${HEU_WEIGHT_VALUE} ${TOTAL_POP}> ~/assip/paramsweeps/run${COUNTER1}${COUNTER2}-${PARAM1_VALUE}-${PARAM2_VALUE}/trial${i}/log.txt &
                                COST_WEIGHT_VALUE=0.100
                                #save progress in file
                                echo ${i} > ~/assip/paramsweeps/run${COUNTER1}${COUNTER2}-${PARAM1_VALUE}-${PARAM2_VALUE}/progress
                        done
                        let COUNTER2=COUNTER2+1
                        echo $COUNTER2 > ~/assip/paramsweeps/progress_risk
                done
                let COUNTER1=COUNTER1+1
                echo $COUNTER1 > ~/assip/paramsweeps/progress_cost
 
                COUNTER2=0
                echo $COUNTER2 > ~/assip/paramsweeps/progress_risk
        done
        rm -rf ~/assip/paramsweeps/paramsweep1/progress_cost
        rm -rf ~/assip/paramsweeps/paramsweep1/progress_risk
done
