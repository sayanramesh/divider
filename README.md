# 8-bit Bitslice Divider

An 8-bit unsigned divider built from a transistor-level bitslice datapath (Magic, TSMC 180nm) and a synthesizable SystemVerilog control unit. The design was taken through the full flow: layout, behavioural simulation, synthesis, place and route, extraction and post-layout verification.

Written for the ELEC6230 VLSI Systems Design coursework at the University of Southampton.

## What it does

The divider uses repeated subtraction:

```
R0  = 0
ACC = Operand1
R1  = Operand2
while (ACC >= R1) begin
    ACC = ACC - R1
    R0  = R0 + 1
end
Result1 = ACC   // remainder
Result0 = R0    // quotient
```

There is no dedicated divide circuit. One ripple-carry adder/subtractor does all the arithmetic:

- **F[0]** drives a row of XOR gates on the B operand. F[0]=0 passes B through (add), F[0]=1 inverts it (subtract).
- **CarryIn** supplies the "+1" that completes two's complement subtraction. With F[0]=0 and the second operand tied to zero, CarryIn=1 gives an increment, which is how R0 is counted up.
- **CarryOut** acts as a "not borrow" flag during subtraction. CarryOut=1 means ACC >= R1, so the loop continues. No separate comparator is needed.

## Architecture

| Block | Description |
|---|---|
| `bitslice.mag` | One bit of the datapath: ACC, R0, R1, Temp, Result0, Result1 registers, three-stage operand mux chain, XOR + full adder ALU, tristate Databus |
| `datapath.mag` | Eight bitslices joined by abutment (carry chain, buses and control lines form automatically at the cell edges) |
| `control.sv` | Mealy FSM generating all datapath control signals |
| `divider.sv` | Structural top level connecting control and datapath |

Interface of `divider`:

```systemverilog
input  [7:0] Operand1, Operand2,
input        Req,
input        Clock, nReset,
output [7:0] Quotient, Remainder,
output       Done
```

Pulse `Req` for one cycle with the operands valid. `Done` goes high for one cycle once `Quotient` and `Remainder` are stable.

### XOR from NAND

The cell library only included NAND2 and NAND3 from the optional gates, so there was no XOR2. The ALU's XOR is built inside the bitslice from four NAND2 gates:

```
n1 = NAND(A, B)
n2 = NAND(A, n1)
n3 = NAND(B, n1)
Y  = NAND(n2, n3)
```

### Control unit

A 10-state FSM: `IDLE`, `LOAD_ACC`, `LOAD_R1`, `CLR_R0`, `CHK_ZERO`, `COMPARE`, `INC_R0`, `LOAD_TEMP`, `COMMIT`, `DONE`.

Design points:

- State register and next-state logic are combined in a single `always_ff`.
- The state update uses a `#20` intra-assignment delay to model clock-to-Q delay. This keeps a behavioural control unit race-free when cross-simulated against the structural datapath.
- `LoadACC` in `COMPARE` is a Mealy output (`LoadACC = CarryOut`), so a valid subtraction is committed in the same cycle its result is known.
- `CHK_ZERO` computes `0 - R1` before the loop. If the divisor is zero the loop condition would never become false, so the FSM skips the loop and returns quotient 0 with remainder equal to the dividend.
- `Done` has its own state after `COMMIT`, so it only rises once the result registers have been loaded.

## Repository layout

```
behavioural/   control.sv, divider.sv, control_stim.sv, divider_stim.sv, divider.tcl
gate_level/    control.sv           (Genus synthesis output)
extracted/     bitslice, datapath and control .sv/.vnet (from Magic extraction)
bitslice.mag
datapath.mag
control.mag
```

Leaf cells live in a separate `cell_lib` directory and are not included here.

## Verification

Each level was checked with its own testbench.

- **Bitslice**: sequenced testbench covering register loads, 0+0 through the ALU, add, subtract with and without borrow, and increment.
- **Datapath**: reusable tasks for each micro-operation, composed into the full division loop with automatic pass/fail checking.
- **Control**: tested against a small behavioural ALU/register model, since its branching depends on CarryOut feedback.
- **Divider**: full integration testbench driven by `Req`/`Done`.

The same operand set was used at every level:

| Operand1 | Operand2 | Case | Quotient | Remainder |
|---|---|---|---|---|
| 10 | 3 | normal | 3 | 1 |
| 9 | 3 | exact division | 3 | 0 |
| 7 | 7 | equal operands | 1 | 0 |
| 3 | 7 | dividend < divisor | 0 | 3 |
| 0 | 5 | zero dividend | 0 | 0 |
| 255 | 1 | max value, longest loop | 255 | 0 |
| 200 | 7 | multiple iterations | 28 | 4 |
| 255 | 16 | large divisor | 15 | 15 |
| 5 | 0 | divide by zero | 0 | 5 |
| 100 | 9 | back to back | 11 | 1 |

Results were identical across the behavioural, gate-level (post-synthesis) and extracted (post-layout) control unit.

## Running the simulations

Requires Cadence Xcelium and the course environment. Commands are run from the project root.

Behavioural control:
```bash
xmverilog behavioural/divider_stim.sv behavioural/divider.sv \
    behavioural/control.sv extracted/datapath.sv +incdir+extracted \
    +access+r +gui
```

Gate-level control (needs the cell library models passed with `-v`):
```bash
xmverilog behavioural/divider_stim.sv behavioural/divider.sv \
    gate_level/control.sv -v fcdeCells.sv extracted/datapath.sv \
    +incdir+extracted +access+r +gui +xmtimescale+1ns/10ps
```

Extracted control: the placed-and-routed control exposes real `Test`, `SDI` and `SDO` scan ports, so tie `Test` and `SDI` to 0 and leave `SDO` open in the `control` instantiation.

## Flow

1. Bitslice and datapath layout in Magic, extraction with `ext2svmod`
2. Control unit written in SystemVerilog and verified behaviourally
3. Synthesis with Cadence Genus (`genus_custom`)
4. Place and route with `vlog2net -fcde`, then route and verify in Magic
5. Post-process, extract, regenerate netlist, re-run the same testbench


## Tools

Magic (TSMC 180nm), Cadence Xcelium / SimVision, Cadence Genus, `vlog2net`, `ext2svmod`.

## Author

Sayan Edathara Kuriyedath Ramesh, MSc Microelectronics and System Design, University of Southampton.
