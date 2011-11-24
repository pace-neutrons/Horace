function [varargout]=load_data(this,new_file_name)
% function loads ASII spe data into run_data structure        
%
% this fucntion is the method of load_spe class
%
% this function has to have its eqivalents in all other loader classes
% as all loaders are accessed through common interface.
%
%usage:
%>>[S,ERR,en]      = load_data(this,[new_file_name])
%>>[S,ERR,en,this] = load_data(this,[new_file_name])
%>>this            = load_data(this,[new_file_name])
%
% $Author: Alex Buts; 20/10/2011
%
% $Revision$ ($Date$)
%
 
if exist('new_file_name','var')
   if ~isa(new_file_name,'char')
        error('LOAD_ASCII:load_data','new file name has to be a string')
   end
   this.file_name  = check_file_exist(new_file_name,{'.spe'});               
   file_name  = this.file_name;
else
   if isempty(this.file_name)
        error('LOAD_ASCII:load_data','input spe file is not defined\n')
   end
    file_name= this.file_name ;        
end


use_mex=get(her_config,'use_mex');
if use_mex
  try
   [S,ERR,en] = get_ascii_file(file_name ,'spe');   
  catch 
    warning('LOAD_ASCII:load_data',' Can not read data using C++ routines -- reverted to Matlab\n Reason: %s',lasterr());
    use_mex=false;
  end
end
if ~use_mex
   [S,ERR,en] = get_spe_matlab(file_name);
end
% eliminate symbolic NaN-s
nans      = ismember(S,-1.E+30);
S(nans)   = NaN;
ERR(nans) = 0;
%
this.S  =S;
this.ERR=ERR;    
this.en =en;        


if     nargout == 1
    varargout{1}=this;
elseif nargout ==2
    varargout{1}=S;    
    varargout{2}=ERR;        
elseif nargout == 3
    varargout{1}=S;    
    varargout{2}=ERR;        
    varargout{3}=en;            
elseif nargout == 4
    varargout{1}=S;    
    varargout{2}=ERR;        
    varargout{3}=en;            
    varargout{4}=this;  
end




