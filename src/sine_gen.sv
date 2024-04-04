module sine_gen #(
  parameter WL = 16) (
  input                  clk,
  input                  reset_b,
  input                  en,
  input                  load,
  input signed [WL-1:0]  cosW,
  input signed [WL-1:0]  sinW,
  output signed [WL-1:0] sine);

  reg signed [WL-1:0]    y1, y2;       // s0.{WL-1}
  reg signed [WL:0]      cosW2;        // s1.{WL-1}
  reg signed [WL:0]      y1_gb;        // s1.{WL-1}
  reg signed [WL:0]      y1_se, y2_se; // s1.{WL-1}
  reg signed [2*WL:0]    m_gb;         // s2.{2*WL-2}
  reg signed [WL:0]      m;            // s1.{WL-1}
   
  always @(posedge clk, negedge reset_b)
    if (! reset_b)
      begin
 	y2 <= 0;
	y1 <= 0;
      end
    else if (load)
      begin
        y2 <= -sinW;
        y1 <= 0;
      end  
    else if (en)
      begin
        cosW2 = cosW << 1;
        y1_se = { y1[WL-1], y1 };
 	m_gb = cosW2 * y1_se;
        m = m_gb[2*WL-1:WL-1];

        y2_se = {y2[WL-1], y2};
        y1_gb = m - y2_se;

        if (y1_gb[WL] ^ y1_gb[WL-1])
	  y1 <= {y1_gb[WL], {WL-1{~y1_gb[WL]}}};
        else
          y1 <= y1_gb[WL-1:0];
	y2 <= y1;
      end // if (en)

  assign sine = y1;

endmodule
