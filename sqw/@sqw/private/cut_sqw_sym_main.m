function [wout,wsym] = cut_sqw_sym_main (data_source, ndims, varargin)
% Take a cut from an sqw object by integrating over one or more axes.
%
% Cut using existing projection axes:
%   >> w = cut_sqw_sym_main (data_source, ndims, p1_bin, p2_bin...,sym)
%                                           %(as many binning arguments
%                                           % as there are plot axes)
%
% Cut with new projection axes:
%   >> w = cut_sqw_sym_main (data_source, ndims, proj, p1_bin, p2_bin, p3_bin, p4_bin, sym)
%
%   >> w = cut_sqw_sym_main (..., '-nopix')     % output cut is dnd structure (i.e. no
%                                               % pixel information is retained)
%
%   >> w = cut_sqw_sym_main (..., '-save')      % save cut to file (prompts for file)
%   >> w = cut_sqw_sym_main (...,  filename)    % save cut to named file
%
% For both the above: return the cuts for each symmetry related cut as well
%   >> [w, wsym] = cut_sym (...)
%
% Write directly to file without creating an output object (useful if the
% output is a large dataset in order to avoid out-of-memory errors)
%
%   >> cut_sqw_sym_main (...)
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
%
%   wsym            Array of data objects, one for each symmetry related cut


hor_log_level = config_store.instance().get_value('herbert_config','log_level');

% Parse input arguments
% ---------------------
% Determine if data source is sqw object or file
if iscellstr(data_source)
    data_source=data_source{1};
    source_is_file=true;
elseif ischar(data_source)
    source_is_file=true;
elseif isa(data_source,'sqw')
    source_is_file=false;
else
    error('Logic problem in chain of cut methods. See T.G.Perring')
end

% Strip off final arguments that are character strings, and parcel the rest as binning arguments
% and symmetry operator(s)
% (the functions that use binning arguments are clever enough to handle incorrect number of arguments and types)
opt=cell(1,0);
if length(varargin)>=1 && ischar(varargin{end}) && size(varargin{end},1)==1
    opt{1}=varargin{end};
end
if length(varargin)>=2 && ischar(varargin{end-1}) && size(varargin{end-1},1)==1
    opt{2}=varargin{end-1};
end

% Get proj structure, if present, and binning information
if numel(varargin)>=2 && (isstruct(varargin{1}) ||...
        isa(varargin{1},'aProjection') || isa(varargin{1},'projaxes'))
    proj_given=true;
    if isa(varargin{1},'aProjection')
        proj=varargin{1};
    else
        proj=projection(varargin{1});
    end
    pbin=varargin(2:end-length(opt)-1);
    sym=varargin{end-length(opt)};
elseif numel(varargin)>=1
    proj_given=false;
    pbin=varargin(1:end-length(opt)-1);
    sym=varargin{end-length(opt)};
else
    error('Check the number and type of input arguments')
end


% Do checks on input arguments
% ----------------------------
% Check consistency of optional arguments.
% (Do some checks for which there is reasonable default behaviour, but as cuts can take a long time, be cautious instead)
keep_pix=true;
save_to_file=false;
outfile='';
if length(opt)==1
    if strncmpi(opt{1},'-nopix',max(length(opt{1}),2))
        keep_pix=false;
        save_to_file=false;
    elseif strncmpi(opt{1},'-pix',max(length(opt{1}),2))
        keep_pix=true;
        save_to_file=false;
    elseif strncmpi(opt{1},'-save',max(length(opt{1}),2))
        keep_pix=true;
        save_to_file=true;
    elseif numel(opt{1})>0 && opt{1}(1)~='-'
        keep_pix=true;
        save_to_file=true;
        outfile=opt{1};
    else
        error('Check optional argument ''%s''',opt{1})
    end
elseif length(opt)==2
    if (strncmpi(opt{1},'-nopix',max(length(opt{1}),2)) && strncmpi(opt{2},'-save',max(length(opt{2}),2))) ||...
            (strncmpi(opt{1},'-save',max(length(opt{1}),2)) && strncmpi(opt{2},'-nopix',max(length(opt{2}),2)))
        keep_pix=false;
        save_to_file=true;
    elseif (strncmpi(opt{1},'-pix',max(length(opt{1}),2)) && strncmpi(opt{2},'-save',max(length(opt{2}),2))) ||...
            (strncmpi(opt{1},'-save',max(length(opt{1}),2)) && strncmpi(opt{2},'-pix',max(length(opt{2}),2)))
        keep_pix=true;
        save_to_file=true;
    elseif strncmpi(opt{1},'-nopix',max(length(opt{1}),2))
        keep_pix=false;
        save_to_file=true;
        outfile=opt{2};
    elseif strncmpi(opt{1},'-pix',max(length(opt{1}),2))
        keep_pix=true;
        save_to_file=true;
        outfile=opt{2};
    elseif strncmpi(opt{2},'-nopix',max(length(opt{2}),2))
        keep_pix=false;
        save_to_file=true;
        outfile=opt{1};
    elseif strncmpi(opt{2},'-pix',max(length(opt{2}),2))
        keep_pix=true;
        save_to_file=true;
        outfile=opt{1};
    else
        error('Check optional arguments: ''%s'' and ''%s''',opt{1},opt{2})
    end
    if ~isempty(outfile) && outfile(1)=='-'     % catch case of given outfile beginning with '-'
        error('Check optional arguments: ''%s'' and ''%s''',opt{1},opt{2})
    end
