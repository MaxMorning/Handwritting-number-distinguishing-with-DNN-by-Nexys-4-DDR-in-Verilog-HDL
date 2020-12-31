module Float8Mult(
    input [7:0] iNum1,
    input [7:0] iNum2,
    output reg [7:0] oNum,
    output reg overflow
    );
    
    reg [3:0] i;
    reg [7:0] result = 0;
    reg [7:0] temp1;
    reg [7:0] temp2;
    always @ ( * ) begin
        result = 0;
        oNum = 8'h00;
        if (|iNum1[6:0] == 1 && |iNum2[6:0] == 1) 
        begin
            overflow = 0;
            oNum[7] <= iNum1[7] ^ iNum2[7];
        
            temp1 = {6'b000001, iNum1[2:0]};
            temp2 = {6'b000001, iNum2[2:0]};
            for (i = 0; i < 4; i = i + 1) begin
                if (temp2[i] == 1'b1) result = result + temp1;
                temp1 = temp1 << 1;
            end
            if (result[7] == 1) begin
                if ({1'b1, iNum1[6:3]} - 7 > 5'b11111 - {1'b0, iNum2[6:3]}) overflow = 1;
                else if (7 > iNum1[6:3] + iNum2[6:3]) oNum = 8'h00;
                else oNum[6:0] = {iNum1[6:3] + (iNum2[6:3] - 7),  result[6:4]};
            end
            else begin
                if ({1'b1, iNum1[6:3]} - 8 > 5'b11111 - {1'b0, iNum2[6:3]}) overflow = 1;
                else if (8 > iNum1[6:3] + iNum2[6:3]) oNum = 8'h00;
                else oNum[6:0] = {iNum1[6:3] + (iNum2[6:3] - 8),  result[5:3]};
            end
        end
    end
endmodule
