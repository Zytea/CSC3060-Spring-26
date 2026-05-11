# 4.2: Control

![](assets%5CCA3060-4-2-Control_0.png)

## ==High Level Control Signal Expressions==

`PCSrc` = ((Branch or JAL) ? 1: 0)

`RegWr` = ( (Branch or Store)? 0: 1)

`MemRd`= (Load ? 1:0)

`MemWr`= (Store ? 1:0)

`ALUSrc` = (R-type? 0:1)

`WBsel` = (Load: 0 | R-type : 1 | JAL : 2)

HDL (Hardware Description Languages), such as Verilog and VHDL, can be used to specify the control signals. HDL codes are hardware-synthesizable. Feed them into a design compiler (Synopsys and Cadence tools) to get a **netlist** (a graphical logic representation).

## ALU Control

ALU Control signal depends on **a) operation type (ALUop) and b) funct3 and funct7 bits**

```verilog
always_comb begin
  case (alu_op)
    2'b00 : alu_control = ALU_ADD;
    2'b01 : alu_control = ALU_SUB;
    2'b10 : begin // 算术逻辑指令
      case (funct3)
        3'b000 : begin
          if (funct7_bit5) alu_control = ALU_SUB;
          else alu_control = ALU_ADD;
        end
        3'b001 : alu_control = ALU_SLL; // SLL / SLLI
        3'b010 : alu_control = ALU_SLT; // SLT / SLTI
        3'b100 : alu_control = ALU_XOR; // XOR / XORI
        3'b101 : begin
          if (funct7_bit5) alu_control = ALU_SRA;
          else alu_control = ALU_SRL;
        end
        3'b110 : alu_control = ALU_OR; // OR / ORI
        3'b111 : alu_control = ALU_AND; // AND / ANDI
        default: alu_control = ALU_ADD;
      endcase
    end
    default : alu_control = ALU_ADD;
  endcase
end
```

> ==ADD==: funct7 = `0000000`
> ==SUB==: funct7 = `0100000`

## A More Complete RV32I Single Cycle Data Path

![](assets%5CCA3060-4-2-Control_2.png)

## Example: SW X2, offset(X1)

![](assets%5CCA3060-4-2-Control_5.png)

## Example: BEQ X1,X2, immediate

![](assets%5CCA3060-4-2-Control_6.png)

> The processor consists of two parts: **Data Path** and **Control**.

## Drawback of Single-Cycle Design

* Long cycle time
  * Cycle time must be long enough for the load instruction (the one with longest cycle time)
    * PC’s Clock-to-Q +
    * Instruction Memory Access Time +
    * Register File Access Time +
    * ALU Delay (address calculation) +
    * Data Memory Access Time +
    * Register File Setup Time +
    * Clock Skew
* Cycle time for load is much longer than needed for all other instructions

## Summary of Single Cycle RV

* Single cycle datapath means CPI=1, but
* the clock cycle time is long
* RISC-V simplifies control implementation
  * Fixed size Instructions
  * Regular format: source registers (rs1 and rs2) are always in the same places
  * Immediates have the same size (12b or 20b)
  * Operations are always computed on registers/immediates
* RISC-V simplifies designs, lower the cost of design and test.
