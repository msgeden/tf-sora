#!/bin/bash

function execute() {
  
  exe=$exe_name ;

  if [[ -n $INSTRUMENT && $INSTRUMENT -eq 1 ]]; then
    exe=INS_$exe_name ;
  fi


  if [[ $(pwd) =~ "cBench" ]]; then
    for i in $(seq 1 1); do # this must be changed
      cmd="./__run $i $exe_name"
      echo "cd $(pwd) && $cmd" >> /tmp/run.txt
    done
    return
  fi
  
 
  cmd="$TIMEOUT --signal=TERM ${RUNTIME} \
       $DYN_PATH/bin64/drrun -t drcachesim -simulator_type basic_counts\
       $DYN_FLAGS \
       -- ./$exe $RUN_OPTIONS < $STDIN " ;

  echo "$cmd"
  echo "cd $(pwd) && $cmd" >> /tmp/run.txt ;
   
}
