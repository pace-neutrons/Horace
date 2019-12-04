function obj = check_and_set_vector_(obj,vector_name,val)
% Verifies and sets appropriate lattice shift
%
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)
%

%
if numel(val) ~= 3
    error('CUT_TRANSF:invalid_argument',...
        ' shift has to be 3-element vecotor, bit it has %d elements',numel(val))
end
if size(val,1) == 3
    val = val';
end
obj.([vector_name,'_']) = val;


