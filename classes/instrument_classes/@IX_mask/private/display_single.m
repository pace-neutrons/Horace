function display_single (w)
% Display useful information from a single instance of an object i.e. a scalar instance
%
%   >> display_single(w)
%
% *** REQUIRED PRIVATE METHOD ***

n=numel(w.msk);
disp(' ')
if n==0
    disp( '   Empty mask')
else
    disp(['   Mask with ',num2str(numel(w.msk)),' entries'])
end
disp(' ')
