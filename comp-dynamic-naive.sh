#!/bin/bash


# this is left as an example 
function compile() {
  SORA_LIBC=$HOME/musl/install
  NAIVE_LIBC=$HOME/musl/install-naive
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
  
  #instrumented musl libc
  echo "ld *.o $NAIVE_LIBC/lib/crt1.o $NAIVE_LIBC/lib/crti.o $NAIVE_LIBC/lib/crtn.o -dynamic-linker $NAIVE_LIBC/syslib/ld-musl-aarch64.so.1 -L$NAIVE_LIBC/lib -lc -o $exe_name"
  ld *.o $NAIVE_LIBC/lib/crt1.o $NAIVE_LIBC/lib/crti.o $NAIVE_LIBC/lib/crtn.o -dynamic-linker $NAIVE_LIBC/syslib/ld-musl-aarch64.so.1 -L$NAIVE_LIBC/lib -lc -o $exe_name 
  
  
}