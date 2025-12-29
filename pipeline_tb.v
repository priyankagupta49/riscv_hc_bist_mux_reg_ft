// `timescale 1ns / 1ps

// module tb;

//     // --------------------------------------------------
//     // Clock and Reset
//     // --------------------------------------------------
//     reg clk = 0;
//     reg rst = 0;

//     always #5 clk = ~clk;   // 100 MHz clock

//     // --------------------------------------------------
//     // Inputs
//     // --------------------------------------------------
//     reg [11:0] operand1, operand2;
//     reg [2:0]  opcode;
//     reg        test_en_in = 0;

//     // --------------------------------------------------
//     // Wires
//     // --------------------------------------------------
//     wire [31:0] imem_waddr, imem_wdata;
//     wire        imem_we;
//     wire        done_signal;

//     wire [31:0] result_w;
//     wire        s_err_imem, d_err_imem;
//     wire        s_err_dmem, d_err_dmem;
//     wire        alu_fault_active;
//     wire        mux_error_flag;

//     // --------------------------------------------------
//     // Internal TB control (MUST be module-level in Verilog)
//     // --------------------------------------------------
//     reg ecc_done;

//     // --------------------------------------------------
//     // Instruction Loader
//     // --------------------------------------------------
//     instr_loader loader (
//         .clk(clk),
//         .rst(rst),
//         .op1(operand1),
//         .op2(operand2),
//         .alu_op(opcode),
//         .imem_we(imem_we),
//         .imem_addr(imem_waddr),
//         .imem_wdata(imem_wdata),
//         .done(done_signal)
//     );

//     // --------------------------------------------------
//     // DUT
//     // --------------------------------------------------
//     Pipeline_top dut (
//         .clk(clk),
//         .rst(rst),
//         .imem_we(imem_we),
//         .imem_waddr(imem_waddr),
//         .imem_wdata(imem_wdata),
//         .loader_done_in(done_signal),
//         .test_en_in(test_en_in),
//         .ResultW_out(result_w),
//         .s_err_imem(s_err_imem),
//         .d_err_imem(d_err_imem),
//         .s_err_dmem(s_err_dmem),
//         .d_err_dmem(d_err_dmem),
//         .hardware_fault_flag(alu_fault_active),
//         .mux_error_flag(mux_error_flag)
//     );

//     // --------------------------------------------------
//     // ALU FAULT INJECTION (SAFE: CLOCKED FORCE)
//     // --------------------------------------------------
//     always @(posedge clk) begin
//         if (test_en_in)
//             force dut.execute.primary_alu.res_p[8] =
//                   ~dut.execute.primary_alu.res_p[8];
//         else
//             release dut.execute.primary_alu.res_p[8];
//     end

//     // --------------------------------------------------
//     // BIST RESULT LOGGER
//     // --------------------------------------------------
//     always @(posedge dut.execute.test_done) begin
//         #2;
//         $display("\n======================================");
//         $display("BIST FINISHED");
//         $display("FINAL MISR SIGNATURE : %h",
//                  dut.execute.alu_checker.signature);
//         $display("EXPECTED GOLDEN      : %h", 32'h81c6f051);

//         if (dut.execute.alu_checker.signature != 32'h81c6f051)
//             $display("RESULT: SUCCESS - FAULT DETECTED");
//         else
//             $display("RESULT: FAILURE - FAULT MISSED");

//         $display("======================================\n");
//     end

//     // --------------------------------------------------
//     // LIVE MONITOR
//     // --------------------------------------------------
//     initial begin
//         $monitor("T=%0t | BIST=%b | Fault=%b | LFSR=%h",
//                  $time,
//                  test_en_in,
//                  alu_fault_active,
//                  dut.execute.lfsr);
//     end

//     // --------------------------------------------------
//     // MAIN TEST SEQUENCE
//     // --------------------------------------------------
//     initial begin

//         // -----------------------------
//         // Reset & program load
//         // -----------------------------
//         rst = 0;
//         operand1 = 12'd5;
//         operand2 = 12'd3;
//         opcode   = 3'd0;

//         #20 rst = 1;

//         wait (done_signal == 1'b1);
//         $display("\n--- Program Loaded ---");

//         // -----------------------------
//         // Start ALU BIST
//         // -----------------------------
//         #100;
//         $display("Starting ALU BIST");
//         test_en_in = 1;

//         wait (dut.execute.test_done == 1'b1);
//         @(posedge clk);
//         test_en_in = 0;

