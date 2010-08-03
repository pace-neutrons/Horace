classdef sqw_hdf < one_sqw
% the class supports hdf5 representation of the sequence of hdf5 sqw files. 
%
%
%

   properties(GetAccess='private', SetAccess='private')
        
      % the variable to hold the list of the headers of the spe files        
        spe_headers_list; 

        %-----------------------------------------------------------
        % THIS IS THE VARIABLES TO CONTROL STORAGE OF CONTRIBUTING sqw(spe)
        % file headers
        %
        % The name of the group with the headers of all sligle sqw(spe) files,
        % contributing into this sqw-n file
        components_Group_Name='COMPONENT_HEADERS';
        % hdf-group ID for the group above;
        components_group_ID;
        
        % name of the attribute, associated with this group and stating the
        % number of the headeders, already written to the file;
        components_counter_attr='num_spe_headers';
        comp_counter_attrID;
        % the value of the attribute above;
        components_counter=0;        
        % the subgroup name 
        component_subgroup_name='header_N';
        % matlab-hdf-stupidity parameter indicating if the
        % components_group_ID is already opened, as matlab does not allow
        % direct check of the components_group_ID;
        compogroup_is_opened=false;        
   end
   properties(GetAccess='public', SetAccess='private')
       sqw_file_header=' an sqw file';
   end

    
   methods
     function this=sqw_hdf(sqw_file,varargin)
    % the constructor for sqw_hdf file
    % usages:
    % obj=sqw_hdf(fileName) -- builf sqw_hdf file on a basis of hdf5 file
    %                          usually for future sqwn data writing, but
    %                          should work both ways
    % obj=sqw_hdf(fileName,'-no_new')
    %                       -- builf sqw_hdf file on a basis of hdf5 file
    %                          but the file has to exist 
    %                          Throws if there are no such file. 
    %                          this is for accessing the data;
    % obj=sqw_hdf(fileName,listOne_spe_fileNames)
    %                       -- build sqw_hdf on a basis of
    %                          sequence of one_sqw files, e.g. combine this
    %                          sequence 
    % where:
    % fileName -- the name of sqw file
    %             if the file exist, it has to be proper sqw_hdf file with all
    %             data in it
    %             if it does not exist, a default sqw_hdf file will be created
    % 
    
    % modificators is the structure, which modifies the properies of sqe
    % header according to requests of sqwn class;
    % see the description of the fields, which can be included into this
    % structure in the function parse_header_arguments.m (the private function of spe_header class)
    %
    % the headers structure will be passed to the parent class, which
    % describes the header of sqw_hdf file and tailor standard
    % properties of header file in accordence with needs of sqw_hdf
    % class                         
    modificators.sqwn_header_structure=build_sqwn_header(sqw_file);
    % we redefine the new file extension here;                
    modificators.new_extension='.sqw'; 
    %
    % if the key -no_new is specified, the constuctor fails if the sqwn
    % file does not exist
    modificators.fail_if_new_file=(nargin>1&&(~iscellstr(varargin{1}))&&strncmpi(varargin{1},'-no_new',7));
    % structure, which describes detectors positions
    detectors =[];
    this=this@one_sqw(sqw_file,detectors,modificators);

      
     if nargin==1 % building from a file?
           if this.new_file_created
              this = create_headers_group(this);
           else
              this=open_headers_group(this);               
           end
     elseif nargin==2  % building new sqw-n from sequence of files;
       if iscellstr(varargin{1})
            listOne_spe_fileNames=varargin{1};
            this = combine_multiple_nxs_files(this,listOne_spe_fileNames);
       elseif ischar(varargin{1}) % this is probably a key 
       else
          help sqw_hdf.sqw_hdf
          error('HORACE:hdf_tools','sqw_hdf=>call with wrong parameters');
       end          
     else
     end
     end
%% ========================================================================     
     function this=write(this,varargin)
         this=write@one_sqw(this);
         if nargin>1
             if nargin>2
             end
         end
     end
    function [sqwn,this]=read(this,varargin)
     % interface to Toby's code, intendet to transform data into the
     % form expected
        sqwn0 =read@one_sqw(this,varargin{:});
        data_fields ={'filename';'filepath';'efix';'emode';'alatt';'angdeg';'cu';'cv';'psi';...
                      'omega';'dpsi';'gl';'gs';'en';'uoffset';'u_to_rlu';'ulen';'ulabel';...
                      'urange';'s';'e';'npix'};        
         for i=1:numel(data_fields)
             data.(data_fields{i})=sqwn0.(data_fields{i});
         end
         sqwn.data=data;
         sqwn.data.title      = sqwn0.main_header_title;         
         sqwn.data.uoffset    = sqwn0.uoffset';         
       
                 
         if any(sqwn0.iax)
            sqwn.data.iax = sqwn0.iax;
            sqwn.data.iint= sqwn0.iint;
         else
            %ndims = max(size(size(sqwn0.npix))); 
            sqwn.data.iax  = zeros(1,0);
            sqwn.data.iint = zeros(2,0);
         end         
         sqwn.data.pax        = sqwn0.pax;         
         sqwn.data.dat        = sqwn0.pax;  % *** > what should be here?       
         sqwn.data.p          = sqwn0.p;
         header_fields = {'filename';'filepath';'efix';'emode';'alatt';'angdeg';'cu';'cv';'psi';...
                          'omega';'dpsi';'gl';'gs';'en';'uoffset';'u_to_rlu';'ulen';'ulabel'};    % column
         %header_shapes = false(numel(header_fields),1);
         % make true the header_shapes for the fields specified 
         header_shapes =ismember(header_fields,{'uoffset'});
                      
        sqwn.header=this.read_component_headers(header_fields,header_shapes);                      

%        MAIN HEADER FIELDS
%        'filename';'filepath';'title';'nfiles'         
         sqwn.main_header.filename= sqwn0.filename;
         sqwn.main_header.filepath= sqwn0.filepath;
         sqwn.main_header.title = sqwn0.main_header_title;
         sqwn.main_header.nfiles= sqwn0.main_header_nfiles;
                
         sqwn.detpar=this.read_detectors();  
        
         %sqwn.main_header.uoffset=sqwn.main_header.uoffset';
    end
     
   end %methods
end %clasdef
