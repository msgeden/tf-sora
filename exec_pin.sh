#!/bin/bash

function execute() {
  
  exe=$exe_name ;

  if [[ -n $INSTRUMENT && $INSTRUMENT -eq 1 ]]; then
    exe=INS_$exe_name ;
  fi

  cmd="$TIMEOUT --signal=TERM ${RUNTIME} \
       $PIN_PATH/pin -t $PIN_LIB/obj-intel64/${PIN_TOOL}.${suffix} \
       $PIN_FLAGS \
       -- ./$exe $RUN_OPTIONS < $STDIN > $STDOUT" ;

  echo "$cmd"
  echo "cd $(pwd) && $cmd" >> /tmp/run.txt ;
   
}
