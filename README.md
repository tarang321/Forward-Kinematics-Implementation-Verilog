
# 🤖 3R Planar Robot Forward Kinematics using CORDIC in Verilog

## 📌 Description

This project implements **forward kinematics** for a **3R (3-Revolute joint) planar robotic manipulator** using the **CORDIC algorithm** in Verilog HDL. It is designed for efficient deployment on FPGA hardware, utilizing only **shift-add operations** instead of traditional multipliers or floating-point units, making it optimal for **low-resource and high-speed applications** in robotics and embedded systems.

---

## 📐 Forward Kinematics of a 3R Planar Robot

Given:
- θ₁, θ₂, θ₃ — Joint angles (in radians)
- L₁, L₂, L₃ — Link lengths

The forward kinematics equations are:

X = L1 * cos(θ1) + L2 * cos(θ1 + θ2) + L3 * cos(θ1 + θ2 + θ3)

Y = L1 * sin(θ1) + L2 * sin(θ1 + θ2) + L3 * sin(θ1 + θ2 + θ3)

---

## 🧠 Techniques Used

### ✅ CORDIC Algorithm (Coordinate Rotation Digital Computer)

- **Purpose:** Compute trigonometric functions (sin, cos) using only shift, add, and lookup operations.
- **Type:** Iterative and pipelined
- **Fixed-Point Format:** Q1.15 for angle inputs, Q17.15 for final position outputs

CORDIC is ideal for:
- FPGA-based implementations
- Replacing costly multipliers/dividers
- Situations requiring real-time performance

#### 🔁 Rotation Mode (used here)
CORDIC is run in **rotation mode** to compute:
```verilog
cos(θ) ≈ x_final
sin(θ) ≈ y_final
