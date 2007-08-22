function dout = convert_to_libisis(din)
% IXTdataset_3d converter for d3d in horace
%
% >> dout = convert_to_libisis(din)
%
% converts a Horace d3d object into a libisis IXTdataset_3d object. Useful
% for arithmetic operations. However, any header information is lost.
%
% inputs:
%           din -       Horace d3d object
% Outputs:
%           dout -      libisis IXTdataset_3d object

dout = IXTdataset_3d;

for i = 1:numel(din)
    unitscode = char('e'.* (din(i).pax == 4) + 'q'.*(din(i).pax~=4));

    dout(i) = IXTdataset_3d(IXTbase('unknown', false, true), din(i).title, din(i).s, sqrt(din(i).e), ... 
        IXTunits(IXTbase('unknown', false, true), 'arb', 'Intensity'),...
            din(i).p1', IXTunits(IXTbase('unknown', false, true), unitscode(1), din(i).label{din(i).pax(1)}), false, ...
            din(i).p2', IXTunits(IXTbase('unknown', false, true), unitscode(2), din(i).label{din(i).pax(2)}), false, ...
            din(i).p3', IXTunits(IXTbase('unknown', false, true), unitscode(3), din(i).label{din(i).pax(3)}), false);
end
