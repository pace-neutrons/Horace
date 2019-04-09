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
%  '-forcereload'     usually data are loaded in memory onece, and taken from memory after that
%                     -forcereload request always loading data into memory.
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
%>>[det,loader_nxspe]=loader_nxspe.load_par(file_name,['-array'],['-getphx'])
%                     returns detectors information from the file
%                     name specified.
% file_name -- the name of another nxspe file or ascii par or phx file.
%                     The function redefines the nxspe loader to work with
%                     new file if the file_name is the name of nxspe file or
%                     sets loader_nxspe read detectors from ascii par file if
%                     this file name refers to ascii par file
%
% '-getphx'         option returns data in phx format.
%                   invoking this assumes (and sets up) -nohorace
%                   option.
% Phx data format has a form:
%
% 1st (1)	secondary flightpath,e.g. sample to detector distance (m)
% 2nd (-)   0
% 3rd (2)	scattering angle (deg)
% 4th (3)	azimuthal angle (deg) (west bank = 0 deg, north bank = 90 deg etc.)
%           Note the reversed sign convention wrt the .par files. For details, see: SavePAR v
% 5th (4) 	angular width e.g. delta scattered angle (deg)
% 6th (5)	angular height e.g. delta azimuthal angle (deg)
% 7th (6)	 detector ID   - this is Mantid specific value, which may not hold similar meaning in files written by different applications.
%
% In standard phx file only the columns 3,4,5 and 6 contain useful information.
% You can expect to find column 1 to be the secondary flightpath and the column
% 7 - the detector ID in Mantid-generated phx files only or in
% the files read from nxspe source
%
% reader ignores column 2, so -getphx option returns array of
% 6xndet data in similar to par format, but the meaning or the
% columns 4 and 5 are different
%

%
% $Revision:: 830 ($Date:: 2019-04-09 10:03:50 +0100 (Tue, 9 Apr 2019) $)
%
options = {'-nohorace','-array','-horace','-forcereload','-getphx'}; % if options changes, parse_par_file_arg should also change
[return_array,reload,file_provided,getphx,new_file_name,lext]=parse_par_file_arg(this,options,varargin{:});

if file_provided
    if ~strcmp('.nxspe',lext)
        this.par_file_name = new_file_name;
    else
        this.file_name = new_file_name;
    end
end

if isempty(this.par_file_name)
    [det,this] = load_nxspe_par(this,return_array,reload);
    if getphx % in this case return_array is true and we are converting only array
        det = convert_par2phx(det);
    end
else
    ascii_par_file = this.par_file_name;
    if return_array
        params = {ascii_par_file,'-nohor'};
    else
        params = {ascii_par_file};
    end
    if getphx
      params = {params{:},'-getphx'};
    end
    [det,this]=load_par@asciipar_loader(this,params{:});
end
%--------------------------------------------------------------------------
function phx = convert_par2phx(par)
% par contains col:
%     4th  "        width (m)
%     5th  "        height (m)
%phx contains col:
%    4 	angular width e.g. delta scattered angle (deg)
%    5 	angular height e.g. delta azimuthal angle (deg)

phx = par;
phx(4,:) =(360/pi)*atan(0.5*(par(4,:)./par(1,:)));
phx(5,:) =(360/pi)*atan(0.5*(par(5,:)./par(1,:)));

%--------------------------------------------------------------------------
function [return_array,reload,file_provided,getphx,new_file_name,lext]=parse_par_file_arg(this,options,varargin)
% method analyses and processes various options specified with loader_nxspe.load_par
% command
%
%
new_file_name ='';
file_provided=false;
lext = this.get_file_extension();
return_array=false;
reload = false;
getphx = false;

if numel(varargin)>0
    log_level = get(herbert_config,'log_level');
    [ok,mess,return_array1,return_array2,hor_format_deprecated,reload,getphx,file_name]=parse_char_options(varargin,options);
    if ~ok
        if log_level >0
            disp('Usage:');
            help loader_nxspe.load_par;
        end
        error('LOADER_NXSPE:load_par',mess)
    else
        return_array =return_array1||return_array2;
    end
    if getphx
        return_array= true;
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
        [dummy0,dummy1,lext] = fileparts(new_file_name);
        if isempty(lext)
            error('LOADER_NXSPE:load_par','new file name %s should have known extension',new_file_name)
        end
        file_provided = true;
    end
    
end
