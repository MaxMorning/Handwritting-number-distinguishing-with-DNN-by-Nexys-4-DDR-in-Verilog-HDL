module TensorReg( // tensor register , read data from it on negedge, send data to it on posedge
    input iClk,
    input ena, // high volt active , enable signal
    input wEna, // high volt active, write enable signal
    input [4:0] addrIn,
    input [63:0] dataIn,

    output reg [63:0] dataOut
);

    reg [63:0] memories [63:0];

    always @ (posedge iClk) begin
        if (ena) begin // active
            if (wEna) begin
                dataOut = memories[addrIn];
            end
            else begin
                memories[addrIn] = dataIn;
            end
        end
        else
            dataOut = {64{1'bz}};
    end
endmodule