
module control(
    output logic Done,
    output logic F,
    output logic CarryIn,
    output logic LoadACC,
    output logic LoadR0,
    output logic LoadR1,
    output logic LoadT,
    output logic LoadR,
    output logic SelACC,
    output logic SelR1,
    output logic SelR,
    output logic EnableOp1,
    output logic EnableOp2,
    output logic EnableALU,
    input  logic Clock,
    input  logic nReset,
    input  logic Req,
    input  logic CarryOut
    );

timeunit 1ns;
timeprecision 10ps;


typedef enum logic [3:0] {
    IDLE,
    LOAD_ACC,
    LOAD_R1,
    CLR_R0,
    CHK_ZERO,
    COMPARE,
    INC_R0,
    LOAD_TEMP,
    COMMIT,
	DONE
} state_t;

state_t state;


always_ff @(posedge Clock, negedge nReset)
  if (!nReset)
    state <= IDLE;
  else
    case (state)
        IDLE: state <= #20 Req ? LOAD_ACC : IDLE;
        LOAD_ACC: state <= #20 LOAD_R1;
        LOAD_R1: state <= #20 CLR_R0;
        CLR_R0: state <= #20 CHK_ZERO;
        CHK_ZERO : state <= #20 CarryOut ? LOAD_TEMP : COMPARE;   // R1==0 - skip loop
        COMPARE: state <= #20 CarryOut ? INC_R0 : LOAD_TEMP;   // ACC>=R1 - loop again
        INC_R0: state <= #20 COMPARE;
        LOAD_TEMP: state <= #20 COMMIT;
        COMMIT: state <= #20 DONE;
		DONE : state <= #20 IDLE;
        default: state <= #20 IDLE;
    endcase
always_comb
  begin
    Done = 0;
    F  = 0;
    CarryIn = 0;
    LoadACC = 0;
    LoadR0  = 0;
    LoadR1 = 0;
    LoadT = 0;
    LoadR = 0;
    SelACC = 0;
    SelR1 = 0;
    SelR = 0;
    EnableOp1 = 0;
    EnableOp2 = 0;
    EnableALU = 0;

    case (state)
        LOAD_ACC: begin //to load accumulator the operand 1
            EnableOp1 = 1;
            LoadACC = 1;
        end
			
        LOAD_R1: begin //to load R1 operand2
            EnableOp2 = 1;
            LoadR1 = 1;
        end

        CLR_R0: begin // to clear R0
            EnableALU = 1;
            LoadR0 = 1;
        end

        CHK_ZERO: begin //to check the dvisor is zero , if carryout is present the divisor is zero
            SelR1 = 1;
            SelR  = 1;
            F = 1;
            CarryIn = 1;
            EnableALU = 1;
        end

        COMPARE: begin // subtract step , if carry out is present,then save the subtracted value in acc 
            SelACC = 1;
            SelR1 = 1;
            SelR = 1;
            F = 1;
            CarryIn = 1;
            EnableALU = 1;
            LoadACC = CarryOut;
        end

        INC_R0: begin // increment R0
            SelR = 1;
            CarryIn = 1;
            EnableALU = 1;
            LoadR0 = 1;
        end

        LOAD_TEMP: begin //load into temporary register
            SelACC = 1;
            EnableALU = 1;
            LoadT = 1;
        end

        COMMIT: begin // commit results
            SelR = 1;
            EnableALU = 1;
            LoadR = 1;
 
        end
		DONE : begin
			Done = 1; //donesignal
		end
        default: ;
    endcase
  end
endmodule
