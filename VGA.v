module VGA(
input wire clk,
input wire reset,

// ���ƼĴ�����д
input wire slave_chipselect,
input wire[1:0] slave_address, //
input wire slave_write, //д����
input wire[31:0] slave_writedata, //д����
input wire slave_read, //������
output wire[31:0] slave_readdata, //������
input wire[3:0] slave_byteenable, //������Ч��־


// ��дSDRAM����
output wire[31:0] master_address, //���ݵ�ַ
output wire master_read, //���˿ڶ�����
output wire master_byteenable,
input wire master_waitrequest, //��ʹ���˿ڵȴ�
input wire master_readdatavalid, //ָʾ�Ѿ��ṩ��Ч����
input wire[7:0] master_readdata, //��������ֵ

// VGA ʱ��
input wire vga_clk,
output wire vga_line_sync,
output wire vga_field_sync,
output wire [2:0] vga_r,
output wire [2:0] vga_g,
output wire [1:0] vga_b
);


wire vga_pixel_flag;

wire [7:0] fifo_data;
wire [7:0] tmp_data0;
reg [7:0] tmp_data1;

wire vga_frame_o;

 


/////////////////////////////////////////////////////////////////////////////////
////////// VGA��� /////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

assign vga_b = vga_pixel_flag ? fifo_data[1:0]:8'b00000000;
assign vga_g = vga_pixel_flag ? fifo_data[4:2]:8'b00000000;
assign vga_r = vga_pixel_flag ? fifo_data[7:5]:8'b00000000;


/////////////////////////////////////////////////////////////////////////////////
////////// VGA ʱ�� /////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
vga_timing vga_l1(
.clk(vga_clk),
.reset_i(reset),
.pixel_flag(vga_pixel_flag),
.hsync(vga_line_sync),
.vsync(vga_field_sync),
.frame_o(vga_frame_o),
.vga_rgb(tmp_data0)
);

 


/////////////////////////////////////////////////////////////////////////////////
////////// VGA �Ĵ������� /////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

//register �����Ĵ���
wire vga_go; //VGA ������־
wire [31:0] vga_base_address; //vga ���ݻ���ַ

vga_register vga_slave(
.clk(clk),
.reset_n(reset),

// ���ƼĴ�����д
.slave_chipselect(slave_chipselect),
.slave_address(slave_address), //
.slave_write(slave_write), //д����
.slave_writedata(slave_writedata), //д����
.slave_read(slave_read), //������
.slave_readdata(slave_readdata), //������
.slave_byteenable(slave_byteenable), //������Ч��־

.vga_base_address(vga_base_address),
.vga_go(vga_go)
);

 


/////////////////////////////////////////////////////////////////////////////////
////////// VGA SDRAM ��ȡ���� /////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

 

 

 

 


wire [11:0] fifo_count;

vga_sdram vga_sdram_11(
.clk(clk),
.reset_n(reset),

.master_address(master_address), //���ݵ�ַ
.master_read(master_read), //���˿ڶ�����
.master_byteenable(master_byteenable),
.master_waitrequest(master_waitrequest), //��ʹ���˿ڵȴ�
.master_readdatavalid(master_readdatavalid),//ָʾ�Ѿ��ṩ��Ч����
.master_readdata(master_readdata), //��������ֵ

.vga_base_addr(vga_base_address), //VGA����ַ
.vga_go(vga_go), //VGA �������
.frame_start_flag(vga_frame_o), //֡��ʼ���
.fifo_count(fifo_count)
);

 

 

 

/////////////////////////////////////////////////////////////////////////////////
////////// VGA FIFO �����ݻ��� ��ƥ�䲻ͬ�ٶȵ�����//////////////////////////
/////////////////////////////////////////////////////////////////////////////////

 

vga_fifo fifo_l2(
.aclr(vga_frame_o),
.data(master_readdata),
// .data(8'b00001000),
.rdclk(~vga_clk),
.rdreq(vga_pixel_flag),
.wrclk(clk),
.wrreq(master_readdatavalid),
.q(fifo_data),
.wrusedw(fifo_count)
);

 

 

endmodule