end
if nargout==0 && ~save_to_file  % Check work needs to be done (*** might want to make this case prompt to save to file)
    error ('Neither output cut object nor output file requested - routine is not being asked to do anything')
end

if save_to_file && ~isempty(outfile)    % check file name makes reasonable sense if one has been supplied
    [~,~,out_ext]=fileparts(outfile);
    if length(out_ext)<=1    % no extension or just a dot
        error('Output filename ''%s'' has no extension - check optional arguments',outfile)
    end
end


% Checks on binning arguments
for i=1:numel(pbin)
    if ~(isempty(pbin{i}) || isnumeric(pbin{i}))
        error('Binning arguments must all be numeric')
    end
end
if ~proj_given          % must refer to plot axes (in the order of the display list)
    if numel(pbin)~=ndims
        error('Number of binning arguments must match the number of dimensions of the sqw data being cut')
    end
else                    % must refer to new projection axes
    if numel(pbin)~=4
        error('Must give binning arguments for all four dimensions if new projection axes')
    end
end


% Checks on symmetry description - check valid, and remove empty descriptions
% Symmetry description can be
%  - scalar symop object, or array of symop objects (multiple symops to be performed in sequence),
%    or empty argument (ignore)
%  - cell array of the above: a cut is performed for each symmetry description

if ~iscell(sym), sym = {sym}; end   % make a cell array for convenience
keep = true(size(sym));
for i=1:numel(sym)
    sym{i} = sym{i}(:)';    % make row vector
    if isempty(sym{i}) || (isa(sym{i},'symop') && all(is_identity(sym{i})))
        keep(i) = false;
    elseif ~isa(sym{i},'symop')
        error('Symmetry descriptor must be an symop object or array of symop objects, or a cell of those')
    end
end
sym = sym(keep);


% =============================================================================================
% Catch case of empty symmetry operation
% =============================================================================================
% In this case, there is only one cut to do, so use cut_sqw_main

if isempty(sym)
    if nargout==0
        if ~proj_given
            cut_sqw_main (data_source, ndims, pbin{:}, opt{:});
        else
            cut_sqw_main (data_source, ndims, proj, pbin{:}, opt{:});
        end
    else
        if ~proj_given
            wout = cut_sqw_main (data_source, ndims, pbin{:}, opt{:});
        else
            wout = cut_sqw_main (data_source, ndims, proj, pbin{:}, opt{:});
        end
        if nargout==2
            wsym = wout;
        end
    end
    return
end


% =============================================================================================
% Case of at least one symmetry operation
% =============================================================================================

% Open output file if required
% ----------------------------
if save_to_file
    if isempty(outfile)
        if keep_pix
            outfile = putfile('*.sqw');
        else
            outfile = putfile('*.d0d;*.d1d;*.d2d;*.d3d;*.d4d');
        end
        if (isempty(outfile))
            error ('No output file name given')
        end
    end
    
    % Open output file now - don't want to discover there are problems after 30 seconds of calculation
    %    Not yet fully supported with sqw_formats_factory but can be. Now just test creation of new file
    %    is possible  and delete it.
    fout = fopen (outfile, 'wb'); % no upgrade possible -- this command also clears contents of existing file
    if (fout < 0)
        error (['Cannot open output file ' outfile])
    end
    fclose(fout);
    delete(outfile);
    %     clob = onCleanup(@()clof(fout));
end


% Get header information from the data source
% --------------------------------------------
if hor_log_level>0, disp('--------------------------------------------------------------------------------'), end
if source_is_file  % data_source is a file
    if hor_log_level>=0, disp(['Taking symmetry related cuts from data in file ',data_source,'...']), end
    ld = sqw_formats_factory.instance().get_loader(data_source);
    data_type = ld.data_type;
    %[mess,main_header,header,detpar,data,position,npixtot,data_type]=get_sqw (data_source,'-nopix');
    if ~strcmpi(data_type,'a')
        error('Data file is not sqw file with pixel information - cannot take cut')
    end
    npixtot = ld.npixels;
    pix_position = ld.pix_position;
    %
    main_header = ld.get_main_header();
    header = ld.get_header('-all');
    detpar = ld.get_detpar();
    data = ld.get_data('-nopix');
    ld.delete();
