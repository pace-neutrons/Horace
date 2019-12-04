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
%
%  The convention is that if the source of data to the calling function (as indicated by
% the field source_arg_is_struct in w) is an object or is one or more filenames, then
% the output arguments are placed in a cell array. This is because the calling function
% will be returning the arguments as varargout, and the output from this function will
% correctly be the cell array that is varargout.
%
%  If the source of data to the calling function is a data source structure, then the
% output arguments arg1, arg2,... are placed in a cell array that in turn is set to
% the only element of the cell array that is argout. This is because the calling function
% was in turn called a function that packed the input object into the data source 
% structure (or itself was passed a data source structure). The output will be unpacked
% by the function that called the function that called this one.

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
    mess='Insufficient number of return arguments provided';
end
