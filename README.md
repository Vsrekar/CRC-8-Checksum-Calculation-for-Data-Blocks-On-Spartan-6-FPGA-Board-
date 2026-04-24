# CRC-8 Checksum for Data Blocks on Spartan-6 FPGA

## 📌 Project Overview
This project implements an **8-bit CRC (Cyclic Redundancy Check) checksum generator and checker** for data blocks using **Verilog HDL**, targeted for execution on a **Spartan-6 FPGA**. The design ensures reliable error detection in digital communication systems.

## 🚀 Features
- Serial CRC-8 checksum generation for input data blocks.
- Extended a MIPS 32 RISC-V ISA by integrating a custom CRC-8 instruction.
- XOR operation is used to perform modulo-2 division.
- Hardware implementation using Verilog .
- Synthesized and tested on Spartan-6 FPGA.

## 🛠️ Technologies Used
- **Hardware Description Language:** Verilog HDL  
- **FPGA Board:** Spartan-6  
- **Toolchain:** Cadence Genus(Logic synthesis) Xilinx ISE (Synthesis,routing and implementation)

## 📂 Project Structure
## 🔄 Pipeline Working (Stage-by-Stage)

The processor follows a classic 5-stage pipeline, where instructions flow sequentially through:

### 1. Instruction Fetch (IF)
- Instruction is fetched from memory using the Program Counter (PC)
- PC is incremented for the next instruction

### 2. Instruction Decode (ID)
- Instruction is decoded
- Source register values are read from the register file
- Instruction type (ALU / CRC / etc.) is identified

### 3. Execute (EX)
- ALU operations (ADD, SUB, XOR, etc.) are performed  
- For the CRC instruction, a 32-bit input is processed in 8-bit chunks:
  - Each byte is XORed with the CRC register
  - Polynomial division (using `0x07`) is performed bit-by-bit
- Final CRC value is generated in this stage

### 4. Memory Access (MEM)
- Intermediate results are passed forward  
- (No major memory operations used in this design)

### 5. Write Back (WB)
- Final result (ALU or CRC output) is written back to the register file


## 🔁 Pipeline Data Flow

- Pipeline registers (`IF_ID`, `ID_EX`, `EX_MEM`, `MEM_WB`) store intermediate values between stages  
- Two-phase clocking (`clk1` and `clk2`) is used to ensure smooth data transfer between stages  
- Each instruction advances one stage per clock cycle, enabling parallel execution  


## 🎛️ FPGA Input & Output Operation

### Input
- Input is provided using 8 toggle switches  
- Each switch set represents 8 bits (1 byte) of data  
- A control switch/button is used to indicate loading of the next byte  
- In total, 32-bit input data is provided in 4 steps  

### Processing
- The 32-bit data is loaded into the processor  
- The custom CRC-8 instruction computes the checksum  

### Output
- The final CRC + input data is displayed on the LCD screen of the FPGA board  
<img width="500" height="360" alt="image" src="https://github.com/user-attachments/assets/0ec47db4-8d40-4f28-834c-2106d95eb293" />

