#!/bin/bash

# this is left as an example 
function compile() {
  
  if [[ -n $CPU2006 && $CPU2006 -eq 1 ]]; then
    # rbc -> lnk
    $LLVM_PATH/opt -S $rbc_name -o $lnk_name
  else
    # source_files is the variable with all the files we're gonna compile
    echo "parallel --tty --jobs=${JOBS} $LLVM_PATH/$COMPILER $COMPILE_FLAGS $OFLAGS -L$HOME/sip24lib/ -Wl,-rpath=$HOME/sip24lib -fno-omit-frame-pointer -fno-stack-protector -fno-asynchronous-unwind-tables -fno-dwarf2-cfi-asm -lsiphash24 \
      -Xclang -disable-O0-optnone \
      -S -c -emit-llvm {} -o {.}.bc ::: "${source_files[@]}"" 
    
    parallel --tty --jobs=${JOBS} $LLVM_PATH/$COMPILER $COMPILE_FLAGS  $OFLAGS -L$HOME/sip24lib/ -Wl,-rpath=$HOME/sip24lib -fno-omit-frame-pointer -fno-stack-protector -fno-asynchronous-unwind-tables -fno-dwarf2-cfi-asm  -lsiphash24 \
      -Xclang -disable-O0-optnone \
      -S -c -emit-llvm {} -o {.}.bc ::: "${source_files[@]}" 
    
    echo "$LLVM_PATH/llvm-link -S *.bc -o $lnk_name"
    $LLVM_PATH/llvm-link -S *.bc -o $lnk_name
  fi
  
  echo "$LLVM_PATH/llc -regalloc=$RA $lnk_name -o $obj_name.s ;"
  $LLVM_PATH/llc -regalloc=$RA $lnk_name -o $obj_name.s;
  
  echo "$LLVM_PATH/$COMPILER  -lm $obj_name.s -o $exe_name ;"
  $LLVM_PATH/$COMPILER -L$HOME/sip24lib/ -Wl,-rpath=$HOME/sip24lib -lm $obj_name.s -o $exe_name -lsiphash24;
  
}
