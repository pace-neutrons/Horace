function varargout=set_instrument_horace(filename,instrument,varargin)
% Change the instrument in a file or set of files containing a Horace data object
%
%   >> set_instrument_horace (file, instrument)
%
% The altered object is written to the same file.
%
% Input:
% -----
%   file        File name, or cell array of file names. In latter case, the
%              change is performed on each file
%
%   instrument  Instrument object, or array of objects with number of elements 
%              equal to the number of
%              runs contributing to the sqw object(s).
%              If the instrument is any empty object, then the instrument
%              is set to the default empty structure.
%
% *OR*
%   inst_func      Function handle to generate instrument object or structure
%                  Must be of the form
%                       inst = my_func (p1, p2, ...)
%                  where p1,p2, ... are parameters to be passed to the
%                  instrument definition function, in this case called my_func,
%                  which in this example will be passed as @my_func.
%
%   arg1, arg2,...  Arguments to be provided to the instrument function.
%                  The arguments must be:
%                   - scalars, row vectors (which can be numerical, logical,
%                     structure, cell array or object), or character strings.
%                   - Multiple arguments can be passed, one for each run that
%                     constitutes the sqw object, by having one row per run
%                     i.e
%                       scalar      ---->   column vector (nrun elements)
%                       row vector  ---->   2D array (nrun rows)
%                       string      ---->   cell array of strings
%
%                  Certain arguments win the sqw object can be referred to by
%                  special strings;
%                       '-efix'     ---->   use value of fixed energy in the
%                                           header block of the sqw object


% Original author: T.G.Perring
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)
if isa(instrument,'function_handle')
    instfunc=instrument; % single function handle
    % Check instrument definition function arguments are OK and consistent
    [ok,mess,instfunc_args]=check_function_args(varargin{:});
    if ~ok
        mess=['Instrument definition function: ',mess];
        error(mess);
    end
    if size(instfunc_args,1)==0
        %is_instfunc=false;
        instrument=instfunc();  % call with no arguments
    else
        % If none of the arguments match substitution arguments we can evaluate the instrument definition function now
        subst_args=substitute_arguments();
        ninst=size(instfunc_args,1);
        if substitution_arguments_present(subst_args,instfunc_args)
            if iscell(filename)
                error('SQW:not_implemeted','setting instrument to multiple files at once have not been implemented')
            end
            ldr = sqw_formats_factory.instance().get_loader(filename);
            header = ldr.get_header('-all');
            nfiles = numel(header);
            if ninst ~= 1 && ninst ~= nfiles
                error('SQW:invalid_argument',...
                    'number of instrument parameters provided (%d) has to be 1 or equal to number of contributing files (%d)',...
                    ninst,nfiles)
            end
            args=substitute_arguments(header,1,instfunc_args(1,:));
            boss_instrument=instfunc(args{:});
            instrument = repmat(boss_instrument,nfiles,1);
            for ifile=2:nfiles
                if ninst == 1
                    args=substitute_arguments(header,ifile,instfunc_args(1,:));
                else
                    args=substitute_arguments(header,ifile,instfunc_args(ifile,:));
                end
                instrument(ifile)=instfunc(args{:});
            end
            ldr = ldr.upgrade_file_format();
            ldr.put_instruments(instrument);
            ldr.delete();
            return
        else
            instrument=instfunc(instfunc_args{1,:});
            if ninst>1
                instrument=repmat(instrument,ninst,1);
                for i=2:ninst
                    instrument(i)=instfunc(instfunc_args{i,:});
                end
            end
        end
    end
    argi = {};
else
    argi = varargin;
end

if nargout > 0
    varargout = set_instr_or_sample_horace_(filename,'-instrument',instrument,argi{:});
else
    set_instr_or_sample_horace_(filename,'-instrument',instrument,argi{:});
end


%==============================================================================
function [ok, mess, argout]=check_function_args(varargin)
% Check arguments have one of the permitted forms below
%
%   >> [ok, mess, argout]=check_function_args(arg1,arg2,...)
%
% Input:
% ------
%   arg1,arg2,...   Input arguments
%                  Each argument can be a 2D array with 0,1 or more rows
%                  If more than one row in an argument, then this gives the
%                  number of argument sets.
%
% Output:
% -------
%   ok              =true all OK; =false otherwise
%   mess            Error message if not OK; empty string if OK
%   argout          Cell array of arguments, each row a cell array
%                  with the input arguments
%
% Checks arguments have one of following forms:
%	- scalar, row vector (which can be numerical, logical,
%     structure, cell array or object), or character string
%
%   - Multiple arguments can be passed, one for each run that
%     constitutes the sqw object, by having one row per run
%   	i.e
%       	scalar      ---->   column vector (nrun elements)
%           row vector  ---->   2D array (nrun rows)
%        	string      ---->   cell array of strings
%
% Returns arg=[] if not valid form

narg=numel(varargin);
ok=true;
mess='';
argout={};

% Find out how many rows, and check consistency
nr=zeros(1,narg);
nc=zeros(1,narg);
for i=1:narg
    if numel(size(varargin{i}))==2
        nr(i)=size(varargin{i},1);
        nc(i)=size(varargin{i},2);
    else
        ok=false;
        mess='Check arguments have valid array size';
        return
    end
end
if all(nr==max(nr)|nr<=1)
    nrow=max(nr);
else
    ok=false;
    mess='If any arguments have more than one row, all such arguments must be the same number of rows';
    return
end

% Now create cell arrays of output arguments
if nrow>1
    argout=cell(nrow,narg);
    for i=1:narg
        if ~iscell(varargin{i})
            if nr(i)==nrow
                argout(:,i)=mat2cell(varargin{i},ones(1,nrow),size(varargin{i},2));
            else
                argout(:,i)=repmat(varargin(i),nrow,1);
            end
        else
            if nr(i)==nrow
                if nc(i)>1
                    argout(:,i)=mat2cell(varargin{i},ones(1,nrow),size(varargin{i},2));
                else
                    argout(:,i)=varargin{i};
                end
            else
                argout(:,i)=repmat(varargin(i),nrow,1);
            end
        end
    end
else
    argout=varargin;
end


%==============================================================================
function status = substitution_arguments_present(subst_args,args)
% Check if any argument are to be substituted

narg=numel(args);
isstr=false(narg,1);
for i=1:narg
    isstr(i)=is_string(args{i});
end
strargs=args(isstr);

status=false;
for i=1:numel(subst_args)
    if any(strcmpi(subst_args{i},strargs))
        status=true;
        return
    end
end

%==============================================================================
function argout = substitute_arguments(headers,ifile,argin)
% Substitute arguments with values from cellarray of headers
%
% Return cellstr with list of all substitution arguments:
%   >> subst_args = substitute_arguments
%
% Argument list with substitutions made from sqw object or header fields of sqw file:
%   >> argout = substitute_arguments(w,ifile,argin)

% List of substitution keywords
if nargin==0
    argout={'-efix'};
    return
end

% Substitute values
argout=argin;
for i=1:numel(argin)
    if is_string(argin{i}) && strcmpi(argin{i},'-efix')
        if ifile>1 || numel(headers) > 1
            argout{i}=headers{ifile}.efix;
        else
            argout{i}=headers.efix;
        end
    end
end

