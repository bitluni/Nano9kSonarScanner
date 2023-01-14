module LCD
(
    input                   CLK,
    input                   nRST,

    input                   PixelClk,

    output                  LCD_DE,
    output                  LCD_HSYNC,
    output                  LCD_VSYNC,

	output          [4:0]   LCD_B,
	output          [5:0]   LCD_G,
	output          [4:0]   LCD_R,
    input           [7:0]   data,
    output reg      [15:0]  x,
    output reg      [15:0]  y,
    output reg              valid
);
    reg [15:0]  tx;
    reg [15:0]  ty;
    reg [7:0] frame;

	localparam      V_BackPorch = 16'd0; //6
	localparam      V_Pluse 	= 16'd5; 
	localparam      HightPixel  = 16'd480;
	localparam      V_FrontPorch= 16'd45; //62

	localparam      H_BackPorch = 16'd182;
	localparam      H_Pluse 	= 16'd1; 
	localparam      WidthPixel  = 16'd800; 
	localparam      H_FrontPorch= 16'd210;

    localparam      PixelForHS  =   WidthPixel + H_BackPorch + H_FrontPorch;  	
    localparam      LineForVS   =   HightPixel + V_BackPorch + V_FrontPorch;

    always @(  posedge PixelClk or negedge nRST  )begin
        if( !nRST ) begin
            ty <= 16'b0;    
            tx <= 16'b0;
            frame <= 8'd0;
        end else 
        begin 
            if(x == PixelForHS) begin
                tx <= 16'b0;
                ty <= ty + 1'b1;
            end else if(y == LineForVS) begin
                ty <= 16'b0;
                tx <= 16'b0;
                frame <= frame + 8'b1;
            end else
                tx <= tx + 1'b1;
            x <= tx - H_BackPorch;
            y <= ty - V_BackPorch;
        end
    end

	reg			[9:0]  Data_R;
	reg			[9:0]  Data_G;
	reg			[9:0]  Data_B;

    always @(  posedge PixelClk or negedge nRST  )begin
        if( !nRST ) begin
			Data_R <= 9'b0;
			Data_G <= 9'b0;
			Data_B <= 9'b0;
        end else begin
			end
	end

    assign  LCD_HSYNC = (( tx >= H_Pluse)&&( tx <= (PixelForHS-H_FrontPorch))) ? 1'b0 : 1'b1;
	assign  LCD_VSYNC = ((( ty  >= V_Pluse )&&( ty  <= (LineForVS-0) )) ) ? 1'b0 : 1'b1;

    assign  valid = LCD_DE;
    assign  LCD_DE = (  ( tx >= H_BackPorch )&&
                        ( tx <= PixelForHS-H_FrontPorch ) &&
                        ( ty >= V_BackPorch ) &&
                        ( ty <= LineForVS-V_FrontPorch-1 ))  ? 1'b1 : 1'b0;

    assign  LCD_R   =   !data[7] ? 5'd0 :  5'b11111;//x[4:0];
    assign  LCD_G   =   !data[7] ? 5'd0 : 6'b111111;//6'b000000;//data[7:2];//y[5:0]; 
    assign  LCD_B   =   !data[7] ? 5'd0 :  5'b11111;//5'b01111;//data[7:3];

endmodule
