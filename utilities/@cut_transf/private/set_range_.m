function obj = set_range_(obj,dir,val)
% Set qe objec range in specific directio?
%
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)
%

if numel(val) == 1 % its dk
    obj.dqe_(dir) = val;
elseif numel(val) == 2 % its integration ranges
    check_min_max_(val,dir);
    obj.dqe_(dir) = NaN;
    obj.qe_range_(dir,1) = val(1);
    obj.qe_range_(dir,2) = val(2);
elseif numel(val) == 3 % range and step
    check_min_max_(val,dir);
    obj.dqe_(dir) = val(2);
    obj.qe_range_(dir,1) = val(1);
    obj.qe_range_(dir,2) = val(3);
else
    error('CUT_TRANSF:invalid_argument','%s %d, %s, actual has %d elements',...
        'Cut transformation ranges in directrion ',dir,...
        ' have to be vector of 1 to 3 elements ',numel(val));
end

function  check_min_max_(val,dir)
if numel(val) == 2
    if val(2)<val(1)
        error('CUT_TRANSF:invalid_argument','Invalid range in direction %d, %s %d %d',...
            dir,'First value has to be larger then the last value, got: ',...
            val(1),val(2));
    end
else  % only 3 can be here
    if val(3)<val(1)
        error('CUT_TRANSF:invalid_argument','Invalid range in direction %d, %s %d %d',...
            dir,'First value has to be larger then the last value, got: ',...
            val(1),val(3));
    end
    
end