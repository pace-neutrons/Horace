function [return_array,force_reload,getphx,lext,this]=parse_loadpar_arguments(this,options,varargin)
% method processes the arguments specified with load_par methods
%
%
% usage:
%>>this = load_par(this,'-nohor')
%                      returns detectors information loaded from the nxspe file,
%                      previously associated with loader_nxspe class by
%                      loader_nxspe constructor
%  this             -- the instance of properly initated loader class
%
% '-nohor' or '-array' -- if present request to return the data as
%                      as (6,ndet) array with fields:

%     1st column    sample-detector distance
%     2nd  "        scattering angle (deg)
%     3rd  "        azimuthal angle (deg)
%                   (west bank = 0 deg, north bank = -90 deg etc.)
%                   (Note the reversed sign convention cf .phx files)
%     4th  "        width (m)
%     5th  "        height (m)
%     6th  "        detector ID
% it return it as horace structure otherwise

% '-forcereload'    -- load_par command does not reload
%                    detector information if the full file name
%                    (with path)
%                    stored in the horace detector structure
%                    coinsides with par_file_name defined in
%                    the class. Include this option if one
%                    wants to reload this information at each
%                    load_par.
%
%>>[det,this]=load_par(this,file_name,['-nohor'])
%                     returns detectors information from the file
%                     name specified. The function alse redefines
%                     the file name, stored in the loader
%



return_array = false;
force_reload = false;
hor_format_deprecated=false;
getphx = false;
file_name  = {};
%
if numel(varargin)>0
    [ok,mess,return_array,return_array2,hor_format_deprecated,force_reload,getphx,file_name]=parse_char_options(varargin,options);
    if ~ok
        if get(herbert_config,'log_level')>0
            disp('Usage:');
            help asciipar_loader.load_par;
        end
        
        error('ASCIIPAR_LOADER:load_par',mess)
    else
        return_array =return_array||return_array2;
    end
    
end
if getphx
    return_array = true;
end
%
if hor_format_deprecated
    warning('ASCIIPAR_LOADER:load_par','option -horace is deprecated, loader returns data in horace format by default')
end
if numel(file_name)>1
    if get(herbert_config,'log_level')>0
        disp('Usage:');
        help asciipar_loader.load_par;
    end
    
    error('ASCIIPAR_LOADER:load_par','Too many input aruments')
elseif numel(file_name)==1
    this.par_file_name = file_name{1};
end

if isempty(this.par_file_name)
    error('ASCIIPAR_LOADER:load_par','Attempting to load ASCII detector parameters but the parameters file is not defined')
end
if ~exist('lext','var')
    [crap1,crap2,lext] = fileparts(this.par_file_name);
    lext= lower(lext);
end

