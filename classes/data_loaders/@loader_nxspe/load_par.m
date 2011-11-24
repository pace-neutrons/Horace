function [det,this]=load_par(this,varargin)
% method loads par data into run data structure and returns it in the format,requested by user
%
% this function has to have its eqivalents in all other loader classes
% as all loaders are accessed through common interface.
%
% usage:
%>>[det,loader_nxspe]= load_par(loader_nxspe_var,'-hor')
%                      returns detectors information loaded from the nxspe file, 
%                      previously associated with loader_nxspe class by 
%                      loader_nxspe constructor
%  loader_nxspe_var -- the instance of properly initated loader_nxspe class 
% '-hor'            -- if present request to return the data as horace structure,
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
%>>[det,loader_nxspe]=load_par(loader_nxspe(),file_name,['-hor'])
%                     returns detectors information from the file
%                     name specified. The function alse redefines
%                     the nxspe file name, stored in loader_nxspe
%                     class, if loader_nxpse was the variable of
%                     loader_nxspe class
%


return_horace_format= false;
file_name           = this.file_name;
%
% verify if the parameters request other file name and horace data format;
if nargin>1
    [new_file_name,file_format] = parse_par_arg(file_name,varargin{:});
    if ~isempty(file_format)
         return_horace_format = true;	       
    end
    if ~strcmp(new_file_name,file_name)
          this =  check_file_correct(this,new_file_name);    
          % new nxspe file provied, so we have to clear all data if they
          % were availible
          if ~isempty(this.S);
              this.S   =[];
              this.ERR =[];
              this.en  =[];
              this.Ei  =[];
              this.psi =[];              
          end
    end

end
if isempty(this.file_name)
   error('LOAD_NXSPE:load_par',' undefined input file name');
end
% load operation itself
par      = load_nxspe_par(this);

% perform requested transformations of data
size_par = size(par);
ndet     = size_par(2);

disp(['loaded ' num2str(ndet) ' detector(s)']);
this.n_detectors = ndet;


if return_horace_format
  det = get_hor_format(par,this.file_name);
else
  det = par;
end
this.det_par = par;


