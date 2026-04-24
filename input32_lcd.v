module input32_lcd(

input clk,
input [7:0] sw,
input btn1,btn2,btn3,btn4, 

input [7:0] crc_in,   

output reg [7:0] lcd_data,
output reg lcd_rs,
output reg lcd_en,

output reg [31:0] data_out

);

reg [7:0] byte0,byte1,byte2,byte3;

reg p1,p2,p3,p4;

always @(posedge clk)
begin

p1 <= btn1;
p2 <= btn2;
p3 <= btn3;
p4 <= btn4;

if(!btn1 && p1)
byte0 <= sw;

if(!btn2 && p2)
byte1 <= sw;

if(!btn3 && p3)
byte2 <= sw;

if(!btn4 && p4)
byte3 <= sw;

data_out <= {byte3,byte2,byte1,byte0};

end


// HEX → ASCII

function [7:0] hex_ascii;

input [3:0] hex;

begin

case(hex)

4'h0: hex_ascii = 8'h30;
4'h1: hex_ascii = 8'h31;
4'h2: hex_ascii = 8'h32;
4'h3: hex_ascii = 8'h33;
4'h4: hex_ascii = 8'h34;
4'h5: hex_ascii = 8'h35;
4'h6: hex_ascii = 8'h36;
4'h7: hex_ascii = 8'h37;
4'h8: hex_ascii = 8'h38;
4'h9: hex_ascii = 8'h39;
4'hA: hex_ascii = 8'h41;
4'hB: hex_ascii = 8'h42;
4'hC: hex_ascii = 8'h43;
4'hD: hex_ascii = 8'h44;
4'hE: hex_ascii = 8'h45;
4'hF: hex_ascii = 8'h46;

endcase

end
endfunction


wire [7:0] h7 = hex_ascii(data_out[31:28]);
wire [7:0] h6 = hex_ascii(data_out[27:24]);
wire [7:0] h5 = hex_ascii(data_out[23:20]);
wire [7:0] h4 = hex_ascii(data_out[19:16]);
wire [7:0] h3 = hex_ascii(data_out[15:12]);
wire [7:0] h2 = hex_ascii(data_out[11:8]);
wire [7:0] h1 = hex_ascii(data_out[7:4]);
wire [7:0] h0 = hex_ascii(data_out[3:0]); 

wire [7:0] c1 = hex_ascii(crc_in[7:4]);
wire [7:0] c0 = hex_ascii(crc_in[3:0]);


// LCD FSM

reg [7:0] state;
reg [20:0] delay;

always @(posedge clk)
begin

delay <= delay + 1;

if(delay == 0)
state <= state + 1;

end


always @(state)
begin

case(state)

0: begin lcd_data=8'h38; lcd_rs=0; lcd_en=1; end
1: lcd_en=0;

2: begin lcd_data=8'h0C; lcd_rs=0; lcd_en=1; end
3: lcd_en=0;

4: begin lcd_data=8'h06; lcd_rs=0; lcd_en=1; end
5: lcd_en=0;

6: begin lcd_data=8'h01; lcd_rs=0; lcd_en=1; end
7: lcd_en=0;

8: begin lcd_data=8'h80; lcd_rs=0; lcd_en=1; end
9: lcd_en=0;


10: begin lcd_data=h7; lcd_rs=1; lcd_en=1; end
11: lcd_en=0;

12: begin lcd_data=h6; lcd_rs=1; lcd_en=1; end
13: lcd_en=0;

14: begin lcd_data=h5; lcd_rs=1; lcd_en=1; end
15: lcd_en=0;

16: begin lcd_data=h4; lcd_rs=1; lcd_en=1; end
17: lcd_en=0;

18: begin lcd_data=h3; lcd_rs=1; lcd_en=1; end
19: lcd_en=0;

20: begin lcd_data=h2; lcd_rs=1; lcd_en=1; end
21: lcd_en=0;

22: begin lcd_data=h1; lcd_rs=1; lcd_en=1; end
23: lcd_en=0;

24: begin lcd_data=h0; lcd_rs=1; lcd_en=1; end
25: lcd_en=0; 

26: begin lcd_data = 8'hC0; lcd_rs = 0; lcd_en = 1; end
27: lcd_en = 0;

28: begin lcd_data = 8'h43; lcd_rs = 1; lcd_en = 1; end // C
29: lcd_en = 0;

30: begin lcd_data = 8'h52; lcd_rs = 1; lcd_en = 1; end // R
31: lcd_en = 0;

32: begin lcd_data = 8'h43; lcd_rs = 1; lcd_en = 1; end // C
33: lcd_en = 0;

34: begin lcd_data = 8'h3D; lcd_rs = 1; lcd_en = 1; end // =
35: lcd_en = 0;

36: begin lcd_data = c1; lcd_rs = 1; lcd_en = 1; end
37: lcd_en = 0;

38: begin lcd_data = c0; lcd_rs = 1; lcd_en = 1; end
39: lcd_en = 0;



endcase

end

endmodule