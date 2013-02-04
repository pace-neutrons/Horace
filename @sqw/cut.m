function varargout = cut (varargin)
% Take a cut from an sqw object by integrating over one or more of the momentum and energy axes.
%
%   >> w = cut (data_source, p1_bin, p2_bin...)     % cut plot axes, keeping existing integration ranges
%                                                   % (as many binning arguments as there are plot axes)
%
%   >> w = cut (data_source, proj, p1_bin, p2_bin, p3_bin, p4_bin)      % cut with new projection axes
%
%   >> w = cut (..., '-nopix')      % output cut is dnd structure
%
%   >> w = cut (..., '-save')       % Save cut to file (prompt for output file)
%   >> w = cut (...,  filename)     % save cut to named file
%
% For very large output, can avoid out-of-memory errors by writing file without
% making output to workspace:
%
%   >> cut(...)                     % save cut to file without making output to workspace 
% 
% Input:
% ------
%   data_source     Data source: sqw file name or sqw-type object
%
%   proj            Data structure containing details of projection axes:
%                  Defines two vectors u and v that give the direction of u1
%                 (parallel to u) and u2 (in the plane of u1 and u2, with u2
%                  having positive component along v); also defines the 
%                  normalisation of u1,u2,u3
%                   Required arguments:
%                       proj.u          [1x3] Vector of first axis (r.l.u.)
%                       proj.v          [1x3] Vector of second axis (r.l.u.)
%                   Optional arguments:
%                       proj.w          [1x3] Vector of third axis (r.l.u.) - only needed if third character of type is 'p'
%                               Will otherwise be ignored.
%                       proj.type       [1x3] Char. string defining normalisation:
%                           Each character indicates if u1, u2, u3 normalised as follows:
%                           - if 'a': unit length is one inverse Angstrom
%                           - if 'r': then if (h,k,l) in r.l.u., is normalised so max(abs(h,k,l))=1
%                           - if 'p': then normalised so that if the orthogonal set created from u and v is u1, u2, u3:
%                               |u1|=|u|, (u x u2)=(u x v), (u x u3)=(u x w)
%                             i.e. the projections of u,v,w along u1,u2,u3 match the lengths of u1,u2,u3
%                           Default:
%                               'ppr'  if w not given
%                               'ppp'  if w is given
%                       proj.uoffset    Row or column vector of offset of origin of projection axes (r.l.u.)
%                       proj.lab        Short labels for u1,u2,u3,u4 as cell array (e.g. {'Q_h', 'Q_k', 'Q_l', 'En'})
%                         *OR*
%                       proj.lab1       Short label for u1 axis (e.g. 'Q_h' or 'Q_{kk}')
%                       proj.lab2       Short label for u2 axis
%                       proj.lab3       Short label for u3 axis
%                       proj.lab4       Short label for u4 axis (e.g. 'E' or 'En')
%
%   p1_bin          Binning along first Q axis
%   p2_bin          Binning along second Q axis
%   p3_bin          Binning along third Q axis
%               - [] or ''          Plot axis: use bin boundaries of input data
%               - [pstep]           Plot axis: sets step size; plot limits taken from extent of the data
%               - [plo, phi]        Integration axis: range of integration
%               - [plo, pstep, phi] Plot axis: minimum and maximum bin centres and step size
%
%   p4_bin          Binning along the energy axis:
%               - [] or ''          Plot axis: use bin boundaries of input data
%               - [pstep]           Plot axis: sets step size; plot limits taken from extent of the data
%                                  If pstep=0 then use bin size of the first spe file and synchronise
%                                  the output bin boundaries with those boundaries. The overall range is
%                                  chosen to ensure that the energy range of the input data is contained within
%                                  the bin boundaries.
%               - [plo, phi]        Integration axis: range of integration
%           	- [plo, pstep, phi]	Plot axis: minimum and maximum bin centres and step size;
%                                  If pstep=0 then use bin size of the first spe file and synchronise
%                                  the output bin boundaries with the reference boundaries. The overall range is
%                                  chosen to ensure that the energy range plo to phi is contained within
%                                  the bin boundaries.
%           
%
% Output:
% -------
%   w              Output data object:
%                     - sqw-type object with full pixel information
%                     - dnd-type object if option '-nopix' given


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Parse input
% -----------
[w, args, mess] = horace_function_parse_input (nargout,varargin{:});
if ~isempty(mess), error(mess); end

% Perform operations
% ------------------
nout=w.nargout_req;
nw=numel(w.data);

if all(w.sqw_type(:))
    if numel(args)>=1 && ~isstruct(args{1}) % proj structure not given, so all sqw objects must have same dimensionality
        if ~all(w.ndims==w.ndims(1))
            error('All sqw objects must have same dimensionality if not using new projection axes')
        end
    end
    for i=1:nw
        if nout>0
            if i==2, wout=repmat(wout,size(w.data)); end
            wout(i)=cut_sqw_main(w.data(i),w.ndims(i),args{:});   % private method - cuts just scalar data_source
        else
            cut_sqw_main(w.data(i),w.ndims(i),args{:});
        end
    end
elseif ~any(w.sqw_type(:)) && all(w.ndims==w.ndims(1))
    for i=1:nw
        if nout>0
            if i==2, wout=repmat(wout,size(w.data)); end
            wout(i)=cut_dnd_main(w.data(i),w.ndims(i),args{:});   % private method - cuts just scalar data_source
        else
            cut_dnd_main(w.data(i),w.ndims(i),args{:});
        end
    end
else
    error('Data files must all be sqw type, or all dnd type with same dimensionality')
end

if nout>0
    argout{1}=wout;
else
    argout={};
end

% Package output arguments
% ------------------------
[varargout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end
