function [wcombine,wout] = cut_sqw_sym_main (data_source, ndims, varargin)
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
% Write directly to file without creating an output object (useful if the
% output is a large dataset in order to avoid out-of-memory errors)
%
%   >> cut(...)


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
if numel(varargin)>=2 && (isstruct(varargin{1}) || isa(varargin{1},'projaxes'))
    proj_given=true;
    proj=varargin{1};
    pbin=varargin(2:end-length(opt)-1);
    sym=varargin{end-length(opt)};
elseif numel(varargin)>=1
    proj_given=false;
    pbin=varargin(1:end-length(opt)-1);
    sym=varargin{end-length(opt)};
else
    error('Check the number opf arguments')
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
    elseif strncmpi(opt{1},'-save',max(length(opt{1}),2))
        save_to_file=true;
    else
        save_to_file=true;
        outfile=opt{1};
    end
elseif length(opt)==2
    if (strncmpi(opt{1},'-nopix',max(length(opt{1}),2)) && strncmpi(opt{2},'-save',max(length(opt{2}),2))) ||...
            (strncmpi(opt{1},'-save',max(length(opt{1}),2)) && strncmpi(opt{2},'-nopix',max(length(opt{2}),2)))
        keep_pix=false;
        save_to_file=true;
    elseif strncmpi(opt{1},'-nopix',max(length(opt{1}),2))
        keep_pix=false;
        save_to_file=true;
        outfile=opt{2};
    elseif strncmpi(opt{2},'-nopix',max(length(opt{2}),2))
        keep_pix=false;
        save_to_file=true;
        outfile=opt{1};
    else
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
if ~iscell(sym), sym = {sym}; end   % make a cell array for convenience
keep = true(size(sym));
for i=1:numel(sym)
    if ~isa(sym{i},'symop')
        error('Symmetry descriptor must be an symop object or array of symop objects, or a cell of those')
    elseif numel(sym{i})==0
        keep(i) = false;
    end
end
sym = sym(keep);


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
% If dnd cuts, then duplicated pixels cannot be accounted for, although the weighting is correct
if hor_log_level>0
    disp(['Combining cuts...'])
end
if isa(w{1},'sqw')
    wcombine = combine_sqw_same_bins (w{:});
else
    wcombine = combine_dnd_same_bins (w{:});
end
wout = repmat(w{1},size(w));
for i=1:numel(w)
    wout(i)=w{i};
end

if hor_log_level>0
    disp('--------------------------------------------------------------------------------')
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
