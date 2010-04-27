function [names,is_column]=fieldnames_and_shapes(struct)
%>> [names,is_column]=fieldnames_and_shapes(struct)
%
% function returns the field names of the structure struct and logical
% field, which informs if the some fields among the data are column
% vectors. 
% It is needed to interpret hdf data, as the difference between row and
% column vector is lost after writing such vector to hdf file;
%
% $Revision$ ($Date$)
%
%
if ~isstruct(struct)
    names={};
    is_column=[];
    return
end
names = fieldnames(struct);
n_names=numel(names);
is_column=false(n_names,1);
for i=1:n_names
    sz=size(struct.(names{i}));
    if sz(2)==1
        is_column(i)=true;
    end
end