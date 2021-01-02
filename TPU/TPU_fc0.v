module full_connect1024(
    input clk,
    input ena,
    input iRst_n,
    input [1023:0] a_bit,
    input [128 * 8 - 1:0] data_from_memory,
    input [14:0] result_from_MultAdd,
    input wire overflow_from_MultAdd,

    output reg [128 * 8 - 1:0] data1_to_MultAdd,
    output reg [128 * 8 - 1:0] data2_to_MultAdd,
    output reg [11:0] addr_to_memory,
    output reg [10 * 8 - 1:0] result,
    output reg done,
    output reg overflow
);

    parameter addr_base = 12'b010010001000;
    parameter b_addr_base = 12'b011011100000;

    wire [1024 * 8 - 1:0] a;
    genvar i;
    generate
        for (i = 0; i < 1024; i = i + 1) begin : A
            assign a[8 * i + 7:8 * i] = {a_bit[i], 7'b0000000};
        end
    endgenerate

    reg [7:0] cnt;
    reg [7:0] rowCnt;

    reg [3:0] status;
    reg [128 * 8 - 1:0] biases;

    reg [14:0] opr1;
    reg [14:0] opr2;

    wire [14:0] single_result;
    reg [14:0] total_result;
    wire overflow_from_adder;
    
    Float8Adder adder(
        .iNum1(opr1),
        .iNum2(opr2),

        oNum(single_result),
        .overflow(overflow_from_adder)
    );

    always @ (posedge clk) begin
        if (!ena) begin
            data1_to_MultAdd <= {(128 * 8){1'bz}};
            data2_to_MultAdd <= {(128 * 8){1'bz}};
            addr_to_memory <= {12{1'bz}};
            result <= {(128 * 8){1'bz}};
            done <= 1'bz;
            overflow <= 1'bz;
        end
        else if (!iRst_n) begin
            cnt = 7;
            rowCnt = 0;
            biases = 0;
            overflow = 0;
            done = 0;
            status = 4'b0000; // ask bias
            total_result <= 0;
        end
        else begin
            case (status)
                4'b0000: // ask bias
                    status <= 4'b0001;
                4'b0001: // get bias, rowCnt = 0
                    status <= 4'b0010;
                4'b0010: // cnt = 7
                    status <= 4'b0011;
                4'b0011: // ask w[cnt]
                    status <= 4'b0100;
                4'b0100: // get w[cnt], calc w[cnt]*a[cnt]
                    status <= 4'b0101;
                4'b0101: // get w[cnt]*a[cnt]
                    status <= 4'b0110;
                4'b0110: // add sum, dec cnt
                    status <= 4'b1011;
                4'b0111: // calc sum + bias
                    status <= 4'b1000;
                4'b1000: // get sum + bias, store result[rowCnt], inc rowCnt
                    status <= 4'b1001;
                4'b1001: // store complete
                    status <= 4'b1100;
                
                4'b1011: // jump by cnt
                    begin
                        if (cnt >= 0) begin
                            status <= 4'b0011;
                        end
                        else
                            status <= 4'b0111;
                    end
                4'b1100: // jump by rowCnt
                    begin
                        if (rowCnt < 128)
                            status <= 4'b0010;
                        else
                            status <= 4'b1010;
                    end
                4'b1010: // set done
                    status <= 4'b1010;

                default:
            endcase
        end
    end

    always @ (status) begin
        case (status)
            4'b0000: // ask bias
                begin
                    addr_to_memory <= b_addr_base;
                end
            4'b0001: // get bias, rowCnt = 0
                begin
                    biases <= data_from_memory;
                    rowCnt <= 0;
                end
            4'b0010: // cnt = 7
                begin
                    cnt <= 7;
                end
            4'b0011: // ask w[cnt]
                begin
                    addr_to_memory <= addr_base + cnt;
                end
            4'b0100: // get w[cnt], calc w[cnt]*a[cnt]
                begin
                    data1_to_MultAdd <= data_from_memory;
                    data2_to_MultAdd <= a[(128 * cnt + 127) * 8 + 7 -: 1024];
                end
            4'b0101: // get w[cnt]*a[cnt]
                begin
                    opr1 <= result_from_MultAdd;
                    opr2 <= total_result;
                end
            4'b0110: // add sum, dec cnt
                begin
                    total_result = single_result;
                    cnt = cnt - 1;
                end
            4'b0111: // calc sum + bias
                begin
                    opr1 <= total_result;
                    opr2 <= {biases[rowCnt * 8 + 7 -:8], 7'b0000000};
                end
            4'b1000: // get sum + bias, store result[rowCnt], inc rowCnt
            4'b1001: // store complete
            default:
    end
endmodule