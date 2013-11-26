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
%
% $Revision$ ($Date$)
%

old_file_name = this.file_name;

[this,return_horace_format,new_file_name]=check_par_file(this,'.nxspe',varargin{:});
%
% new if the parameters request other file name and horace data format;
if ~isempty(new_file_name) && ~strcmp(new_file_name,old_file_name)
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

% load operation itself
par      = load_nxspe_par(this);

% perform requested transformations of data
size_par = size(par);
ndet     = size_par(2);

if get(herbert_config,'log_level')>0
    disp(['LOADER_NXSPE:load_par::loaded ' num2str(ndet) ' detector(s)']);
end
this.n_detectors = ndet;
this.det_par = par;


if return_horace_format
  det = get_hor_format(par,this.file_name,false);
else
  det = par;
end



