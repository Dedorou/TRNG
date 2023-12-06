module trng #(
parameter ADDR_WIDTH = 13,
parameter LFSR_WIDTH = 32,
parameter TMW_WIDTH  = 23,
parameter RO_WIDTH   = 7
)(
input                       s_axi_aclk,
input                       s_axi_aresetn,

input  [ADDR_WIDTH - 1 : 0] s_axi_awaddr,
input              [2  : 0] s_axi_awprot,
input                       s_axi_awvalid,
output                      s_axi_awready,
             
input              [31 : 0] s_axi_wdata,
input              [3  : 0] s_axi_wstrb,
input                       s_axi_wvalid,
output                      s_axi_wready,
             
output             [1  : 0] s_axi_bresp,
output                      s_axi_bvalid,
input                       s_axi_bready,
             
input              [12 : 0] s_axi_araddr,
input              [2  : 0] s_axi_arprot,
input                       s_axi_arvalid,
output                      s_axi_arready,
            
output             [31 : 0] s_axi_rdata,
output             [1  : 0] s_axi_rresp,
output                      s_axi_rvalid,
input                       s_axi_rready
);

wire                      rst;
wire                      clk;
wire                      en;
wire             [3  : 0] we;
wire [ADDR_WIDTH - 1 : 0] addr;
wire             [31 : 0] wrdata;
wire             [31 : 0] rddata;


register_map #(
  .ADDR_WIDTH(ADDR_WIDTH),
  .LFSR_WIDTH(LFSR_WIDTH),
  .TMW_WIDTH (TMW_WIDTH),
  .RO_WIDTH  (RO_WIDTH)
) register_map (
  .clk     (clk),
  .rst     (rst),
  .en_i    (en),
  .we_i    (we),
  .addr_i  (addr),
  .wrdata_i(wrdata),
  .rdata_o (rddata)
);

axi4_lite_slave_ctrl #(
  .addr_width (ADDR_WIDTH))
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