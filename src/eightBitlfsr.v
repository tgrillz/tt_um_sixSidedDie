`default_nettype none

module eightBitlfsr # (parameter BITNUM = 8)(
    input wire clk,
    input wire rst_n,
    input wire [7:0] seed,
    output wire [7:0] out
    );

    reg [BITNUM-1:0] state = 8'b1000_0001;
    reg [7:0] lfsrVal;
    reg [7:0] insideRoll;

    always @(posedge clk) begin     
        if(!rst_n) begin
            state <= seed;
        end else begin
            state <= seed;
            if (state == 8'b0000_0000) begin
                state <= 8'b1000_0001;
            end else begin
                // Create a "randomly" generated number using lfsr
                state <= {state[6:0], (state[0] ^ state[3] ^ state[7])};
            end

            lfsrVal <= {5'b00000, state[2:0]};   // isolates 3 LSB
            
            if (lfsrVal < 6) begin
                insideRoll <= lfsrVal + 1;      // number between 1 and 6
            end else begin
                insideRoll <= insideRoll;         // hold until next valid number 
            end

        end
    end        

    assign out = insideRoll;

endmodule
