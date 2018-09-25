function [ok,mess,proj_update,pbin_update,ndims,pin,en] = cut_sqw_check_pbins (header, data, proj, pbin)
% Check that the binning arguments are valid, and update the projetion with the current projection
%
%   >> [ok,mess,proj_update,pbin_update,ndims,pin,en] = cut_sqw_check_pbins (header, data, proj, pbin)
%
% Input:
% ------

% Get some 'average' quantities for use in calculating transformations and bin boundaries
% -----------------------------------------------------------------------------------------
% *** assumes that all the contributing spe files had the same lattice parameters and projection axes
% This could be generalised later - but with repercussions in many routines
header_ave=header_average(header);

en = header_ave.en;  % energy bins for synchronisation with when constructing defaults
upix_to_rlu = header_ave.u_to_rlu(1:3,1:3);
upix_offset = header_ave.uoffset;

% Get current plot and integration axis bin boundaries
% ----------------------------------------------------
% Construct bin boundaries cellarray for input data set, including integration axes as a single bin
% These will be the default bin inputs when computing the output bin boundary and integration ranges
% If proj is not empty, then the input pbin will be be correctly ordered as the projection axes,
% but if proj is empty, then the input pbin will have to be reordered according to the
% display axis field
pin=cell(1,4);
pin(data.pax)=data.p;   % works even if zero elements
if ~isempty(data.iax)
    pin(data.iax)=mat2cell(data.iint,2,ones(1,numel(data.iax)));
end

% Get matrix to convert from projection axes of input data to required output projection axes
% -------------------------------------------------------------------------------------------
% The conversion here is that for the projection axes in which the plot and integration axes of the data section
% are expressed. Recall that this is not necessarily the same as that in which the individual pixel information is
% expressed.
proj_update = proj;
if ~isempty(proj_update)
    % New projection provided
    proj_update = proj_update.retrieve_existing_tranf(data,upix_to_rlu,upix_offset);
    pbin_update = pbin;
    
else
    % Recover initial projection
    proj_update = projection();  % empty instance of the projaxes class
    proj_update = proj_update.retrieve_existing_tranf(data,upix_to_rlu,upix_offset);
    
    % Reorder pbin to correspond to the input plotting axes (currently refer to display axes)
    % The current display axis limits will be inserted later from the variable pin
    pbin_update=cell(1,4);
    for i=1:numel(data.pax)
        j=data.dax(i);   % plot axis corresponding to ith binning argument
        pbin_update(data.pax(j))=pbin(i);
    end
    
end

% Resolve multiple integration axes
[ok, mess, pbin_update, ndims] = cut_sqw_calc_pbins (data.urange, proj_update, pbin_update, pin, en);
