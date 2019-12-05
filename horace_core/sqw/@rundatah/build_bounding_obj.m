function rdl = build_bounding_obj(obj,varargin)
% return limiting rundata object, namely object with all detectors but only
% min and max transmitted energy range
%
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)
%
if nargin == 3
    en_min  = varargin{1};
    en_max  = varargin{2};
    range_given = true;
elseif nargin == 1
    range_given = false;
else
    error('RUNDATA:invalid_argument',...
        'calc_bounding_obj: method called with wrong number of input arguments');
end

if isempty(obj.loader)
    if ~range_given
        error('RUNDATAH:invalid_argument',...
            'calc_bounding_obj: trying to calculate rundata urange but the object is not fully defined and energy range is not specified')
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
            error('RUNDATAH:invalid_argument',...
                'calc_bounding_obj: incomplete input object, %s',mess);
        end
        en = rdl.en;
        if numel(en) > 2
            enps=(en(2:end)+en(1:end-1))/2;
        elseif numel(en) == 1
            enps = en(1);
        elseif numel(en) == 2
            enps = en;
        else
            error('RUNDATAH:invalid_argument',...
                'calc_bounding_obj: no energy loaded in input object and no energy ranges are provided');
        end
        en_min = enps(1);
        en_max = enps(end);
    else
        error('RUNDATAH:invalid_argument',...
            'calc_bounding_obj: no input range is given and source object does not contain enenrgy range');
    end
else
    rdl = rundatah(obj);
    enps = [en_min,en_max];
end
%
if isempty(en_max) || en_min==en_max
    en = [en_min-1,en_min+1];
else
    en = [en_min*(1-sign(enps(1))*eps);en_max*(1+sign(enps(end))*eps)];
    
end

nen  = numel(en);
ndet = numel(det.x2);

%

% Get the maximum limits along the projection axes across all spe files
%rdl.data_file_name = '';
rdl.S= zeros(nen,ndet);
rdl.ERR = zeros(nen,ndet);
rdl.en = en;


