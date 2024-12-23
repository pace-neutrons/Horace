function obj=select_loader_(obj,varargin)
% method selects the data loader for the rundata class as function of
% supplied file names and defines other data fields, if they are specified
% by command line arguments
%
% it assumes that the first and, if present second argument in varargin are
% the data_file_name and parameters_file_name
%
% Usage: (private, used by rundata constructor);
%>>this=select_loader(this,'data_file.nxspe',['par_file.par'],varargin{2:end})
%>>this=select_loader(this,'data_file.spe',   'par_file.par',varargin{2:end})
%
%
% where varagin{:} has the form:
% 'field', value -- with field to be an existing rundata field name and
%          value -- its desired value, which may redefine the value, specified in the
%                   correspondent spe or par file.
%
% $Author: AB 20/10/2011
%
%

if nargin==1; return; end
assume_ASCII_spe_loader = false;

first_file = varargin{1};
if isempty(first_file) % assume ASCII spe loader
    if isempty(first_file) && numel(varargin) == 1
        obj.loader_ = [];
        return;
    end
    assume_ASCII_spe_loader = true;
elseif ~ischar(first_file)    % build from a file;
    error('HERBERT:rundata:invalid_argument',...
        'unsupported first argument. Should be data file name but the input is not char and is %s',...
        class(first_file));
end
% check if second parameter is a file
second_file ='';
addarg_start_from=2;
if nargin>2
    if ischar(varargin{2}) || isempty(varargin{2})
        second_file=varargin{2};
        addarg_start_from=3;
    end
end

if assume_ASCII_spe_loader
    obj.loader_ = loader_ascii();
    obj.loader_.par_file_name =second_file;
else
    if ~verLessThan('matlab', '9.0') && verLessThan('matlab', '9.1')
        warning('off','MATLAB:subscripting:noSubscriptsSpecified')
    end

    obj.loader_ = loaders_factory.instance().get_loader(first_file,second_file);
end
def_fields = obj.loader_.defined_fields();
lat_fields = oriented_lattice.lattice_fields;
in_lat  = ismember(lat_fields,def_fields);
if any(in_lat)
    if isempty(obj.lattice_)
        obj.lattice_ = oriented_lattice();
        lat_fields = lat_fields(in_lat);

        lat = obj.lattice_;
        for i=1:numel(lat_fields)
            flt = lat_fields{i};
            lat.(flt) = obj.loader_.(flt);
        end
        obj.lattice = lat;
    end
end


if nargin>addarg_start_from
    % set up values which are defined by other arguments
    if isa(varargin{addarg_start_from},'rundata')
        varargin{addarg_start_from}.loader_ = obj.loader_;
    end
    obj=set_param_recursively(obj,varargin{addarg_start_from:end});
end
