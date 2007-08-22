function dout = convert_to_libisis(din)
% Horace conversion from d0d to IXTdatum function.
%
% >> dout = IXTdatum(din)
%
% inputs:
%       din -   Horace d0d object
% outputs:
%       dout -  Libisis IXTdatum object
%
% purpose: To convert a Horrace d0d object into an IXTdatum object to
% perform operations on it.

dout = IXTdatum;

for i = 1:length(din)
    dout(i) = IXTdatum(IXTbase('unknown', false, true),din(i).s, din(i).e);
end