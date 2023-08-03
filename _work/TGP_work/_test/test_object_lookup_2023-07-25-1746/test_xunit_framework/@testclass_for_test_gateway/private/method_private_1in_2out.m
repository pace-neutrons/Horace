function [b1, b2] = method_private_1in_2out (obj, a1)
b1 = 10*sin(obj.age) + 10*a1;
b2 = 10*cos(obj.age) + 10*a1.^2;
end
