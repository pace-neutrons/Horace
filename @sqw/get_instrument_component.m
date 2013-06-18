function obj_arr = get_instrument_component(w,name)
% Return an array of the named instrument component in a single sqw object
%
%   >> obj_arr = instrument_component(w,name)
%
% Input:
% ------
%   w           sqw object (must be sqw type)
%   name        Name of instument field e.g 'moderator'
%
% Output:
% -------
%   obj_arr     Array of the object in the sqw object
%               The ith element of obj_arr is
%                   w.header{i}.instrument.(name)

if ~is_sqw_type(w)
    error('Check object is sqw-type: cannot get instrument components from a dnd-type sqw object')
end

header=w.header;
if ~iscell(header)
    obj_arr=header.instrument.(name);
else
    nrun=numel(header);
    obj_arr=repmat(header{1}.instrument.(name),[nrun,1]);
    for i=2:nrun
        obj_arr(i)=header{i}.instrument.(name);
    end
end
