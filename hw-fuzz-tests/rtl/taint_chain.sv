// RTL counterpart of the selector chain in ../test.cpp.
module taint_chain (
    input  logic [7:0] tagged_value,
    input  logic [7:0] index1, index2, index3, index4,
    output logic [7:0] result,
    // Keep each stage observable so Verilator retains its taint feedback store.
    output logic [7:0] first, second, third
);
    assign first  = index1 >= 20 ? "0" : index1 == 4  ? tagged_value : "1";
    assign second = index2 >= 20 ? "0" : index2 == 5  ? first        : "2";
    assign third  = index3 >= 20 ? "0" : index3 == 7  ? second       : "3";
    assign result = index4 >= 20 ? "0" : index4 == 11 ? third        : "4";
endmodule
