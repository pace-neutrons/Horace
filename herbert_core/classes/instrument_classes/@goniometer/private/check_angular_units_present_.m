function [is,val,argi] = check_angular_units_present_(obj,varargin)
% Function used as goniometer construction helper. It goes through
% the list of input parameters and checks if property 'angular_units' is
% present among input values. If it is there, list of input parameters is
% strept off this parameter and the value is returned in inputs.
%
% If it is present, it means that angles provided as constructor parameters
% are expressed in these units, so the units have to be set first to avoid
% deg->rad or rad->deg recalculation when angles are set and
%
%
argi = varargin;
is = false;
val = [];

if nargin == 2 && (isstruct(varargin{1}) || isa(varargin{1},'goniometer'))
    argi = varargin{1};
    if isa(argi,'goniometer')
        is = true;
        val = argi.angular_units;
    else
        if isfield(argi,'angular_units')
            is = true;
            val = argi.angular_units;
            argi= rmfield(argi,'angular_units');
        end
    end
else
    pos_par_names = obj.constructionFields();
    pos_deg = numel(pos_par_names); % The location of deg/rad argument as positonal argument
    %                               % is at the end of the parameter list
    if numel(varargin)>=pos_deg % full number of construction arguments
        ang_units_cand = varargin{pos_deg};
        if istext(ang_units_cand)
            ang_units_cand  = char(ang_units_cand);
        else
            ang_units_cand = '';
        end
        if  ~isempty(ang_units_cand) &&...
                ismember(ang_units_cand,{'deg','rad'})
            % deg/rad argument is present as last postional argument
            is   = true;
            val  = varargin{pos_deg};

            keep_arg = true(1,numel(varargin));
            keep_arg(pos_deg) = false;
            % may be it is in the last argument position but member of key-value pair?
            angunits_key_cand = varargin{pos_deg-1};
            if strncmp(angunits_key_cand,'angular_units',numel(angunits_key_cand))
                keep_arg(pos_deg-1) = false;
            end
            argi = varargin(keep_arg);
            return;
        end
    end
    % check if 'angular_units' is present as key-value pair
    is_ang = cellfun(@(x)istext(x)&&strncmp(x,'angular_units',max(3,numel(x))),argi);
    % check if angular units are defined using key-value pair
    if any(is_ang)
        is = true;
        au_key_num = find(is_ang);
        au_val_num = au_key_num +1;
        val  = argi{au_val_num};
        is_ang(au_val_num) = true;
        argi = argi(~is_ang);
    end
end