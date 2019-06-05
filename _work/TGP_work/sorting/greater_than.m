function status = greater_than (A,B)
% Generic routine to determine if one object array  is greater than another
%
%   >> status = greater_than (A,B)
%
% An object array is deemed 'greater' if one of the following applies, in
% order:
% - class name is longer
% - class name is greater by Matlab comparison string1>string2
% - number of dimensions of the array size
% - larger extent along first dimension, second dimension,...
% - recursive comparison until objects, cell arrays and structures are
%   resolved into numeric, logical or character comparisons
%
% Objects are compared using a method that overloads '>' (i.e. gt.m)
% If such a method does not exist, then objects are recursively resolved
% into structures of the independent properties.


% First version by T.G.Perring 2019-05-09


classA = class(A);
classB = class(B);
szA = size(A);
szB = size(B);

if isequal(classA,classB) && isequal(szA,szB)
    if ismethod(A,'gt') || ischar(A)    % method query doesnt work for some reason
        Agreater = (A>B);
        Bgreater = (B>A);
    elseif iscell(A)
        Agreater = cellfun(@(x,y)(greater_than(x,y)),A,B);
        Bgreater = cellfun(@(x,y)(greater_than(x,y)),B,A);
    elseif isstruct(A) || isobject(A)
        fieldsA = fieldnamesIndep(A);
        fieldsB = fieldnamesIndep(B);
        if isequal(fieldsA,fieldsB)
            Agreater = arrayfun(@(x,y)(greater_than_struct_or_obj(x,y)),A,B);
            Bgreater = arrayfun(@(x,y)(greater_than_struct_or_obj(x,y)),B,A);
        else
            status = greater_than(fieldsA,fieldsB);
            return
        end
    end
    iA = find(Agreater(:),1);
    iB = find(Bgreater(:),1);
    status = (isscalar(iA) && (~isscalar(iB) || iA<iB));
    
else
    status = (greater_than(classA,classB) ||...
        (isequal(classA,classB) && greater_than(szA,szB)));
end

%------------------------------------------------------------------------------
function status = greater_than_struct_or_obj(A,B)
% Case of both a scalar structure with same fieldnames, or both a scalar object
% with same independent properties. This is assumed to have already been checked
 
structA = structIndep(A); % a straight pointer copy if is a structure
structB = structIndep(B);
status = greater_than(struct2cell(structA),struct2cell(structB));
