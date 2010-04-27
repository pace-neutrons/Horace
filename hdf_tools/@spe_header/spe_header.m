classdef spe_header
%    
% the class suports hdf5-file representation of single spe-file header,
% which keeps all important information about the conditions of the
% experiment;
%
% Constructor Usages:
% this = spe_header(sqw_data) -- initiates hdf5 file to represent 
%                                existing sqw structhre related to one spe
%                                file. The structure is written to the file
%                                and the file remains opened
% this = spe_header(filename) -- finds and initiates exisiting hdf5 file
%                                associated with sqw data previously
%                                written on hdd. File becomes opened
%
% *** > should experiment with handle class which actomatically closes files and frees the resorurces when the variable goes out of scope
%
% intended superclass (parent's) usage:
% this = spe_header(first,[control_structure])
%                                in this form it can be used as the
%                                base class for other classes requested a
%                                hdf-5 header with similar properties. In
%                                this case the first parameter has the same
%                                meaning as in two previous cases, 
% where the control structure is the structure with possible fields:
% "fields_to_mod"                contains the field list whch a allows you
%                                to modify the fields, present in the
%                                header. If the field list has the names of the fields,
%                                already present in the basic spe_header,
%                                these fields are deleted from the resulting structure 
% "file_ext"                     you can modify file extention specifying a
%                                new one here; has to be a string;
% 
%                             
% 
% In the basic form the cass is used to read and write the additional
% infomation  about particular sqw file to and from correspondent hdf5 file
%
% $Revision$ ($Date$)
%
   properties (GetAccess='private', SetAccess='private')  
      % the fields in the list have to be present and can not be repeated
      % in an input structure (but may be empty); this field list is
      % overwritten by real fields, which are present in the structure, if
      % the file is build from a structure
       spe_field_names={'s','e','npix','pix',        ...
                         'cu','cv','psi','omega','dpsi','gl','gs','en',...
                         'uoffset','u_to_rlu','ulen','ulabel',   ...
                         'iax','iint','pax','p','dax'            ... % this are the field common for 
                       };                   
      % these fields can be present in input spe structur? but should never be written to spe header;                   
       non_spe_field_names={'detectors','s','e','npix','pix'};                   
       % the  fields which are defined in this structure and have to be
       % written to file
       this_field_names={'filename','filepath'};
     end
   properties (GetAccess='protected', SetAccess='private')  
        file_ext = '.nxs';       % the extention we want the hdf file to have
        default_fileName='sqw_'  % default file name used if the header is created from an structure without file name defined there
        
        HeaderDSName='spe_header'; %  spe-header dataset name; may be appended
                                   %  by the _Number_of_dataset if there is
                                   %  more then one dataset in an hdf file
                                   
        delete_existing_file=true; % What to do if the file we are trying to create already exists
                                   % Different strategies are possible;                                  
                                   % *** > only 'delete existing and write new ' stragegy is implemented at the moment
                                   
      % the list of the field names of the sqw structure which must be
      % used in the header and written to the hard drive as the header data;
      %
        
       new_file_created=false; 
        % fail if the file requested not exist; By default creates new spe
        % hdf5 header 
       fail_if_new_file=false;  

       sqw_file_ID=-1;            % hdf file id to work with open hdf file     
       
       % the variable which keeps the number of this partirclular instance of the       
       nInstance;  % It is used to form the name of the dataset header in  
                   % the file in case if there is more then one spe header
                   % present in the hdf file
                   % 
      
   end
   properties (GetAccess='public', SetAccess='private')
       filename;                 % name of the hdf5 (nexus) file with the data
       filepath;              
       %
                   
       % spe-header file         
       file_is_opened=false;             
   end
%% =======================================================================          
   methods      
       function this=spe_header(data,control_structure)
       % the class is responsible hdf5-file representation of single spe-file header 
       %
       %
       % Keep track of class instances; not so usefull without destructor 
       global nInstances;
       if isempty(nInstances)
           nInstances=1;
       else
           nInstances=nInstances+1;
       end
       this.nInstance=nInstances;
       

       if nargin>1   % modify some class properties, defined in the header.         
          if ~isa(control_structure,'struct')        
               help spe_header;
               error('HORACE:hdf_tools','spe_header=> second parameter, if present, has to be a  control structure');
          end
          [this,new_data_structure]=parse_header_arguments(this,control_structure);           
       else
           new_data_structure=[];
       end
       
       % build the hdf file on the basis of sqw structure;
       if   isstruct(data)           
            % 
            [this.filepath,this.filename]=set_file_name(this,data.filepath,data.filename);
       
            this=create_hdf_spe_header(this,data);
            this.new_file_created = true;

       % this is a file
       elseif ischar(data)         
           [file_path,file_name]=fileparts(data); 
           [this.filepath,this.filename] = set_file_name(this,file_path,file_name);          
           file                = full_file_name(this);           
           if ~exist(file,'file') 
               if this.fail_if_new_file
                   error('HORACE:hdf_tools',' trying to open non-existent sqw file %s',[file_name,this.file_ext]);
               end
               % create default sqw structure
               if isempty(new_data_structure)
                [spe_structure,this]=build_default_spe_structure(this);
               else
                 % the stucture is defined elsewhere;                   
                 spe_structure=new_data_structure;
               end
                % create this structure in the file 
                this=create_hdf_spe_header(this,spe_structure);                
                this.new_file_created = true;
           else
            %open an existing hdf file to get access to the structure;
                this.new_file_created=false;                                
           end
           if ~this.file_is_opened
                this.sqw_file_ID     = open_or_create(file);
                this.file_is_opened  = true;
           end

           
       else
            help spe_header;
            error('HORACE:hdf_tools','this=spe_header(data) constructor for spe_header is called with wrong arguments');          
       end

           
              
              
      end   % constructor
%% =======================================================================         
 
%     function copy_header(this,new_location_ID,varargin)
%     % the function copies this spe header into the new location in an
%     % hdf file (current or another).
%     %
%     % inputs: 
%     % new_location_ID -- new location identifier, under which we are going to place our copies;
%     % varargin{1}     -- if present the number of the header in the new
%     %                    location , if not present, the current header number will be used
%     %                    e.g. this.HeaderDSName_num2str(this.nInstance)
%     headerDSName  = this.HeaderDSName;
%     old_group_ID = H5G.open(headerDSName);
%     
%     if isempty(varargin{:})
%         destination_name=headerDSName;
%     else
%         destination_name=[headerDSName,'_',num2str(varargin{1})];
%     end
%     
% %    H5O.copy(old_group_ID,headerDSName,new_location_ID,destination_name,ocpypl_id,lcpl_id);
%     H5O.copy(old_group_ID,headerDSName,new_location_ID,destination_name,'H5P_DEFAULT','H5P_DEFAULT');    
%     end
%% =======================================================================         
    function name=full_file_name(this)
        name = fullfile(this.filepath,[this.filename,this.file_ext]);
    end
%-------------------------------------------------------------------------    
    function [fields,is_empty,this]=data_fields(this,varargin)
    % the function returns the cellarray of the data fields, present in the
    % file under spe group
    % usage:
    % [fields,is_empty]=spe_file.data_fields(['-brief'])
    % fields      are the names of the datasets stored under the spe header. The
    %             names are specified in the full form, fully identifying the
    %             location of the dataset within hdf file. 
    % is_empty    boolean array indicating the fields which are empty
    %
    % when '-brief' parameter is specified, the names of the datasets are
    %               returned in brief form, only the field name and no
    %               location within the file
    %
    [fields,is_empty,this]  =list_spe_datasets(this);
    if nargin>1
        set_name=[hdf_group_name(this.HeaderDSName),'/'];
        fields =  regexprep(fields,set_name,'');
    end
    end
%% =======================================================================      
      function this=open_hdf(this)
        if ~this.file_is_opened 
            full_file_name=fullfile(this.file_path,[this.file_name,this.file_ext]);
            this.sqw_file_ID    = open_or_create(full_file_name);        
            this.file_is_opened = true;
        end
      end
 
%% =======================================================================      
      function [sqw_data,this]=read_header(this,varargin)
      % function reads the group which should exist in the hdf5 file
      % under the header this.HeaderDSName_XXX where XXX is an instance number 
      %
      % if varargin is present, it has to be structure with field names
      % present in the file. The function then reads these fields only
      %
       if this.file_is_opened
            file_ID = this.sqw_file_ID;
            file_opened_initially=true;
       else
            fileName= full_file_name(this);
            file_ID = open_or_create(fileName);
            file_opened_initially=false;
       end

       sqw_data=read_spe_header(this,file_ID,varargin{:});

       if ~file_opened_initially
          H5F.close(file_ID);
       end
      
      end
  %% =======================================================================
    function this=delete(this)
% *** should be a handle class but not entirely clear what to do with it        
        if this.file_is_opened
            H5F.close(this.sqw_file_ID);           
        end
        this.file_is_opened=false;
    end
              
   end  % methods
    
end