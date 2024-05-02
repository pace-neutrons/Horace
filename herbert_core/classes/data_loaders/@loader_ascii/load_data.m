function [varargout]=load_data(obj,new_file_name)
% Loads ASCII spe data into run_data structure
%
% this fucntion is the method of load_spe class
%
% this function has to have its equivalents in all other loader classes
% as all loaders are accessed through common interface.
%
%usage:
%>>[S,ERR,en]      = load_data(this,[new_file_name])
%>>[S,ERR,en,this] = load_data(this,[new_file_name])
%>>this            = load_data(this,[new_file_name])

%

if exist('new_file_name', 'var')
    if ~isa(new_file_name,'char')
        error('HERBERT:loader_ascii:invalid_argument',...
            'new file name has to be a string')
    end
    obj.file_name  = new_file_name;
else
    if isempty(obj.file_name)
        error('HERBERT:loader_ascii:invalid_argument',...
            'input spe file is not fully defined')
    end

end
file_name  = obj.file_name;

use_mex=config_store.instance().get_value('hor_config','use_mex');
if use_mex
    try
        [S,ERR,en] = get_ascii_file(file_name ,'spe');
    catch err
        [force_mex,ll]=config_store.instance().get_value('hor_config','force_mex_if_use_mex','log_level');
        if ~force_mex
            if ll > -1
                warning('HERBERT:loader_ascii:runtime_error',' Cannot read data using C++ routines -- reverted to Matlab\n Reason: %s',err.message);
            end
            use_mex=false;
        else
            error('HERBERT:loader_ascii:runtime_error',' Cannot read data using C++ routines \n Reason: %s',err.message);
        end
    end
end

if ~use_mex
    [S,ERR,en] = get_spe_(file_name);
end

% Convert symbolic NaN-s into ISO NaN-s
nans      = (S(:,:)<-1.e+29);
S(nans)   = NaN;
ERR(nans) = 0;

accuracy = obj.ASCII_DATA_ACCURACY;
% Fill output argument(s)
if nargout == 1
    % set also all dependent on S variables
    obj.S_  =round(S,accuracy );
    obj.ERR_=round(ERR,accuracy );
    obj.en_ =round(en,accuracy );

    varargout{1}=obj;
elseif nargout ==2
    varargout{1}=round(S,accuracy );
    varargout{2}=round(ERR,accuracy );
elseif nargout == 3
    varargout{1}=round(S,accuracy );
    varargout{2}=round(ERR,accuracy );
    varargout{3}=round(en,accuracy );
elseif nargout == 4
    obj.S_  =round(S,accuracy );
    obj.ERR_=round(ERR,accuracy);
    obj.en_ =round(en,accuracy);

    varargout{1}=obj.S_ ;
    varargout{2}=obj.ERR_;
    varargout{3}=obj.en_;
    varargout{4}=obj;
end
