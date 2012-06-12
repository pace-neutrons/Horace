%====================================================
function [det,this]=load_par(this,varargin)
% method loads par data into run data structure and returns it in the format,requested by user
%
% this function has to have its eqivalents in all other loader classes
% as all loaders are accessed through common interface.
%
% usage:
%>>det= load_par(loader_ascii,'-hor')
%             returns detectors information loaded from the ASCII file, 
%             previously associated with load_ascii class by load_ascii constructor
%  loader_ascii -- the class name of ASCII file loader class
% '-hor'            -- if present request to return the data as horace structure, if not --  as 6-column array
%
%>>[det,loader_ascii]=load_par(loader_ascii,file_name,['-hor'])
%                               returns detectors information from the file
%                               name specified. The function alse redefines
%                               the par file name, stored in loader_ascii
%                               class
%
%
% $Author: Alex Buts; 20/10/2011
%
% $Revision$ ($Date$)
%


return_horace_format=false;
file_name           = this.par_file_name;
if nargin>1
    [new_file_name,file_format]=parse_par_arg(file_name,varargin{:});
    if isempty(new_file_name)
        error('LOAD_ASCII:load_par',' undefined input file name');
    end
    if ~isempty(file_format)
         return_horace_format = true;	       
    end
    if ~strcmp(new_file_name,file_name)
            this.par_file_name           = check_file_exist(new_file_name,{'.par'});
    end

end
if isempty(this.par_file_name)
    error('LOAD_ASCII:load_par',' undefined input par file name');
end

par             = load_ASCII_par(this.par_file_name);

size_par = size(par);
ndet=size_par(2);
if get(herbert_config,'log_level')>0
    disp(['loaded ' num2str(ndet) ' detector(s)']);
end

this.n_detectors = ndet;
this.det_par     = par;

if size_par(1)==5
    det_id = 1:ndet;
    par = [par;det_id];
elseif(size_par(1)~=6)
    error('LOAD_ASCII:wrong_file_format',' proper par file has to have 5 or 6 column but this one has %d',size_par(1));        
end

if return_horace_format
  det =  get_hor_format(par,this.par_file_name);
else
  det=par;
end


