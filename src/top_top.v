module top(
    input clk,
    input [7:0] adcData,//1-8
    output adcClk,  //10
    output adcCs,    //9
    output reg [5:0] led,

	output			LCD_CLK,
	output			LCD_HYNC,
	output			LCD_SYNC,
	output			LCD_DEN,
	output	[4:0]	LCD_R,
	output	[5:0]	LCD_G,
	output	[4:0]	LCD_B,

    input resetButton
);

wire [7:0] sample[8];
wire sampleClk[8];

//assign led = sample[7:2];
wire clk32M;



pll32M your_instance_name(
    .clkout(clk32M), //output clkout
    .clkin(clk) //input clkin
);

reg clk16M;

always @(posedge clk32M)
    clk16M <= ~clk16M;

wire [7:0] WadcClk;
wire [7:0] WadcCs;
assign adcClk = WadcClk[0];
assign adcCs = WadcCs[0];

reg [9:0] counter = 0;

always @(posedge clk) begin
    counter <= counter + 1'd1;
    //adcData <= counter;
    //adcClk = counter[8];
    //adcCs = counter[9];
end

wire [15:0] x;
wire [15:0] y;
wire valid;

reg [10:0] addr = 10'd0;
reg index;

wire inEn = 1'b1;
wire [7:0] outData[8];
wire [7:0] outDataA[8];
wire [7:0] outDataB[8];

reg [10:0] trigger [2];

Gowin_rPLL chip_pll
(
    .clkout(CLK_SYS), //output clkout      //200M
    .clkoutd(CLK_PIX), //output clkoutd   //33.33M
    .clkin(clk) //input clkin
);

wire [11:0] readA = x[10:0] /*+ trigger[1] - 11'd400*/;
wire [11:0] readB = 11'd2048 + x[10:0] /*+ trigger[0] - 11'd400*/;

generate
    genvar i;
    for(i=0; i<1; i=i+1) begin : adcs
        ADC adc(
                .clk(clk16M),
                .adcData(adcData[i]),
                .adcClk(WadcClk[i]),
                .adcCs(WadcCs[i]),
                .sampleClk(sampleClk[i]),
                .sample(sample[i])
        );


        Gowin_SDPB ram4k(
            .dout(outData[i]), 
            .clka(CLK_PIX), 
            .cea(1'b1), 
            .reseta(1'b0), 
            .clkb(CLK_PIX), 
            .ceb(1'b1), 
            .resetb(1'b0), 
            .oce(1'b1), 
            .ada({~index,addr}), 
            .din(sample[i]), 
            .adb(valid?(index?readA:readB):12'b0));

        );
    end
endgenerate/**/

reg [7:0] oldSample;

always @(posedge sampleClk[0]) begin
    //led <= sample[7:2];
    if(sample[0] > 230)
        led <= ~6'b111111;
    else
    if(sample[0] > 200)
        led <= ~6'b111110;
    else
    if(sample[0] > 170)
        led <= ~6'b111100;
    else
    if(sample[0] > 130)
        led <= ~6'b111000;
    else
    if(sample[0] > 90)
        led <= ~6'b110000;
    else
    if(sample[0] > 40)
        led <= ~6'b100000;
    else
        led <= ~6'b000000;


    if(sample[0][7] && !oldSample[7] &&
        addr > 11'd400 && trigger[~index] == 11'd400)
        trigger[~index] <= addr;

    oldSample <= sample[0];

    if(addr < 11'd2047)
        addr <= addr + 11'd1;
    else


    if(LCD_SYNC) begin     
        addr <= 11'd0;
        index <= ~index;
        trigger[index] <= 11'd400;
    end
end


assign		LCD_CLK		=	CLK_PIX;

LCD	display
	(
		.CLK		(	CLK_SYS     ),
		.nRST		(	resetButton),

		.PixelClk	(	CLK_PIX		),
		.LCD_DE		(	LCD_DEN	 	),
		.LCD_HSYNC	(	LCD_HYNC 	),
    	.LCD_VSYNC	(	LCD_SYNC 	),

		.LCD_B		(	LCD_B		),
		.LCD_G		(	LCD_G		),
		.LCD_R		(	LCD_R		),
        .data       ((outData[0] + 16'd100 - y < 16'd10 || x == 402 || y == 228? 8'd255 : 8'd0)),
        .x(x),
        .y(y),
        .valid(valid)
	);

endmodule