function wout = cut_sqw_main (data_source, ndims_source, varargin)
% Take a cut from an sqw object by integrating over one or more axes.
%
% Cut using existing projection axes:
%   >> w = cut_sqw_main (data_source, ndims_source, p1_bin, p2_bin...)
%                                           %(as many binning arguments
%                                           % as there are plot axes)
%
% Cut with new projection axes:
%   >> w = cut_sqw_main (data_source, ndims_source, proj, p1_bin, p2_bin, p3_bin, p4_bin)
%
%   >> w = cut_sqw_main (..., '-nopix')     % output cut is dnd structure (i.e. no
%                                           % pixel information is retained)
%
%   >> w = cut_sqw_main (..., '-save')      % save cut to file (prompts for file)
%   >> w = cut_sqw_main (...,  filename)    % save cut to named file
%
% Write directly to file without creating an output object (useful if the
% output is a large dataset in order to avoid out-of-memory errors)
%
%   >> cut_sqw_main (...)
%
%
% Input:
% ------
%   data_source     Data source: sqw object or filename of a file with sqw-type data
%                  (character string or cellarray with one character string)
%
%   ndims           Number of dimensions of the sqw data
%
%   proj            Data structure containing details of projection axes,
%                  with fields described below. Alternatively, a projaxes
%                  object created from those fields (type >> help projaxes
%                  for details).
%     ---------------------------------------------------------------------
%     Required fields:
%       u           [1x3] Vector of first axis (r.l.u.) defining projection axes
%       v           [1x3] Vector of second axis (r.l.u.) defining projection axes
%
%     Optional fields:
%       w           [1x3] Vector of third axis (r.l.u.) - only needed if the third
%                   character of argument 'type' is 'p'. Will otherwise be ignored.
%
%       nonorthogonal Indicate if non-orthogonal axes are permitted
%                   If false (default): construct orthogonal axes u1,u2,u3 from u,v
%                   by defining: u1 || u; u2 in plane of u and v but perpendicular
%                   to u with positive component along v; u3 || u x v
%
%                   If true: use u,v (and w, if given) as non-orthogonal projection
%                   axes: u1 || u, u2 || v, u3 || w if given, or u3 || u x v if not.
%
%       type        [1x3] Character string defining normalisation. Each character
%                   indicates how u1, u2, u3 are normalised, as follows:
%                   - if 'a': projection axis unit length is one inverse Angstrom
%                   - if 'r': then if ui=(h,k,l) in r.l.u., is normalised so
%                             max(abs(h,k,l))=1
%                   - if 'p': if orthogonal projection axes:
%                                   |u1|=|u|, (u x u2)=(u x v), (u x u3)=(u x w)
%                               i.e. the projections of u,v,w along u1,u2,u3 match
%                               the lengths of u1,u2,u3
%
%                             if non-orthogonal axes:
%                                   u1=u;  u2=v;  u3=w
%                   Default:
%                         'ppr'  if w not given
%                         'ppp'  if w is given
%
%         uoffset   Row or column vector of offset of origin of projection axes (rlu)
%
%       lab         Short labels for u1,u2,u3,u4 as cell array
%                   e.g. {'Q_h', 'Q_k', 'Q_l', 'En'})
%                       *OR*
%       lab1        Short label for u1 axis (e.g. 'Q_h' or 'Q_{kk}')
%       lab2        Short label for u2 axis
%       lab3        Short label for u3 axis
%       lab4        Short label for u4 axis (e.g. 'E' or 'En')
%     ---------------------------------------------------------------------
%
%   p1_bin          Binning along first Q axis
%   p2_bin          Binning along second Q axis
%   p3_bin          Binning along third Q axis
%           - [] or ''          Plot axis: use bin boundaries of input data
%           - [pstep]           Plot axis: sets step size; plot limits
%                              taken from the extent of the data
%           - [plo, phi]        Integration axis: range of integration
%           - [plo, pstep, phi] Plot axis: minimum and maximum bin centres
%                              and step size
%
%   p4_bin          Binning along the energy axis:
%           - [] or ''          Plot axis: use bin boundaries of input data
%           - [pstep]           Plot axis: sets step size; plot limits
%                              taken from the extent of the data.
%                               If pstep=0 then use bin size of the first
%                              spe file and synchronise the output bin
%                              boundaries with those boundaries. The overall
%                              range is chosen to ensure that the energy
%                              range of the input data is contained within
%                              the bin boundaries.
%           - [plo, phi]        Integration axis: range of integration
%           - [plo, pstep, phi] Plot axis: minimum and maximum bin centres
%                              and step size.
%                               If pstep=0 then use bin size of the first
%                              spe file and synchronise the output bin
%                              boundaries with the reference boundaries.
%                              The overall range is chosen to ensure that
%                              the energy range plo to phi is contained
%                              within the bin boundaries.
%
%
% Output:
% -------
%   w               Output data object:
%                     - sqw-type object with full pixel information
%                     - dnd-type object if option '-nopix' given


% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)


% *** Currently only works if uoffset(4)=0 for input, output datasets

hor_log_level = config_store.instance().get_value('herbert_config','log_level');


% Parse input arguments
% ---------------------
return_cut = (nargout>0);

[ok, mess, data_source, proj, pbin, args, opt] = ...
    cut_sqw_check_input_args (data_source, ndims_source, return_cut, varargin{:});
if ~ok
    error ('CUT_SQW:invalid_arguments', mess)
end

% Ensure there are no excess input arguments
if numel(args)~=0
    error ('CUT_SQW:invalid_arguments', 'Check the number and type of input arguments')
end


% Read the header information (or if data source is an object, unpack the major fields)
% -------------------------------------------------------------------------------------
[ok, mess, main_header, header, detpar, data, npixtot, pix_position] = ...
    cut_sqw_read_data (data_source, hor_log_level);
if ~ok
    error ('CUT_SQW:invalid_arguments', mess)
end
% Get some 'average' quantities for use in calculating transformations and bin boundaries
% -----------------------------------------------------------------------------------------
% *** assumes that all the contributing spe files had the same lattice parameters and projection axes
% This could be generalised later - but with repercussions in many routines
header_ave=header_average(header);


% Update projection by current projection, and reorder binning descriptors
% ------------------------------------------------------------------------
% Properties of proj are updated to hold projection information for the
% input projection axes, and if proj is not given pbin is reordered from the
% display axes to the input projection axes. Multiple integration axes are
% determined and the corresponding elements of pbin are turned into two
% dimensional arrays.
[proj, pbin, ndims, pin, en] = proj.update_pbins(header_ave, data,pbin);

% Perform cuts
% ------------
sz = cellfun(@(x)max(size(x,1),1),pbin);     % size of array of cuts (note: numel(wsize)==4)
if return_cut
    sz_squeeze = [sz(sz>1),ones(1,max(2-sum(sz>1),0))];
    if opt.keep_pix
        wout = repmat(sqw,sz_squeeze);
    else
        wout = eval(['repmat(d',num2str(ndims),'d,sz_squeeze)']);
    end
end
for i=1:prod(sz)
    % Get pbin for each cut (allow for a bin descriptor being empty)
    [i1,i2,i3,i4] = ind2sub(sz,i);
    pbin_tmp = cell(1,4);
    if ~isempty(pbin{1}), pbin_tmp{1}=pbin{1}(i1,:); else, pbin_tmp{1}=pbin{1}; end
    if ~isempty(pbin{2}), pbin_tmp{2}=pbin{2}(i2,:); else, pbin_tmp{2}=pbin{2}; end
    if ~isempty(pbin{3}), pbin_tmp{3}=pbin{3}(i3,:); else, pbin_tmp{3}=pbin{3}; end
    if ~isempty(pbin{4}), pbin_tmp{4}=pbin{4}(i4,:); else, pbin_tmp{4}=pbin{4}; end
    
    % Make cut
    if return_cut
        wout(i) = cut_sqw_main_single (data_source,...
            main_header, header, detpar, data, npixtot, pix_position,...
            proj, pbin_tmp, pin, en, opt, hor_log_level);
    else
        cut_sqw_main_single (data_source,...
            main_header, header, detpar, data, npixtot, pix_position,...
            proj, pbin_tmp, pin, en, opt, hor_log_level);
    end
end
