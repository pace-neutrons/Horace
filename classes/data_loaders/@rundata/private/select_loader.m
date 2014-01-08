function this=select_loader(this,varargin)
% method selects the data loader for the rundata class as function of
% supplied file names and defines other data fields, if they are specified 
% by command line arguments
%
% it assumes that the first and, if present second argument in varargin are
% the data_file_name and parameters_file_name
% 
% Usage: (private, used by rundata constructor);
%>>this=select_loader(this,'data_file.nxspe',['par_file.par'],varargin{2:end})
%>>this=select_loader(this,'data_file.spe',   'par_file.par',varargin{2:end})
%>>this=select_loader(this,'data_file.spe_h5','par_file.par',varargin{2:end})
%  
% where varagin{:} has the form: 
% 'field', value -- with field to be an existing rundata field name and 
%          value -- its desired value, which may redefine the value, specified in the 
%                   correspondent spe or par file. 
%
% $Author: Alex Buts 20/10/2011
% 
% $Revision$ ($Date$)
%
  
if nargin==1; return; end

first_file = varargin{1};
if ~isstring(first_file)    % build from a file;
    error('RUNDATA:invalid_argument','unsupported first argument');            
end 
% check if second parameter is a file
second_file ='';
vararg_start_from=2;
if nargin>2
    if isstring(varargin{2})
        second_file=varargin{2};
        vararg_start_from=3;
    end
end
this.loader = loaders_factory.instance().get_loader(first_file,second_file);

if nargin>vararg_start_from
    % set up values which are defined by other arguments
    this=set_param_recursively(this,varargin{vararg_start_from:end});
end


 
   
