function inplaceTest(x)
% Call functions with either regular or in-place semantics.
% Straight from Matlab web page, "Loren and the Art of Matlab" 22 March 2007
% Modified to make more CPU intense
% Test with:
% n = 38*2^20; x = randn(n,1);

%% Call a Regular Function with the Same Left-Hand Side
disp('myfunc...')
x = myfunc(x); 
%% Call an In-place Function with the Same Left-Hand Side
disp('myfuncIP...')
x = myfuncIP(x); 
%% Call a Regular Function with a Different Left-Hand Side
disp('myfunc...')
y = myfunc(x); 
%% Call an In-place Function with Same Left-Hand Side
% Note: if we changed this next call to assign output to a new LHS, we get an error
disp('myfuncIP...')
x = myfuncIP(x); 
end

function x = myfuncIP(x)
x = exp(tan(sin(2*x.^2+3*x+4)));
end


function y = myfunc(x)
y = exp(tan(sin(2*x.^2+3*x+4)));
end