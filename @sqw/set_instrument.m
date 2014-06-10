function varargout = set_instrument (varargin)
% Change the instrument in an sqw object or array of objects
%
%   >> wout = set_instrument (w, instrument)
%
%   >> wout = set_instrument (w, inst_func, arg1, arg2,...)
%
% EXAMPLES:
%   >> wout = set_instrument (w, instrument);
%   >> wout = set_instrument (w, @maps_instrument, '-efix', 600, 'S')
%
%
% Input:
% -----
%   w               Input sqw object or array of objects
%
%   instrument      Instrument object or structure, or array of objects or
%                  structures, with number of elements equal to the number of
%                  runs contributing to the sqw object(s).
%                   If the instrument is any empty object, then the instrument
%                  is set to the default empty structure.
%
% *OR*
%   inst_func       Function handle to generate instrument object or structure
%                  Must be of the form
%                       inst = my_func (p1, p2, ...)
%                  where p1,p2, ... are parameters to be passed to the 
%                  instument definition function, in this case called my_func,
%                  which in this example will be passed as @my_func.
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
% Output:
% -------
%   wout        Output sqw object with changed instrument

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% This routine is also used to set the instrument in sqw files, when it overwrites the input file.

% Parse input
% -----------
[w, args, mess] = horace_function_parse_input (nargout,varargin{:});
if ~isempty(mess), error(mess); end


% Perform operations
% ==================
narg=numel(args);
if narg==0
    % No input arguments - nothing to do
    if w.source_is_file
        argout={};
    else
        argout{1}=w.data;
    end
    
elseif narg==1 || isa(args{1},'function_handle')
    % Perform checks on input
    % -----------------------
    % Check instrument parameter arguments are valid
    if isstruct(args{1}) || isobject(args{1})
        is_instfunc=false;
        instrument=args{1}; % single structure or object
        ninst=numel(instrument);
    elseif isempty(args{1})
        is_instfunc=false;
        instrument=struct;  % empty item indicates no instrument; set to default 1x1 empty structure
        ninst=numel(instrument);
    elseif isscalar(args{1}) && isa(args{1},'function_handle')
        instfunc=args{1}; % single function handle
        % Check instrument definition function arguments are OK and consistent
        [ok,mess,instfunc_args]=check_function_args(args{2:end});
        if ~ok
            mess=['Instrument definition function: ',mess];
            error(mess);
        end
        if size(instfunc_args,1)==0
            is_instfunc=false;
            instrument=instfunc();  % call with no arguments
            ninst=1;
        else
            % If none of the arguments match substitution arguments we can evaluate the instrument definition function now
            subst_args=substitute_arguments();
            ninst=size(instfunc_args,1);
            if substitution_arguments_present(subst_args,instfunc_args);
                is_instfunc=true;
            else
                is_instfunc=false;
                instrument=instfunc(instfunc_args{1,:});
                if ninst>1
                    instrument=repmat(instrument,ninst,1);
                    for i=2:ninst
                        instrument(i)=instfunc(instfunc_args{i,:});
                    end
                end
            end
        end
    else
        error('Instrument must be a structure, object or function handle (or an empty argument to indicate ''no instrument'')')
    end
    
    % Check that the data has the correct type
    if ~all(w.sqw_type(:))
        error('Instrument can only be set or changed in sqw-type data')
    end
    
    % Change the instrument
    % ---------------------
    source_is_file=w.source_is_file;
    nobj=numel(w.data);     % number of sqw objects or files
    
    % Set output argument if object input
    if source_is_file
        flname=w.data;  % name(s) of sqw files
    else
        wout=w.data;    % set output argument if object input
    end
    
    % Check the number of spe files matches the number of instruments
    if ninst>1
        for i=1:nobj
            if w.nfiles(i)~=ninst
                error('An array of instruments was given but its length does not match the number of spe files in (all) the sqw source(s) being altered')
            end
        end
    end
        
    % Change the instruments for each data source in a loop
    for i=1:nobj
        % Read the header part of the data
        if source_is_file
            [mess,h.main_header,h.header,h.detpar,h.data]=get_sqw (flname{i},'-hisverbatim');
            if ~isempty(mess), error(mess), end
        else
            h=wout(i);  % pointer to object
        end
        % Change the header
        nfiles=h.main_header.nfiles;
        tmp=h.header;   % to keep referencing to sub-fields to a minimum
        if nfiles>1
            for ifile=1:nfiles
                if ninst==1
                    if is_instfunc
                        args=substitute_arguments(h,ifile,instfunc_args(1,:));
                        tmp{ifile}.instrument=instfunc(args{:});
                    else
                        tmp{ifile}.instrument=instrument;
                    end
                else
                    if is_instfunc
                        args=substitute_arguments(h,ifile,instfunc_args(ifile,:));
                        tmp{ifile}.instrument=instfunc(args{:});
                    else
                        tmp{ifile}.instrument=instrument(ifile);
                    end
                end
            end
        else
            if is_instfunc
                args=substitute_arguments(h,1,instfunc_args(1,:));
                tmp.instrument=instfunc(args{:});
            else
                tmp.instrument=instrument;
            end
        end
        % Write back out
        if source_is_file
            h.header=tmp;
            mess = put_sqw (flname{i},h.main_header,h.header,h.detpar,h.data,'-his');
            if ~isempty(mess), error(['Error writing to file ',flname{i},' - check the file is not corrupted: ',mess]), end
        else
            wout(i).header=tmp;
        end
    end
    
    % Set return argument if necessary
    if source_is_file
        argout={};
    else
        argout{1}=wout;
    end
else
    error('Check the number of input arguments')
end


% Package output arguments
% ------------------------
[varargout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end


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
%       	scalar      ---->   column vector (nrun elemnents)
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
% Check if any argumnent are to be substituted

narg=numel(args);
isstr=false(narg,1);
for i=1:narg
    isstr(i)=isstring(args{i});
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
function argout = substitute_arguments(w,ifile,argin)
% Substitue arguments with values from object
%
% Return cellstr with list of all substitution arguments:
%   >> subst_args = substitute_arguments
%
% Argument list with subsitutions made from sqw object or header fields of sqw file:
%   >> argout = substitute_arguments(w,ifile,argin)     
    
% List of substitution keywords
if nargin==0
    argout={'-efix'};
    return
end

% Substitute values
argout=argin;
for i=1:numel(argin)
    if isstring(argin{i}) && strcmpi(argin{i},'-efix')
        if ifile>1 || w.main_header.nfiles>1
            argout{i}=w.header{ifile}.efix;
        else
            argout{i}=w.header.efix;
        end
    end
end
