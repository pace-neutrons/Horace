 function [varargout]=load_data(this,new_file_name)
% function loads soe_h5  data into run_data structure        
%
% this fucntion is the method of loader_speh5 class
%
% this function has to have its eqivalents in all other loader classes
% as all loaders are accessed through common interface.
% 
   
if exist('new_file_name','var')
    file_name =  check_file_correct(new_file_name);    
    this.file_name =file_name ;
    this.en        =[];
else    
    if isempty(this.file_name)
        error('LOAD_SPEH5:load_data',' input spe_h5 file is not defined\n')
    end
    file_name= this.file_name ;    
end


ver=hdf5read(file_name,'spe_hdf_version');
if ver>=2
    this.efix=hdf5read(file_name,'Ei');
else
    this.efix=NaN;  
end
this.speh5_version=ver;
data{1} = hdf5read(file_name,'S(Phi,w)');
data{2} = hdf5read(file_name,'Err');
if isempty(this.en)
    data{3} = hdf5read(file_name,'En_Bin_Bndrs');
    this.en  = data{3};
else
    data{3} = this.en;
end
% eliminate symbolic NaN-s (build according to ASCII agreement)
nans          = ismember(data{1},-1.E+30);
data{1}(nans) = NaN;
data{2}(nans) = 0;

this.S   = data{1};
this.ERR = data{2};



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






