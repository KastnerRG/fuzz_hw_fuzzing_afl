#include "Vtaint_chain.h"
#include "verilated.h"
#include <tainting.h>
#include <cstdio>
#include <cstdlib>

int main(int argc, char **argv) {
    if (argc != 2) return 2;
    FILE *input = std::fopen(argv[1], "rb");
    if (!input) return 2;
    unsigned char bytes[6] = {};
    const auto size = std::fread(bytes, 1, sizeof(bytes), input);
    std::fclose(input);
    if (size < sizeof(bytes)) return 0;

    VerilatedContext context;
    context.threads(1);
    Vtaint_chain dut{&context};
    dut.tagged_value = '1';
    dut.index1 = bytes[1] - '0';
    dut.index2 = bytes[2] - '0';
    dut.index3 = bytes[3] - '0';
    dut.index4 = bytes[4] - '0';
    Tainting::taintPtr(&dut.tagged_value, sizeof(dut.tagged_value));
    dut.eval();
    const bool tagged = Tainting::check(&dut.result, sizeof(dut.result));
    std::fprintf(stderr, "RTL result=%u tagged=%d\n", dut.result, tagged);
    dut.final();
    // The same deliberately reachable assertion as the original C++ example.
    if (tagged) std::abort();
    return 0;
}
