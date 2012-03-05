function [ok,xlab,xunit] = units_to_caption (units, emode)
% Determine if a unit is valid, and return x-axis caption and unit
%
%   >> [ok,cap,ucap] = isvalid_units (units, emode)
%
% Input:
% ------
%   units   Units code(s) along x-axis e.g. 'lam' or {'t','tau'} (lower case only; character string or cell array of strings)
%          Valid units (depending on the energy mode) are:
%               t       time-of-flight
%               d       d-spacing (elastic only)
%               v       neutron velocity         (also v1,   v2   for inelastic indirect and direct respectively)
%               tau     inverse neutron velocity (also tau1, tau2 for inelastic indirect and direct respectively)
%               lam     wavelength               (also lam1, lam2 for inelastic indirect and direct respectively)
%               k       wavevector               (also k1,   k2   for inelastic indirect and direct respectively)
%               e       neutron energy           (also e1,   e2   for inelastic indirect and direct respectively)
%               w       energy transfer (meV)    (inelastic only)
%               wn      energy transfer (cm^-1)  (inelastic only)
%               thz     energy transfer (THz)    (inelastic only)
%               q       momentum transfer
%               q+      momentum transfer        (inelastic only)
%               q-      momentum transfer        (inelastic only)
%               sq      square of momentum transfer
%               sq+     square of momentum transfer (inelastic only)
%               sq-     square of momentum transfer (inelastic only)
%
%          If direct geometry (i.e. emode=1) the neutron wavelength, velocity etc.
%          refer to the final energy; if indirect geometry (i.e. emode=2) they
%          refer to the incident energy.
%
%   emode   Energy mode: 0,1 or 2 for elastic, direct geometry or indirect geometry (scalar or array)
%          Must have same number of elements as there are unit codes
%
% Output:
% -------
%   ok          =true all OK; false otherwise
%   xlab        Caption for x-axis (character string or cell array of strings, according as input argument 'units')
%              String is empty if corresponding input unit is invalid
%   xunit       Units for caption (character string or cell array of strings, according as input argument 'units')
%              String is empty if corresponding input unit is invalid

persistent u

