function status = greater_than_private (A,B,public)
% Generic routine to determine if one argument is greater than another
%
%   >> status = greater_than_private (A,B,public)
%
% An entity is deemed 'greater' if one of the following applies, in
% order:
% - class name is longer
% - class name is greater by Matlab comparison string1>string2
% - number of dimensions of the array size
% - larger extent along first dimension, second dimension,...
% - recursive comparison until objects, cell arrays and structures are
%   resolved into numeric, logical or character comparisons
%
% Objects of the same class are compared using a method that overloads '>',
% that is, a method with name 'gt'.
%
% If such a method does not exist for a particular object, then that object
% is resolved into a structure of the properties using structPublic or
% structIndep according to the value of the logical flag 'public', and
% comparison done on the contents of the fields. The process is continued
% until all nested structures and objects have been resolved.
%
%
% Input:
% ------
%   A, B    The two arguments to be compared. They can have any class and
%           size.
%
%   public  Logical flag:
%            true:  keep public properties (independent and dependent)
%                   More specifically, it calls an object method called
%                  structPublic if it exists; otherwise it calls the
%                  generic function structPublic.
%            false: keep independent properties only (hidden, protected and
%                   public)
%                   More specifically, it calls an object method called
%                  structIndep if it exists; otherwise it calls the
%                  generic function structIndep.


% First version by T.G.Perring 2019-05-09


classA = class(A);
classB = class(B);
szA = size(A);
szB = size(B);

if isequal(classA,classB) && isequal(szA,szB)
    if ~isa(A,'function_handle')
        if iscell(A)
            Agreater = cellfun(@(x,y)(greater_than_private(x,y,public)),A,B);
            ABequal  = cellfun(@(x,y)(isequaln(x,y)),A,B);
        elseif isobject(A)
            if ismethod(A,'gt')
                Agreater = arrayfun(@(x,y)(gt(x,y)),A,B);
            else
                Agreater = arrayfun(@(x,y)(greater_than_obj(x,y,public)),A,B);
            end
            ABequal  = arrayfun(@(x,y)(isequaln(x,y)),A,B);
        elseif isstruct(A)
            fieldsA = fieldnames(A);
            fieldsB = fieldnames(B);
            if isequal(fieldsA,fieldsB)
                Agreater = arrayfun(@(x,y)(greater_than_struct(x,y,public)),A,B);
                ABequal  = arrayfun(@(x,y)(isequaln(x,y)),A,B);
            else
                status = greater_than_private(fieldsA,fieldsB,public);
                return
            end
        else
            Agreater = (A>B);
            ABequal = (A==B);
        end
        Bgreater = ~(Agreater|ABequal);
        iA = find(Agreater(:),1);
        iB = find(Bgreater(:),1);
        status = (isscalar(iA) && (~isscalar(iB) || iA<iB));
    else
        % A function handle object can only be scalar
        status = greater_than_private(func2str(A),func2str(B),public);
    end
    
else
    status = (greater_than_private(classA,classB,public) ||...
        (isequal(classA,classB) && greater_than_private(szA,szB,public)));
end

%------------------------------------------------------------------------------
function status = greater_than_obj(A,B,public)
% Case of scalar objects of same class (assumed already checked)

if public
    structA = structPublic(A);
    structB = structPublic(B);
else
    structA = structIndep(A);
    structB = structIndep(B);
end
status = greater_than_private(struct2cell(structA),struct2cell(structB),public);

%------------------------------------------------------------------------------
function status = greater_than_struct(A,B,public)
% Case of scalar structures with same fieldnames (assumed already checked)

status = greater_than_private(struct2cell(A),struct2cell(B),public);
