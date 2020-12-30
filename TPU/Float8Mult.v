module Float8Mult(
    input [7:0] iNum1,
    input [7:0] iNum2,
    output reg [7:0] oNum,
    output reg overflow
    );
    
    reg [3:0] i;
    reg [9:0] result = 0;
    reg [9:0] temp;
    always @ ( * ) begin
        result = 0;
        oNum = 8'h00;
        if (|iNum1[6:0] == 1 && |iNum2[6:0] == 1) 
        begin
            overflow = 0;
            oNum[7] <= iNum1[7] ^ iNum2[7];
        
            temp = {1'b1, iNum1[3:0]};
            for (i = 0; i < 4; i = i + 1) begin
                if (iNum2[i] == 1'b1) result = result + temp;
                temp = temp << 1;
            end
            result = result + temp;
            if (result[9] == 1) begin
                if ({1'b1, iNum1[6:4]} - 3 > 4'b1111 - {1'b0, iNum2[6:4]}) overflow = 1;
                else if (3 > iNum1[6:4] + iNum2[6:4]) oNum = 8'h00;
                else oNum[6:0] = {iNum1[6:4] + iNum2[6:4] - 3,  result[8:5]};
            end
            else begin
                if ({1'b1, iNum1[6:4]} - 4 > 4'b1111 - {1'b0, iNum2[6:4]}) overflow = 1;
                else if (4 > iNum1[6:4] + iNum2[6:4]) oNum = 8'h00;
                else oNum[6:0] = {iNum1[6:4] + iNum2[6:4] - 4,  result[7:4]};
            end
        end
    end
endmodule
