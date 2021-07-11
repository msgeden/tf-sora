# if 0, redirect benchmark output to /dev/null
# if 1, print benchmark output to stdout
[[ -n $DEBUG ]] || DEBUG=0

# Specify the timeout. Default is INF(0)
[[ -n $RUNTIME ]] || RUNTIME=0

# Execute the benchmark
[[ -n $EXEC ]] || EXEC=1

# Compile
[[ -n $COMPILE ]] || COMPILE=1

# Instrument
[[ -n $INSTRUMENT ]] || INSTRUMENT=0

# JOBS
[[ -n $JOBS ]] || JOBS=1

# ANALYZE
[[ -n $ANALYZE ]] || ANALYZE=0

# INSTRUMENT
[[ -n $INSTRUMENT ]] || INSTRUMENT=0

# DIFF
[[ -n $DIFF ]] || DIFF=0

[[ $DIFF -eq 1 && $DEBUG -eq 1 ]] && {
  echo "Can't use DIFF=1 & DEBUG=1 at the same time"
  exit 1
}

# Remove all temp files
[[ -n CLEAN ]] || CLEAN=0

# Set the lib suffix.
suffix="dylib"
if [[ $(uname -s) == "Linux" ]]; then
  suffix="so"
fi

# if we're on osx, we must use `gtimeout` instead of `timeout`
# `gtimeout` can be download from homebrew
TIMEOUT=timeout
if [[ $(uname -s) == "Darwin" ]]; then
  TIMEOUT=gtimeout
fi


# -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- 

# LLVM_PATH  => The place where I have all the LLVM tools
if [[ $RA == "sora" ]]; then
  LLVM_PATH=$HOME/LLVM/11.1.0/llvm-project/build/bin
else
  LLVM_PATH=/usr/bin
  #LLVM_PATH=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
fi

if [[ $INSTRUMENT == 1 ]]; then
  LLVM_PATH=$HOME/LLVM/11.1.0/llvm-project/build/bin
fi
[[ -d "${LLVM_PATH}" ]] || {
	echo "One must define LLVM_PATH before running tf"
	exit 1
}

# -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- 

# DYNAMORIO 
[[ -n $DYNRIO ]] || DYNRIO=0

if [[ $DYNRIO -eq 1 ]]; then
  # DYN_PATH   => The place where I keep the dynamoRIO
	#DYN_PATH="$HOME/DynamoRIO"
  DYN_PATH="$HOME/dynamorio-master/build"
  [[ -n $DYN_PATH ]] || {
		echo "One must define the DYNRIO before when DYNRIO=1"
		exit 1
	}
  
  # DYN_LIB    => The place where I keep the DynamoRIO lib implemented.
	DYN_LIB="$DYN_PATH/samples/bin/lib"
  [[ -n $DYN_LIB ]] || {
		echo "One must define PIN_LIB when PIN=1"
		exit 1
	}

  # DYN_TOOL   => The tool used
  #[[ -n $DYN_TOOL ]] || {
  #  echo "You must define a DYN_TOOL variable before using tf with DynamoRIO"
  #  exit 1
  #}

  # DYN_FLAGS  => Flags to pass to DynamoRIO
  [[ -n $DYN_FLAGS ]] || DYN_FLAGS=" "

  echo "DYN_PATH is set to $DYN_PATH"
  echo "DYN_LIB is set to $DYN_LIB"
  echo "DYN_TOOL is set to $DYN_TOOL"
  
  #echo "Compiling DYN TOOLS"
  #DYN_ROOT=DYN_PATH make -C $DYN_LIB || {
  #  echo "Error compiling DYNRIO TOOLS"
  #  exit 1
  #}
  
fi


# THIS PART IS LEFT AS AN EXAMPLE FOR THE PEOPLE WORKING WITH PIN!
# PIN 
[[ -n $PIN ]] || PIN=0

if [[ $PIN -eq 1 ]]; then
  # PIN_PATH   => The place where I keep the pin source code
	PIN_PATH=""
  [[ -n $PIN_PATH ]] || {
		echo "One must define the PIN before when PIN=1"
		exit 1
	}
  
  # PIN_LIB    => The place where I keep the Pin lib implemented.
	PIN_LIB=""
  [[ -n $PIN_LIB ]] || {
		echo "One must define PIN_LIB when PIN=1"
		exit 1
	}

  # PIN_TOOL   => The tool used
  [[ -z $PIN_TOOL ]] || {
    echo "You must define a PIN_TOOL variable before using tf with PIN"
    exit 1
  }

  # PIN_FLAGS  => Flags to pass to PIN
  [[ -n $PIN_FLAGS ]] || PIN_FLAGS=" "

  echo "PIN_PATH is set to $PIN_PATH"
  echo "PIN_LIB is set to $PIN_LIB"
  echo "PIN_TOOL is set to $PIN_TOOL"
  
  echo "Compiling PIN TOOLS"
  PIN_ROOT=$PIN_PATH make -C $PIN_LIB || {
    echo "Error compiling PIN TOOLS"
    exit 1
  }
  
fi

# -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # --

# perf
[[ -n $OCPERF ]] || OCPERF=0

if [[ $OCPERF -eq 1 ]]; then
  #PERF EVENT
  [[ -n $PERF_TOOL ]] || PERF_TOOL="mem_uops_retired.all_loads" # mem-stores

  #USER OR KERNEL SPACE
  [[ -n $PERF_TYPE ]] || PERF_TYPE="u"

  #OUTPUT FILE
  [[ -n $PERF_FILE ]] || PERF_FILE="perf_${PERF_TOOL}_${PERF_TYPE}.out"
  
	PERF_BIN=""
	[[ -n $PERF_BIN ]] || {
		echo "One must define PERF_BIN when PERF=1"
		exit 1
	}
  
  echo "PERF_BIN is set to $PERF_BIN"
  echo "PERF_TOOL is set to $PERF_TOOL"
  echo "PERF_TYPE is set to $PERF_TYPE"
fi

# -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- 

BASEDIR="$(pwd)"

BENCHSDIR="$BASEDIR/Benchs/"

# -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- 

echo "#########################"
echo "DEBUG is set to $DEBUG"
echo "RUNTIME is set to $RUNTIME"
echo "CLEAN is set to $CLEAN"
echo "PIN is set to $PIN"
echo "EXEC is set to $EXEC"
echo "COMPILE is set to $COMPILE"
echo "INSTRUMENT is set to $INSTRUMENT"
echo "suffix is set to $suffix" # .so or .dylib
echo "BASEDIR is set to $BASEDIR"
echo "Benchmarks dir is set to $BENCHSDIR"
echo "PASS is set to $PASS"
echo "DIFF is set to $DIFF"
echo "#########################"
