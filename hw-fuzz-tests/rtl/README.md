# RTL taint-chain validation

This is an added RTL counterpart of the bundled C++ test in `../test.cpp`.
It validates this AFL fork and its modified LLVM sanitizer on a Verilator model.
It is a small integration example, not a reproduction of Phantom Trails' BOOM evaluation.

Build with `./build.sh` after installing the pinned modified LLVM/compiler-rt and instrumented libc++ under `/opt/hw_fuzzing_afl` and rebuilding this repository's AFL wrappers with that compiler.
`HWFUZZ_PREFIX`, `VERILATOR`, and `BUILD_JOBS` override those build settings.

The RTL implements the four indexed selections from the C++ example.
Each intermediate stage is exposed as an output so Verilator preserves its store for taint feedback.
The harness labels `tagged_value` and checks whether that label reaches the RTL output.
The input `abcdef` takes an unlabelled path and exits successfully.
The input `a457;a` propagates the label and triggers the example's deliberate assertion.
The initial seed `a4cdef` labels the first stage, giving AFL a nonempty taint map before it explores the remaining selectors.
Fuzz with `HWFUZZ_COVERAGE=Taint ../../afl-fuzz -g 6 -G 6 -i seeds -o output -- ./build/taint-chain @@`.
The fixed input length matches the six bytes consumed by the harness.

The unified image runs this example with `make run FUZZER=hw_fuzzing_afl DURATION=30` from the parent repository.
Its runner verifies the unlabelled and labelled replays, checks that three successive stages add taint feedback, and then checks executed inputs and the saved campaign bitmap.
The known assertion input is used only for validation and is not placed in the fuzzing corpus.
Coverage probes use `afl-showmap -r` because its default hit-count display discards raw taint labels such as `255`.
The parent Makefile supplies the custom seccomp profile required for the modified sanitizer's address-layout restart.

Report this added target separately from results on the authors' original processor artifact when comparing fuzzers.