//         // -----------------------------
//         // ECC TEST
//         // -----------------------------
//         #200;
//         wait (dut.execute.RegWriteM == 1'b1);

//         $display("\nInjecting single-bit error into Data Memory");
//         dut.memory.dmem.mem[1][30] =
//             ~dut.memory.dmem.mem[1][30];
//             // Force a dummy read to trigger ECC
// #20;
// force dut.memory.MemWriteM = 1'b0;
// force dut.memory.ALU_ResultM = 32'd4;  // address = word 1
// force dut.memory.ResultSrcM = 1'b1;    // select memory read

// @(posedge clk);
// release dut.memory.MemWriteM;
// release dut.memory.ALU_ResultM;
// release dut.memory.ResultSrcM;

          
 
       

//         ecc_done = 0;

//         fork
//             begin
//                 wait (s_err_dmem === 1'b1);
//                 if (!ecc_done) begin
//                     ecc_done = 1;
//                     $display("SUCCESS: ECC detected single-bit error");
//                 end
//             end
//             begin
//                 #1000;
//                 if (!ecc_done) begin
//                     ecc_done = 1;
//                     $display("ERROR: ECC timeout - no detection");
//                 end
//             end
//         join
//           $display("DEBUG: Simulation still running at time %0t", $time);

//         // -----------------------------
//         // Final result check
//         // -----------------------------
//         #50;
//         $display("\nFinal Result = %0d", result_w);

//         if (result_w == 32'd8)
//             $display("VERDICT: ALL SYSTEMS FUNCTIONAL");
//         else
//             $display("VERDICT: SYSTEM FAILURE");

//         // -----------------------------
//         // WRITEBACK MUX FAULT TEST
//         // -----------------------------
//         #1000;
//         $display("\nInjecting Writeback MUX fault");

//         force dut.writeBack.result_mux.y1 = ~dut.writeBack.result_mux.y1;
//         #50;

//         if (mux_error_flag)
//             $display("SUCCESS: MUX fault detected and masked");
//         else
//             $display("FAILURE: MUX fault not detected");

//         release dut.writeBack.result_mux.y1;
        
//                 #70;
//        // $display("\nFinal Result = %0d", result_w);

// //        if (result_w == 32'd8)
// //            $display("VERDICT: ALL SYSTEMS FUNCTIONAL");
// //        else
// //            $display("VERDICT: SYSTEM FAILURE");

//         #100;
//         $finish;
//     end

// endmodule






