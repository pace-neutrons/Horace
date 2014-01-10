function [varargout]=load_data(this,new_file_name)
% Loads ASCII spe data into run_data structure
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

% $Author: Alex Buts; 20/10/2011
%
% $Revision$ ($Date$)


if exist('new_file_name','var')
    if ~isa(new_file_name,'char')
        error('LOAD_ASCII:load_data','new file name has to be a string')
    end
    this.file_name  = new_file_name;
    
else
    if isempty(this.file_name)
        error('LOAD_ASCII:load_data','input spe file is not fully defined')
    end
    
end
file_name  = this.file_name;

use_mex=get(herbert_config,'use_mex_C');
if use_mex
    try
        [S,ERR,en] = get_ascii_file(file_name ,'spe');
    catch err
        force_mex = get(herbert_config,'force_mex_if_use_mex');
        if ~force_mex
            if get(herbert_config,'log_level')>-1
                warning('LOAD_ASCII:load_data',' Cannot read data using C++ routines -- reverted to Matlab\n Reason: %s',err.message);
            end
            set(herbert_config,'use_mex_C',false);  % don't use Herbert C++ routines from now on
            use_mex=false;
        else
            error('LOAD_ASCII:load_data',' Cannot read data using C++ routines \n Reason: %s',err.message);
        end
    end
end
if ~use_mex
    [S,ERR,en] = get_spe_matlab(file_name);
end

% Convert symbolic NaN-s into ISO NaN-s
nans      = (S(:,:)<-1.e+29);
S(nans)   = NaN;
ERR(nans) = 0;

% Fill output argument(s)
if nargout == 1
    % set also all dependent on S variables
    this.S_stor  =S;
    this.ERR_stor=ERR;
    this.en_stor =en;
    
    varargout{1}=this;
elseif nargout ==2
    varargout{1}=S;
    varargout{2}=ERR;
elseif nargout == 3
    varargout{1}=S;
    varargout{2}=ERR;
    varargout{3}=en;
elseif nargout == 4
    this.S_stor  =S;
    this.ERR_stor=ERR;
    this.en_stor =en;
    
    varargout{1}=S;
    varargout{2}=ERR;
    varargout{3}=en;
    varargout{4}=this;
end
