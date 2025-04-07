`timescale 1ns / 1ps
module forward_kinematics (
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

    // Intermediate angles
    reg signed [15:0] theta12, theta123;

    always @(*) begin
        theta12 = theta1 + theta2;
        theta123 = theta12 + theta3;

        X = (L1 * cos_approx(theta1) + 
             L2 * cos_approx(theta12) + 
             L3 * cos_approx(theta123)) / 1000;

        Y = (L1 * sin_approx(theta1) + 
             L2 * sin_approx(theta12) + 
             L3 * sin_approx(theta123)) / 1000;
    end
endmodule
