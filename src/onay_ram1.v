
module onay_ram (
    input              clk,
    input              w_en,
    input       [9:0]  addr,
    input              data_in,
    output             data_o                            
);
    
(*ram_style="block"*)
integer i=0;
reg    ram [0:1023];

initial begin
     for(i=0;i<1023;i=i+1)begin
        ram[i]=0;
     end
end

assign data_o=ram[addr];

always@(negedge clk)begin
    if(w_en)begin
        ram[addr]<=data_in;
    end
end




endmodule