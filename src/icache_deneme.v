module icache (

            input                    clk_i,
            input                    reset_i,
    
            input      [31:0]        adress_i,
            output                   instruction_kabul_o,
            output reg               icache_busy,
            output     [31:0]        instruction_o,

            output reg               iomem_valid   ,
            input                    iomem_ready   ,
            output reg [3:0]         iomem_wstrb   ,
            output reg [31:0]        iomem_addr    ,
            output reg [31:0]        iomem_wdata   ,
            input      [31:0]        iomem_rdata           
);


//                          ETIKET                                          Index      Offset
// |-----------------------------------------------------------------||---------------|-----|
// |31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10||9 8 7 6 5 4 3 2| 1 0 |
// |-----------------------------------------------------------------||---------------|-----|

localparam CACHE_OKU         =2'b00 ;
localparam MEMORY_CEK        =2'b01 ;
localparam CACHE_KAYDET      =2'b10 ;
localparam BITTI             =2'b11 ;

localparam BOSTA             =2'b00;
localparam SIL               =2'b01;


reg     [1:0]      state    = CACHE_OKU;
reg     [1:0]      durum    = BOSTA;
reg     [9:0]      counter;
reg                bosaltma_aktif=0;
reg     [31:0]     adress_next;
reg     [31:0]     data_next;
reg     [9:0]      adress;
reg                write_en;
reg                read_en=1;
reg     [20:0]     tag_in;
wire    [20:0]     tag_data;
reg                onay_in;
wire               onay_data;
reg    [31:0]      okunan_data;
wire   [31:0]      data_o;
reg                hit;
reg                instruction_kabul;



//--------------------------------------
// HIT OLUP OLMADIGI TEST EDİLİYOR
//--------------------------------------

always@(*)begin
    if(durum==SIL)begin
        adress=counter;
    end
    else if(state==CACHE_OKU)begin
        adress=adress_i[11:2];
    end 
    else begin
        adress=adress_next[11:2];
    end

end

// instruction_kabul ve hitin "ve"'lenme sebebi 1'den fazla clock darbesi ile yollanmamaya çalışılmasından
// 
assign instruction_o        =   (instruction_kabul && hit)?   data_o    :   32'b0;
assign instruction_kabul_o  =   (instruction_kabul && hit)?   1'b1      :   1'b0;


always @(posedge clk_i) begin

    if(!reset_i || bosaltma_aktif)
        begin
            state      <=  CACHE_OKU;
            iomem_valid<=0;
            instruction_kabul   <=  0;
            adress_next         <=  32'b0;
            iomem_wstrb         <=  0;
            case(durum)

                BOSTA:begin
                    if(!reset_i && durum==BOSTA)begin
                        counter        <=0;
                        bosaltma_aktif <=1;
                        tag_in  <=22'b0;
                        onay_in <=1'b0;
                        okunan_data<=32'b0;
                        write_en<=1;
                        durum          <=SIL;
                    end
                end
                SIL:begin
                    counter <=counter+1;
                    tag_in  <=22'b0;
                    onay_in <=1'b0;
                    okunan_data<=32'b0;
                    write_en<=1;
                    if(counter == 10'd1023)begin
                        durum<=BOSTA;
                        write_en<=0;
                        bosaltma_aktif<=0;
                    end
                end
            endcase
        end
    else begin
        case(state)

            CACHE_OKU:begin
                write_en<=0;
                onay_in <=0;
                tag_in  <=22'b0;
                if(!hit)begin
                    icache_busy         <=  1;
                    adress_next         <=  adress_i;
                    instruction_kabul   <=  0;
                    state               <=  MEMORY_CEK;
                end 
                else begin
                    instruction_kabul   <=1;
                end
             end

            MEMORY_CEK:begin
                iomem_valid         <=  1;
                iomem_addr          <=  adress_next;
                iomem_wstrb         <=  0;
                iomem_wdata         <=  0;
                if(iomem_ready)begin
                    iomem_valid     <=  0;
                    iomem_addr      <=  0;
                    okunan_data     <=  iomem_rdata;
                    state           <=  BITTI;
                    write_en        <=1;
                    tag_in          <=adress_next[31:12];
                    onay_in         <=1;

                end
             end

            CACHE_KAYDET:begin
                write_en            <=1;
                tag_in              <=adress_next[31:10];
                onay_in             <=1;
                okunan_data         <=data_next;
                state               <=BITTI;
             end

            BITTI:begin
                write_en            <=0;
                tag_in              <=0;
                onay_in             <=0;
                okunan_data         <=0;
                icache_busy         <=0;
                state               <=CACHE_OKU;
            end

        endcase

    end 

end



always @(*)begin

   if (onay_data && tag_data==adress_i[31:12] ) begin
      hit=1;
   end
   else begin
      hit=0;
   end

end


 tag tag1(

    .clk        (clk_i               ),
    .w_en       (write_en            ),
    .addr       (adress              ),
    .data_in    (tag_in              ),
    .data_o     (tag_data            )   

   );

 onay_ram   onay1(

    .clk        (clk_i                ),
    .w_en       (write_en             ),
    .addr       (adress               ),
    .data_in    (onay_in              ),
    .data_o     (onay_data            )         

   );

 ram inst(

    .clk        (clk_i              ),
    .w_en       (write_en           ),
    .r_en       (read_en            ),
    .addr       (adress             ),
    .data_in    (okunan_data        ),
    .data_o     (data_o             )         

   );


endmodule