A = [3,12,65,3,4,3,6,3,2];

[Bref,ixref] = sort(A);


[B,ix] = mergesort_tgp(A);

if ~isequal(Bref,B) || ~isequal(ixref,ix)
    error('Oh crap!')
end
