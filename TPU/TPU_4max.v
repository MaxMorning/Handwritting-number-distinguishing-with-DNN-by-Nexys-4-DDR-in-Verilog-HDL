module max_in_4(
    input [2 * 2 * 8 - 1:0] data_in,

    output reg [7:0] data_max
);

    reg [1:0] cnt;
    always @ (*) begin
        data_max = data_in[7:0];

        for (cnt = 0; cnt < 3; cnt = cnt + 1) begin
            if (data_max == 8'b10000000 || data_in[cnt * 8 + 15 -: 8] == 8'b10000000)
                data_max = 8'b10000000;
            else if (data_max[7] ^ data_in[cnt * 8 + 15] == 1) begin
                if (data_max[7] == 1)
                    data_max = data_in[cnt * 8 + 15 -: 8];
                else 
                    data_max = data_max;
            end
            else if (data_in[cnt * 8 + 14 -: 7] > data_max[6:0]) begin
                if (data_max[7] == 0)
                    data_max = data_in[cnt * 8 + 15 -: 8];
            end
            else
                if (data_max[7] == 1)
                    data_max = data_in[cnt * 8 + 15 -: 8];
        end
    end
endmodule