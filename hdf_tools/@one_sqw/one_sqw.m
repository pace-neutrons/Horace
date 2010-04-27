classdef one_sqw < dnd_hdf 
%    
% class suports hdf5 representation of single sqw dataset related to
% correspondent experiment and spe dataset
%
% $Revision$ ($Date$)
%
  properties (GetAccess='private',SetAccess='private')
%       Valid sqw data structure, which must contain the fields listed
%       below can be of 4 types described here
%                       type 'b'    fields: uoffset,...,s,e
%                       type 'b+'   fields: uoffset,...,s,e,npix
%                       type 'a'    uoffset,...,s,e,npix,urange,pix
%               or if the pix field is not read from type 'a', in which case 
%                       type 'a-'   uoffset,...,s,e,npix,urange
% see function sqw_type below.
% *** > 
% REDUCED FIELD SET FOR DEBUG PURPOSES:
     type_fields_needed = {'filename','filepath','main_header_nfiles','main_header_title',...
                             'u_to_rlu','ulen','ulabel',...
                             's','e','npix','urange','pix'};
%      type_fields_needed = {'uoffset', 'cu','cv','psi','omega','dpsi','gl','gs','en',...
%                            'u_to_rlu','ulen','ulabel',...
%                            'iax','iint','pax','p','dax',...
%                            's','e','npix','urange','pix'};
                         
     % This is parameter defining number of fields in type_fields_needed.
     % We establish a file type (a,a-,b,b,b+) on the difference
     %  between the number of fields in type_fields_needed and the real 
     % number of fields present in the structure written to  the file
      n_fields            = 0;     % calculated dynamically 
      
      % this parameter is used while reading pixels by hyperslabs, it
      % identifies the nuber of pixels to be selected;
      pixes_selection_size=0;
  end
   
   properties (GetAccess='protected', SetAccess='private')         
% hdf properties of the pixels dataset;
        pixel_DSName = 'pix';          
        pixel_DT;
        pixel_Space;        
        pixel_DSProperties;
        pixel_DS_compression = 3;   % number from 0 to 9 defining the compression level for signal dataset;
        pixel_DS_chunk       = 1024   % the number which specifies a dataset chunk size in one direction 
                                  % Should be choosen to get optimal
                                  % dataset size and access speed
        pixel_DSID;               % hdf dataset id to work with open dataset       
         
        % we can choose single and double presition pixel accuracy. To
        % avoid modifying in in multiple places accross the class, we are
        % specifying it here;
        pixel_accuracy    = 'single'; % assumed single if not 'double';
                                                                   
   end
   properties (GetAccess='protected', SetAccess='protected')     
%     the structure identifies locations of pixel data of every signal cell in the pixel data
%     array 
        pixel_dataspace_layout = [];
        % *** > is not fully verified;
        reserve                = 1;  % the share of free space to reserve for pixels in each pseudo-cell in the pixel array on hdd
                                     % as the array itself is compressed,
                                     % this should not affect the real
                                     % space      
   end
   properties (GetAccess='public',SetAccess='protected')          %
       pixel_dims    = [9,1023*1024]; % default size and dimensionality of pixel array; redefined if buld from existing structure
   end
   properties (GetAccess='public',SetAccess='private')
       pixels_present=false; % pixel data are present in the file;
       process_pixels=true;  % store/retrieve pixel information together with image data
   end

