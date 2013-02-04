function [argout,mess]=horace_function_pack_output(w,varargin)
% Pack return arguments for a Horace function that takes object, filename or data source structure input
%
%   >> [argout,mess] = horace_function_pack_output(w,varargin)
%
% Input:
% ------
%   w               Data dource structure created by call to horace_function_parse_input
%                  by the caller
%   arg1, arg2, ... Output arguments that need to be packed for the caller to return
%                  (If nargout_req==0, then there can be no arguments here)
%
% Output:
% -------
%   argout          Cell array containing the output arguments
%                   - source_arg_is_struct==false:
%                       Cell array of the arguments arg1, arg2, ...
%                       If no output arguments, then empty cell array
%                   - source_arg_is_struct==true:
%                       Cell array with single element that is in turn a
%                      cell array of the arguments arg1, arg2, ...
%                       If no output arguments, then a cell array with a single
%                      empty cell array
%
%   mess            Error message; empty if all OK, otherwise meeage 
%                  and argout is set to empty cell array.
%
%  The convention is that if the source of data to the calling function (as indicated by
% the field source_arg_is_struct in w) is an object of the class or is one or more
% filenames, then the output arguments, if any, are filled.
%  If the source of data is a data source structure, then a single output argument is returned
% to be unpacked by the function that called the function that calls this one.

if numel(varargin)>=w.nargout_req
    if w.source_arg_is_struct
        if numel(varargin)==0
            argout={{}};
        else
            argout={varargin};
        end
    else
        if numel(varargin)==0
            argout={};
        else
            argout=varargin;
        end
    end
    mess='';
else
    argout={};
    mess='Insufficent number of return arguments provided';
end
