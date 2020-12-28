module mouse_control(
    input iRst_n,
    inout clkBus,
    inout dataBus,
    output reg [15:0] oLights
);

    reg [10:0] data;
    reg [3:0] cnt;
    reg [1:0] byteCnt;
    reg clkBusSendEna;
    reg dataBusSendEna;

    reg clkSendBit;
    wire clkReceiveBit;
    assign clkBus = clkBusSendEna ? clkSendBit : 1'bz;
    assign clkReceiveBit = clkBus;

    reg dataSendBit;
    wire dataReceiveBit;
    reg [3:0] cursorPos;
    reg eccError;
    assign dataBus = dataBusSendEna ? dataSendBit : 1'bz;
    assign dataReceiveBit = dataBus;

    reg ecc;
    always @ (negedge clkBus or negedge iRst_n or posedge eccError) begin
        if (!iRst_n) begin
            ecc <= 1'b0;
            cnt <= 10;
            byteCnt <= 0;
            clkBusSendEna <= 0;
            dataBusSendEna <= 0;
            oLights <= 16'b0000000001000000;
            cursorPos <= 6;
            eccError <= 0;
        end
        else if (eccError) begin
            
        end
        else begin
            data[cnt] <= dataBus;
            ecc = dataBus ? ~ecc : ecc;
            if (cnt == 0) begin // receive 11 bit
                cnt <= 10;

                // check valid
                if (!ecc) begin
                    // error, communicate with slave
                    clkBusSendEna <= 1'b1;
                    dataSendBit <= 1'b0;
                    eccError <= 1'b1;
                end
                else begin
                    // correct , process
                    case (byteCnt)
                        0: // first byte
                            begin
                                oLights[15] <= data[9];
                                oLights[14] <= data[8];
                                byteCnt <= 1;
                            end
                        1: // x shift
                            begin
                                byteCnt <= 2;
                                if (data[9] == 0)
                                    cursorPos <= cursorPos + data[8:7];
                                else
                                    cursorPos <= cursorPos - data[8:7];
                                oLights[13:0] = 14'b0;
                                oLights[cursorPos] = 1'b1;
                            end
                        2: // y shift
                            begin
                                byteCnt <= 0;
                            end
                        default:
                            begin
                                byteCnt <= 0;
                            end
                    endcase
                end
            end
            else 
                cnt <= cnt - 1;
        end
    end
endmodule