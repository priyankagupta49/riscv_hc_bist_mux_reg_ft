`timescale 1ns / 1ns

module Pipeline_top(
    input clk, rst, imem_we,
    input [31:0] imem_waddr, imem_wdata,
    input loader_done_in, test_en_in,
    output [31:0] ResultW_out,
    output s_err_imem, d_err_imem, s_err_dmem, d_err_dmem,
    output hardware_fault_flag, mux_error_flag
);
    // --- ECC Bus Wires (39-bit) ---
    wire [38:0] InstrD_ECC, PCD_ECC, PCPlus4D_ECC;
    wire [38:0] RD1_E_ECC, RD2_E_ECC, Imm_Ext_E_ECC, PCE_ECC, PCPlus4E_ECC;
    wire [38:0] ALU_ResultM_ECC, WriteDataM_ECC, PCPlus4M_ECC;
    wire [38:0] PCPlus4W_ECC, ALU_ResultW_ECC, ReadDataW_ECC;

    // --- Control Wires ---
    wire [31:0] PC_Next, ResultW;
    wire RegWriteW, ResultSrcW, PCSrcE;
    wire [4:0] RDW, RS1_D, RS2_D, RS1_E, RS2_E, RD_E, RD_M;
    wire [1:0] ForwardAE, ForwardBE;

    assign ResultW_out = ResultW;

    // --- 1. PC Selector (FT Mux) ---
    // Note: PC_Next is 32-bit as it feeds the Fetch PC_Module
    Mux PC_Selector (
        .clk(clk), .rst(rst),
        .a(32'h0), // Logic for PCPlus4D decoding would go here if needed
        .b(32'h0), // Logic for PCTargetE
        .s(PCSrcE),
        .c(PC_Next),
        .error_detected(err_pc_sel)
    );

    // --- 2. Fetch Stage ---
    fetch_cycle fetch (
        .clk(clk), .rst(rst), .PC_Next_In(PC_Next), .imem_we(imem_we),
        .imem_waddr(imem_waddr), .imem_wdata(imem_wdata), 
        .loader_done_in(loader_done_in),
        .s_err(s_err_imem), .d_err(d_err_imem),
        .InstrD_ECC(InstrD_ECC), .PCPlus4D_ECC(PCPlus4D_ECC), .PCD_ECC(PCD_ECC)
    );

    // --- 3. Decode Stage ---
    decode_cycle decode (
        .clk(clk), .rst(rst), 
        .InstrD_ECC(InstrD_ECC), .PCD_ECC(PCD_ECC), .PCPlus4D_ECC(PCPlus4D_ECC),
        .ResultW(ResultW), .RegWriteW(RegWriteW), .RDW(RDW),
        .RD1_E_ECC(RD1_E_ECC), .RD2_E_ECC(RD2_E_ECC), .Imm_Ext_E_ECC(Imm_Ext_E_ECC),
        .PCE_ECC(PCE_ECC), .PCPlus4E_ECC(PCPlus4E_ECC),
        .RS1_E(RS1_E), .RS2_E(RS2_E), .RD_E(RD_E), .RS1_D(RS1_D), .RS2_D(RS2_D),
        .RegWriteE(RegWriteE), .ALUSrcE(ALUSrcE), .MemWriteE(MemWriteE), 
        .ResultSrcE(ResultSrcE), .BranchE(BranchE), .ALUControlE(ALUControlE)
    );

    // --- 4. Execute Stage ---
    execute_cycle execute (
        .clk(clk), .rst(rst),
        .RD1_E_ECC(RD1_E_ECC), .RD2_E_ECC(RD2_E_ECC), .Imm_Ext_E_ECC(Imm_Ext_E_ECC),
        .PCE_ECC(PCE_ECC), .PCPlus4E_ECC(PCPlus4E_ECC),
        .RegWriteE(RegWriteE), .ALUSrcE(ALUSrcE), .MemWriteE(MemWriteE),
        .ResultSrcE(ResultSrcE), .BranchE(BranchE), .ALUControlE(ALUControlE),
        .RD_E(RD_E), .ResultW(ResultW), .ForwardA_E(ForwardAE), .ForwardB_E(ForwardBE),
        .ALU_ResultM_In(ResultW_out), // Used for forwarding
        .test_en_in(test_en_in),
        .PCSrcE(PCSrcE), .RegWriteM(RegWriteM), .MemWriteM(MemWriteM), 
        .ResultSrcM(ResultSrcM), .RD_M(RD_M),
        .ALU_ResultM_ECC(ALU_ResultM_ECC), .WriteDataM_ECC(WriteDataM_ECC), 
        .PCPlus4M_ECC(PCPlus4M_ECC), .PCTargetE(PCTargetE),
        .hardware_fault_flag(hardware_fault_flag)
    );

    // --- 5. Memory Stage ---
    memory_cycle memory (
        .clk(clk), .rst(rst),
        .RegWriteM(RegWriteM), .MemWriteM(MemWriteM), .ResultSrcM(ResultSrcM),
        .RD_M(RD_M), .PCPlus4M_ECC(PCPlus4M_ECC), .WriteDataM_ECC(WriteDataM_ECC), 
        .ALU_ResultM_ECC(ALU_ResultM_ECC),
        .s_err(s_err_dmem), .d_err(d_err_dmem),
        .RegWriteW(RegWriteW), .ResultSrcW(ResultSrcW), .RD_W(RDW),
        .PCPlus4W_ECC(PCPlus4W_ECC), .ALU_ResultW_ECC(ALU_ResultW_ECC), 
        .ReadDataW_ECC(ReadDataW_ECC)
    );

    // --- 6. Write Back Stage ---
    writeback_cycle writeBack (
        .clk(clk), .rst(rst), .ResultSrcW(ResultSrcW),
        .PCPlus4W_ECC(PCPlus4W_ECC), .ALU_ResultW_ECC(ALU_ResultW_ECC), 
        .ReadDataW_ECC(ReadDataW_ECC),
        .ResultW(ResultW), .mux_error(mux_error_flag)
    );

    // --- 7. Hazard Unit ---
    hazard_unit Forwarding_Block (
        .rst(rst), .RegWriteM(RegWriteM), .RegWriteW(RegWriteW),
        .ResultSrcM(ResultSrcM), .RD_M(RD_M), .RD_W(RDW),
        .Rs1_E(RS1_E), .Rs2_E(RS2_E), .Rs1_D(RS1_D), .Rs2_D(RS2_D),
        .ForwardAE(ForwardAE), .ForwardBE(ForwardBE)
    );

endmodule