function [argout,mess] = horace_function_call_method (nargout_caller, func, input_type, varargin)
% Generic function to call sqw or dnd class methods
%
%   >> [argout,mess] = horace_function_call_method (nargout_caller, func, input_type, data_source, arg1, arg2, ...)
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
%   mess            Error message; empty if all OK, otherwise contains a message 
%                   and argout is set to empty cell array.
%
%  The convention is that if the source of data to the calling function (as indicated by
% the field source_arg_is_struct in w) is an object of the class or is one or more
% filenames, then the output arguments, if any, are filled.
%  If the source of data is a data source structure, then a single output argument is returned
% to be unpacked by the function that called the function that calls this one.

% Original author: T.G.Perring
%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)
%

% Check input_type option
% -----------------------
[ok,opt_sqw,opt_dnd,opt_hor]=is_horace_data_file_opt(input_type);
if ~ok
    error('Invalid value for ''input_type''')
end
    
% Parse input
% -----------
argout={};
if numel(varargin)>=1
    % Check for Horace data object type or filename input
    [hor_obj,sqw_obj,dnd_obj]=is_horace_data_object(varargin{1});
    if hor_obj
        % Horace object passed as first argument: this is assumed to be the data source
        if opt_hor || (opt_sqw&&sqw_obj) || (opt_dnd&&dnd_obj)
            [w, args, mess] = horace_function_parse_input (nargout_caller,varargin{:});
        else
            if opt_sqw
                mess='Invalid data type: expected sqw object(s)';
            else
                mess='Invalid data type: expected d0d,d1d,d2d,d3d,or d4d object(s)';
            end
        end
    else
        % If first argument is not a Horace object, then only other valid input is filename(s)
        [w, args, mess] = horace_function_parse_input (nargout_caller,input_type,varargin{:});
    end
    if ~isempty(mess), return, end
    
else
    % No input arguments; prompt for file name
    if opt_sqw
        [filename,mess]=getfile_horace('*.sqw');
    elseif opt_dnd
        [filename,mess]=getfile_horace('*.d0d;*.d1d;*.d2d;*.d3d;*.d4d');
    elseif opt_hor
        [filename,mess]=getfile_horace('*.sqw;*.d0d;*.d1d;*.d2d;*.d3d;*.d4d');
    end
    if ~isempty(mess), return, end
    [w, args, mess] = horace_function_parse_input (nargout_caller,input_type,filename);
    if ~isempty(mess), return, end
    
end

if all(w.sqw_type)
    dummy_obj=sqw;
else
    ndims=w.ndims(1);
    if ndims==0
        dummy_obj=d0d;
    elseif ndims==1
        dummy_obj=d1d;
    elseif ndims==2
        dummy_obj=d2d;
    elseif ndims==3
        dummy_obj=d3d;
    elseif ndims==4
        dummy_obj=d4d;
    end
end

% Perform operations
% ------------------
% Channel the call to a method of the correct class
argout=func(dummy_obj,w,args{:});

% Package output arguments
% ------------------------
[argout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end
