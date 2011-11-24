 function [varargout]=load_data(this,new_file_name)
% function loads mxspe data into run_data structure        
%
% this fucntion is the method of loader_nxspe class
%
% this function has to have its eqivalents in all other loader classes
% as all loaders are accessed through common interface.
%
%usage:
%>>[S,ERR,en]      = load_data(this,[new_file_name])
%>>[S,ERR,en,this] = load_data(this,[new_file_name])
%>>this            = load_data(this,[new_file_name])
%
%
if exist('new_file_name','var')
    % check the new_file_name describes correct file and found the data
    % location within nexus file;
    this = check_file_correct(this,new_file_name);       
    % if correct new file name was provided, we have to clear old par
    % values if they are present
    if ~isempty(this.det_par)
        this.det_par=[];
    end
else    
    if isempty(this.file_name)
        error('LOAD_NXSPE:invalid_argument',' input nxspe file is not defined')
    end 
end
%
file_name  = this.file_name;
root_folder= this.root_nexus_dir;

data=cell(1,5);

this.efix = hdf5read(file_name,[root_folder,'/NXSPE_info/fixed_energy']); 
this.psi  = hdf5read(file_name,[root_folder,'/NXSPE_info/psi']); 
%
data{1}  = hdf5read(file_name,[root_folder,'/data/data']);
data{2}  = hdf5read(file_name,[root_folder,'/data/error']);
data{3}  = hdf5read(file_name,[root_folder,'/data/energy']);

% eliminate symbolic NaN-s (build according to ASCII agreement)
nans          = ismember(data{1},-1.E+30);
data{1}(nans) = NaN;
data{2}(nans) = 0;


this.S   = data{1};
this.ERR = data{2};
this.en  = data{3};
if nargout==1
    varargout{1}=this;
else    
    min_val = nargout;
    if min_val>3;
        min_val=3;
        varargout{4}=this;
    end
    varargout(1:min_val)={data{1:min_val}};
 
end



