function [is,val,argi] = check_angular_units_present_(obj,varargin)
%
if nargin == 2 && isstruct(varargin{1})
    argi = varargin{1};
    if isfield(argi,'angular_units')
        is = true;
        val = argi.angular_units;
        argi= rmfield(argi,'angular_units');
    else
        is = false;
        val = [];
    end
else
    pos_par_names = obj.saveableFields();
    pos_deg = numel(pos_par_names); % The location of deg/rad argument as positonal argument
    if numel(varargin)>=pos_deg && ischar(varargin{pos_deg}) && ismember(varargin{pos_deg},{'deg','rad'})
        % deg/rad argument is present as last postional argument
        is   = true;
        val  = varargin{pos_deg};

        keep = true(1,numel(varargin));
        keep(pos_deg) = false;
        if strncmp(varargin{pos_deg-1},'angular_units',numel(varargin{pos_deg-1}))
            keep(pos_deg-1) = false;
        end
        argi = varargin(keep);
    else
        argi = varargin;
        is = false;
        val = [];
    end
    is_ang = cellfun(@(x)ischar(x)&&strncmp(x,'angular_units',numel(x)),argi);
    % check if angular units are defined using key-value pair
    if any(is_ang) % the constructor defines specific units for
        % the angular values. It has to be set first
        is = true;
        au_key_num = find(is_ang);
        au_val_num = au_key_num +1;
        val  = argi{au_val_num};
        is_ang(au_val_num) = true;
        argi = argi(~is_ang);
    end
end