else
    if hor_log_level>=0, disp('Taking cut from sqw object...'), end
    % for convenience, unpack the fields that themselves are major data structures
    %(no memory penalty as matlab just passes pointers)
    main_header = data_source.main_header;
    header = data_source.header;
    detpar = data_source.detpar;
    data   = data_source.data;
    npixtot= size(data.pix,2);
end


% Get some 'average' quantities for use in calculating transformations and bin boundaries
% -----------------------------------------------------------------------------------------
% *** assumes that all the contributing spe files had the same lattice parameters and projection axes
% This could be generalised later - but with repercussions in many routines
header_ave=header_average(header);
alatt = header_ave.alatt;
angdeg = header_ave.angdeg;
en = header_ave.en;  % energy bins for synchronisation with when constructing defaults
upix_to_rlu = header_ave.u_to_rlu(1:3,1:3);
upix_offset = header_ave.uoffset;


% Perform cuts
% ------------
if proj_given && isfield(proj,'nonorthogonal') && proj.nonorthogonal
    error('Symmetrised cuts not implemented for nonorthogonal axes')
end

if ~keep_pix
    nopix = {'-nopix'};
else
    nopix={};
end

w = cell(1,numel(sym)+1);
% Perform the cut without any symmetry operations
if ~proj_given
    w{1} = cut_sqw_main (data_source, ndims, pbin{:}, nopix{:});
else
    w{1} = cut_sqw_main (data_source, ndims, proj, pbin{:}, nopix{:});
end

% Now perform the cut for each array of symmetry operations
[proj_ref, pbin_ref] = get_proj_and_pbin (w{1});
for i=1:numel(sym)
    [ok, mess, proj_trans, pbin_trans] = transform_proj (sym{i},...
        alatt, angdeg, proj_ref, pbin_ref);
    if ~ok, error(mess), end
    w{i+1} = cut_sqw_main (data_source, ndims, proj_trans, pbin_trans{:}, nopix{:});
    if isa(w{1},'sqw')
        w{i+1}.data.pix(1:3,:) = transform_pix (sym{i}, upix_to_rlu, upix_offset,...
            w{i+1}.data.pix(1:3,:));
    end
end


% Merge cuts
% ----------
% Take account of duplicated pixels if sqw cuts
% If dnd cuts, then duplicated pixels cannot be accounted for, although the weighting by number
% of pixels is correct
if hor_log_level>0
    disp(['Combining cuts...'])
end
if isa(w{1},'sqw')
    wout = combine_sqw_same_bins (w{:});
else
    wout = combine_dnd_same_bins (w{:});
end

if nargout==2
    wsym = repmat(w{1},size(w));
    for i=1:numel(w)
        wsym(i)=w{i};
    end
end

if hor_log_level>0
    disp('--------------------------------------------------------------------------------')
end


% Save to file if requested
% ---------------------------
if save_to_file
    save (wout, outfile);
end




%------------------------------------------------------------------------------
function [proj, pbin] = get_proj_and_pbin (w)
% Reverse engineer the projection and binning of a cut. Works for dnd and sqw
% objects

if isa(w,'sqw')
    data = w.data;
else
    data = w;
end

% Get projection
% --------------------------
% Projection axes
proj.u = data.u_to_rlu(1:3,1)';
proj.v = data.u_to_rlu(1:3,2)';
proj.w = data.u_to_rlu(1:3,3)';

% Determine if projection is orthogonal or not
b = bmatrix(data.alatt, data.angdeg);
ux = b*proj.u';
vx = b*proj.v';
nx = cross(ux,vx); nx = nx/norm(nx);
wx = b*proj.w'; wx = wx/norm(wx);
if abs(cross(nx,wx))>1e-10
    proj.nonorthogonal = true;
else
    proj.nonorthogonal = false;
end

proj.type = 'ppp';

proj.uoffset = data.uoffset';

% Get binning
% -------------------------
pbin=cell(1,4);
for i=1:numel(data.pax)
    pbin{data.pax(i)} = pbin_from_p(data.p{i});
end
for i=1:numel(data.iax)
    pbin{data.iax(i)} = data.iint(:,i)';
end

%------------------------------------------------------------------------------
function pbin = pbin_from_p (p)
% Get 1x3 binning description from equally spaced bin boundaries
pbin = [(p(1)+p(2))/2, (p(end)-p(1))/(numel(p)-1), (p(end-1)+p(end))/2];
