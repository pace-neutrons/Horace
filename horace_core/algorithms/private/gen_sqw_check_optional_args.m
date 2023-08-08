function [present,grid,pix_db_range,instrument,sample]=gen_sqw_check_optional_args...
    (nfile,grid_default,instrument_default,sample_default,lattice,varargin)
% Check optional input arguments to gen_sqw, and set defaults to those that are missing
%
%   >> [grid,pix_db_range,inst,sample] = gen_sqw_check_optional_args...
%          (nfile,grid_default,inst_default,sample_default,arg1,arg2,...)
%
% where arg1,arg2,.. can be:
%   ..., grid_in)                   % grid size
%   ..., grid_in, pix_db_range_in)        % grid size and range of data to retain
%   ..., instrument_in, sample_in)  % instrument and sample information
%   ..., grid_in, pix_db_range_in, instrument_in, sample_in)      % all four
%
% Input:
% ------
%   nfile               Number of spe files
%   grid_default        Default grid size: scalar or row vector of grid dimensions
%                      e.g. 50  or [20,20,10,40]
%                      Set to [] to indicate that no default will be set.
%   instrument_default  Default instrument descriptor. Structure or object
%   sample_default      Default sample descriptor. Structure or object
%
% and one or more of the following (see above for valid combinations):
%   grid_in             Scalar or 1x4 vector of grid dimensions
%                       If not given or [], the default is set from argument grid_default
%   pix_db_range_in           Range of data grid for output as a 2x4 matrix:
%                           [x1_lo,x2_lo,x3_lo,x4_lo;x1_hi,x2_hi,x3_hi,x4_hi]
%                       If not given or [], returned as [] (to signifiy that
%                       it needs to be autoscaled or set later)
%   instrument_in       Structure or object [scalar or array]
%   sample_in           Structure or object [scalar or array]
%
% Output:
% -------
%   present             Structure with following fields each set to true or false
%                      according as whether or not the input arguments were present
%                           present.grid
%                           present.pix_db_range
%                           present.instrument
%                           present.sample
%   grid                Grid (scalar or 1x4 vector; [] to indicate autoscaling
%                      required or to be set later)
%   pix_db_range        Range of data grid (2x4 array; [] to indicate autoscaling
%                      required or to be set later)
%   instrument          Column vector of instrument descriptors, one per spe file
%   sample              Column vector of sample descriptors, one per spe file


% Set default return arguments in case of error
present=struct('grid',false,'pix_db_range',false,'instrument',false,'sample',false);
grid=[]; pix_db_range=[]; instrument=[]; sample=[];


% Check defaults
[grid_default,mess]=check_grid_size(grid_default);
if ~isempty(mess)
    error('HORACE:gen_sqw:runtime_error',...
        'Default grid invalid - problem in code');

end

if numel(instrument_default)~=1 || ~(isobject(instrument_default)||isstruct(instrument_default))
    error('HORACE:gen_sqw:invalid_argument',...
        'Default instrument must be a scalar structure or object');
end

if  ~(isa(sample_default,'IX_samp')||isstruct(sample_default))
    error('HORACE:gen_sqw:invalid_argument',...
        'Default sample descriptor must be a scalar structure or object');
end


% Check arguments
narg=numel(varargin);
if narg==0
    grid=grid_default;
    pix_db_range=[];

    instrument=repmat(instrument_default,[nfile,1]);
    sample=repmat(sample_default,[nfile,1]);

elseif narg==1  % grid
    [grid,mess]=check_grid_size(varargin{1},grid_default);
    if ~isempty(mess)
        error('HORACE:gen_sqw:invalid_argument',mess)
    end
    present.grid=true;
    pix_db_range=[];

    instrument=repmat(instrument_default,[nfile,1]);
    sample=repmat(sample_default,[nfile,1]);

elseif narg==2 && isnumeric(varargin{1})    % grid, pix_db_range
    [grid,mess]=check_grid_size(varargin{1},grid_default);
    if ~isempty(mess)
        error('HORACE:gen_sqw:invalid_argument',mess)
    end
    present.grid=true;
    [pix_db_range,mess]=check_pix_range(varargin{2});
    if ~isempty(mess)
        error('HORACE:gen_sqw:invalid_argument',mess)
    end

    present.pix_db_range=true;

    instrument=repmat(instrument_default,[nfile,1]);
    sample=repmat(sample_default,[nfile,1]);

