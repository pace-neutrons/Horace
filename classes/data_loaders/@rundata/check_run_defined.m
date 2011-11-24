function  [undefined,fields_to_load,fields_from_defaults,fields_undef]  = check_run_defined(run,fields_needed)
% method verifies if all necessary run parameters are defined by the class
%
% Input: 
% run             -- initated instance of the rundata class
% fields_needed   -- list of the fields to verify (optional) -- if absent,
%                    derived from the class method
% returns:
% undefined -- the number, which informs the user on how the file is
%               defined. It can be:
% 0         -- all data defined and loaded to memory
% 1         -- all data defined but some fields have to be read from hdd
% 2         -- some fields are needed, but no definition for them can be
%              found in memory, hdd or from defaults
%
% fields_to_load -- cellarray of field names which have to be load from hdd
% fields_from_defaults -- cellarray of field naems, which values have
%                         default and the default for them were used
% fields_undef   -- cellarray of the fields, which are missed'
%
% $Author: Alex Buts; 20/10/2011
%
% $Revision: 1 $ ($Date:  $)
%
%
undefined           = 0; % false; all defined;
fields_to_load      ={};
fields_from_defaults={};

% check if all necessary fields are already provided 
s=warning('off','MATLAB:structOnObject');
all_values    = struct2cell(struct(run));
is_undef      = cellfun(@is_empty,all_values);
all_fields    = fields(run);
warning(s.state,'MATLAB:structOnObject');
% if everything is defined, no point to bother, finish
fields_undef  = all_fields(is_undef);
if isempty(fields_undef)
    return;    
end


% what fields have to be defined (as function of crystal/powder parameter)?
if ~exist('fields_needed','var')
    fields_needed = what_fields_are_needed(run);
end

% only some of undefined fields are needed to define run
is_needed     = ismember(fields_undef,fields_needed);
fields_undef  = fields_undef(is_needed);    
if isempty(fields_undef)
     return;    
end        

    

% something still undefined, let's check if we can deal with it;
undefined = 1;  

% can missing fields be obtained from data loader?
loader_provides = defined_fields(run.loader);
is_in_loader    = ismember(fields_undef,loader_provides);
if sum(is_in_loader)>0
    fields_to_load=fields_undef(is_in_loader);
else
    fields_to_load={};
end
% if we can obtain everything we need from a file?
fields_undef = fields_undef(~is_in_loader);
if isempty(fields_undef) % we can load everything
      fields_from_defaults={};
      return;
end

% do the missing fields have defaults?
have_defaults        = ismember(fields_undef,run.fields_have_defaults);
fields_from_defaults = fields_undef(have_defaults);
% and now something else left:
fields_undef = fields_undef(~have_defaults);
% necessary fields are still undefined by the run
if ~isempty(fields_undef) 
    undefined = 2;       
    disp([' Necessary fields: ',fields_undef{:} ]);
    disp([' are not defined by either the data reader ',class(run.loader),' or by the command line arguments\n']); 
    
end

function isit=is_empty(the_cell)
% the function which is applied to each element of cell array verifying if
% it is empty
   isit=false;
   if isempty(the_cell)
        isit=true;
   end


