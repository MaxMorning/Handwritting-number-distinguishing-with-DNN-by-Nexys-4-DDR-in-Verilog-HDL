module max_in_10(
    input [10 * 8 - 1:0] data_in,

    output reg [7:0] data_max,
    output [3:0] oIndex
);

    reg [3:0] cnt;
    reg [3:0] index;
    assign oIndex = 9 - index;
    always @ (*) begin
        data_max = data_in[7:0];
        index = 0;

        for (cnt = 0; cnt < 10; cnt = cnt + 1) begin
            if (data_max == 8'b10000000) begin
                data_max = 8'b10000000;
            end
            else if (data_in[cnt * 8 + 7 -: 8] == 8'b10000000) begin
                data_max = 8'b10000000;
                index = cnt;
            end
            else if (data_max[7] ^ data_in[cnt * 8 + 7] == 1) begin
                if (data_max[7] == 1) begin
                    data_max = data_in[cnt * 8 + 7 -: 8];
                    index = cnt;
                end
                else 
                    data_max = data_max;
            end
            else if (data_in[cnt * 8 + 6 -: 7] > data_max[6:0]) begin
                if (data_max[7] == 0) begin
                    data_max = data_in[cnt * 8 + 7 -: 8];
                    index = cnt;
                end
            end
            else
                if (data_max[7] == 1) begin
                    data_max = data_in[cnt * 8 + 7 -: 8];
                    index = cnt;
                end
        end
    end
endmodule