if (isempty(u))
    units_arr=cell(49,1); emode_arr=zeros(49,1); xlab_arr=cell(49,1); xunit_arr=cell(49,1);
	units_arr{1} ='t';    emode_arr(1) =0; xlab_arr{1} ='Time-of-flight';              xunit_arr{1} ='{\mu}s';
    units_arr{2} ='t';    emode_arr(2) =1; xlab_arr{2} ='Time-of-flight';              xunit_arr{2} ='{\mu}s';
    units_arr{3} ='t';    emode_arr(3) =2; xlab_arr{3} ='Time-of-flight';              xunit_arr{3} ='{\mu}s';
    units_arr{4} ='v';    emode_arr(4) =0; xlab_arr{4} ='Velocity';                    xunit_arr{4} ='m/s';
    units_arr{5} ='v';    emode_arr(5) =1; xlab_arr{5} ='Final velocity';              xunit_arr{5} ='m/s';
    units_arr{6} ='v';    emode_arr(6) =2; xlab_arr{6} ='Incident velocity';           xunit_arr{6} ='m/s';
    units_arr{7} ='v1';   emode_arr(7) =1; xlab_arr{7} ='Final velocity';              xunit_arr{7} ='m/s';
    units_arr{8} ='v2';   emode_arr(8) =2; xlab_arr{8} ='Incident velocity';           xunit_arr{8} ='m/s';
    units_arr{9} ='tau';  emode_arr(9) =0; xlab_arr{9} ='Reciprocal velocity';         xunit_arr{9} ='s/m';
    units_arr{10}='tau';  emode_arr(10)=1; xlab_arr{10}='Final reciprocal velocity';   xunit_arr{10}='s/m';
    units_arr{11}='tau';  emode_arr(11)=2; xlab_arr{11}='Incident reciprocal velocity';xunit_arr{11}='s/m';
    units_arr{12}='tau1'; emode_arr(12)=1; xlab_arr{12}='Final reciprocal velocity';   xunit_arr{12}='s/m';
    units_arr{13}='tau2'; emode_arr(13)=2; xlab_arr{13}='Incident reciprocal velocity';xunit_arr{13}='s/m';
    units_arr{14}='lam';  emode_arr(14)=0; xlab_arr{14}='Wavelength';                  xunit_arr{14}='Å';
    units_arr{15}='lam';  emode_arr(15)=1; xlab_arr{15}='Final wavelength';            xunit_arr{15}='Å';
    units_arr{16}='lam';  emode_arr(16)=2; xlab_arr{16}='Incident wavelength';         xunit_arr{16}='Å';
    units_arr{17}='lam1'; emode_arr(17)=1; xlab_arr{17}='Final wavelength';            xunit_arr{17}='Å';
    units_arr{18}='lam2'; emode_arr(18)=2; xlab_arr{18}='Incident wavelength';         xunit_arr{18}='Å';
    units_arr{19}='k';    emode_arr(19)=0; xlab_arr{19}='Wavelength';                  xunit_arr{19}='Å^{-1}';
    units_arr{20}='k';    emode_arr(20)=1; xlab_arr{20}='Final wavelength';            xunit_arr{20}='Å^{-1}';
    units_arr{21}='k';    emode_arr(21)=2; xlab_arr{21}='Incident wavelength';         xunit_arr{21}='Å^{-1}';
    units_arr{22}='k1';   emode_arr(22)=1; xlab_arr{22}='Final wavelength';            xunit_arr{22}='Å^{-1}';
    units_arr{23}='k2';   emode_arr(23)=2; xlab_arr{23}='Incident wavelength';         xunit_arr{23}='Å^{-1}';
    units_arr{24}='e';    emode_arr(24)=0; xlab_arr{24}='Energy';                      xunit_arr{24}='meV';
    units_arr{25}='e';    emode_arr(25)=1; xlab_arr{25}='Final energy';                xunit_arr{25}='meV';
    units_arr{26}='e';    emode_arr(26)=2; xlab_arr{26}='Incident energy';             xunit_arr{26}='meV';
    units_arr{27}='e1';   emode_arr(27)=1; xlab_arr{27}='Final energy';                xunit_arr{27}='meV';
    units_arr{28}='e2';   emode_arr(28)=2; xlab_arr{28}='Incident energy';             xunit_arr{28}='meV';
    units_arr{29}='w';    emode_arr(29)=1; xlab_arr{29}='Energy transfer';             xunit_arr{29}='meV';
    units_arr{30}='w';    emode_arr(30)=2; xlab_arr{30}='Energy transfer';             xunit_arr{30}='meV';
    units_arr{31}='wn';   emode_arr(31)=1; xlab_arr{31}='Energy transfer';             xunit_arr{31}='cm^{-1}';
    units_arr{32}='wn';   emode_arr(32)=2; xlab_arr{32}='Energy transfer';             xunit_arr{32}='cm^{-1}';
    units_arr{33}='thz';  emode_arr(33)=1; xlab_arr{33}='Energy transfer';             xunit_arr{33}='THz';
    units_arr{34}='thz';  emode_arr(34)=2; xlab_arr{34}='Energy transfer';             xunit_arr{34}='THz';
    units_arr{35}='q';    emode_arr(35)=0; xlab_arr{35}='Momentum transfer';           xunit_arr{35}='Å^{-1}';
    units_arr{36}='q';    emode_arr(36)=1; xlab_arr{36}='Momentum transfer';           xunit_arr{36}='Å^{-1}';
    units_arr{37}='q';    emode_arr(37)=2; xlab_arr{37}='Momentum transfer';           xunit_arr{37}='Å^{-1}';
    units_arr{38}='q-';   emode_arr(38)=1; xlab_arr{38}='Momentum transfer';           xunit_arr{38}='Å^{-1}';
    units_arr{39}='q+';   emode_arr(39)=2; xlab_arr{39}='Momentum transfer';           xunit_arr{39}='Å^{-1}';
    units_arr{40}='q-';   emode_arr(40)=1; xlab_arr{40}='Momentum transfer';           xunit_arr{40}='Å^{-1}';
    units_arr{41}='q+';   emode_arr(41)=2; xlab_arr{41}='Momentum transfer';           xunit_arr{41}='Å^{-1}';
    units_arr{42}='sq';   emode_arr(42)=0; xlab_arr{42}='Momentum transfer squared';   xunit_arr{42}='Å^{-2}';
    units_arr{43}='sq';   emode_arr(43)=1; xlab_arr{43}='Momentum transfer squared';   xunit_arr{43}='Å^{-2}';
    units_arr{44}='sq';   emode_arr(44)=2; xlab_arr{44}='Momentum transfer squared';   xunit_arr{44}='Å^{-2}';
    units_arr{45}='sq-';  emode_arr(45)=1; xlab_arr{45}='Momentum transfer squared';   xunit_arr{45}='Å^{-2}';
    units_arr{46}='sq-';  emode_arr(46)=2; xlab_arr{46}='Momentum transfer squared';   xunit_arr{46}='Å^{-2}';
    units_arr{47}='sq+';  emode_arr(47)=1; xlab_arr{47}='Momentum transfer squared';   xunit_arr{47}='Å^{-2}';
    units_arr{48}='sq+';  emode_arr(48)=2; xlab_arr{48}='Momentum transfer squared';   xunit_arr{48}='Å^{-2}';
    units_arr{49}='d';    emode_arr(49)=0; xlab_arr{49}='D-spacing';                   xunit_arr{49}='Å';
    u.units_arr=units_arr; u.emode_arr=emode_arr; u.xlab_arr=xlab_arr; u.xunit_arr=xunit_arr;
end

if ischar(units) && isnumeric(emode) && numel(emode)==1
    ind=find(strcmpi(units,u.units_arr) & emode==u.emode_arr,1);
    if ~isempty(ind)
        ok=true;
        if nargout>1
            xlab=u.xlab_arr{ind};
            xunit=u.xunit_arr{ind};
        end
    else
        ok=false;
        if nargout>1
            xlab='';
            xunit='';
        end
    end
elseif iscellstr(units) && isnumeric(emode) && numel(units)==numel(emode)
    ok=false(size(units));
    if nargout>1
        xlab=cell(size(units));
        xunit=cell(size(units));
    end
    for i=1:numel(units)
        ind=find(strcmpi(units{i},u.units_arr) & emode(i)==u.emode_arr,1);
        if ~isempty(ind)
            ok(i)=true;
            if nargout>1
                xlab{i}=u.xlab_arr{ind};
                xunit{i}=u.xunit_arr{ind};
            end
        else
            ok(i)=false;
            if nargout>1
                xlab{i}='';
                xunit{i}='';
            end
        end
    end
else
    error('Check units are character string or cellstr, emode is numeric, and that the number of elements of each are equal')
end
