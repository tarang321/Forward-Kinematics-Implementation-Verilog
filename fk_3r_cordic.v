`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2025 21:44:24
// Design Name: 
// Module Name: fk_3r_cordic
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


module fk_3r_cordic (
    input clk,
    input rst,
    input start,
    input signed [15:0] theta1,
    input signed [15:0] theta2,
    input signed [15:0] theta3,
    input signed [15:0] L1,
    input signed [15:0] L2,
    input signed [15:0] L3,
    output reg signed [31:0] X,
    output reg signed [31:0] Y,
    output reg done
);

    wire [15:0] angle1 = theta1;
    wire [15:0] angle2 = theta1 + theta2;
    wire [15:0] angle3 = theta1 + theta2 + theta3;

    wire signed [15:0] cos1, sin1, cos2, sin2, cos3, sin3;
    wire done1, done2, done3;

    reg stage1_done, stage2_done, stage3_done;

    reg s1_start, s2_start, s3_start;

    cordic_sin_cos cordic1 (.clk(clk), .rst(rst), .start(s1_start), .angle_in(angle1), .cos_out(cos1), .sin_out(sin1), .done(done1));
    cordic_sin_cos cordic2 (.clk(clk), .rst(rst), .start(s2_start), .angle_in(angle2), .cos_out(cos2), .sin_out(sin2), .done(done2));
    cordic_sin_cos cordic3 (.clk(clk), .rst(rst), .start(s3_start), .angle_in(angle3), .cos_out(cos3), .sin_out(sin3), .done(done3));

    reg [3:0] state;
    localparam IDLE = 0, START1 = 1, WAIT1 = 2, START2 = 3, WAIT2 = 4,
               START3 = 5, WAIT3 = 6, COMPUTE = 7, DONE = 8;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            X <= 0;
            Y <= 0;
            {s1_start, s2_start, s3_start} <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        s1_start <= 1;
                        state <= START1;
                    end
                end

                START1: begin
                    s1_start <= 0;
                    state <= WAIT1;
                end

                WAIT1: begin
                    if (done1) begin
                        s2_start <= 1;
                        state <= START2;
                    end
                end

                START2: begin
                    s2_start <= 0;
                    state <= WAIT2;
                end

                WAIT2: begin
                    if (done2) begin
                        s3_start <= 1;
                        state <= START3;
                    end
                end

                START3: begin
                    s3_start <= 0;
                    state <= WAIT3;
                end

                WAIT3: begin
                    if (done3) begin
                        state <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    X <= (L1 * cos1 + L2 * cos2 + L3 * cos3) >>> 15;
                    Y <= (L1 * sin1 + L2 * sin2 + L3 * sin3) >>> 15;
                    state <= DONE;
                end

                DONE: begin
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule

