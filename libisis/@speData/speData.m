function this=speData(varargin)
% The class is the wrapper around LIBISIS spe class
% It kept for compartibility and should not be used for future development
% 
% The class provides early binding between spe files and the data in memory
% regardless of the format of the spe files (ASCII or hdf) and allows to
% load data and remove it from the memory as they needed or not needed any
% more. 
% if received ASCII file name as input argument, it checks if 
% hdf file with the same name exists and if it is, works with this file
% instead.
%
% usages:
% speData(fileName)        -- bind spe-data to a file name; file has to
%                             exist, consructor checks for it and throws 
%                             if can not find the file
% speData(fileName,'bind') -- explicitly bind spe data to a file name
%                             similar to the call without parameters
% speData(fileName,'load') -- bind data to a file name and load data from
%                             the file into the memory
% speData(fileName,data)   -- build the class on the basis  of spe data to
%                             export it into file-format of the current choice.
%                             (can not write nxspe at the moment)
%% $Revision$ ($Date$)
this=struct(...
'fileDir','',...
'fileName','',...
'fileExt','',...
'nDetectors',0, ...
'en',[],        ...
'par',[],       ...
'data_loaded',false,... % boolean to check if the spe data are loaded to memory (initial state)
'hdfFileExt','',... % three file extebsions currently supported; they defined below
'nxspe_root_folder','', ... % if the extension is nxspe, the data are hiden behind arbitrary named root folder; when we parce nxspe, we have to identify this folder
'speFileExt','.spe',... % and ascii (spe) HAVE TO BE DEFINED LOWER CASE HERE !!!!
'ifTransfer2hdf',true); % this field specify default way to deal with the data
                        % if any kind of default write operation is
                        % executed e.g. deflate called without parameters to clean the memory
                        % or the class is build from a datastructure;
                        % When field is true, and inital data are
                        % in ASCII format, hdf5 file will be written for future use. 
                        % if false, revese would occur, e.g. existing hdf5
                        % file will be written as ascii file

this.hdfFileExt = {'.spe_h5','.nxspe'}; % there are other extentions possible to load                        
this.ifTransfer2hdf=get(hor_config,'transformSPE2HDF');

% establish normal inheritence overloading over inherited functions
superiorto('spe');
this=class(this,'speData',spe);

if(nargin==1)
    this=bind_to_file(this,varargin{1});
elseif(nargin==2)
    if(ischar(varargin{2}))
        switch(varargin{2})
            case 'load'
                this=load_data_from_file(this,varargin{1});
            case 'bind'
                this=bind_to_file(this,varargin{1});  % local file function;
            otherwise
             error('speData:wrong_Constructor_arg','if builing spe data from a file second argument has to be ''load'' or ''bind''');
        end
    elseif(isstruct(varargin{2}))
        this=build_spe_from_data(this,varargin{1},varargin{2});
        this=save_SPE_data(this);
    else
      error('speData:wrong_Constructor_arg','second argument has to be either sting or structure with spe data');
    end
else
    error('speData:wrong_Constructor_arg','spe data have the form: speData(file_name,[''load'';''bind''])');
end

%%
function this=bind_to_file(this,fullfileName)
% the function checks if the file exists, and reads its header;
% as the file esists now, it can be accessed later without unnecessary
% checks
%
% 
fullfileName=strtrim(fullfileName);
[fileDir,fileName,fileExt]=fileparts(fullfileName);

this.fileDir    =  fileDir;
this.fileName= fileName;
this.fileExt   =  fileExt;
file_tag        =  lower(this.fileExt);

AllFileExt = {this.speFileExt,this.hdfFileExt{:}};
existing_fext = ismember(AllFileExt,file_tag);
if ~any(existing_fext)
        error('speData:bind_to_file',' unrecognized file extension %s for the file %s',...
               this.fileExt,this.fileName);
end

n_ext = find(existing_fext);
switch(n_ext)
    case (1) % spe file extension
        % despite the program asks to work with an spe file, a correspondent        
        % hdf file may exist and we would better work with it        
        hdf_file=fullfile(fileDir,[fileName this.hdfFileExt{1}]);
        if(exist(hdf_file,'file')) % bind to hdf5 file instead;
            [this.nDetectors,this.en]=get_hdf5_header(hdf_file);
            this.fileExt=this.hdfFileExt{1};
        else
            if(~exist(fullfileName,'file')) % spe file does not exist either
                % may be there is '.SPE' instead of '.spe' file?
                fullfileName = fullfile(this.fileDir,[this.fileName,upper(this.fileExt)]);
                if(~exist(fullfileName,'file')) % spe file does not exist either
                    error('HORACE:speData','trying to open non-existing spe or SPE file %s',fullfileName);
                else
                    this.fileExt = upper(this.fileExt);
                end
            end
        [this.nDetectors,this.en]=get_spe_header(fullfileName);
        end
    case(2) % spe_hdf5 file extension;
      if(~exist(fullfileName,'file')) % hdf file requested but does not exist
            error('HORACE:speData','trying to open non-existing spe-hdf file %s',fullfileName);
      end       
      [this.nDetectors,this.en,this.spe.Ei]=get_hdf5_header(fullfileName);
    case(3) % nxspe file
      if(~exist(fullfileName,'file')) % hdf file requested but does not exist
            error('HORACE:speData','trying to open non-existing spe-hdf file %s',fullfileName);
      end       
      this=get_nxspe_header(this,fullfileName);
    otherwise
end


%%
function  this=load_data_from_file(this,fileName)
  this = bind_to_file(this,fileName);
  this = loadData(this);

%%
function this=build_spe_from_data(this,file,data)
% checks input data and builds valid spe structure 
%
% data has following fields:
%   data.S          [ne x ndet] array of signal values
%   data.ERR        [ne x ndet] array of error values (st. dev.)
%   data.en         Column vector of energy bin boundaries
%
%   filename        Name of file excluding path; empty if problem
%   filepath        Path to file including terminating file separator; empty if problem
%

this.spe=spe(data,file);


