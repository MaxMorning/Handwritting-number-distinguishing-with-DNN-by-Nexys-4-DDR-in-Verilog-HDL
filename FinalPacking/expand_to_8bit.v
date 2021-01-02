module expand_to_8bit(
    input wire [32 * 32 - 1:0] data_in,
    input wire [2:0] addr,
    output reg [128 * 8 - 1:0] data_out
);
    reg [7:0] i;
    always @ (*) begin
        for (i = 0; i <= 127; i = i + 1) begin
            data_out[8 * (addr * 128 + i) + 7 -:8] <= {data_in[addr * 128 + i], 7'b0000000};
        end
    end

endmodule