%% ======================================================================           
    methods      
       function this=one_sqw(varargin)
       % the constructor for hdf5 representation of single sqw dataset
       %
       % >> this = one_sqw(sqw_data,detectors,header_control_structure)
       % >> this = one_sqw(sqw_data,detectors,'-nonew')
       % 
       % >> this = one_sqw(sqw_data,detectors) -- initiates hdf5 file to represent 
       %                                          existing sqw structhre
       %                                          and detectors structure
       % >> this = one_sqw(filename,detectors,'-nonew')        
       % >> this = one_sqw(filename,detectors,header_control_structure)        
       % >> this = one_sqw(filename,header_control_structure)  
       % >> this = one_sqw(filename,'-nonew')               
       % >> this = one_sqw(filename) -- finds and initiates hdf5 file
       %                                associated with sqw data 
       %
       % filename      -- the name of a file with exisitng data
       % detectors     -- detectors structure;
       % sqw_data      -- data for sqw header
       % header_control_structure
       %               --    the structure with fields, recognized
       %                      by class spe_header and functions
       %                      upper in the inheritance chain;
       % 
       %
       % enable 'nonew' option e.g. fail if the file does not exist
       modify_parameters=false;
       if (nargin==2&&ischar(varargin{2}))
            modify_parameters=true;           
            n_mod =2;
       end
       if (nargin==3&&ischar(varargin{3}))
            modify_parameters=true;           
            n_mod =3;                      
       end
       if modify_parameters
           if strcmp(varargin{n_mod},'-nonew')
               modificators.fail_if_new_file=true;
               varargin{n_mod}              =modificators;
           end
       end
       %
       this=this@dnd_hdf(varargin{:});
       
       this.n_fields =numel(this.type_fields_needed);
       
       data = varargin{1};       

       this=open_hdf(this);       
      
       if isstruct(data)     
             % builds datasets layout
             this.pixel_dims  = size(data.pix);
           
            % defines pixels dataset and writes it header to the file
            this = create_pix_dataset(this);
       elseif ischar(data)           
           if this.new_file_created % new file has been created from defaults
               % defined default pix dataset and creates default header in
               % the file (var length dataset)
                this = create_pix_dataset(this);
           else
            % opens the dataset headers. 
            this = open_pix_dataset(this);  
           end
       else
            help one_sqw.one_sqw;
            error('HORACE:hdf_tools','this=one_sqw(data) constructor for one_sqw is called with wrong arguments');
            
       end
              
       end   % constructor


 %% ======================================================================       
    function this=write_chunks(this,sqw_data,chunks,varargin)
    % write part of existing datasets, defined by the array of points to
    % use
    %
    % > this=write_chunks(this,sqw_data,chunks,varargin)
    % where:
    % sqw_data  -- the structure with s,e,npix and optionally pix
    % chunks    -- the array of the selection points for these data;
    %              the array is either mxn vector of points where m is the
    %              dimensions of the underlying dnd object and n -- number
    %              of points to select or 1D representation of such vector
    % *** > multidimentional reperesentation is currently not supported
    %              obtained using sub2ind function convoluting m-indexes
    %              into 1D location in m-dimensional file
    % varargin  -- if present should be '-nopix' or '-pix' specifying if
    %              one needs to write to file the pixel information
    %              if one does want to write pixels, field pix has to be
    %              present in the swq_data structure;    
    % side effects:
    %  1) from dnd_hdf.write_chunks
    %     npix_in_file recalculated accordingly to the values, specified in
    %     sqw_data.npix; *** > ? overhead?
    %  2)  (from write_pixel_chunks)
    %      calculates pixel dataspece layout if it is not calculated before and
    %      data to calculate it are present; if it is empty and data are not
    %      present, error is thrown. 


    if  nargin>3
         old_state = this.process_pixels;
         if strcmp(varargin{1},'-nopix')
             this.process_pixels=false;
         end
    end
    this=write_chunks@dnd_hdf(this,sqw_data,chunks);

    if this.process_pixels
        this=write_pixel_chunks(this,sqw_data.pix,chunks,sqw_data.npix);
    end
    
    if  nargin>3
         this.process_pixels=old_state;        
    end
    end
%------------------------------------------------------------------------    
    function this=write(this,sqw_data,varargin)
    % write the signal, error and pixel information combined in sqw_data
    % structure to propertly prepared and opened hdf file
    %
    % if last parameter is present, it analysed to see if writing pixel data is
    % requested
    % usage:        
    % one_sqw = write(this,sqw_data,varargin)
    %           where varargin{1} is either '-nopix' or'-pix'
    % side effects:
    %     modifies the npixels_in_file, signal_dims and pixel_dims (if -pix options active)
    %     parameters to the values,  defined in sqw_data
    %  
    if  nargin>2
         old_state = this.process_pixels;
         if strcmp(varargin{1},'-nopix')             
             this.process_pixels=false;
         end
    end
    %bigtic;    
    this = write@dnd_hdf(this,sqw_data);
    this = write_pixels_only(this,sqw_data.pix);
    %bigtoc(' writing signal dataset time: ')          
    
    if  nargin>2
         this.process_pixels=old_state;
    end
    end      
