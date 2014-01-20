function [det,this]=load_par(this,varargin)
% method loads par data into run data structure and returns it in the format,requested by user
% usage:
% if ascii par file is defined, the method returns the information from ASCII par file
% if it is absent, it returns detectors information stored in nxspe file. 
%
%>>[det,loader_nxspe]= loader_nxspe.load_par(['-nohor'])
%                      returns detectors information loaded from the nxspe file,
%                      previously associated with loader_nxspe class by
%                      loader_nxspe constructor
%
%  loader_nxspe_var -- the instance of properly initiated loader_nxspe class
% '-nohor' or '-array' -- if present request to return the data as Horace structure,
%
%                      if not --  as (6,ndet) array with fields:
%
%     1st column    sample-detector distance
%     2nd  "        scattering angle (deg)
%     3rd  "        azimuthal angle (deg)
%                   (west bank = 0 deg, north bank = -90 deg etc.)
%                   (Note the reversed sign convention cf .phx files)
%     4th  "        width (m)
%     5th  "        height (m)
%     6th  "        detector ID
%
%>>[det,loader_nxspe]=loader_nxspe.load_par(file_name,['-array'])
%                     returns detectors information from the file
%                     name specified.
% file_name -- the name of another nxspe file or ascii par or phx file.
%                     The function redefines the nxspe loader to work with
%                     new file if the file_name is the name of nxspe file or
%                     sets loader_nxspe read detectors from ascii par file if
%                     this file name refers to ascii par file
%
%
% $Revision$ ($Date$)
%

options = {'-nohorace','-array','-horace'}; % if options changes, parse_par_file_arg should also change
[return_array,file_profided,new_file_name,lext]=parse_par_file_arg(this,options,varargin{:});

if file_profided
    if ~strcmp('.nxspe',lext)
        this.par_file_name = new_file_name;
    else
        this.file_name = new_file_name;
    end
end

if isempty(this.par_file_name)
    [det,this] = load_nxspe_par(this,return_array);
else
    ascii_par_file = this.par_file_name;
    if return_array
        params = {ascii_par_file,'-nohor'};
    else
        params = {ascii_par_file};
    end
    [det,this]=load_par@asciipar_loader(this,params{:});
end
%--------------------------------------------------------------------------
function [return_array,file_provided,new_file_name,lext]=parse_par_file_arg(this,options,varargin)
% method analyses and processes various options specified with loader_nxspe.load_par
% command
%
%
new_file_name ='';
file_provided=false;
lext = this.get_file_extension();
return_array=false;

if numel(varargin)>0
    log_level = get(herbert_config,'log_level');
    [ok,mess,return_array1,return_array2,hor_format_deprecated,file_name]=parse_char_options(varargin,options);
    if ~ok
        if log_level >0
            disp('Usage:');
            help loader_nxspe.load_par;
        end
        error('LOADER_NXSPE:load_par',mess)
    else
        return_array =return_array1||return_array2;
    end
    %
    if hor_format_deprecated
        warning('LOADER_NXSPE:load_par','option -horace is deprecated, loader returns data in Horace format by default')
    end
   % 
    if ~isempty(file_name)
        if numel(file_name)>1
            if log_level >0
                disp('Usage:');
                help loader_nxspe.load_par;
            end
            error('LOADER_NXSPE:load_par','only one file name allowed as input parameter')
        end
        new_file_name = file_name{1};
        [~,~,lext] = fileparts(new_file_name);
        if isempty(lext)
            error('LOADER_NXSPE:load_par','new file name %s should have known extension',new_file_name)
        end
        file_provided = true;
    end
    
end
