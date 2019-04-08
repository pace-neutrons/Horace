function obj = check_and_set_vector_(obj,vector_name,val)
% Verifies and sets appropriate lattice shift
%
%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)
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