elseif narg==2 && ~isnumeric(varargin{1})   % instrument, sample
    grid=grid_default;
    pix_db_range=[];

    [instrument,mess]=check_inst_or_sample(varargin{1},nfile,'instrument',instrument_default);
    if ~isempty(mess)
        error('HORACE:gen_sqw:invalid_argument',mess)
    end

    present.instrument=true;
    [sample,mess]=check_inst_or_sample(varargin{2},nfile,'sample',sample_default);
    if ~isempty(mess)
        error('HORACE:gen_sqw:invalid_argument',mess)
    end

    present.sample=true;

elseif narg==4                              % grid, pix_db_range, instrument, sample
    [grid,mess]=check_grid_size(varargin{1},grid_default);
    if ~isempty(mess)
        error('HORACE:gen_sqw:invalid_argument',mess)
    end

    present.grid=true;
    [pix_db_range,mess]=check_pix_range(varargin{2});
    if ~isempty(mess)
        error('HORACE:gen_sqw:invalid_argument',mess)
    end

    present.pix_db_range=true;

    [instrument,mess]=check_inst_or_sample(varargin{3},nfile,'instrument',instrument_default);
    if ~isempty(mess)
        error('HORACE:gen_sqw:invalid_argument',mess)
    end

    present.instrument=true;
    [sample,mess]=check_inst_or_sample(varargin{4},nfile,'sample',sample_default);
    if ~isempty(mess)
        error('HORACE:gen_sqw:invalid_argument',mess)
    end

    present.sample=true;

else
    if ~isempty(mess)
        error('HORACE:gen_sqw:invalid_argument', ...
            'Incorrect number and type of optional arguments')
    end
end
if numel(lattice) == numel(sample)
    single_lattice = false;
elseif numel(lattice) == 1
    single_lattice = true;
else
    error('HORACE:gen_sqw:invalid_argument', ...
        'number of lattice elements (%d) is not consistent with number of samples (%d)',...
        numel(lattice),numel(sample));
end

for i=1:numel(sample)
    if single_lattice
        lat = lattice;
    else
        lat = lattice(i);
    end
    if isempty(sample(i).alatt)
        sample(i).alatt = lat.alatt;
    end
    if isempty(sample(i).angdeg)
        sample(i).angdeg = lat.angdeg;
    end
end


%--------------------------------------------------------------------------------------------------
function [grid_out,mess]=check_grid_size(grid,grid_default)
% Set default grid size if none given. mess empty if OK, otherwise contains error message
% It is assumed that grid_default is valid (positive non-zero scalar or 1x4 vector)
if isempty(grid)
    if nargin>1
        grid_out=grid_default;
        mess='';
        if ~isempty(grid_default)
            disp('--------------------------------------------------------------------------------')
            disp(['Using default grid size of ',str_compress(num2str(grid),'x'),' for output sqw file'])
        end
    else
        grid_out=[];
        mess='';
    end

elseif isnumeric(grid) && (isscalar(grid)||(isvector(grid)&&all(size(grid)==[1,4]))) &&...
        all(grid-round(grid)==zeros(size(grid))) && all(grid>0)
    grid_out=grid;
    mess='';

else
    grid_out=[];
    mess='Grid size must be scalar or row vector length 4';
end

%--------------------------------------------------------------------------------------------------
function [pix_db_range_out,mess]=check_pix_range(pix_db_range)
% Check if pix_db_range is given
if isempty(pix_db_range)
    pix_db_range_out=[];
    mess='';

elseif isnumeric(pix_db_range) && numel(size(pix_db_range))==2 &&...
        all(size(pix_db_range)==[2,4]) && all(pix_db_range(2,:)>=pix_db_range(1,:))
    pix_db_range_out=pix_db_range;
    mess='';

else
    mess='pix_db_range must be 2x4 array, first row lower limits, second row upper limits, with lower<=upper';
end

%--------------------------------------------------------------------------------------------------
function [val_out,mess]=check_inst_or_sample(val,nfile,val_name,val_default)
% Check (and exapnd if necessary) the sample or instrumnet description
if isempty(val)
    val_out=repmat(val_default,[nfile,1]);
    mess='';

elseif isobject(val)||isstruct(val)
    if numel(val)==nfile
        val_out=val;
        mess='';
    elseif numel(val)==1
        val_out=repmat(val,[nfile,1]);
        mess='';
    else
        val_out=[];
        mess=[val_name,' descriptor must be a scalar structure or object, or array of ',...
            'the same with size that matches the number of files'];
    end

else
    val_out=[];
    mess=[val_name,' descriptor must be a scalar structure or object'];
end
