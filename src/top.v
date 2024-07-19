module top(
    input clk,
    input [7:0] adcData,//1-8

	output			io11,
	output			io12,

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

//simple debug
assign led = sample[0][7:2];

//array of clocks and chip selects for all ADCs
wire [7:0] WadcClk;
wire [7:0] WadcCs;
//clock and chip select is shared externaly (all 8 are in sync)
assign adcClk = WadcClk[0];
assign adcCs = WadcCs[0];

//coordinates for screen
wire [15:0] x;
wire [15:0] y;
wire valid;
//memory index of sample and index of buffer (double buffering)
reg [10:0] addr = 10'd0;
reg index;

//memory output to display pixel
wire [7:0] outData[8];

//TFT pixel clock
Gowin_rPLL chip_pll
(
    .clkout(CLK_SYS), //output clkout      //200M
    .clkoutd(CLK_PIX), //output clkoutd   //33.33M
    .clkin(clk) //input clkin
);

/* //clock for 40kHz sampling
wire clk20480k;
pll20480k adcClkMod(
    .clkout(clk20480k), //output clkout
    .clkin(clk) //input clkin
);*/

//memory address for read operation from double buffer
wire [11:0] readAddr = (index ? 12'd2048 : 0) + x[10:0];

generate
    genvar i;
    for(i=0; i<8; i=i+1) begin : adcs
        ADC adc(
                .clk(clk),//20480k),
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
            .adb(valid?readAddr:12'b0)
        );
    end
endgenerate/**/

//process each new sample
always @(posedge sampleClk[0]) begin
    if(addr < 11'd2047)
        addr <= addr + 11'd1;
    else
    if(LCD_SYNC) begin     
        addr <= 11'd0;
        index <= ~index;
    end
end

assign LCD_CLK = CLK_PIX;

//TFT controller pulling x,y pixels in 8bit grey scale
LCD	display
	(
		.CLK		(CLK_SYS),
		.nRST		(resetButton),

		.PixelClk	(CLK_PIX),
		.LCD_DE		(LCD_DEN),
		.LCD_HSYNC	(LCD_HYNC),
    	.LCD_VSYNC	(LCD_SYNC),

		.LCD_B		(LCD_B),
		.LCD_G		(LCD_G),
		.LCD_R		(LCD_R),
        .data       (

//slicing display into 8 channels, one line in the center
((outData[y[8:6]][7:2] + 16'd0) - y[5:0] < 16'd4 || x == 402 ? 8'd255 : 8'd0)

),
        .x(x),
        .y(y),
        .valid(valid)
	);

endmodule