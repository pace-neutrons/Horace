function [is,mess] = eq_to_tol_shape_equal(obj1,obj2,name_a,name_b,ignore_str)
%EQ_TO_TOL_SHAPE_EQUAL Helper function used by equal_to_tol to validate
% if shape of two objects is equal for purposes of equal_to_tol comparison
% procedure
%
% Provided to be overloadable by some special classes
% Assumes that equal types have been already validated so types are equal
%
% Inputs:
% obj1    -- object 1 to compare
% obj2    -- object 2 to compare
%
% Optional:
% name_a  -- the name of first object in comparison
% name_b  -- the name of second object in comparison
%            These names become part of information message in case if
%            objects types are different
%
% Returns:
% is      -- true if objects types are equal and false if not.
% mess    -- the message providing additinal information about object types
%            it the types are different

mess = '';
is = true;

% Check that corresponding objects have the same type
if all(isempty(obj1)&isempty(obj2)) % empty objects are the same size regardless
    % of Matlab zero sizes
    return;
end
if istext(obj1)
    if ignore_str
        return;
    end
end
if isstring(obj1)
    sz1 = strlength(obj1);
    sz2 = strlength(obj2);
else
    sz1 = size(obj1);
    sz2 = size(obj2);
end
if all(sz1 == sz2)
    return;   
end
if nargin<3
    name_a = 'input_1';
end
if nargin<4
    name_b = 'input_2';
end

is = false;
if istext(obj1)
   mess = sprintf('Char arrays are different. "%s" has size: [%s] and "%s" size: [%s]', ...
        name_a,disp2str(sz1),name_b,disp2str(sz2));    
   if numel(sz1)==2 && numel(sz2)==2 && sz1(1)==1 && sz2(1)==1
       tobj1 = strrep(obj1,'\','\\');
       tobj2 = strrep(obj2,'\','\\');
       mess = sprintf('%s\n Strings contain:\n first : "%s"\n second: "%s"', ...
           mess,tobj1,tobj2);
   end
else
mess = sprintf('Objects "%s" have different sizes. "%s" has size: [%s] and "%s" size: [%s]', ...
    class(obj1),name_a,disp2str(sz1),name_b,disp2str(sz2));
end
