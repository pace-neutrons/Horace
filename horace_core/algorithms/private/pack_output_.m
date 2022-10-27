function out = pack_output_(out_to_convert,cell_output,same_type)
% convert bunch of the input parameters in the form reququested by
% output parameters
% Inputs:
% out_to_convert -- cellarray of parameters to convert to the requested
%                   form
% nout           -- number of ouptput requested by the calling function
% cell_output    -- if true, the result should be returned in cellarray, if
%                   false, and all elements in out_to_convert array are the
%                   same type, the result is combined into array
% same_type      -- if true, indicates that all elements of the input
%                   cellarray are the same type and combining them into the
%                   single array is possible. If false, or absent, the type
%                   of inputs are identified by the routine
% Outputs:
% out           -- depending on the combination of inputs, the data
%                   transformed into the form:
% or                varargout = array(out_to_convert)
% or                varargout = out_to_convert;
%

if nargin<4
    same_type = false;
    if ~cell_output % no need to check if the input is the same or different
        class_name = class(out_to_convert{1});
        is_same = cellfun(@(x)isa(x,class_name),out_to_convert);
        if all(is_same)
            same_type = true;
        end
    end
end


if ~cell_output && all(same_type)
    out = [out_to_convert{:}];
else
    out = out_to_convert;
end
