module TPU_Adder(
    input [32 * 8 - 1:0] data_in1,
    input [32 * 8 - 1:0] data_in2,

    output [32 * 8 - 1:0] data_out,
    output overflow
);
    wire [31:0] overflows;
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin
            Float8Adder inst(
                .iNum1(data_in1[8 * i + 7: 8 * i]),
                .iNum2(data_in2[8 * i + 7: 8 * i]),
                .oNum(data_out[8 * i + 7: 8 * i]),
                .overflow(overflows[i])
            );
        end
    endgenerate
    
    assign overflow = | overflows;
endmodule