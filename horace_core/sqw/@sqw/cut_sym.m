function varargout = cut_sym (varargin)
% Take a cut from an sqw object, with symmetrisation, by integrating over one or more axes.
%
% Cut using existing projection axes:
%   >> w = cut_sym (data_source, p1_bin, p2_bin..., sym)
%                                               %(as many binning arguments
%                                               % as there are plot axes)
%
% Cut with new projection axes:
%   >> w = cut_sym (data_source, proj, p1_bin, p2_bin, p3_bin, p4_bin, sym)
%
%   >> w = cut_sym (..., '-nopix')      % output cut is dnd structure (i.e. no
%                                   % pixel information is retained)
%
%   >> w = cut_sym (..., '-save')       % save cut to file (prompts for file)
%   >> w = cut_sym (...,  filename)     % save cut to named file
%
% For both the above: return the cuts for each symmetry related cut as well
%   >> [w, wsym] = cut_sym (...)
%
% Write directly to file without creating an output object (useful if the
% output is a large dataset in order to avoid out-of-memory errors)
%
%   >> cut_sym (...)
%
% Input:
% ------
%   data_source     Data source: sqw file name or sqw-type object
%                  Can also be a cell array of file names or an array of
%                  sqw objects.
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
%   sym             Symmetry operator (or an array of symmetry operators
%                  to be applied in the order sym(1), sym(2),...)
%                  by which a symmetry related cut is to be accumulated.
%                   Must have class symop.
%
%                   For several symmetry related cuts, provide a cell array
%                  of symmetry operators and/or arrays of symmetry operators
%           EXAMPLES
%                   s1 = symop ([1,0,0],[0,1,0],[1,1,1]);
%                   s2 = symop ([1,0,0],[0,0,1],[1,1,1]);
%                   % For all four symmetry related cuts:
%                   sym = {s1,s2,[s1,s2]};
%
%
% Output:
% -------
%   w               Output data object:
%                     - sqw-type object with full pixel information
%                     - dnd-type object if option '-nopix' given
%                   If an array of input data sources was given, then w
%                  is an array
%
%   wsym            Array of data objects, one for each symmetry related cut
%                   If an array of input data sources was given, then w
%                  is a cell array of arrays



% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)


% Parse input
% -----------
[w, args, mess] = horace_function_parse_input (nargout,varargin{:});
if ~isempty(mess), error(mess); end

% Perform operations
% ------------------
nout=w.nargout_req;
nw=numel(w.data);

if all(w.sqw_type(:))
    % sqw type data
    if numel(args)>=1 && ~isstruct(args{1}) % proj structure not given, so all sqw objects must have same dimensionality
        if ~all(w.ndims==w.ndims(1))
            error('All sqw objects must have same dimensionality if not using new projection axes')
        end
    end
    for i=1:nw
        if nout>0
            if nout==1
                if i==1
                    wout=cut_sqw_sym_main(w.data(i),w.ndims(i),args{:});
                    if nw>1
                        cut_array = (numel(wout)>1);
                        if ~cut_array
                            wout=repmat(wout,size(w.data));     % make array
                        else
                            wout=repmat({wout},size(w.data));   % make cell array
                        end
                    end
                else
                    if ~cut_array
                        wout(i)=cut_sqw_sym_main(w.data(i),w.ndims(i),args{:});
                    else
                        wout{i}=cut_sqw_sym_main(w.data(i),w.ndims(i),args{:});
                    end
                end
            else
                if i==1
                    [wout,wsym]=cut_sqw_sym_main(w.data(i),w.ndims(i),args{:});
                    if nw>1
                        cut_array = (numel(wout)>1);
                        if ~cut_array
                            wout=repmat(wout,size(w.data));     % make array
                        else
                            wout=repmat({wout},size(w.data));   % make cell array
                        end
                        wsym=repmat({wsym},size(w.data));   % make cell array
                    end
                else
                    if ~cut_array
                        [wout(i),wsym{i}]=cut_sqw_sym_main(w.data(i),w.ndims(i),args{:});
                    else
                        [wout{i},wsym{i}]=cut_sqw_sym_main(w.data(i),w.ndims(i),args{:});
                    end
                end
            end
        else
            cut_sqw_sym_main(w.data(i),w.ndims(i),args{:});
        end
    end
elseif ~any(w.sqw_type(:)) && all(w.ndims==w.ndims(1))
    % dnd type data
    for i=1:nw
        if nout>0
            if nout==1
                if i==1
                    wout=cut_dnd_sym_main(w.data(i),w.ndims(i),args{:});
                    if nw>1
                        cut_array = (numel(wout)>1);
                        if ~cut_array
                            wout=repmat(wout,size(w.data));     % make array
                        else
                            wout=repmat({wout},size(w.data));   % make cell array
                        end
                    end
                else
                    if ~cut_array
                        wout(i)=cut_dnd_sym_main(w.data(i),w.ndims(i),args{:});
                    else
                        wout{i}=cut_dnd_sym_main(w.data(i),w.ndims(i),args{:});
                    end
                end
            else
                if i==1
                    [wout,wsym]=cut_dnd_sym_main(w.data(i),w.ndims(i),args{:});
                    if nw>1
                        cut_array = (numel(wout)>1);
                        if ~cut_array
                            wout=repmat(wout,size(w.data));     % make array
                        else
                            wout=repmat({wout},size(w.data));   % make cell array
                        end
                        wsym=repmat({wsym},size(w.data));   % make cell array
                    end
                else
                    if ~cut_array
                        [wout(i),wsym{i}]=cut_dnd_sym_main(w.data(i),w.ndims(i),args{:});
                    else
                        [wout{i},wsym{i}]=cut_dnd_sym_main(w.data(i),w.ndims(i),args{:});
                    end
                end
            end
        else
            cut_dnd_sym_main(w.data(i),w.ndims(i),args{:});
        end
    end
else
    error('Data files must all be sqw type, or all dnd type with same dimensionality')
end

if nout>0
    argout{1}=wout;
    if nout==2
        argout{2}=wsym;
    end
else
    argout={};
end

% Package output arguments
% ------------------------
[varargout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end

