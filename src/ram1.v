
module ram (
    input              clk,
    input              w_en,
    input              r_en,
    input       [9:0]  addr,
    input       [31:0] data_in,
    output reg  [31:0] data_o                            
);
    
(*ram_style="block"*)
integer i=0;
reg [31:0] ram [0:1023];

initial begin
     for(i=0;i<1023;i=i+1)begin
        ram[i]<=32'b0;
     end
end
always@(negedge clk)begin
    if(w_en)begin
        ram[addr]<=data_in;
    end
    if(r_en)begin
       data_o<=ram[addr];
    end
end




endmodule