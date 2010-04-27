classdef detectors < spe_header
%    
% class suports hdf5 representation of detectors dataset located in an
% hdf sqw file
% 
%
% $Revision$ ($Date$)
%
    
    properties (GetAccess='private', SetAccess='private')  
        detectors_DSName = 'detectors';          
        detectors_DT;                % detectors datatype (complex -- in hdf5 sence)
        detectors_Space;         
        detectors_DSProperties;      % detectors modifiable properties; two listed below
        detectors_DS_compression = 3; % number from 0 to 9 defining the compression level for detectors dataset;
        detectors_DSID;               % hdf dataset id to work with open dataset                                          
        
        % will be copyied from the input structure and attached to the dataset as attributes
        detector_basic_fields = {'det_filename','det_filepath'};
        % will be written do dataset as a single array;
        detector_data_fields  = {'group','x2','phi','azim','width','height'};        
        detector_fields={}; % calculated combination of both above;
    end
    properties (GetAccess='public', SetAccess='private')  
        n_detectors=2048; % default number of detectors (hint -- 
        % should be equal to the optimal size of a chunk, possible to write to hdd)
        %
        % defauld detector file name and path; will be used to verify if
        % the initial attribures request writing; Can not be empty;
        det_filename='default filename';
        det_filepath='default location';        
    end
    methods
       function this=detectors(data,varargin)
       % the constructor for hdf5 representation of detectors in an hdf file        
       % >> this = detectors(sqw_data,detectors) -- initiates hdf5 file to represent 
       %                                          existing sqw structhre
       %                                          and detectors structure
       % >> this = detectors(sqw_data,detectors,header_control_structure)
       % 
       %         -- header_control_structure -- parameter, transferred to
       %            spe header
       % >> this = detectors(filename,detectors,header_control_structure)
       %         -- filename -- the name of the file  
       % >> this = detectors(filename,header_control_structure)  
       %
       % >> this = detectors(filename) -- finds and initiates hdf5 file
       %                                   associated with sqw data 
       start=1;
       if nargin>1 % exclude detectors structure if it is eventually present among the parameters
           if isempty(varargin{1})||isfield(varargin{1},'group')
               start=2;
           end
       end
              
       this=this@spe_header(data,varargin{start:end});  % this will also check if the file exists        
       
       if this.new_file_created
           if nargin>1
               det = varargin{1};
               if ~isempty(det)&&isfield(det,'group')
                  this.n_detectors=numel(det.group);
                  [this.det_filepath,this.det_filename] = set_file_name(this,det.filepath,det.filename);          
               end
           end
           this=build_detectors_header(this,this.sqw_file_ID);
        else
           this=open_detectors_header(this,this.sqw_file_ID);            
        end
        this.detector_fields={this.detector_basic_fields{:},this.detector_data_fields{:}};
           
       end
       %
       function detectors_struct=read_detectors(this,detectors_struct)
       %
       %>> detectors=read_detectors(this)
       %>> detectors=read_detectors(this,detectors_struct)       
       % 
       % reads detectors data from the file into the structure;
       % side_effects:
       % nothing (everything data specific has been set-up in constructor)
        if nargin==1
               detectors_struct=struct();
        end
        detectors_struct.filename=this.det_filename;
        detectors_struct.filepath=this.det_filepath;       
       
        data=H5D.read(this.detectors_DSID,this.detectors_DT,'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
        for i=1:numel(this.detector_data_fields)
               detectors_struct.(this.detector_data_fields{i})=double(data(i,:));
        end       
           
       end
       function this=write(this,sqw_data)
           
           this=write_spe_header(this,sqw_data);
           if isfield(sqw_data,'det0')
                this=write_detectors(this,sqw_data.det0);
           elseif isfield(sqw_data,'det')
               this=write_detectors(this,sqw_data.det);               
           end
       end
       %
       function this=write_detectors(this,detectors_struct)
       %
       % >>  this=write_detectors(this,detectors_struct)
       %
       % writes detectors data contained in the detectors_struct 
       % into propertly prepared and opened hdf file
       %
       % side effects:
       % sets up the fields:
       %
       % n_detectors, det_filename and  det_filepath
       %
       % to the values found in the structure if they are different from
       % the one, defined by the constructror;
       % 
        if ~strcmp(this.det_filename,detectors_struct.filename)||(~strcmp(this.det_filepath,detectors_struct.filepath))
               this.det_filepath=detectors_struct.filepath;
               this.det_filename=detectors_struct.filename;
               write_attributes_list(this.detectors_DSID,this.detector_basic_fields,this);               
        end
           
        fields = this.detector_data_fields; % for clarity
        nfields = numel(fields);
        
        if numel(detectors_struct.(fields{1})) ~= this.n_detectors
            this.n_detectors = numel(detectors_struct.(fields{1}));
            H5D.extend(this.detectors_DSID,this.n_detectors);
            this.detectors_Space= H5D.get_space(this.detectors_DSID);
        end
        
        wData=single(zeros(nfields,this.n_detectors));
        for i=1:nfields
               wData(i,:)=single(detectors_struct.(fields{i}));
        end
        %
           
        H5D.write(this.detectors_DSID,this.detectors_DT,this.detectors_Space,this.detectors_Space, 'H5P_DEFAULT',wData);
       end
       %-------------------------------------------------------------------
       function this=delete(this)
           H5T.close(this.detectors_DT);
           H5S.close(this.detectors_Space);           
           H5P.close(this.detectors_DSProperties);
           H5D.close(this.detectors_DSID);
           this=delete@spe_header(this);
       end
       %-------------------------------------------------------------------
       function diference=difr(this,other_detector_structure)
       % overloaded minus for file located detectors group
       % returns array of differences between all detector groups
       %
       % >> diference=difr(this,other_detector_structure)
       %
         struct1=this.read_detectors();
         fields = this.detector_data_fields;         
         len = this.n_detectors;
         wid = numel(fields);
         diference=zeros(len,wid);

         for i=1:wid
            diference(:,i)=struct1.(fields{i})-other_detector_structure.(fields{i});
         end
        
       end
        
    end
end