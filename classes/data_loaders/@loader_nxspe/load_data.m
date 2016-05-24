function [varargout]=load_data(this,new_file_name)
% function loads nxspe data into run_data structure
%
% this function is the method of loader_nxspe class
%
% this function has to have its equivalents in all other loader classes
% as all loaders are accessed through common interface.
%
%usage:
%>>[S,ERR]         = load_data(this,[new_file_name])
%>>[S,ERR,en]      = load_data(this,[new_file_name])
%>>[S,ERR,en,this] = load_data(this,[new_file_name])
%>>this            = load_data(this,[new_file_name])
%
%
%
% $Revision$ ($Date$)
%

if exist('new_file_name','var')
    % check the new_file_name describes correct file, got internal file
    % info and obtain this info.
    this.file_name = new_file_name;
end

if isempty(this.file_name)
    error('LOAD_NXSPE:invalid_argument',' input nxspe file is not defined')
end

%
file_name  = this.file_name;
root_folder= this.root_nexus_dir;

data=cell(1,3);

%
data{1}  = hdf5read(file_name,[root_folder,'/data/data']);
data{2}  = hdf5read(file_name,[root_folder,'/data/error']);
if isempty(this.en)
    this.en_ =hdf5read(file_name,[root_folder,'/data/energy']);
end
data{3} = this.en;
% convert symbolic NaN-s (build according to ASCII agreement) to ISO
% NaN-s
S = data{1};
nans = (S(:,:)<-1.e+29);
data{1}(nans) = NaN;
data{2}(nans) = 0;


this.S_   = data{1};
this.ERR_ = data{2};

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
