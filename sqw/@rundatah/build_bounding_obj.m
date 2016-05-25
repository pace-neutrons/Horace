function rdl = build_bounding_obj(obj,varargin)
% return limiting rundata object, namely object with all detectors but only
% min and max transmitted energy range
%
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)
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

if obj_defined
    [rdl,ok,mess] = obj.load_methadata();
    if ~ok
        error('RUNDATAH:invalid_argument',...
            'calc_bounding_obj: incomplete input object, %s',mess);
    end
    en = rdl.en;
    if numel(en) > 2
        enps=(en(2:end)+en(1:end-1))/2;
    elseif numel(en) == 1
        enps = en(1);
    elseif range_given
        enps = [en_min;en_max];
    elseif numel(en) == 2
        enps = en;
    else
        error('RUNDATAH:invalid_argument',...
            'calc_bounding_obj: no energy loaded in input object and no energy ranges are provided');
    end
    if range_given
        en_min = min([enps(1);en_min]);
        if ~isempty(en_max)
            en_max = max([enps(end);en_max]);
        else
            en_max = enps(end);
        end
    else
        en_min = enps(1);
        en_max = enps(end);
    end
else
    [rdl,ok,mess,undef_fields] = obj.load_methadata();
    if ~ok
        if numel(undef_fields)>1 || ~strcmp(undef_fields{1},'en')
            error('RUNDATAH:invalid_argument',...
                'calc_bounding_obj: input rundata are not fully defined, %s',...
                mess);
        end
    end
end
%
if isempty(en_max) || en_min==en_max
    en = [en_min-1,en_min+1];
else
    bin_size = 0.5*(en_max-en_min);
    en = [en_min-bin_size;en_min+bin_size;en_max+bin_size];
end

if rdl.emode == 1
    if en(end)>rdl.efix
        enps = (en(2:end)+en(1:end-1))/2;
        if enps(end)>rdl.efix
            en = [enps(1)-eps;enps(1)+eps;rdl.efix-eps;rdl.efix];
        else
            bin_size = (rdl.efix-enps(end))*(1-eps);
            en = [enps-bin_size,enps+bin_size];
            en = reshape(en',numel(en),1);
            if en(end) == rdl.efix
                en(end) = en(end)*(1-eps);
            end
        end
    end
elseif rdl.emode == 2
    if rdl.efix+en(1)<0
        enps = (en(2:end)+en(1:end-1))/2;
        if rdl.efix+enps(1)<0
            en = [-rdl.efix;-rdl.efix+eps;enps(end)-eps;enps(end)+eps];
        else
            bin_size = (rdl.efix-en(1))*(1-eps);
            en = [enps-bin_size;enps-bin_size];
            en = reshape(en',numel(en),1);            
        end
    end
end



%
ndet = numel(det.x2);
nen  = numel(en)-1;
%

% Get the maximum limits along the projection axes across all spe files
%rdl.data_file_name = '';
rdl.S= zeros(nen,ndet);
rdl.ERR = zeros(nen,ndet);
rdl.en = en;

