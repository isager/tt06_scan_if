module amba_apb #(
  parameter PADDR_WL = 4,
  parameter PDATA_WC = 2**PADDR_WL,
  parameter PDATA_WL = 8
) (
  input                     clk, reset_b,

  input [PDATA_WL-1:0]      pwdata,
  input [PADDR_WL-1:0]      paddr,
  input                     penable, psel, pwrite,
  output                    pready,
  output reg [PDATA_WL-1:0] prdata,

  output reg [PDATA_WL-1:0] data[PDATA_WC-1:0]
);

  integer                   i;

  assign pready = psel && penable;

  always @(posedge clk or negedge reset_b)
    if (! reset_b)
      begin
	for (i=0; i<PDATA_WC; i=i+1)
	  data[i] <= 0;
	prdata <= 0;
      end
    else if (psel && !penable)
      begin
	if (pwrite)
	  begin
	    for (i=0; i<PDATA_WC; i=i+1)
	      if (paddr == i)
		data[i] <= pwdata;
	  end
	else
	  begin
	    if (paddr < PDATA_WC)
	      prdata <= data[paddr];
	    else
	      prdata <= 0;
	  end
      end

endmodule