%% ======================================================================           
     function [sqw_data,this]=read_chunks(this,chunks,varargin)
    % read part of existing datasets, cells are defined by the array of
    % chunks
    % >>
    % sqw_data=read_chunks(this,chunks)
    % sqw_data=read_chunks(this,chunks,['-nopix','-pix','-nodata'])
    % sqw_data=read_chunks(this,chunks,['-nopix','-pix','-nodata'],npix)    
    %
    % we will usually read data, unless reading pixels only is specificly request 
    % 
    % side effects:
    %
    % 1) if pixel dataset layout is not defined by the object, npix data used
    %    to calculate it. If npix is not present in varargin{1}, the data are read 
    %    from the associated file (regardless to -nodata settings)
    %
    %
    read_data=true;
    if  nargin>2
         old_state = this.process_pixels;
         if strcmp(varargin{1},'-nopix')
             this.process_pixels=false;
         elseif strcmp(varargin{1},'-nodata')
             read_data=false;
             this.process_pixels=true;                      
         end
    end
    if (~this.pixels_present)&&this.process_pixels
          error('HORACE:one_sqw','read_chuns: pixels requested but no pixels stored in the dataset')
    end    

    if nargin==4
        if read_data
            [sqw_data,this]=read_chunks@dnd_hdf(chunks);
        end
        [sqw_data.pix,this]=read_pixel_chunks(this,chunks,varargin{2});       
    else
        if read_data
            [sqw_data,this]=read_chunks@dnd_hdf(chunks);
        end
        [sqw_data.pix,this]=read_pixel_chunks(this,chunks);             

    end
    if  nargin>2
         this.process_pixels=old_state;        
    end
    end    
%------------------------------------------------------------------------   
    function [sqw_data,this]=read(this,varargin)
    % read the signal, error and (pissibly) pixel information from
    % propertly prepared and opened hdf file
    %
    % if varargin is present, it analysed to see if reading pixel data is
    % requested
    %
    % >>
    % sqw_data=read(this,[{-nopix,-pix}]) 
    %
    % 'this'  - previously defined one_sqw class
    % -nopix or -pix -- optional parameter specifying if reading pixel information
    %                  is requested. When it omitted, the default behaviour
    %                  is determined by the presence pixels in the data
    %                  file. If they are present, they should be read. 
    %
    %                  The error will be thrown if pixels are requested and the pixel data are not
    %                  present in the file
    % side effects:
    % 1) spe_header fields read from the file into object
    % 2) -- singals and errors -- no effects
    % 3) sets up pixel dimensions field of the class to actuall size of the 
    %    pixels dataset in hdf file
    old_state = this.process_pixels; 
    if  nargin>1
        if old_state
            if strcmp(varargin{1},'-nopix');     this.process_pixels=false;
            end
        else
            if strcmp(varargin{1},'-pix');       this.process_pixels=true;
            end            
        end        
    end
    if ~this.pixels_present && this.process_pixels
        this.process_pixels= old_state;
        error('HORACE:hdf_tools','sqw=read(one_sqw,sqw_data) pixel information requested but is not present in the file');
    end
     [sqw_data,this]      = read_header(this);  
      sqw_data.detpar     = read_detectors(this);
     [sqw_data,this]      = read_signal(this,sqw_data);
    if this.process_pixels
        [sqw_data.pix,this]=read_pixels_only(this);
    end

    this.process_pixels  = old_state;
   
    end    
%------------------------------------------------------------------------    
    function [pixels,this]  = read_pixels(this)
    % >> [pixels,one_sqw_object]  = read_pixels(one_sqw_object)
    % reads all pixels information from an sqw file
    %
    % does nothing if process_pixel field is false
    %
    % side effects:
    % sets up pixel dimensions field of the class to actuall size of the 
    % pixels dataset in hdf file
    % 
        [pixels,this]=read_pixels_only(this);
    end
