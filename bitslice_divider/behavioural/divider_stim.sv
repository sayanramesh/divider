

module divider_stim;

timeunit 1ns;
timeprecision 10ps;

logic Clock;
logic nReset;
logic Req;
logic [7:0] Operand1;
logic [7:0] Operand2;
wire [7:0] Quotient;
wire [7:0] Remainder;
wire Done;

integer errors = 0;
integer test_num = 0;

divider instance1(
    .Quotient,
    .Remainder,
    .Done,
    .Operand1,
    .Operand2,
    .Req,
    .Clock,
    .nReset
    );


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
        $display("Test %0d : %0d / %0d  TimeOuT , Done never asserted.",
                  test_num, a, b);
    end
    else if (Quotient !== exp_q || Remainder !== exp_r) begin
        errors = errors + 1;
        $display("Test %0d : %0d / %0d FAIL  Q=%0d R=%0d (expected Q=%0d R=%0d) in %0d cycles",
                  test_num, a, b, Quotient, Remainder, exp_q, exp_r, cycles);
    end
    else begin
        $display("Test %0d : %0d / %0d PASS  Q=%0d R=%0d in %0d cycles",
                  test_num, a, b, Quotient, Remainder, cycles);
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
