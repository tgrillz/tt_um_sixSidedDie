/*
 * Copyright (c) 2025 tgrillz
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_tgrillz_sixSidedDie #(parameter STATE = 8'b1000_0001)(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path 
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // ^ this is enables this IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // All output pins must be assigned. If not used, assign to 0.
    // assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
    assign uio_out = 0;
    assign uio_oe  = 0;
    assign uo_out[7] = 1'b0;

    // List all unused inputs to prevent warnings
    // wire _unused = &{ena, clk, rst_n, 1'b0};
    wire _unused = &{ena, uio_in, ui_in[7:1], 1'b0};
  
    reg [7:0] roll;
    reg [7:0] thisRoll;
    reg [7:0] outRoll;
    reg lastReset;
    reg [6:0] outNum;
    
    // Creats a "randomly" generated number using lfsr
    // Note this will always turn on to 0 if the dip switch is set to on at start up
    // A reset or a reset of the dipswitch is needed to adjust
    // Assumes an explicit reset at initilization
    
    eightBitlfsr lfsr(.clk(clk), .rst_n(rst_n), .seed(STATE), .out(thisRoll));

    always @(posedge clk) begin  

        if (!rst_n) begin    
            roll <= 8'b0000_0000;
            outRoll <= 8'b0000_0000;
            lastReset <= 1'b1;

        end else begin

            // if "on"
            if (ui_in[0]) begin
                // if new roll after reset get new number
                if (!lastReset) begin
                    roll <= thisRoll;
                // otherwise hold number until next roll
                end else begin
                    roll <= roll;
                end

            // if "off" keep cycling through numbers                
            end else begin
                roll <= thisRoll;
            end

            // update tracker of last reset value
            if (outNum == 7'b0000000)
                lastReset <= 1'b0;
            else
                lastReset <= rst_n;
        end

        // Outputs 0 if in "off" state
        if (ui_in[0]) begin
            outRoll <= roll;
        end else begin
            outRoll <= 0;
        end

    end

    // Output number to 7 segment display
    sevenSeg sevenSegment(.clk(clk), .rst_n(rst_n), .inputNum(outRoll), .out(outNum));

    // Assign 7 segment bits to LSB of outwire
    assign uo_out[6:0] = outNum;

endmodule