//640*480
module vga_timing( clk,reset_i,pixel_flag,
hsync,
vsync,
frame_o,
vga_rgb);

////////////////////////////////////////////////
// VGA
////////////////////////////////////////////////
input clk;
input reset_i;
output hsync; //VGA��ͬ���ź�
output vsync; //VGA��ͬ���ź�
output pixel_flag;
output frame_o;
output[7:0] vga_rgb;


reg [10:0] hcount; //VGA��ɨ�������
reg [9:0] vcount; //VGA��ɨ�������
reg [8:0] data; //VGA����
reg vga_clk;

wire h_end;
wire v_end;

wire dat_act;

 

////////////////////////////////////////////////
// VGA
////////////////////////////////////////////////
always @(posedge clk)
begin
vga_clk = ~vga_clk;
end
// ����....
always @(posedge clk)
begin
if(h_end)
hcount <= 10'd0;
else
hcount <= hcount + 10'd1;
end

assign h_end = (hcount == 799);

// ����....
always @(posedge clk)
begin
if(h_end)
begin
if(v_end)
vcount <= 10'd0;
else
vcount <= vcount + 10'd1;
end
end
assign v_end = (vcount == 524);


//ʹ���ź�
assign pixel_flag = ((hcount >= 144) && (hcount < 784))&& ((vcount >= 34) && (vcount < 514));

 

assign hsync = (hcount > 95);//ˮƽͬ��
assign vsync = (vcount > 2);//��ֱͬ��

 

reg frame_o_t;
always @(posedge clk)
begin
if( vcount < 3)
frame_o_t <= 1;
else
frame_o_t <= 0;
end

assign frame_o = frame_o_t;//��ֱͬ��


wire[10:0] x_pos;
wire[10:0] y_pos;
assign x_pos = hcount - 144;//��ֱͬ��
assign y_pos = vcount - 34;//��ֱͬ��


reg[7:0] vga_rgb_t;

always @(posedge clk)
begin

if( x_pos<500 && y_pos > 80)
vga_rgb_t <= 8'b01101111;
else
vga_rgb_t <= 8'b00000000;
end


assign vga_rgb = vga_rgb_t;


endmodule