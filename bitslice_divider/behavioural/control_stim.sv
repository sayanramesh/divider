
module control_stim;

timeunit 1ns;
timeprecision 10ps;

logic Clock;
logic nReset;
logic Req;
logic [7:0] Operand1;
logic [7:0] Operand2;
logic Done;
logic [0:0] F;
logic CarryIn;
logic LoadACC;
logic LoadR0;
logic LoadR1;
logic LoadT;
logic LoadR;
logic SelACC;
logic SelR1;
logic SelR;
logic EnableOp1;
logic EnableOp2;
logic EnableALU;

logic [7:0] ACC, R0, R1, Temp, Result0, Result1;
logic  CarryOut;


integer errors   = 0;
integer test_num = 0;
control instance1(
    .Done,
    .F,
    .CarryIn,
    .LoadACC,
    .LoadR0,
    .LoadR1,
    .LoadT,
    .LoadR,
    .SelACC,
    .SelR1,
    .SelR,
    .EnableOp1,
    .EnableOp2,
    .EnableALU,
    .Clock,
    .nReset,
    .Req,
    .CarryOut
    );

logic [7:0] alu_a, r_sel, alu_b, alu_b_xor;
logic [8:0] alu_result;
wire  [7:0] Databus;

assign alu_a = SelACC ? ACC : 8'h00; // SelACC mux
assign r_sel = SelR1 ? R1 : R0; // SelR1 mux
assign alu_b = SelR ? r_sel : 8'h00; // SelR mux
assign alu_b_xor = alu_b ^ {8{F[0]}}; // 8 XOR gates (F[0] inverts B)
assign alu_result = alu_a + alu_b_xor + CarryIn; // 8 full adders, ripple carry
assign CarryOut = alu_result[8];
assign Databus = EnableOp1 ? Operand1 : //tristate Databus
                 EnableOp2 ? Operand2 :
                 EnableALU ? alu_result[7:0] : 8'hzz;
always_ff @(posedge Clock, negedge nReset)
  begin
    if (!nReset) begin
        ACC <= 8'h00;
        R0   <= 8'h00;
        R1 <= 8'h00;
        Temp <= 8'h00;
        Result0 <= 8'h00;
        Result1 <= 8'h00;
    end
    else begin
        if (LoadACC) ACC <= Databus;
        if (LoadR0)  R0 <= Databus;
        if (LoadR1) R1 <= Databus;
        if (LoadT) Temp <= Databus;
        if (LoadR) begin
            Result0 <= Databus;   // quotient
            Result1 <= Temp; // remainder 
        end
    end
  end
initial begin
    Clock = 0;
    forever #500 Clock = ~Clock;
end
task automatic run_division(input [7:0] a, input [7:0] b,
          input [7:0] exp_q, input [7:0] exp_r
                          );
    integer cycles;
begin
    test_num = test_num + 1;
    Operand1 = a;
    Operand2 = b;

    @(negedge Clock);
    Req = 1'b1;
    @(negedge Clock);
    Req = 1'b0;
    cycles = 0;
    while (Done !== 1'b1 && cycles < 5000) begin
        @(negedge Clock);
        cycles = cycles + 1;
    end
    @(negedge Clock);

    if (cycles >= 5000) begin
        errors = errors + 1;
        $display("Test %0d : %0d / %0d TIMEOUT, Done never asserted ",
                  test_num, a, b);
    end
    else if (Result0 !== exp_q || Result1 !== exp_r) begin
        errors = errors + 1;
        $display("Test %0d : %0d / %0d  FAIL  Q=%0d R=%0d (expected Q=%0d R=%0d) in %0d cycles",
                  test_num , a, b, Result0, Result1, exp_q, exp_r, cycles);
    end
    else begin
        $display("Test %0d : %0d / %0d  PASS  Q=%0d R=%0d in %0d cycles",
                  test_num, a, b, Result0, Result1, cycles);
    end
    @(negedge Clock);
    @(negedge Clock);
end
endtask
initial begin
    Req      = 0;
    Operand1 = 0;
    Operand2 = 0;
    nReset   = 0;
    #1000 nReset = 1;
    #1000;

    run_division(8'd10,  8'd3, 8'd3, 8'd1);
    run_division(8'd9,   8'd3, 8'd3, 8'd0);
    run_division(8'd7, 8'd7, 8'd1, 8'd0);
    run_division(8'd3, 8'd7, 8'd0, 8'd3);
    run_division(8'd0, 8'd5, 8'd0, 8'd0);
    run_division(8'd255, 8'd1, 8'd255, 8'd0);
    run_division(8'd200, 8'd7, 8'd28, 8'd4);
    run_division(8'd255, 8'd16, 8'd15, 8'd15);
    run_division(8'd5, 8'd0, 8'd0, 8'd5);
    run_division(8'd100, 8'd9, 8'd11, 8'd1);

    if (errors == 0)
        $display("ALL %0d TESTS PASSED", test_num);
    else
        $display("%0d OF %0d TESTS FAILED", errors, test_num);
    #1000;
    $stop;
    $finish;
end
endmodule
