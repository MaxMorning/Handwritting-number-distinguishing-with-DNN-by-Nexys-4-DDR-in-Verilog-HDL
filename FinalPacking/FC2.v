module full_connect2(
    input ena,
    input clk,
    input iRst_n,
    input [128 * 16 - 1:0] data_from_rom,
    input [128 * 16 - 1:0] data_from_ram,
    input [30:0] data_from_MultAdder,
    input overflow_from_MultAdder,
    
    output reg overflow,
    output reg done,
    output reg [10:0] addr_to_rom,
    output reg [128 * 16 - 1:0] opr1_to_MultAdder,
    output reg [128 * 16 - 1:0] opr2_to_MultAdder,
    output reg [10 * 16 - 1:0] data_to_ram
);

    parameter   rom_addr_base = 11'h401,
                bias_addr_base = 11'h40b;

    reg [7:0] rowCnt;
    reg [128 * 16 - 1:0] biases;
    reg [3:0] status;
    reg [30:0] sum;

    reg [30:0] adder_opr1;
    reg [30:0] adder_opr2;

    wire [30:0] adder_sum;
    wire adder_overflow;
    Float16Adder adder(
        .iNum1(adder_opr1),
        .iNum2(adder_opr2),

        .oNum(adder_sum),
        .overflow(adder_overflow)
    );

    always @ (posedge clk) begin
        if (!ena) begin
            overflow <= 1'bz;
            done <= 0;
            addr_to_rom <= {11{1'bz}};
            opr1_to_MultAdder <= {(128 * 16){1'bz}};
            opr2_to_MultAdder <= {(128 * 16){1'bz}};
        end
        else if (!iRst_n) begin
            overflow <= 0;
            done <= 0;
            rowCnt <= 0;
            status <= 4'b1010;
            sum <= 0;
        end
        else begin
            case (status)
                4'b1010: // ask bias
                    begin
                        status <= 4'b1011;
                        addr_to_rom <= bias_addr_base;
                    end
                4'b1011: // get bias
                    begin
                        status <= 4'b1000;
                        biases = data_from_rom;
                    end
                4'b1000: // r = 0
                    begin
                        status <= 4'b0000;
                        rowCnt <= 0;
                    end
                4'b0000: // ask w,a
                    begin
                        status <= 4'b0001;
                        addr_to_rom <= rom_addr_base + rowCnt;
                    end
                4'b0001: // get w,a ; calc wa
                    begin
                        status <= 4'b0010;
                        opr1_to_MultAdder <= data_from_ram;
                        opr2_to_MultAdder <= data_from_rom;
                    end
                4'b0010: // get wa ; calc wa + b
                    begin
                        status <= 4'b0011;
                        overflow <= overflow | overflow_from_MultAdder;
                        adder_opr1 = {biases[16 * rowCnt + 15 -: 16], 15'b000000000000000};
                        adder_opr2 <= data_from_MultAdder;
                    end
                4'b0011: // get wa + b ; ++r
                    begin
                        status <= 4'b0100;
                        overflow = overflow | adder_overflow;
                        data_to_ram[16 * rowCnt + 15 -: 16] = (adder_sum[30] == 0 || adder_sum[29:0] == 0) ? adder_sum[30:15] : 16'b0000000000000000; // relu
                        rowCnt = rowCnt + 1;
                        sum = 0;
                    end
                4'b0100: // r < 10 ?
                    begin
                        if (rowCnt < 10)
                            status <= 4'b0000;
                        else
                            status <= 4'b0101;
                    end
                4'b0101: // set done
                    begin
                        status <= 4'b0101;
                        done <= 1;
                    end
                default: 
                    status <= 4'b1010;
            endcase
        end
    end
endmodule