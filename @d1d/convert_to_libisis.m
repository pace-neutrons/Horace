function dout = convert_to_libisis(din)
% IXTdataset_1d converter for d1d in horrace
%
% >> dout = IXTdataset_1d(din)
%
% converts a Horace d1d object into a libisis IXTdataset_1d object. Useful
% for arithmetic operations. However, any header information is lost.
%
% inputs:
%           din -       Horace d1d object
% Outputs:
%           dout -      libisis IXTdataset_1d object

dout = IXTdataset_1d;

for i = 1:numel(din)
    unitscode = char('e'.* (din(i).pax == 4) + 'q'.*(din(i).pax~=4));

    dout(i) = IXTdataset_1d(IXTbase('unknown', false, true), din(i).title, din(i).s', sqrt(din(i).e'), ... 
        IXTunits(IXTbase('unknown', false, true), 'arb', 'Intensity'),...
            din(i).p1', IXTunits(IXTbase('unknown', false, true), unitscode(1), din(i).label{din(i).pax}),...
            false);
end
