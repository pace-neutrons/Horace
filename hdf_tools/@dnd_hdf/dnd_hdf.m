classdef dnd_hdf < detectors 
%    
% class suports hdf5 representation of single dnd dataset 
%
% $Revision$ ($Date$)
%
   
   properties (GetAccess='protected', SetAccess='private')  
% hdf properties of the signal dataset;
        signal_DSName = 'Signals';          
        signal_DT;                % signal datatype (complex -- in hdf5 sence)
        signal_Space;         
        signal_DSProperties;      % dataset modifiable properties; two listed below
        signal_DS_compression = 3;   % number from 0 to 9 defining the compression level for signal dataset;
        signal_DS_chunk       = 2048;  % the number which specifies a dataset chunk size in one direction 
                                   % Should be choosen to get optimal dataset size
        signal_DSID;               % hdf dataset id to work wih open dataset       
        %
        % the fields of the class, to be written as attributres to the
        % dataset
        dataset_description_fields={'n_pixels_in_file','signal_dims'};
   end
   properties (GetAccess='public',SetAccess='protected')          %
       % number of pixels contributing into signal dataset; Summ of all npix elements        
       % has to be modified each time npix field is supplied
       n_pixels_in_file= -1;           
       % default size and dimensionality of signal array; redefined if buld from existing structure       
       % prod(signal_dims) can not change for an existing file
       signal_dims     =[50,50,50,50] 
   end
 
%% ======================================================================           
    methods      
       function this=dnd_hdf(varargin)
       % the constructor for hdf5 representation of single dnd dataset
       %
       % >> this = dnd_hdf(sqw_data,detectors,header_control_structure)
       % >> this = dnd_hdf(sqw_data,detectors,'-nonew')
       % 
       % >> this = dnd_hdf(sqw_data,detectors) -- initiates hdf5 file to represent 
       %                                          existing sqw structhre
       %                                          and detectors structure
       % >> this = dnd_hdf(filename,detectors,'-nonew')        
       % >> this = dnd_hdf(filename,detectors,header_control_structure)        
       % >> this = dnd_hdf(filename,header_control_structure)  
       % >> this = dnd_hdf(filename,'-nonew')               
       % >> this = dnd_hdf(filename) -- finds and initiates hdf5 file
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
       this=this@detectors(varargin{:});
       this.signal_DS_compression=get(hdf_config,'hdf_compression');
       if this.signal_DS_compression<0||this.signal_DS_compression>9
           this.signal_DS_compression=0;
           set(hdf_config,'hdf_compression',0);
           warning('HORACE:hdf_tools','wrond compression level requested for hdf files, it has been reset to 0 compression');
       end
             
       data = varargin{1};   
       % after here the target file becomes open permamently
       this = open_hdf(this);       
      
       if isstruct(data)     
           this.signal_dims     = size(data.s);
           this.n_pixels_in_file= sum(reshape(data.npix,1,numel(data.npix)));
          
          % builds datasets layout and writes correspondent headers to the file
           this = create_signal_dataset(this);
       elseif ischar(data)           
           if this.new_file_created % new file has been created from defaults
               % create default dataset on the basis of default
               % signal_dims and n_pixels_in_file; note that
               % prod(signal_dims) can not change for an existing file
               this = create_signal_dataset(this);
           else
            % opens the dataset headers. 
            this = open_signal_dataset(this);  
           end
       else
            help dnd_hdf.dnd_hdf;
            error('HORACE:hdf_tools','this=dnd_hdf(varargin) constructor for dnd_hdf is called with wrong arguments');
            
       end
              
       end   % constructor


 %% ======================================================================       
    function this=write_chunks(this,sqw_data,chunks)
    % write part of existing datasets, the method for 
    % Usage:
    % this=write_chunks(this,sqw_data,chunks,varargin)
    % where:
    % sqw_data  -- the structure with s,e,npix and optionally pix
    % chunks    -- the array of the selection points for these data;
    %              the array is either mxn vector of points where m is the
    %              dimensions of the underlying dnd object and n -- number
    %              of points to select or 1D representation of such vector
    %              obtained using sub2ind function convoluting m-indexes
    %              into 1D location in m-dimensional file
    % side effects:
    %     npix_in_file recalculated accordingly to the values, specified in
    %     sqw_data.npix;
    if numel(sqw_data.s) ~= prod(this.signal_dims)
        error('HORACE:hdf_tools','the size of the signal array (%d) is not constistent with the space, allocated in file (%d)',numel(sqw_data.s),prod(this.signal_dims))        
    end
    % *** >  this is not entirely true as we are writing only the part of
    %        a dataset and the final numel may differ from the one in file
    %        it is danged of misuse, but unclear how to avoid without
    %        substantial overhead
    %this.n_pixels_in_file = sum(sqw_data.npix)

     signal         = zeros(3,numel(sqw_data.s));
     signal(1,:)    = reshape(sqw_data.s,numel(sqw_data.s),1);
     signal(2,:)    = reshape(sqw_data.e,numel(sqw_data.e),1);
     signal(3,:)    = reshape(sqw_data.npix,numel(sqw_data.npix),1);              
    
   
    
    % indexes of data in an hdf-file start from 0; 
     chunks_dim = size(chunks);
     chunks_rank= size(chunks_dim);
     if chunks_rank(1)==1 % chunks are in the form of 1D indexing
         signal_chunks=chunks-1;        
     else       
         error('HORACE:hdf_tools','N-d chunks have not been tested, 1D representation needed')
         %signal_chunks=sub2ind(size(sqw_data.s),chunks)-1;        
     end
  
    
    H5S.select_elements(this.signal_Space, 'H5S_SELECT_SET',fliplr(signal_chunks));
    H5D.write (this.signal_DSID,this.signal_DT,'H5S_ALL',this.signal_Space,'H5P_DEFAULT',signal);

    end
