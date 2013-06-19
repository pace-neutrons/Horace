function wout = set_sample_and_inst(win,sample,instrument,varargin)
% Add or replace instument and sample information to an sqw object in a convenient single function
%
%   >> wout = set_sample_and_inst (win,sample,instrument)
%
%   >> wout = set_sample_and_inst (win,sample,instrument_func,arg1,arg2,...)
%
% EXAMPLES:
%   >> wout = set_sample_and_inst (win,sample,instrument);
%   >> wout = set_sample_and_inst (win,sample,@maps_instrument,'-efix',600,'S')
%
%
% Input:
% ------
%   win             Input sqw object
%
%   sample          Sample object or structure (usually IX_sample object)
%                  Note: only a single sample object can be provided. That is,
%                  there is a single sample for the entire sqw data set
%
%   instrument      Instrument object or structure, or array of objects or
%                  structures, with number of elements equal to the number of
%                  runs contributing to the sqw object.
%
% *OR*
%   inst_func       Function handle to generate instrument object or structure
%                  Must be of the form
%                       inst = my_func (p1, p2, ...)
%                  where p1,p2, ... are scalars, row vectors (which can be
%                  numerical, logical, structure cell array or object), or
%                  character strings.
%                   In this example, the argument to be passed to this function is
%                       @my_func
%
%   arg1, arg2,...  Arguments to be provided to the instrument function.
%                  The arguments must be:
%                   - scalars, row vectors (which can be numerical, logical,
%                     structure, cell array or object), or character strings.
%                   - Multiple arguments can be passed, one for each run that
%                     constitutes the sqw object, by having one row per run
%                     i.e
%                       scalar      ---->   column vector (nrun elemnents)
%                       row vector  ---->   2D array (nrun rows)
%                       string      ---->   cell array of strings
%
%                  Certain arguments win the sqw object can be referred to by
%                  special strings;
%                       '-efix'     ---->   use value of fixed energy in the
%                                           header block of the sqw object
% 
%
% Output:
% -------
%   wout            Input sqw object with the instrument and sample fields
%                  replaced in the header
%
% This function is designed to make adding sample and instrument information
% convenient, but cannot cover the most general forms of the instument
% function arguments. In that case, you must set the individual fields

% Catch trivial case of empty structures
if isempty(sample) && isempty(instrument) && nargin==3
    wout=win;
    return
end

% Check input arguments
if isempty(sample)
    sample=struct;  % the default
elseif ~((isstruct(sample) || isobject(sample)) && isscalar(sample))
    error('Sample must be a scalar structure or object')
end

nrun=win.main_header.nfiles;
if isempty(instrument)
    instrument=repmat(struct,[nrun,1]);  % the default
    inst_func=false;
elseif (isstruct(instrument) || isobject(instrument))
    if isscalar(instrument)
        instrument=repmat(instrument,[nrun,1]);
    elseif numel(instrument)~=nrun
        error('Instrument structure or object must be a scalar or array with length equal to the number of runs in the sqw object')
    end
    inst_func=false;
elseif isa(instrument,'function_handle')
    % Parse arguments to instrument definition function
    args=cell(numel(varargin),nrun);
    for i=1:numel(varargin)
        if ischar(varargin{i}) && isequal(lower(varargin{i}),'-efix')
            if nrun==1
                args{i}=win.header.efix;
            else
                for irun=1:nrun
                    args{i,irun}=win.header{irun}.efix;
                end
            end
        else
            [arg,ok]=check_arg(varargin{i},nrun);
            if ok
                args(i,:)=arg;
            else
                error('Number of elements of each instrument function argument must be scalar or equal number of runs in sqw object')
            end
        end
    end
    inst_func=true;
else
    error('Instrument must be a scalar structure or object, or a handle to a function that generates the instrument')
end

% Fill instrument and sample sections
header=win.header;
if nrun==1
    header.sample=sample;
    if inst_func
        header.instrument=instrument(args{:});
    else
        header.instrument=instrument(i);
    end
else
    for i=1:nrun
        header{i}.sample=sample;
        if inst_func
            header{i}.instrument=instrument(args{:,i});
        else
            header{i}.instrument=instrument(i);
        end
    end
end

% Fill output sqw object
wout=win;
wout.header=header;

%========================================================================================
function [argout,ok]=check_arg(arg,n)
% Checks argument has one of following form:
%	- scalars, row vectors (which can be numerical, logical,
%     structure or object), or character strings
%
%   - Multiple arguments can be passed, one for each run that
%     constitutes the sqw object, by having one row per run
%   	i.e
%       	scalar      ---->   column vector (nrun elemnents)
%           row vector  ---->   2D array (nrun rows)
%        	string      ---->   cell array of strings
%
% Returns arg=[] if not valid form

ok=true;
if ischar(arg)
    argout=repmat({arg},n,1);
elseif iscellstr(arg) && numel(arg)==n
    argout=arg;
elseif isempty(arg) || isscalar(arg) || isrowvector(arg)
    argout=repmat({arg},n,1);
elseif numel(size(arg))==2 && size(arg,1)==n
    argout=mat2cell(arg,ones(1,n),size(arg,2));
else
    argout=[];
    ok=false;
end
