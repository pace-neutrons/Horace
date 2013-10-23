function test_sigvar
% A couple of tests of sigvar objects that once were not handled correctly
%
% Author: T.G.Perring

banner_to_screen(mfilename)

% Data
% ----
k1=sigvar([31,5]);
k2=sigvar([14,16]);
ksum=sigvar([45,21]);

k3=sigvar([20,15,10]);

% Checks
% -------
% Add correctly
tmp=k1+k2;
if ~isequal(ksum,tmp)
    assertTrue(false,'Addition fails')
end

% Should fail to add if different sizes:
try
    tmp=k1+k3;
    mess='''ksum=k2+k3''Should have failed but did not';
catch
    mess='';
end
if ~isempty(mess)
    assertTrue(false,mess)
end

% Success announcement
% --------------------
banner_to_screen([mfilename,': Test(s) passed'],'bot')
