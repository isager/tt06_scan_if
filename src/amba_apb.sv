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

  output reg [PDATA_WL*PDATA_WC-1:0] data
);

//  integer                   i;

  assign pready = psel && penable;

  always @(posedge clk or negedge reset_b)
    if (! reset_b)
      begin
	data <= 0;
	prdata <= 0;
      end
    else if (psel && !penable)
      begin
        integer i, j;
        j = paddr*PDATA_WL;
        
	if (pwrite && paddr < PDATA_WC)
          for (i = 0; i < PDATA_WL; i = i+1)
            begin
	      data[j] <= pwdata[i];
              j = j+1;
            end
        else if (!pwrite)
          if (paddr < PDATA_WC)
            for (i = 0; i < PDATA_WL; i = i+1)
              begin
	        prdata[i] <= data[j];
                j = j+1;
              end
	  else
	    prdata <= 0;
      end

endmodule

