module max_in_10(
    input [10 * bit - 1:0] data_in,

    output reg [(bit - 1):0] data_max,
    output [3:0] oIndex
);

    reg [3:0] cnt;
    reg [3:0] index;
    assign oIndex = 9 - index;
    always @ (*) begin
        data_max = data_in[(bit - 1):0];
        index = 0;

        for (cnt = 0; cnt < 10; cnt = cnt + 1) begin
            if (data_max == {1'b1, {(bit - 1){1'b0}}}) begin
                data_max = {1'b1, {(bit - 1){1'b0}}};
            end
            else if (data_in[cnt * bit + (bit - 1) -: bit] == {1'b1, {(bit - 1){1'b0}}}) begin
                data_max = {1'b1, {(bit - 1){1'b0}}};
                index = cnt;
            end
            else if (data_max[(bit - 1)] ^ data_in[cnt * bit + (bit - 1)] == 1) begin
                if (data_max[(bit - 1)] == 1) begin
                    data_max = data_in[cnt * bit + (bit - 1) -: bit];
                    index = cnt;
                end
                else 
                    data_max = data_max;
            end
            else if (data_in[cnt * bit + (bit - 2) -: (bit - 1)] > data_max[(bit - 2):0]) begin
                if (data_max[(bit - 1)] == 0) begin
                    data_max = data_in[cnt * bit + (bit - 1) -: bit];
                    index = cnt;
                end
            end
            else
                if (data_max[(bit - 1)] == 1) begin
                    data_max = data_in[cnt * bit + (bit - 1) -: bit];
                    index = cnt;
                end
        end
    end
endmodule