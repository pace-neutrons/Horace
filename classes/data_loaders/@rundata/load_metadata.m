function  [this,ok,mess,undef_list] = load_metadata(this,varargin)
% Load in memory all run related information except large data itself
%
% Large data are S, ERR, en (if not already in memory) and detectors information
% Returns modified object and true if all necessary metadata can be loaded
% or false if not. It also returns list of undefined fields
%
%Usage:
%>>[this,ok,mess,undef_list] = load_metadata(this);
%>>[this,ok,mess,undef_list] = load_metadata(this,'-for_powder');
% if '-for_pwder'  option is specified, lattice or lattice fields do not
% need to be defined
%
% $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)
%
keys = {'-for_powder'};
[ok,mess,for_powder] = parse_char_options(varargin,keys);
if ~ok
    error('RUNDATA:invalid_argument','load_metadata: %s',mess);
end
mess ='';
ok = true;
large_data_fields = {'S','ERR','en','det_par'};
if ~isempty(this.lattice)
    undef_lattice = this.lattice.get_undef_fields();
else
    if for_powder
        undef_lattice = {};
    else
        undef_lattice= {'lattice'};
    end
end
%
data_fields = rundata.main_data_fields();
in_metha = ~ismember(data_fields,large_data_fields);
metha_fields = data_fields(in_metha);
in_undef_list = cellfun(@(fln)(isemptyfield(this,fln)),metha_fields);
undef_data = metha_fields(in_undef_list);
undef_list = [undef_data';undef_lattice(:)'];
if ~isempty(undef_list) && ~isempty(this.loader)
    ldf = this.loader.loader_can_define();
    if ~for_powder
        % extract lattice fields stored in loader
        lat_in_load = ismember(undef_lattice,ldf);
        lat_fld = undef_lattice(lat_in_load);
        latt = this.oriented_lattice__;
        %
        for i=1:numel(lat_fld)
            fld = lat_fld{i};
            val = this.loader__.(fld);
            if ~isempty(val) && ~isnan(val)
                latt.(fld) = val;
            end
        end
        this.oriented_lattice__ = latt;
        undef_lattice = this.lattice.get_undef_fields();
        
        %
        % extract data fields stored in loader. It seems, this never 
        % occurs with current loaders?
        if numel(undef_data)>0
            dat_in_load = ismember(undef_data,ldf);
            dat_fld = undef_data(dat_in_load);
            for i=1:numel(dat_fld )
                fld = dat_fld{i};
                val = this.loader__.(fld);
                if ~isempty(val) && ~isnan(val)
                    this.(fld) = val;
                end
            end
            
            in_undef_list = cellfun(@(fln)(isemptyfield(this,fln)),metha_fields);
            undef_data = metha_fields(in_undef_list);
        end
        undef_list = [undef_data';undef_lattice(:)'];
    end
    
end
if ~isempty(undef_list)
    ok = false;
    ndf = cellfun(@(x)([x,'; ']),undef_list,'UniformOutput',false);    
    mess = ['Found undefined fields: ',ndf{:}];
end

function is = isemptyfield(this,fln)
if isempty(this.(fln))
    is = true;
else
    is = false;
end

