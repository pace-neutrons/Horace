function [obj_arr,ok] = get_instrument_field(header,name)
% Return an array of the named instrument field within a single sqw object or file header
%
%   >> obj_arr = instrument_component(w,field1,field2,...)
%
% Input:
% ------
%   header      Header block in an sqw object or file (must be sqw type)
%   name        Name(s) of instument field
%                   e.g 'moderator'
%                   e.g 'moderator','pulse_model'
%
% Output:
% -------
%   obj_arr     Array of the object in the sqw object
%   ok          =true  if the field exists and can be created as an array if
%                      more than one spe data set in the header)
%               =false otherwise (e.g. the field does not exist)

try
    if ~iscell(header)
        obj_arr=header.instrument.(name);
    else
        nrun=numel(header);
        obj_arr=repmat(header{1}.instrument.(name),[nrun,1]);
        for i=2:nrun
            obj_arr(i)=header{i}.instrument.(name);
        end
    end
    ok=true;
catch
    obj_arr=[];
    ok=false;
end