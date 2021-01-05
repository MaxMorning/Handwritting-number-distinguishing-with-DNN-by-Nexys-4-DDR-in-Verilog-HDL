module max_in_10(
    input [10 * 16 - 1:0] data_in,

    output reg [15:0] data_max,
    output [3:0] oIndex
);

    reg [3:0] cnt;
    reg [3:0] index;
    assign oIndex = 9 - index;
    always @ (*) begin
        data_max = data_in[15:0];
        index = 0;

        for (cnt = 0; cnt < 10; cnt = cnt + 1) begin
            if (data_max == 16'b1000000000000000) begin
                data_max = 16'b1000000000000000;
            end
            else if (data_in[cnt * 16 + 15 -: 16] == 16'b1000000000000000) begin
                data_max = 16'b1000000000000000;
                index = cnt;
            end
            else if (data_max[15] ^ data_in[cnt * 16 + 15] == 1) begin
                if (data_max[15] == 1) begin
                    data_max = data_in[cnt * 16 + 15 -: 16];
                    index = cnt;
                end
                else 
                    data_max = data_max;
            end
            else if (data_in[cnt * 16 + 14 -: 15] > data_max[14:0]) begin
                if (data_max[15] == 0) begin
                    data_max = data_in[cnt * 16 + 15 -: 16];
                    index = cnt;
                end
            end
            else
                if (data_max[15] == 1) begin
                    data_max = data_in[cnt * 16 + 15 -: 16];
                    index = cnt;
                end
        end
    end
endmodule