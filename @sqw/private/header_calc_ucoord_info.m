function [kfix,emode,ne,k,en,spec_to_pix]=header_calc_ucoord_info(h)
% Create information required to compute pixel coordinates
%
%   >> [efix,emode,ne,en,spec_to_pix]=header_calc_ucoord_info(h)
%
% Input:
% ------
%   h               Header block for sqw data: scalar structure (if single spe
%                   file) or cell array of structures, one per spe file
%
%
% Output:
% -------
%   kfix            Column vector with fixed wavevector for each run in the header (Ang^-1)
%
%   emode           Column vector with fixed emode (0,1,2) for each run in the header
%                   Direct geometry=1, indirect geometry=2, elastic=0
%
%   ne              Column vector with number of energy bins for each run in the header
%
%   k               Cell array of column vectors, one per run, with centres of the energy bins
%                   converted to wavevector (Ang^-1)
%
%   en              Cell array of column vectors, one per run, with centres of the energy bins
%                   in meV
%
%   spec_to_pix     Cell array (column) of the matricies to convert spectrometer coordinates
%                   (x-axis along ki, z-axis vertically upwards) to pixel coordinates.
%                   Need to account for the possibility that the crystal has been reoriented,
%                   in which case the pixels are no longer in crystal Cartesian coordinates.

c=neutron_constants;
k_to_e = c.c_k_to_emev;

if ~iscell(h)
    efix=h.efix;
    kfix=sqrt(efix/k_to_e);
    emode=h.emode;
    ne=numel(h.en)-1;
    en={0.5*(h.en(2:end)+h.en(1:end-1))};
    if emode==1
        k={sqrt((efix-en{1})/k_to_e)};
    elseif emode==2
        k={sqrt((efix+en{1})/k_to_e)};
    elseif emode==0
        k={(2*pi)./exp(en{1})};     % The en array is assumed to have bin centres as the logarithm of wavelength
    end
    [spec_to_xcart, xcart_to_rlu, spec_to_rlu] = calc_proj_matrix (h.alatt, h.angdeg,...
        h.cu, h.cv, h.psi, h.omega, h.dpsi, h.gl, h.gs);
    spec_to_pix={h.u_to_rlu(1:3,1:3)\spec_to_rlu};
else
    nspe=numel(h);
    kfix=zeros(nspe,1);
    emode=zeros(nspe,1);
    ne=zeros(nspe,1);
    k=cell(nspe,1);
    en=cell(nspe,1);
    spec_to_pix=cell(nspe,1);
    for i=1:numel(h)
        efix=h{i}.efix;
        kfix(i)=sqrt(efix/k_to_e);
        emode(i)=h{i}.emode;
        ne(i)=numel(h{i}.en)-1;
        en{i}=0.5*(h{i}.en(2:end)+h{i}.en(1:end-1));
        if emode(i)==1
            k{i}=sqrt((efix-en{i})/k_to_e);
        elseif emode(i)==2
            k{i}=sqrt((efix+en{i})/k_to_e);
        elseif emode(i)==0
            k{i}=(2*pi)./exp(en{i});    % The en array is assumed to have bin centres as the logarithm of wavelength
        end
        [spec_to_xcart, xcart_to_rlu, spec_to_rlu] = calc_proj_matrix (h{i}.alatt, h{i}.angdeg,...
            h{i}.cu, h{i}.cv, h{i}.psi, h{i}.omega, h{i}.dpsi, h{i}.gl, h{i}.gs);
        spec_to_pix{i}=h{i}.u_to_rlu(1:3,1:3)\spec_to_rlu;
    end
end
