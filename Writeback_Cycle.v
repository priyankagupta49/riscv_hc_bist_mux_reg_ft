`timescale 1ns / 1ps

module writeback_cycle(
    input clk, rst, ResultSrcW,
    input [38:0] PCPlus4W_ECC, ALU_ResultW_ECC, ReadDataW_ECC,
    output [31:0] ResultW,
    output mux_error
);
    wire [31:0] PCPlus4W, ALU_ResultW, ReadDataW;

    // --- 1. ECC Decoders: Final Correction ---
    hamming_ecc_unit dec_alu (.data_in(32'b0), .code_in(ALU_ResultW_ECC), .data_out(ALU_ResultW));
    hamming_ecc_unit dec_rd  (.data_in(32'b0), .code_in(ReadDataW_ECC),  .data_out(ReadDataW));
    hamming_ecc_unit dec_pc4 (.data_in(32'b0), .code_in(PCPlus4W_ECC),   .data_out(PCPlus4W));

    // --- 2. Fault Tolerant Result Selection ---
    Mux result_mux (     
        .clk(clk), .rst(rst),
        .a(ALU_ResultW),
        .b(ReadDataW),
        .s(ResultSrcW),
        .c(ResultW),
        .error_detected(mux_error)
    );
endmodule