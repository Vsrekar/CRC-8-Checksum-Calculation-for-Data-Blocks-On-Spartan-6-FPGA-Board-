module top_crc_system(

input clk,                 // 12 MHz board clock
input [7:0] sw,            // toggle switches
input btn1,btn2,btn3,btn4, // push buttons

output [7:0] lcd_data,
output lcd_rs,
output lcd_en

);

wire [31:0] input_data;
wire [7:0] crc_out;

// input module
input32_lcd input_block(

.clk(clk),
.sw(sw),
.btn1(btn1),
.btn2(btn2),
.btn3(btn3),
.btn4(btn4),

.data_out(input_data),  
.crc_in(crc_out), 

.lcd_data(lcd_data),
.lcd_rs(lcd_rs),
.lcd_en(lcd_en)

);


// clock phase generator for pipeline
reg phase;

always @(posedge clk)
phase <= ~phase;

wire clk1 = clk & phase;
wire clk2 = clk & ~phase;


// processor
pipe_MIPS32 cpu(

.clk1(clk1),
.clk2(clk2),
.input_data(input_data),
.crc_result(crc_out)

);

endmodule