`timescale 1ns / 1ps

module tb;

    // --------------------------------------------------
    // Clock and Reset
    // --------------------------------------------------
    reg clk = 0;
    reg rst = 0;

    always #5 clk = ~clk;   // 100 MHz clock

    // --------------------------------------------------
    // Inputs
    // --------------------------------------------------
    reg [11:0] operand1, operand2;
    reg [2:0]  opcode;
    reg        test_en_in = 0;

    // --------------------------------------------------
    // Wires
    // --------------------------------------------------
    wire [31:0] imem_waddr, imem_wdata;
    wire        imem_we;
    wire        done_signal;

    wire [31:0] result_w;
    wire        s_err_imem, d_err_imem;
    wire        s_err_dmem, d_err_dmem;
    wire        alu_fault_active;
    wire        mux_error_flag;

    // --------------------------------------------------
    // Internal TB control (MUST be module-level in Verilog)
    // --------------------------------------------------
    reg ecc_done;

    // --------------------------------------------------
    // Instruction Loader
    // --------------------------------------------------
    instr_loader loader (
        .clk(clk),
        .rst(rst),
        .op1(operand1),
        .op2(operand2),
        .alu_op(opcode),
        .imem_we(imem_we),
        .imem_addr(imem_waddr),
        .imem_wdata(imem_wdata),
        .done(done_signal)
    );

    // --------------------------------------------------
    // DUT
    // --------------------------------------------------
    Pipeline_top dut (
        .clk(clk),
        .rst(rst),
        .imem_we(imem_we),
        .imem_waddr(imem_waddr),
        .imem_wdata(imem_wdata),
        .loader_done_in(done_signal),
        .test_en_in(test_en_in),
        .ResultW_out(result_w),
        .s_err_imem(s_err_imem),
        .d_err_imem(d_err_imem),
        .s_err_dmem(s_err_dmem),
        .d_err_dmem(d_err_dmem),
        .hardware_fault_flag(alu_fault_active),
        .mux_error_flag(mux_error_flag)
    );

    // --------------------------------------------------
    // ALU FAULT INJECTION (SAFE: CLOCKED FORCE)
    // --------------------------------------------------
    always @(posedge clk) begin
        if (test_en_in)
            force dut.execute.primary_alu.res_p[8] =
                  ~dut.execute.primary_alu.res_p[8];
        else
            release dut.execute.primary_alu.res_p[8];
    end

    // --------------------------------------------------
    // BIST RESULT LOGGER
    // --------------------------------------------------
    always @(posedge dut.execute.test_done) begin
        #2;
        $display("\n======================================");
        $display("BIST FINISHED");
        $display("FINAL MISR SIGNATURE : %h",
                 dut.execute.alu_checker.signature);
        $display("EXPECTED GOLDEN      : %h", 32'h81c6f051);

        if (dut.execute.alu_checker.signature != 32'h81c6f051)
            $display("RESULT: SUCCESS - FAULT DETECTED");
        else
            $display("RESULT: FAILURE - FAULT MISSED");

        $display("======================================\n");
    end

    // --------------------------------------------------
    // LIVE MONITOR
    // --------------------------------------------------
    initial begin
        $monitor("T=%0t | BIST=%b | Fault=%b | LFSR=%h",
                 $time,
                 test_en_in,
                 alu_fault_active,
                 dut.execute.lfsr);
    end

    // --------------------------------------------------
    // MAIN TEST SEQUENCE
    // --------------------------------------------------
    initial begin

        // -----------------------------
        // Reset & program load
        // -----------------------------
        rst = 0;
        operand1 = 12'd5;
        operand2 = 12'd3;
        opcode   = 3'd0;

        #20 rst = 1;

        wait (done_signal == 1'b1);
        $display("\n--- Program Loaded ---");

        // -----------------------------
        // Start ALU BIST
        // -----------------------------
        #100;
        $display("Starting ALU BIST");
        test_en_in = 1;

        wait (dut.execute.test_done == 1'b1);
        @(posedge clk);
        test_en_in = 0;

        // -----------------------------
        // ECC TEST
        // -----------------------------
        #200;
        wait (dut.execute.RegWriteM == 1'b1);

        $display("\nInjecting single-bit error into Data Memory");
        dut.memory.dmem.mem[1][30] =
            ~dut.memory.dmem.mem[1][30];
            // Force a dummy read to trigger ECC
            
                #70;
      //  $display("\nFinal Result = %0d", result_w);

//        if (result_w == 32'd8)
//            $display("VERDICT: ALL SYSTEMS FUNCTIONAL");
//        else
//            $display("VERDICT: SYSTEM FAILURE");
#20;
force dut.memory.MemWriteM = 1'b0;
force dut.memory.ALU_ResultM = 32'd4;  // address = word 1
force dut.memory.ResultSrcM = 1'b1;    // select memory read

@(posedge clk);
release dut.memory.MemWriteM;
release dut.memory.ALU_ResultM;
release dut.memory.ResultSrcM;

         
  
       

        ecc_done = 0;

        fork
            begin
                wait (s_err_dmem === 1'b1);
                if (!ecc_done) begin
                    ecc_done = 1;
                    $display("SUCCESS: ECC detected single-bit error");
                end
            end
            begin
                #1000;
                if (!ecc_done) begin
                    ecc_done = 1;
                    $display("ERROR: ECC timeout - no detection");
                end
            end
        join
          $display("DEBUG: Simulation still running at time %0t", $time);

        // -----------------------------
        // Final result check
        // -----------------------------
        #50;
//        $display("\nFinal Result = %0d", result_w);

//        if (result_w == 32'd8)
//            $display("VERDICT: ALL SYSTEMS FUNCTIONAL");
//        else
         //   $display("VERDICT: SYSTEM FAILURE");

        // -----------------------------
        // WRITEBACK MUX FAULT TEST
        // -----------------------------
        #1000;
        $display("\nInjecting Writeback MUX fault");

        force dut.writeBack.result_mux.y1 = ~dut.writeBack.result_mux.y1;
        #50;

        if (mux_error_flag)
            $display("SUCCESS: MUX fault detected and masked");
        else
            $display("FAILURE: MUX fault not detected");

        release dut.writeBack.result_mux.y1;
        
                #70;
      //  $display("\nFinal Result = %0d", result_w);

//        if (result_w == 32'd8)
//            $display("VERDICT: ALL SYSTEMS FUNCTIONAL");
//        else
//            $display("VERDICT: SYSTEM FAILURE");

        #100;
        $finish;
    end

endmodule

