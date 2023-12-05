module main(
input              s_axi_aclk,
input              s_axi_aresetn,

input     [12 : 0] s_axi_awaddr,
input     [2  : 0] s_axi_awprot,
input   	       s_axi_awvalid,
output  	       s_axi_awready,
 
input     [31 : 0] s_axi_wdata,
input     [3  : 0] s_axi_wstrb,
input              s_axi_wvalid,
output             s_axi_wready,
 
output    [1  : 0] s_axi_bresp,
output             s_axi_bvalid,
input              s_axi_bready,
 
input     [12 : 0] s_axi_araddr,
input     [2  : 0] s_axi_arprot,
input              s_axi_arvalid,
output             s_axi_arready,

output    [31 : 0] s_axi_rdata,
output    [1  : 0] s_axi_rresp,
output             s_axi_rvalid,
input              s_axi_rready
);

wire      [12 : 0] addr;
wire      [31 : 0] wrdata;
wire      [3  : 0] we;
reg       [31 : 0] rddata;
wire               clk;
wire               rst;
wire               en;

reg       [3  : 0] seed_reg_we;
wire      [31 : 0] seed_reg_out;
     
reg                LFSR_we;
wire      [31 : 0] LFSR_out;
     
reg                en_reg_we;
wire               en_reg_out;
     
reg                TMW_counter_we;     
wire      [9  : 0] TMW_counter_out;	

wire               ring_oscillator_out;

wire we_or = we[0] | we[1] | we[2] | we[3];

reg       [31 : 0] rddata_int;

always @(posedge clk ) begin
   rddata <= rddata_int;
end

always @(*) begin
	LFSR_we        = 1'b0;
	seed_reg_we    = 1'b0;
	en_reg_we      = 1'b0;
	TMW_counter_we = 1'b0;
	rddata_int         = 32'b0;

	case (addr[12 : 4])
		9'h1 : begin : LFSR_addr 
			LFSR_we        = en & we_or;//or we???
			rddata_int         = LFSR_out;
		end
		9'h2 : begin : seed_addr	
			seed_reg_we    = {4{en}} & we;
			rddata_int         = seed_reg_out;
		end
		9'h3 : begin : en_reg_addr
			en_reg_we      = en & we_or;
			rddata_int[0]      = en_reg_out; 
		end
		9'h4 : begin : TMW_counter_addr
			TMW_counter_we = en & we_or;
			rddata_int [9 : 0] = TMW_counter_out;
		end
      9'h5 : begin : ring_oscillator_addr
			rddata_int [0] = ring_oscillator_out;
		end
	endcase 
end

LFSR #(
   .width(32),
   .polynom(32'h80000370)
) LFSR (    
   .clk(clk), 
   .rst(rst), 
   .en(en_reg_out),
   .seed_we(LFSR_we),
   .seed(seed_reg_out),
   .ring_oscillator(ring_oscillator_out),
   .data_out(LFSR_out)
);

byte_write_reg #(
   .width(32),
   .byte_width(8)
) seed_reg (
   .clk(clk), 
   .rst(rst), 
   .we(seed_reg_we), 
   .D(wrdata), 
   .Q(seed_reg_out)
);

param_reg #(
   .N(1)
) en_reg (
   .clk(clk), 
   .rst(rst), 
   .we(en_reg_we), 
   .D(wrdata[0]), 
   .Q(en_reg_out)
);

ring_oscillator #(
   .N(7)
) ring_oscillator (
  .clk(clk),
  .rst(rst),
  .en(ring_oscillator_en),
  .out(ring_oscillator_out)
);

TMW_counter #(
  .N(10)
) TMW_counter (
.clk(clk),
.rst(rst),
.valid(TMW_counter_we),
.max_counts(wrdata[9 : 0]),
.en_out(ring_oscillator_en),
.data(TMW_counter_out)
);

//axi_bram_ctrl_0 axi_bram_ctrl_0(
axi4_lite_slave_ctrl #(
   .addr_width (13))
axi4_lite_slave_ctrl (
   .s_axi_aclk    (s_axi_aclk),
   .s_axi_aresetn (s_axi_aresetn),
   
   .s_axi_awaddr  (s_axi_awaddr),
   .s_axi_awprot  (s_axi_awprot),
   .s_axi_awvalid (s_axi_awvalid),
   .s_axi_awready (s_axi_awready),
   
   .s_axi_wdata   (s_axi_wdata),
   .s_axi_wstrb   (s_axi_wstrb),
   .s_axi_wvalid  (s_axi_wvalid),
   .s_axi_wready  (s_axi_wready),
   
   .s_axi_bresp   (s_axi_bresp),
   .s_axi_bvalid  (s_axi_bvalid),
   .s_axi_bready  (s_axi_bready),
   
   .s_axi_araddr  (s_axi_araddr),
   .s_axi_arprot  (s_axi_arprot),
   .s_axi_arvalid (s_axi_arvalid),
   .s_axi_arready (s_axi_arready),
   
   .s_axi_rdata   (s_axi_rdata),
   .s_axi_rresp   (s_axi_rresp),
   .s_axi_rvalid  (s_axi_rvalid),
   .s_axi_rready  (s_axi_rready),
   
   .bram_rst_a    (rst),
   .bram_clk_a    (clk),
   .bram_en_a     (en),
   .bram_we_a     (we),
   .bram_addr_a   (addr),
   .bram_wrdata_a (wrdata),
   .bram_rddata_a (rddata)
);


endmodule