%------------------------------------------------------------------------    
    function this=write(this,sqw_data)
    % write the whole dnd object information, contained in sqw_data
    % structure to propertly prepared and opened hdf file
    %
    % this=write(this,sqw_data)
    %
    % side effects:
    %     modifies  n_pixels_in_file   parameters to the values, defined by sqw_data
    %     plus side effects inherited from detectors;
    % 
    % the dataset is constant so we can not change it size here;
    if numel(sqw_data.s) ~= prod(this.signal_dims)
        error('HORACE:hdf_tools','the size of the signal array (%d) is not constistent with the space, allocated in file (%d)',numel(sqw_data.s),prod(this.signal_dims))        
    end
    
    
     this.n_pixels_in_file = sum(reshape(sqw_data.npix,1,numel(sqw_data.npix)));
     this.signal_dims      = size(sqw_data.s);

     this = write@detectors(this,sqw_data);
     this = write_signals_only(this,sqw_data);

    
    end    
%------------------------------------------------------------------------    
    function this  = write_signal(this,sqw_signal)
    % writes the signal, and error information combined in sqw_data
    % structure to propertly prepared and opened hdf file
    if numel(sqw_signal.s) ~= prod(this.signal_dims)
        error('HORACE:hdf_tools','the size of the signal array (%d) is not constistent with the space, allocated in file (%d)',numel(sqw_data.s),prod(this.signal_dims))        
    end
    
    
       this.n_pixels_in_file = sum(reshape(sqw_signal.npix,1,numel(sqw_signal.npix)));
       this.signal_dims      = size(sqw_signal.s);
       
       this = write_signals_only(this,sqw_signal);
   end    
    
%% ======================================================================           
     function [sqw_data,this]=read_chunks(this,chunks,sqw_data)
    % read part of existing datasets, cells are defined by the 1D array of
    % chunks i.e. selected points;
    %
    % >>  sqw_data=read_chunks(this,chunks)
    % or 
    % >>  sqw_data=read_chunks(this,chunks,sqw_data) 
    %
    % where chunks is the array of indexes of cells to read. The indexes 
    % are an 1D array, specifying the locations of the points requested to 
    % read in the global array. The locations are expressed in 1D array
    % representation (as provided by function sub2ind)
    %
        data_chunks=chunks-1;   
        H5S.select_elements(this.signal_Space, 'H5S_SELECT_SET',flipud(data_chunks));
        clear data_chunks;
        
        data=H5D.read(this.signal_DSID,this.signal_DT,'H5S_ALL',this.signal_Space,'H5P_DEFAULT');

        if nargin==2
            sqw_data.s=zeros(this.signal_dims);
            sqw_data.e=zeros(this.signal_dims);            
            sqw_data.npix=zeros(this.signal_dims);                        
        elseif nargin~=3
            help dnd_hdf.read_chunks
            error('HORACE:hdf_tools','finction has been called with wrong numner of arguments')
        end      
        
        % spread over existing arrays
        sqw_data.s(chunks)   =data(1,:);
        sqw_data.e(chunks)   =data(2,:);        
        sqw_data.npix(chunks)=data(3,:);                
    
     end    
%------------------------------------------------------------------------   
    function [sqw_data,this]=read(this)
    % read the signal, error and propertly prepared and opened hdf file
    %
    % side effects:
    % 1) spe_header fields read from the file into object
    % 2) -- singals and errors -- no effects

    [sqw_data,this] = read@detectors(this);
    [sqw_data,this] = read_signals(this,sqw_data);

    end    
%------------------------------------------------------------------------
    function [sqw_struct,this]  = read_signal(this,varargin)
    % read the structure with signal information (signal,error and npix) from a dataset
    %
    % >>   [sqw_struct,this]  = read_signal(this,sqw_struct)
    %                           add (or reread) fields to existing stucture
    % or 
    % >>   [sqw_struct,this]  = read_signal(this)
    %                           return signal stucture with fields s, e and
    %                           npix;
    
        [sqw_struct,this] = read_signals(this,varargin);
    end
%-------------------------------------------------------------------------    
    function npix=npixels_in_file(this)
    %         
    % >> npix=this.npixels_in_file()
    % return number of pixels contributed to DND dataset
    %
    if this.n_pixels_in_file <0
         npix = read_npix_attribute(this);
         this.n_pixels_in_file=npix;
    else
         npix=this.n_pixels_in_file;
    end
    end
%------------------------------------------------------------------------    
    function this = delete(this)
    % method to close hdf dataset
    % has to be called manually as there are no destructor in Matlab
    %
    try
     H5P.close (this.signal_DSProperties);
     H5D.close (this.signal_DSID);   
     H5S.close (this.signal_Space);
     H5T.close (this.signal_DT);
              
    catch
    end
    
    this=delete@detectors(this);

    end    
    end  % methods   
end % class
