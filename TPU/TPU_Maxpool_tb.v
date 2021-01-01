`timescale 1ns / 1ps

module TPU_Maxpool_tb;
    reg [24 * 24 * 8 - 1:0] tensor_in;

    wire [12 * 12 * 8 - 1:0] tensor_out;

    maxpool inst(
        .tensor_in(tensor_in),
        .tensor_out(tensor_out)
    );
    initial begin
        tensor_in = {12{
                {12{8'b01010101, 8'b10101000}},
                {12{8'b01110101, 8'b00101000}}
            }
        };

        // exp 8'b01110101
    end
endmodule
