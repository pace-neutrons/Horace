function [b1, b2] = method_3in_2out (obj, a1, a2, a3)
b1 = 10*sin(obj.age) + sin(10*a1) + a3;
b2 = 10*cos(obj.age) + exp(0.1*a2) + a3;
end
