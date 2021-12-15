module vga_sdram(input wire clk,
input wire reset_n,

output wire[31:0] master_address, //���ݵ�ַ
output wire master_read, //���˿ڶ�����
output wire master_byteenable,
input wire master_waitrequest, //��ʹ���˿ڵȴ�
input wire master_readdatavalid, //ָʾ�Ѿ��ṩ��Ч����
input wire[7:0] master_readdata, //��������ֵ

input wire[31:0] vga_base_addr, //VGA����ַ
input wire vga_go, //VGA �������
input wire frame_start_flag, //֡��ʼ���
input wire[11:0] fifo_count
);

 

reg [19:0] input_data_count;
reg vga_read;

assign master_read = vga_read;
assign master_byteenable = 1'd1; //λʹ��
assign master_address = vga_base_addr + input_data_count;

//ͳ��FIFO�Ѿ����˶�������
always @ (posedge clk or negedge reset_n)
begin
if (!reset_n)
begin
//vga_read <= 1'b0; //SDRAM ֹͣ��
end

// һ֡���ݿ�ʼʱ�����FIFO
else if (!master_waitrequest ) //��ַ���� : // 1. ������Ч
begin

if (frame_start_flag)
begin
vga_read <= 1'b0;
end
else if( (fifo_count < 500) && (input_data_count < 307200) )
begin
vga_read <= 1'b1; // ��FIFO������
end
else if(fifo_count > 2000)
begin
vga_read <= 1'b0; // ��FIFO������
end


end
end


always @ (posedge clk or negedge reset_n)
begin
if (!reset_n)
begin
//input_data_count <= 0;
end

// һ֡���ݿ�ʼʱ�����FIFO
else if (!master_waitrequest ) //��ַ���� : // 1. ������Ч
begin

if (frame_start_flag)
begin
input_data_count <= 0;
end
else if( input_data_count < 307200)
begin
if(vga_read == 1'b1)
input_data_count <= input_data_count + 1;
end

end
end

 

endmodule