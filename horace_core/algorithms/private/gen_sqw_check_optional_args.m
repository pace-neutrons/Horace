function [ok,mess,present,grid,urange,instrument,sample]=gen_sqw_check_optional_args...
    (nfile,grid_default,instrument_default,sample_default,varargin)
% Check optional input arguments to gen_sqw, and set defaults to those that are missing
%
%   >> [ok,mess,grid,urange,inst,sample] = gen_sqw_check_optional_args...
%          (nfile,grid_default,inst_default,sample_default,arg1,arg2,...)
%
% where arg1,arg2,.. can be:
%   ..., grid_in)                   % grid size
%   ..., grid_in, urange_in)        % grid size and range of data to retain
%   ..., instrument_in, sample_in)  % instrument and sample information
%   ..., grid_in, urange_in, instrument_in, sample_in)      % all four
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
%   urange_in           Range of data grid for output as a 2x4 matrix:
%                           [x1_lo,x2_lo,x3_lo,x4_lo;x1_hi,x2_hi,x3_hi,x4_hi]
%                       If not given or [], returned as [] (to signifiy that
%                      it needs to be autoscaled or set later)
%   instrument_in       Structure or object [scalar or array]
%   sample_in           Structure or object [scalar or array]
%
% Output:
% -------
%   ok                  Logical: true if all fine, false otherwise
%   mess                Error message if not ok; ='' if ok
%   present             Structure with following fields each set to true or false
%                      according as whether or not the input arguments were present
%                           present.grid
%                           present.urange
%                           present.instrument
%                           present.sample
%   grid                Grid (scalar or 1x4 vector; [] to indicate autoscaling
%                      required or to be set later)
%   urange              Range of data grid (2x4 array; [] to indicate autoscaling
%                      required or to be set later)
%   instrument          Column vector of instrument descriptors, one per spe file
%   sample              Column vector of sample descriptors, one per spe file


% Set default return arguments in case of error
present=struct('grid',false,'urange',false,'instrument',false,'sample',false);
grid=[]; urange=[]; instrument=[]; sample=[];


% Check defaults
[grid_default,mess]=check_grid_size(grid_default);
if ~isempty(mess)
    ok=false; mess='Default grid invalid - problem in code'; 
    return
end

if numel(instrument_default)~=1 || ~(isobject(instrument_default)||isstruct(instrument_default))
    ok=false; mess='Default instrument must be a scalar structure or object'; 
    return
end

if numel(sample_default)~=1 || ~(isobject(sample_default)||isstruct(sample_default))
    ok=false; mess='Default sample descriptor must be a scalar structure or object'; 
    return
end


% Check arguments
narg=numel(varargin);
if narg==0
    grid=grid_default;
    urange=[];
    
    instrument=repmat(instrument_default,[nfile,1]);
    sample=repmat(sample_default,[nfile,1]);
    
elseif narg==1  % grid
    [grid,mess]=check_grid_size(varargin{1},grid_default);  
    if ~isempty(mess), ok=false; return, end
    present.grid=true;
    urange=[];
    
    instrument=repmat(instrument_default,[nfile,1]);
    sample=repmat(sample_default,[nfile,1]);

elseif narg==2 && isnumeric(varargin{1})    % grid, urange
    [grid,mess]=check_grid_size(varargin{1},grid_default);  
    if ~isempty(mess), ok=false; return, end
    present.grid=true;
    [urange,mess]=check_urange(varargin{2});                
    if ~isempty(mess), ok=false; return, end
    present.urange=true;
    
    instrument=repmat(instrument_default,[nfile,1]);
    sample=repmat(sample_default,[nfile,1]);

elseif narg==2 && ~isnumeric(varargin{1})   % instrument, sample
    grid=grid_default;
    urange=[];
    
    [instrument,mess]=check_inst_or_sample(varargin{1},nfile,'instrument',instrument_default);
    if ~isempty(mess), ok=false; return, end
    present.instrument=true;
    [sample,mess]=check_inst_or_sample(varargin{2},nfile,'sample',sample_default);
    if ~isempty(mess), ok=false; return, end
    present.sample=true;

elseif narg==4                              % grid, urange, instrument, sample
    [grid,mess]=check_grid_size(varargin{1},grid_default);  
    if ~isempty(mess), ok=false; return, end
    present.grid=true;
    [urange,mess]=check_urange(varargin{2});                
    if ~isempty(mess), ok=false; return, end
    present.urange=true;
    
    [instrument,mess]=check_inst_or_sample(varargin{3},nfile,'instrument',instrument_default);
    if ~isempty(mess), ok=false; return, end
    present.instrument=true;
    [sample,mess]=check_inst_or_sample(varargin{4},nfile,'sample',sample_default);
    if ~isempty(mess), ok=false; return, end
    present.sample=true;

else
    ok=false; mess='Check number and type of optional arguments';
    return
end

% Fill error flags
ok=true;
mess='';


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
function [urange_out,mess]=check_urange(urange)
% Check if urange is given
if isempty(urange)
    urange_out=[];
    mess='';

elseif isnumeric(urange) && numel(size(urange))==2 &&...
        all(size(urange)==[2,4]) && all(urange(2,:)>=urange(1,:))
    urange_out=urange;
    mess='';
    
else
    mess='urange must be 2x4 array, first row lower limits, second row upper limits, with lower<=upper';
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
