`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ryken Thompson
// 
// Create Date: 12/07/2023 01:57:32 PM
// Design Name: 
// Module Name: LiquidCrystal
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module LiquidCrystal(
    input CLK,
    input RST,
    input [9:0] lcd_instr,
    output logic lcd_ready = 0,
    output logic rs,
    output logic e,
    output logic [7:0] data
    );
    
    localparam freq = 50; //Freq in MHz
    
    logic [31:0] clk_count = 0;
    logic count_en = 0;
    logic count_rst = 0;
    
    enum {POWER_ON, INIT, IDLE, SEND} PS, NS;
    
    //assign rs = lcd_instr[8];
    //  assign data = lcd_instr[7:0];
    
    always_ff @(posedge CLK) begin
        if (RST) begin
            PS <= POWER_ON;
        end
        else PS <= NS;
    end
    
    always_comb begin
        data = 8'b00000000;
        rs = 1'b0;
        e = 1'b0;
        count_en = 0;
        count_rst = 0;
        lcd_ready = 0;
        
        case (PS)
            
            //Wait for LCD to properly power up
            POWER_ON: begin
                if (clk_count < (50000 * freq)) begin //Wait 50ms for LCD to properly power on
                    count_en = 1;
                    NS = POWER_ON;
                end
                else begin
                    count_rst = 1;
                    data = 8'b00110000;
                    NS = INIT;
                end
            end
            
            //Begin LCD initialization sequence
            INIT: begin
                count_en = 1;
                if (clk_count < (10 * freq)) begin //Set the LCD Function 
                    data = 8'b00111100; //2 line mode, display on
                    e = 1'b1;
                    NS = INIT;
                end
                else if (clk_count < (60*freq)) begin // Wait 50 us
                    data = 8'b00000000;
                    e = 1'b0;
                    NS = INIT;
                end
                else if (clk_count < (70*freq)) begin //Display On, Cursor off, blink off
                    data = 8'b00001100;
                    e = 1'b1;
                    NS = INIT;
                end
                else if (clk_count < (120*freq)) begin //Wait 50 us
                    data = 8'b00000000;
                    e = 1'b0;
                    NS = INIT;
                end
                else if (clk_count < (130*freq)) begin //Display Clear
                    data = 8'b00000001;
                    e = 1'b1;
                    NS = INIT;
                end
                else if (clk_count < (2130*freq)) begin //Wait 2 ms for proper clear
                    data = 8'b00000000;
                    e = 1'b0;
                    NS = INIT;
                end
                else if (clk_count < (2140*freq)) begin //Entry mode set: increment mode, entire shift off
                    data = 8'b00000110;
                    e = 1'b1;
                    NS = INIT;
                end
                else if (clk_count < (2200*freq)) begin // Wait 60 us
                    data = 8'b00000000;
                    e = 1'b0;
                    NS = INIT;
                end
                else begin // Init complete
                    count_rst = 1;
                    NS = IDLE;
                end
            end
            
            //Wait for send signal before sending enable
            IDLE: begin
                lcd_ready = 1;
                data = lcd_instr[7:0];
                rs = lcd_instr[8];
                if (lcd_instr[9]) begin
                    NS = SEND;
                end
                else begin
                    NS = IDLE;
                end
            end
            SEND: begin
                lcd_ready = 0;
                data = lcd_instr[7:0];
                rs = lcd_instr[8];
                if (clk_count < (50 * freq)) begin
                    count_en = 1;
                    NS = SEND;
                    if (clk_count < freq) begin
                        e = 1'b0;
                    end
                    else if (clk_count < (14*freq)) begin
                        e = 1'b1;
                    end
                    else if (clk_count < (27*freq)) begin
                        e = 1'b0;
                    end
                end
                else begin
                    count_rst = 1;
                    NS = IDLE;
                end
            end
            default: begin
                NS = POWER_ON;
            end
        endcase
    end
    
    
    always_ff @(posedge CLK) begin
        if (count_rst) begin
            clk_count = 0;
        end
        else if (count_en) begin
            clk_count = clk_count + 1;
        end
    end
    
endmodule
