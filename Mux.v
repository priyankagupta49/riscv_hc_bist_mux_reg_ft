`timescale 1ns / 1ps

module Mux (
    input         clk,   // unused, ok for future pipelining
    input         rst,
    input  [31:0] a, b,
    input         s,
    output [31:0] c,
    output        error_detected
);

    wire [31:0] y1;   // Path 1
    wire [31:0] y2;   // Path 2 (diverse but equivalent)
    wire [31:0] err;

    // Path 1: Standard MUX
    assign y1 = (~{32{s}} & a) | ({32{s}} & b);

    // Path 2: De Morgan equivalent (NO inversion mismatch)
    assign y2 = ~((~(~{32{s}} & a)) & (~({32{s}} & b)));

    // Fault detection
    assign err = y1 ^ y2;
    assign error_detected = |err;

    // Fault correction
    assign c = error_detected ? y2 : y1;

endmodule

`timescale 1ns / 1ps

// 3-to-1 Fault-Tolerant Mux
module Mux_3_by_1 (
    input         clk,   // unused (reserved for future pipelining)
    input         rst,   // unused
    input  [31:0] a, b, c,
    input  [1:0]  s,
    output [31:0] d,
    output        error_detected
);

    wire [31:0] y1;
    wire [31:0] y2;
    wire [31:0] err;

    // --------------------------------------------------
    // Path 1: Reference MUX (golden behavior)
    // --------------------------------------------------
    assign y1 = (s == 2'b00) ? a :
                (s == 2'b01) ? b :
                (s == 2'b10) ? c :
                32'h00000000;

    // --------------------------------------------------
    // Path 2: Structurally diverse but equivalent logic
    // --------------------------------------------------
    assign y2 = (~{32{s[1]}} & ~{32{s[0]}} & a) |
                (~{32{s[1]}} &  {32{s[0]}} & b) |
                ( {32{s[1]}} & ~{32{s[0]}} & c);

    // --------------------------------------------------
    // Fault detection
    // --------------------------------------------------
    assign err = y1 ^ y2;
    assign error_detected = |err;

    // --------------------------------------------------
    // Fault correction
    // --------------------------------------------------
    assign d = error_detected ? y2 : y1;

endmodule
