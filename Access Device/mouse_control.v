module ps2mouse(
    input ena,
    input iRst_n,
    input sysClk,
    inout ps2clk,
    inout ps2data,
    output reg [9:0] oHPos,
    output reg [9:0] oVPos
)

    reg status;
    reg hostClkOut;
    reg hostDataOut;
    reg hostDataBit;
    reg hostDataRec;
    wire initial_done;

    reg hostClkBit;
    reg hostClkRec;
    assign ps2clk = hostClkOut ? hostClkBit : 1'bz;
    always @ (hostClkOut)
        if (hostClkOut == 0)
            hostClkRec <= ps2clk;

    
    assign ps2data = hostDataOut ? hostDataBit : 1'bz;
    always @ (hostDataOut)
        if (hostDataOut == 0)
            hostDataRec <= ps2data;

    mouse2host mouse_inst(
        .ena(initial_done),
        .iRst_n(iRst_n),
        .clkBus(hostClkRec)
        .dataBus(hostDataRec),
        .oHPos(oHPos),
        .oVPos(oVPos)
    );

    host2mouse host_inst(
        .iRst_n(iRst_n),
        .sysClk(sysClk),
        .sendData(8'b11101010)
        .ps2clk(ps2clk),
        .ps2data(ps2data),
        .oAsk(initial_done)
    );
    always @ (posedge sysClk) begin
        if (ena) begin
            if (~iRst_n) begin
                status <= 0;
            end
            else if (status == 0 && initial_done == 1)
                status <= 1;
        end
    end

endmodule


// mouse send to host
module mouse2host(
    input ena,
    input iRst_n,
    input clkBus,
    input dataBus,
    output reg eccError,
    output reg [9:0] oHPos,
    output reg [9:0] oVPos
);

    reg [10:0] data;
    reg [3:0] cnt;
    reg [1:0] byteCnt;


    reg ecc;
    always @ (negedge clkBus or posedge eccError) begin
        if (ena == 0) begin
            ecc <= 1'b0;
            cnt <= 10;
            byteCnt <= 0;
            eccError <= 0;
            oHPos <= 511;
            oVPos <= 511;
        end
        else begin
            if (!iRst_n) begin
                ecc <= 1'b0;
                cnt <= 10;
                byteCnt <= 0;
                eccError <= 0;
                oHPos <= 511;
                oVPos <= 511;            
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
                                    // oLights[15] <= data[9];
                                    // oLights[14] <= data[8];
                                    byteCnt <= 1;
                                end
                            1: // x shift
                                begin
                                    byteCnt <= 2;
                                    if (data[9] == 0)
                                        oHPos <= oHPos + data[8:2];
                                    else
                                        begin
                                            data <= ~(data + 1);
                                            oHPos <= oHPos - data[8:2];
                                        end
                                        
                                end
                            2: // y shift
                                begin
                                    byteCnt <= 0;
                                    if (data[9] == 0)
                                        oVPos <= oVPos + data[8:2];
                                    else
                                        begin
                                            data <= ~(data + 1);
                                            oVPos <= oVPos - data[8:2];
                                        end
                                end
                            default :
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
    end
endmodule

//host send to mouse
module host2mouse(
    input iRst_n,
    input sysClk, // 15KHz
    input [7:0] sendData, // data to be sent
    inout ps2clk,
    inout ps2data,
    output reg oAsk
);

    reg ecc;
    reg hostClkOut;
    reg [3:0] byteCnt;

    reg hostClkBit;
    reg hostClkRec;
    assign ps2clk = hostClkOut ? hostClkBit : 1'bz;
    always @ (hostClkOut)
        if (hostClkOut == 0)
            hostClkRec <= ps2clk;

    reg hostDataOut;
    reg hostDataBit;
    reg hostDataRec;
    reg sendDone;
    reg [3:0] receiveByteCnt;
    reg [7:0] receiveData;
    assign ps2data = hostDataOut ? hostDataBit : 1'bz;
    always @ (hostDataOut)
        if (hostDataOut == 0)
            hostDataRec <= ps2data;

    reg [1:0] timeCnt;
    always @ (posedge sysClk) begin
        if (~oAsk) begin
            if (!iRst_n) begin
                oAsk <= 0;
                hostClkOut <= 1;
                hostClkBit <= 0;
                hostDataOut <= 1;
                hostDataBit <= 0;
                timeCnt <= 0;
                ecc <= 0;
            end
            else if (timeCnt == 2'b11) begin
                // hostDataBit = 1;
                hostClkBit = 1;
                hostClkOut = 0;
            end
            else
                timeCnt <= timeCnt + 1;
        end
        else begin
            oAsk <= 0;
            hostClkOut <= 1;
            hostClkBit <= 0;
            hostDataOut <= 1;
            hostDataBit <= 0;
            timeCnt <= 0;
            ecc <= 0;
        end
    end

    always @ (negedge hostClkOut or posedge hostClkRec) begin
        if (~oAsk) begin
            if (!iRst_n) begin
                byteCnt <= 0;
                sendDone <= 0;
            end
            else if (byteCnt == 11) begin
                byteCnt <= 0;
                sendDone <= 1;
                hostDataOut <= 0;
            end
            else begin
                if (byteCnt == 0)
                    hostDataBit <= 0;
                else if (byteCnt == 9)
                    hostDataBit <= ~ecc;
                else if (byteCnt == 10)
                    hostDataBit <= 1;
                else begin
                    hostDataBit <= sendData[byteCnt - 1]
                    ecc <= sendData[byteCnt - 1] ? ~ecc : ecc;
                end
                byteCnt = byteCnt + 1;

            end
        end
        else begin
            byteCnt <= 0;
            sendDone <= 0;
        end
    end

    always @ (posedge sendDone or negedge hostClkRec) begin
        if (~oAsk) begin
            if (sendDone) begin
            receiveData[receiveByteCnt] = hostDataRec;
            receiveByteCnt = receiveByteCnt + 1;
        end
        else
            receiveByteCnt <= 0;
        
        if (receiveByteCnt == 11 && receiveData = 11'b01111101011) begin
            oAsk <= 1;
        end
        else 
            oAsk <= 0;
        end
        else
            oAsk <= 0;
        
    end
endmodule