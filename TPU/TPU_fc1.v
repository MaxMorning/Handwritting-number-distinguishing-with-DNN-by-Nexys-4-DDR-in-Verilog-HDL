module full_connect256(
    input clk,
    input ena,
    input iRst_n,
    input [128 * 8 - 1:0] data_from_memory,
    input [14:0] result_from_MultAdd,
    input wire overflow_from_MultAdd,

    output reg [128 * 8 - 1:0] data1_to_MultAdd,
    output reg [128 * 8 - 1:0] data2_to_MultAdd,
    output reg [11:0] addr_to_memory,
    output reg [128 * 8 - 1:0] result,
    output reg done,
    output reg overflow
);

    parameter addr_base = 12'b010000000000;
    parameter a_addr_base = 12'b011000000000;
    parameter b_addr_base = 12'b011010000000;

    reg [7:0] cnt;
    reg [3:0] status;

    reg [128 * 8 - 1:0] biases;
    reg [128 * 8 - 1:0] a0;
    reg [128 * 8 - 1:0] a1;
    reg [14:0] w0a0;
    reg [14:0] w1a1;
    wire [14:0] w0a0PlusW1a1;
    reg [7:0] bias;
    wire [1:0] overflows;
    wire [14:0] single_result;

    Float8Adder adder(
        .iNum1(w0a0),
        .iNum2(w1a1),

        .oNum(w0a0PlusW1a1),
        .overflow(overflows[0])
    );

    Float8Adder adder2(
        .iNum1(w0a0PlusW1a1),
        .iNum2(bias),

        .oNum(single_result),
        .overflow(overflows[1])
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
            cnt = 0;
            biases = 0;
            overflow = 0;
            done = 1;
            status = 4'b0000; // ask a0
        end
        else begin
            case (status)
                4'b0000: // ask a0
                    status <= 4'b0001;
                
                4'b0001: // get a0, ask a1
                    status <= 4'b0010;

                4'b0010: // get a1, ask bias
                    status <= 4'b0011;

                4'b0011: // get bias
                    status <= 4'b0100;

                4'b0100: // ask w0
                    status <= 4'b0101;
                
                4'b0101: // get w0, ask w1, calc w0 * a0
                    status <= 4'b0110;

                4'b0110: // get w1, get w0a0, calc w1 * a1
                    status <= 4'b0111;
                
                4'b0111: // get a1w1, calc a0w0 + a1w1 + b
                    status <= 4'b1000;

                4'b1000: // get result, set result, inc cnt
                    status <= 4'b1001;

                4'b1001: // jump or return
                    begin
                        if (cnt < 128) begin
                            status <= 4'b0100;
                        end
                        else begin
                            done <= 1;
                        end
                    end
                default: 
                    status <= 3'b000;
            endcase
        end
    end

    always @ (status) begin
        case (status)
                4'b0000: // ask a0
                    begin
                        addr_to_memory <= a_addr_base;
                    end
                
                4'b0001: // get a0, ask a1
                    begin
                        a0 <= data_from_memory;
                        addr_to_memory <= a_addr_base + 1;
                    end

                4'b0010: // get a1, ask bias
                    begin
                        a1 <= data_from_memory;
                        addr_to_memory <= b_addr_base;
                    end

                4'b0011: // get bias
                    begin
                        biases <= data_from_memory;
                    end

                4'b0100: // ask w0
                    begin
                        addr_to_memory <= addr_base + 2 * cnt;
                    end
                
                4'b0101: // get w0, ask w1, calc w0 * a0
                    begin
                        data1_to_MultAdd <= data_from_memory;
                        data2_to_MultAdd <= a0;
                        addr_to_memory <= addr_base + 2 * cnt + 1;
                    end

                4'b0110: // get w1, get w0a0, calc w1 * a1
                    begin
                        w0a0 = result_from_MultAdd;
                        overflow = overflow | overflow_from_MultAdd;
                        data1_to_MultAdd <= data_from_memory;
                        data2_to_MultAdd <= a1;
                    end
                
                4'b0111: // get a1w1, calc a0w0 + a1w1 + b
                    begin
                        w1a1 = result_from_MultAdd;
                        overflow = overflow | overflow_from_MultAdd;
                    end

                4'b1000: // get result, set result, inc cnt
                    begin
                        result[8 * cnt + 7 -: 8] = single_result[14:7];
                        overflow = overflow | |overflows;
                        cnt = cnt + 1;
                    end

                default: // jump or return
                    begin
                        
                    end
            endcase
    end

endmodule