#!/bin/bash

# this is left as an example 
function compile() {
  
  if [[ -n $CPU2006 && $CPU2006 -eq 1 ]]; then
    # rbc -> lnk
    echo "$LLVM_PATH/opt -S $rbc_name -o $lnk_name"
    $LLVM_PATH/opt -S $rbc_name -o $lnk_name
  else
    # source_files is the variable with all the files we're gonna compile
    echo "parallel --tty --jobs=${JOBS} $LLVM_PATH/$COMPILER $COMPILE_FLAGS \
      -Xclang -disable-O0-optnone \
      -S -c -emit-llvm {} -o {.}.bc ::: "${source_files[@]}""
    parallel --tty --jobs=${JOBS} $LLVM_PATH/$COMPILER $COMPILE_FLAGS \
      -Xclang -disable-O0-optnone \
      -S -c -emit-llvm {} -o {.}.bc ::: "${source_files[@]}" 

    echo "parallel --tty --jobs=${JOBS} $LLVM_PATH/opt -S {.}.bc -o {.}.rbc ::: "${source_files[@]}""
    parallel --tty --jobs=${JOBS} $LLVM_PATH/opt -S {.}.bc -o {.}.rbc ::: "${source_files[@]}"
  
    #Generate all the bcs into a big bc:
    echo "$LLVM_PATH/llvm-link -S *.rbc -o $lnk_name"
    $LLVM_PATH/llvm-link -S *.rbc -o $lnk_name
  fi
  
  # Optimizations
  echo "$LLVM_PATH/opt -S -load $PASS_PATH -${PASS} $lnk_name -o $prf_name"
  $LLVM_PATH/opt -S -load $PASS_PATH -${PASS} $lnk_name -o $prf_name
  
  # Generate obj file
  echo "$LLVM_PATH/llc -filetype=obj $prf_name -o $obj_name"
  $LLVM_PATH/llc -filetype=obj $prf_name -o $obj_name ;
  
  # Compile everything now, producing a final executable file:
  echo "$LLVM_PATH/$COMPILER -lm $obj_name -o INS_$exe_name"
  $LLVM_PATH/$COMPILER -lm $obj_name -o INS_$exe_name ;
}
