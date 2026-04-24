// ============================================================
//  5-Stage Pipelined MIPS32 with CRC-8 Instruction
//  Modified for FPGA integration
// ============================================================

module pipe_MIPS32(

input clk1,
input clk2,

input [31:0] input_data,    // external 32-bit input
output [7:0] crc_result     // CRC result

);

// ------------------------------------------------------------
// Register file and memory
// ------------------------------------------------------------

reg [31:0] Reg [0:31];
reg [31:0] Mem [0:1023];


// ------------------------------------------------------------
// Pipeline registers
// ------------------------------------------------------------

reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;

reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type;

reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
reg EX_MEM_cond;

reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;


// ------------------------------------------------------------
// Opcodes
// ------------------------------------------------------------

parameter ADD   = 6'b000000,
          SUB   = 6'b000001,
          XOR_OP= 6'b000010,
          SLL_OP= 6'b000011,
          HLT   = 6'b111111,
          LW    = 6'b001000,
          SW    = 6'b001001,
          ADDI  = 6'b001010,
          BNEQZ = 6'b001101,
          BEQZ  = 6'b001110,
          CRC8  = 6'b001111;


// ------------------------------------------------------------
// Instruction types
// ------------------------------------------------------------

parameter RR_ALU=3'b000,
          RM_ALU=3'b001,
          LOAD  =3'b010,
          STORE =3'b011,
          BRANCH=3'b100,
          HALT  =3'b101,
          CRC_OP=3'b110;


// ------------------------------------------------------------
// CRC parameters
// ------------------------------------------------------------

parameter POLY = 8'h07;
parameter CRC_INIT = 8'h00;

reg [7:0] crc_reg;
reg [7:0] crc_byte;

integer crc_i;
integer crc_j;


// ------------------------------------------------------------

reg HALTED;
reg TAKEN_BRANCH;


// ------------------------------------------------------------
// Load external input into R4
// ------------------------------------------------------------

always @(posedge clk1)
begin
Reg[4] <= input_data;
end


// ------------------------------------------------------------
// IF Stage
// ------------------------------------------------------------

always @(posedge clk1)
begin

if(HALTED==0)
begin

IF_ID_IR <= Mem[PC];
IF_ID_NPC <= PC + 1;
PC <= PC + 1;

end

end


// ------------------------------------------------------------
// ID Stage
// ------------------------------------------------------------

always @(posedge clk2)
begin

ID_EX_A <= Reg[IF_ID_IR[25:21]];
ID_EX_B <= Reg[IF_ID_IR[20:16]];

ID_EX_IR <= IF_ID_IR;
ID_EX_NPC <= IF_ID_NPC;

case(IF_ID_IR[31:26])

ADD,SUB,XOR_OP,SLL_OP: ID_EX_type <= RR_ALU;
ADDI: ID_EX_type <= RM_ALU;
CRC8: ID_EX_type <= CRC_OP;
HLT : ID_EX_type <= HALT;

default: ID_EX_type <= HALT;

endcase

end


// ------------------------------------------------------------
// EX Stage
// ------------------------------------------------------------

always @(posedge clk1)
begin

EX_MEM_type <= ID_EX_type;
EX_MEM_IR <= ID_EX_IR;

case(ID_EX_type)

RR_ALU:
begin

case(ID_EX_IR[31:26])

ADD: EX_MEM_ALUOut <= ID_EX_A + ID_EX_B;
SUB: EX_MEM_ALUOut <= ID_EX_A - ID_EX_B;
XOR_OP: EX_MEM_ALUOut <= ID_EX_A ^ ID_EX_B;
SLL_OP: EX_MEM_ALUOut <= ID_EX_A << ID_EX_B;

endcase

end


RM_ALU:
begin

EX_MEM_ALUOut <= ID_EX_A + ID_EX_Imm;

end


// ------------------------------------------------------------
// CRC computation
// ------------------------------------------------------------

CRC_OP:
begin

crc_reg = CRC_INIT;

for(crc_i=3; crc_i>=0; crc_i=crc_i-1)
begin

crc_byte = ID_EX_A[crc_i*8 +: 8];

crc_reg = crc_reg ^ crc_byte;

for(crc_j=0; crc_j<8; crc_j=crc_j+1)
begin

if(crc_reg[7])
crc_reg = (crc_reg << 1) ^ POLY;
else
crc_reg = crc_reg << 1;

end

end

EX_MEM_ALUOut <= {24'b0,crc_reg};

end


endcase

end


// ------------------------------------------------------------
// MEM Stage
// ------------------------------------------------------------

always @(posedge clk2)
begin

MEM_WB_type <= EX_MEM_type;
MEM_WB_IR <= EX_MEM_IR;

case(EX_MEM_type)

RR_ALU: MEM_WB_ALUOut <= EX_MEM_ALUOut;
RM_ALU: MEM_WB_ALUOut <= EX_MEM_ALUOut;
CRC_OP: MEM_WB_ALUOut <= EX_MEM_ALUOut;

endcase

end


// ------------------------------------------------------------
// WB Stage
// ------------------------------------------------------------

always @(posedge clk1)
begin

case(MEM_WB_type)

RR_ALU: Reg[MEM_WB_IR[15:11]] <= MEM_WB_ALUOut;

RM_ALU: Reg[MEM_WB_IR[20:16]] <= MEM_WB_ALUOut;

CRC_OP: Reg[MEM_WB_IR[20:16]] <= MEM_WB_ALUOut;

HALT: HALTED <= 1'b1;

endcase

end


// ------------------------------------------------------------
// Output CRC
// ------------------------------------------------------------

assign crc_result = Reg[3][7:0];

endmodule