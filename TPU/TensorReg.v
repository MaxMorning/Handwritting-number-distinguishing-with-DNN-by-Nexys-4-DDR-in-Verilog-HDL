module TensorReg( // tensor register , read data from it on negedge, send data to it on posedge
    input iClk,
    input ena, // high volt active , enable signal
    input wEna, // high volt active, write enable signal
    input [4:0] addrIn,
    input [255:0] dataIn,

    output reg [255:0] dataOut
);

    reg [255:0] memories [31:0];

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
            dataOut = {255{1'bz}};
    end
endmodule