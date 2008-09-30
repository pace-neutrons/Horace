function str = rand_digit_string(n)
% Create string of n random digits
digits=max(0,min(9,floor(10*rand(1,n))));
str=blanks(n);
for i=1:n
    str(i)= int2str(digits(i));
end
