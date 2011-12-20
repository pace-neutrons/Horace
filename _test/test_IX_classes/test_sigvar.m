% A couple of tests of sigvar objects that once were not handled correctly
% ------------------------------------------------------------------------
% Data
k2=sigvar([31,5]);
l2=sigvar([14,16]);
klsum=sigvar([45,21]);

k3=sigvar([20,15,10]);

% Checks
% -------
% Add correctly
tmp=k2+l2;
if ~isequal(klsum,tmp)
    error('Addition fails')
end

% Should fail to add if different sizes:
try
    ksum=k2+k3;
    mess='''ksum=k2+k3''Should have failed but did not';
catch
    mess='';
end
if ~isempty(mess)
    error(mess)
end
