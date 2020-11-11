function c = dot_special(a,b)
%accelerated dot product function, without error catching.
c = sum(conj(a).*b);