%% ======================================================================       
    function [fields,this]=data_fields(this,varargin)
    % the function returns the cellarray of the data fields, present in
    % this one_sqw file 
    % usage:
    % fields=one_sqw_file.data_fields(['-brief'])
    %
    % fields are the names of the datasets stored in the hdf file and uder 
    %        spe header. The names are specified in the full hdf5 form, 
    %        fully identifying the location of the datasets within hdf file. 
    %
    % when '-brief' parameter is used, the names of the datasets are
    %               returned in brief form, only the field name and no
    %               location within the file
    %
    fields  =list_one_sqw_datasets(this);
 
    if nargin>1
        signal_DS_name = this.signal_DSName;        
        signal_DS_contents ={'s','e','npix'};         
        
        set_name=[hdf_group_name(this.HeaderDSName),'/'];
        fields =  regexprep(fields,set_name,'');
    else
        signal_DS_name = hdf_group_name(this.signal_DSName); 
        signal_DS_contents ={'/s','/e','/npix'}; 
    end
    % /Signals is complex dataset with 3 fields namely s,e and err, so we
    % will redefine these fields below
    signals_loc = ismember(fields,signal_DS_name);
    if any(signals_loc)       
        fields = fields(~signals_loc);
        fields = {fields{:},signal_DS_contents{:}};
    end
    spe_fields = data_fields@spe_header(this,varargin{:});
    fields  = {fields{:},spe_fields{:}};
    end

    function type=sqw_type(this)
    % function analyses the fields, present in the hdf file and returns
    % a type, which describes the fields present in the file
%  usage 
%  type =sqw_file.sqw_type()
%
% where type is:
%   type        Type of sqw data written to file: 
%               Valid sqw data structure, which must contain the fields listed below 
%                       type 'b'    fields: uoffset,...,s,e
%                       type 'b+'   fields: uoffset,...,s,e,npix
%                       type 'a'    uoffset,...,s,e,npix,urange,pix
%               or if the pix field is not read from type 'a', in which case 
%                       type 'a-'   uoffset,...,s,e,npix,urange
        % fields in the file
        fields_list   =data_fields(this,'-brief');
        % what is present from the requested
        fields_present=ismember(this.type_fields_needed,fields_list);
        type_id = sum(fields_present);
        switch(type_id)
            case (this.n_fields-3)
                type = 'b'; return;
            case (this.n_fields-2)
                type = 'b+'; return;
            case (this.n_fields-1) 
                type = 'a-';return;
            case (this.n_fields)
                type = 'a'; return;
            otherwise
                % generate error message
                missing_fields = this.type_fields_needed(~fields_present);                
                n_missing_fields = numel(missing_fields);
                field_names = cell(1,n_missing_fields+1);
                field_names{1} = sprintf('\n');
                for i=1:n_missing_fields
                    field_names{i+1}=sprintf(' %s \n',missing_fields{i});
                end
                
                messg=['fields: ',[field_names{:}],' are requested, but not present in the file; Wrong sqw file'];
                error('HORACE:hdf_tools',messg);                
        end                
    
    end
    function npix=read_npix(this)   
    % read npix information from the dataset
    % >> npix=read_npix(this)   
    %
        if this.n_pixels_in_file==0
            npix =[];
            return;
        end
                                 %selection:  start, stride, count, block;
                                 %start counts from 0;
        H5S.select_hyperslab(this.signal_Space,'H5S_SELECT_SET',2,3,this.n_pixels_in_file,1);

        %H5D.read(dataset_id, mem_type_id, mem_space_id, file_space_id, plist_id)        
        npix=H5D.read(this.signal_DSID,'H5T_NATIVE_DOUBLE','H5S_ALL', this.signal_Space, 'H5P_DEFAULT');                      
    end
%    
    function npix=npixels_in_file(this)
    % npix=npixels(this)        
    % return number of pixels stored in a sqw file and contributed into
    % DND dataset
    %
        if this.pixels_present
            if ~isempty(this.pixel_dataspace_layout)
                npix = this.pixel_dataspace_layout(end);
            else
                npix = read_npix_attribute(this);
            end            
        else
            npix=0;
        end
    end
    function this = delete(this)
    % method to close hdf dataset
    % has to be called manually as there are no destructor in Matlab
    %
   try
    H5P.close (this.signal_DSProperties);
    H5D.close (this.signal_DSID);   
    H5S.close (this.signal_Space);
    H5T.close (this.signal_DT);
              
    H5P.close (this.pixel_DSProperties);
    H5D.close (this.pixel_DSID);
    H5S.close (this.pixel_Space);
    H5T.close (this.pixel_DT);   
   catch
   end
    
    this=delete@detectors(this);

    end    
    end  % methods   
end % class
