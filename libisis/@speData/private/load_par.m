function this = load_par(this)
% Try to load Horace par data from existing nxspe file
%
%   >> this = load_par(this)
%
% If data not present, or data format is incorrect, throws

% $Revision: 508 $ ($Date: 2010-11-29 15:50:24 +0000 (Mon, 29 Nov 2010) $)

% Note: non-nxspe file does not contain par data
if  strcmpi(this.fileExt,'.nxspe')
    filename        = fullfile(this.fileDir,[this.fileName this.fileExt]);
    fields          = spe_hdf_filestructure(2);
    fields          = fields.data_field_names;
    if iscell(this.nxspe_root_folder)
        warning('SPEDATA:load_par','multiple par fields are currently not supported');
        hdf5_root_folder = this.nxspe_root_folder{1};
    else
        hdf5_root_folder  = this.nxspe_root_folder;
    end
    
    this.par.group = 1:this.nDetectors;
    this.par.phi     = (hdf5read(filename,[hdf5_root_folder,'/',fields{7}]))';
    this.par.azim  = (hdf5read(filename,[hdf5_root_folder,'/',fields{8}]))';  % llok for sign change to get correct convention?
    this.par.width  = (hdf5read(filename,[hdf5_root_folder,'/',fields{9}]))';
    this.par.height = (hdf5read(filename,[hdf5_root_folder,'/',fields{10}]))';
    this.par.x2      = (hdf5read(filename,[hdf5_root_folder,'/',fields{11}]))';

else
    error('SPEDATA:load_par','logic error - load par from nxspe is called non-nxspe file');
end
