module writeback_cycle(
    input clk, rst, ResultSrcW,
    input [31:0] PCPlus4W, ALU_ResultW, ReadDataW,
    output [31:0] ResultW,
    output mux_error // NEW: Output to report Mux mismatch
);
    Mux result_mux (    
        .a(ALU_ResultW),
        .b(ReadDataW),
        .s(ResultSrcW),
        .c(ResultW),
        .error_detected(mux_error)
    );
endmodule