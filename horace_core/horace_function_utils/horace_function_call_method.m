function argout = horace_function_call_method (nargout_caller, func, input_type, varargin)
% Generic function to call sqw or dnd class methods
%
%   >> argout = horace_function_call_method (nargout_caller, func, input_type, data_source, arg1, arg2, ...)
%
% Input:
% ------
%   nargout_caller  Number of return arguments expected by caller. This gives the
%                  minimum number of return arguments that must be provided
%   func            Handle to function name (the appropriate class will be resolved
%                  in this function)
%   input_type      Required data input type
%                       '$sqw' - sqw objects
%                       '$dnd' - dnd objects
%                       '$hor' - either of the above
%   data_source     sqw or dnd object (or array of objects)
%                       *OR*
%                   filename or cell array of filenames
%                     If input_type is '$hor', then will treat as all sqw files, if can
%                     Otherwise, will attempt to treat as all dnd files with same dimensionality.
%
%   arg1, arg2,...  Arguments to be passed to the method
%
% Output:
% -------
%   argout          Cell array containing the output arguments
%                   - source_arg_is_struct==false:
%                       Cell array of the arguments arg1, arg2, ...
%                       If no arguments, then empty cell array
%                   - source_arg_is_struct==true:
%                       Cell array with single element that is in turn a
%                      cell array of the arguments arg1, arg2, ...
%                       If no arguments, then a cell array with a single
%                      empty cell array
%
%  The convention is that if the source of data to the calling function (as indicated by
% the field source_arg_is_struct in w) is an object of the class or is one or more
% filenames, then the output arguments, if any, are filled.
%  If the source of data is a data source structure, then a single output argument is returned
% to be unpacked by the function that called the function that calls this one.

% Original author: T.G.Perring

% Check input_type option
% -----------------------
[ok,opt_sqw,opt_dnd,opt_hor]=is_horace_data_file_opt(input_type);
if ~ok
    error('HORACE:horace_function_call_method:invalid_argument', ...
          'Invalid value for ''input_type''')
end

% Parse input
% -----------
argout={};
if numel(varargin)>=1
    % Check for Horace data object type or filename input
    [hor_obj,sqw_obj,dnd_obj]=is_horace_data_object(varargin{1});
    if isa(varargin{1},'SQWDnDBase')
        % Horace object passed as first argument: this is assumed to be the data source
        if opt_sqw && isa(varargin{1},'DnDBase')
            error('HORACE:horace_function_call_method:invalid_argument', ...
                  'Invalid data type: expected sqw object(s)');
        end

        if opt_dnd && isa(varargin{1},'sqw')
            error('HORACE:horace_function_call_method:invalid_argument', ...
                  'Invalid data type: expected d0d,d1d,d2d,d3d,or d4d object(s)');
        end

        [w, args] = horace_function_parse_input (nargout_caller,varargin{:});
    else
        % If first argument is not a Horace object, then only other valid input is filename(s)

        [w, args] = horace_function_parse_input (nargout_caller,input_type,varargin{:});
    end

else
    % No input arguments; prompt for file name
    if opt_sqw
        [filename,mess]=getfile_horace('*.sqw');
    elseif opt_dnd
        [filename,mess]=getfile_horace('*.d0d;*.d1d;*.d2d;*.d3d;*.d4d');
    elseif opt_hor
        [filename,mess]=getfile_horace('*.sqw;*.d0d;*.d1d;*.d2d;*.d3d;*.d4d');
    end
    if ~isempty(mess)
        error('HORACE:horace_function_call_method:invalid_argument', mess)
    end

    [w, args] = horace_function_parse_input (nargout_caller,input_type,filename);

end

if all(w.sqw_type)
    dummy_obj=sqw();
else
    ndims=w.ndims(1);
    DnDBase.dnd(ndims);
end

% Perform operations
% ------------------
% Channel the call to a method of the correct class
argout = func(dummy_obj,w,args{:});

% Package output arguments
% ------------------------
argout = horace_function_pack_output(w,argout{:});
