`timescale 1ns / 1ps

// 2-to-1 Fault-Tolerant Mux
module Mux (
    input  [31:0] a, b,
    input         s,
    output [31:0] c,
    output        error_detected
);
    wire [31:0] y1;   // Path 1: normal MUX (AND-OR)
    wire [31:0] y2;   // Path 2: De Morgan MUX (OR-AND-NOT)
    wire [31:0] err;

    // Path 1: Conventional logic
    assign y1 = (~{32{s}} & a) | ({32{s}} & b);

    // Path 2: De Morgan equivalent
    assign y2 = ~((a | {32{s}}) & (b | ~{32{s}}));

    // Fault detection and correction
    assign err = y1 ^ y2;
    assign error_detected = |err;
   assign c = (error_detected === 1'b1) ? y2 : y1;

endmodule

// 3-to-1 Fault-Tolerant Mux
module Mux_3_by_1 (
    input  [31:0] a, b, c,
    input  [1:0]  s,
    output [31:0] d,
    output        error_detected
);
    wire [31:0] y1, y2, err;

    // Path 1: Standard conditional
    assign y1 = (s == 2'b00) ? a :
                (s == 2'b01) ? b :
                (s == 2'b10) ? c : 32'h0;

    // Path 2: Boolean-expanded diverse structure
    assign y2 = (~{32{s[1]}} & ~{32{s[0]}} & a) |
                (~{32{s[1]}} &  {32{s[0]}} & b) |
                ( {32{s[1]}} & ~{32{s[0]}} & c);

    assign err = y1 ^ y2;
    assign error_detected = |err;
    assign d = (error_detected) ? y2 : y1;
endmodule