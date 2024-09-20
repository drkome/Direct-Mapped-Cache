
module tag (
    input              clk,
    input              w_en,
    input       [9:0]  addr,
    input       [20:0] data_in,
    output      [20:0] data_o                            
);
    
(*ram_style="block"*)
integer i=0;
reg [20:0] ram [0:1023];

initial begin
     for(i=0;i<1023;i=i+1)begin
        ram[i]<=32'b0;
     end
end

assign data_o=ram[addr];

always@(negedge clk)begin
    if(w_en)begin
        ram[addr]<=data_in;
    end

end




endmodule