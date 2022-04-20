function [rdl,obj] = build_bounding_obj(obj,varargin)
% return limiting rundata object, namely object with all detectors but only
% min and max transmitted energy range
%
%
if nargin == 3
    en_min  = varargin{1};
    en_max  = varargin{2};
    range_given = true;
elseif nargin == 1
    range_given = false;
else
    error('HORACE:build_bounding_obj:invalid_argument',...
        'calc_bounding_obj: method called with wrong number of input arguments');
end

if isempty(obj.loader)
    if ~range_given
        error('HORACE:build_bounding_obj:invalid_argument',...
            'calc_bounding_obj: trying to calculate rundata pix_range but the object is not fully defined and energy range is not specified')
    end
    obj_defined = false;
else
    obj_defined = true;
end

% load or retrieve detectors, the operation does not reload detectors
% already in memory
[det,obj]=obj.get_par();


if ~range_given
    if obj_defined
        [rdl,ok,mess] = obj.load_metadata();
        if ~ok
            error('HORACE:build_bounding_obj:invalid_argument',...
                'calc_bounding_obj: incomplete input object, %s',mess);
        end
        en = rdl.en;
        if isempty(en)
            error('HORACE:build_bounding_obj:invalid_argument',...
                'calc_bounding_obj: no energy loaded in input object and no energy ranges are provided');
        end
        en_min = en(1);
        en_max = en(end);
    else
        error('HORACE:build_bounding_obj:invalid_argument',...
            'calc_bounding_obj: no input range is given and source object does not contain enenrgy range');
    end
    if en_min == en_max
        en = [en_min-1,en_max+1];
    else
        en = get_en_from_range(en_min,en_max);
    end

else
    rdl = rundatah(obj);
    en = get_en_from_range(en_min,en_max);
end
%

nen  = numel(en);
ndet = numel(det.x2);

%

% Get the maximum limits along the projection axes across all spe files
%rdl.data_file_name = '';
rdl.S= zeros(nen,ndet);
rdl.ERR = zeros(nen,ndet);
rdl.en = en;


function en = get_en_from_range(en_min,en_max)

if en_min == 0 || en_max == 0 || sign(en_min)*sign(en_max)>0
    en = [en_min*(1-sign(en_min)*eps),en_max*(1+sign(en_max)*eps)];
else %we want even number of equally spaced bins, to produce 3 odd bin cenres    
    en = [en_min*(1-sign(en_min)*eps),0,en_max*(1+sign(en_max)*eps)];
end
