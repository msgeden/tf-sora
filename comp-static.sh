#!/bin/bash

# this is left as an example 
function compile() {
  
  # source_files is the variable with all the files we're gonna compile
  echo "parallel --tty --jobs=${JOBS} $LLVM_PATH/$COMPILER $COMPILE_FLAGS $OFLAGS -fno-omit-frame-pointer -fno-stack-protector -fno-asynchronous-unwind-tables -fno-dwarf2-cfi-asm  \
      -mllvm --regalloc=$RA \
     -c {} -o {.}.o ::: "${source_files[@]}"" 
  if [[ $OFLAGS == "-O0" ]]; then
    parallel --tty --jobs=${JOBS} $LLVM_PATH/$COMPILER $COMPILE_FLAGS $OFLAGS -fno-omit-frame-pointer -fno-stack-protector -fno-asynchronous-unwind-tables -fno-dwarf2-cfi-asm  \
     \
     -c {} -o {.}.o ::: "${source_files[@]}"
  else
    parallel --tty --jobs=${JOBS} $LLVM_PATH/$COMPILER $COMPILE_FLAGS $OFLAGS -fno-omit-frame-pointer -fno-stack-protector -fno-asynchronous-unwind-tables -fno-dwarf2-cfi-asm  \
      -mllvm --regalloc=$RA \
     -c {} -o {.}.o ::: "${source_files[@]}"
  fi  
  
  #echo "$LLVM_PATH/llc -regalloc=$RA $lnk_name -o $obj_name.s"
  #$LLVM_PATH/llc -regalloc=$RA $lnk_name -o $obj_name.s

  #instrumented musl libc
  if [[ $RA == "sora" ]]; then
    echo "  $LLVM_PATH/$COMPILER -static /home/munden/musl/install/lib/libc.a *.o -lm -o $exe_name"
    $LLVM_PATH/$COMPILER -static /home/munden/musl/install/lib/libc.a *.o -lm -o $exe_name
  else
    echo "  $LLVM_PATH/$COMPILER -static /home/munden/musl/install-naive/lib/libc.a *.o -lm -o $exe_name"
    $LLVM_PATH/$COMPILER -static /home/munden/musl/install-naive/lib/libc.a *.o -lm -o $exe_name
  fi

  
}