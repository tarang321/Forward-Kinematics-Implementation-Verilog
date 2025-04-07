`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2025 00:20:30
// Design Name: 
// Module Name: forward_kinematics_retimed
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

module forward_kinematics_retimed (
    
    input clk,
    input rst,
    input signed [15:0] theta1,
    input signed [15:0] theta2,
    input signed [15:0] theta3,
    input signed [15:0] L1,
    input signed [15:0] L2,
    input signed [15:0] L3,
    output reg signed [31:0] X,
    output reg signed [31:0] Y
);

    function signed [15:0] cos_approx(input signed [15:0] angle);
        case(angle)
            0:    cos_approx = 1000;
            30:   cos_approx = 866;
            45:   cos_approx = 707;
            60:   cos_approx = 500;
            90:   cos_approx = 0;
            120:  cos_approx = -500;
            135:  cos_approx = -707;
            150:  cos_approx = -866;
            180:  cos_approx = -1000;
            default: cos_approx = 0;
        endcase
    endfunction

    function signed [15:0] sin_approx(input signed [15:0] angle);
        case(angle)
            0:    sin_approx = 0;
            30:   sin_approx = 500;
            45:   sin_approx = 707;
            60:   sin_approx = 866;
            90:   sin_approx = 1000;
            120:  sin_approx = 866;
            135:  sin_approx = 707;
            150:  sin_approx = 500;
            180:  sin_approx = 0;
            default: sin_approx = 0;
        endcase
    endfunction

    // Pipeline registers
    reg signed [31:0] x1, y1, x2, y2;
    reg signed [15:0] theta12, theta123;

    // Stage 1: Compute L1 * cos(?1), L1 * sin(?1)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x1 <= 0;
            y1 <= 0;
            theta12 <= 0;
        end else begin
            x1 <= L1 * cos_approx(theta1);
            y1 <= L1 * sin_approx(theta1);
            theta12 <= theta1 + theta2;
        end
    end

    // Stage 2: Compute L2 * cos(?1+?2), L2 * sin(?1+?2)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x2 <= 0;
            y2 <= 0;
            theta123 <= 0;
        end else begin
            x2 <= x1 + L2 * cos_approx(theta12);
            y2 <= y1 + L2 * sin_approx(theta12);
            theta123 <= theta12 + theta3;
        end
    end

    // Stage 3: Compute L3 * cos(?1+?2+?3), L3 * sin(?1+?2+?3)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            X <= 0;
            Y <= 0;
        end else begin
            X <= (x2 + L3 * cos_approx(theta123)) / 1000;
            Y <= (y2 + L3 * sin_approx(theta123)) / 1000;
        end
    end

endmodule



