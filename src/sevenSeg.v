`default_nettype none

module sevenSeg (
    input wire clk,
    input wire rst_n,
    input wire [7:0] inputNum,
    output wire [6:0] out
    );

    reg [7:0] displayIt;
    reg [6:0] outNum;

    always @(posedge clk) begin
        if (!rst_n) begin
            displayIt <= 0;
        end else begin
            displayIt <= inputNum;
        end
    end

    always @(*) begin
       // Output number to 7 segment display
        case(displayIt)
            0:  outNum = 7'b0111111;
            1:  outNum = 7'b0000110;
            2:  outNum = 7'b1011011;
            3:  outNum = 7'b1001111;
            4:  outNum = 7'b1100110;
            5:  outNum = 7'b1101101;
            6:  outNum = 7'b1111100;
            7:  outNum = 7'b0000111;
            8:  outNum = 7'b1111111;
            9:  outNum = 7'b1100111;
            default:
                outNum = 7'b0000000;
        endcase
    end

    assign out = outNum;
endmodule