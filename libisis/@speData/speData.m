function this=speData(varargin)
% the class supports memory representation of an spe data
% it created to incorporate the spe-files access operations to allow
% simple changes in the format of the spe files
% usages:
% speData(fileName) -- bind spe-data to a file name
% speData(fileName,'bind') -- explicitly bind spe data to a file name
% speData(fileName,'load') -- bind data to a file name and load data from
%                             the file into the memory
% speData(fileName,data)  -- build the class on the basis  of spe data to
%                            export it into format of the current choice.
%
%% $Revision$ ($Date$)
this=struct(...
'data_loaded',false,... % boolean to check if the spe data are loaded to memory
'nDetectors', 0,...
'nEnergyBins',0,...
'fileDir',   [],...
'fileName',  [],...
'fileExt',   [],...
'en',        [],...   % Column vector of energy bin boundaries
'S',         [],...   % [nEnergyBins x nDetectors] array of signal values
'ERR',       [],...   % [nEnergyBins x nDetectors] array of error values (st. dev.)
'hdfFileExt','.h5',... % two file extebsions currently supported; hdf5
'speFileExt','.spe',... % and ascii (spe) HAVE TO BE DEFINED LOWER CASE HERE !!!!
'enName','Energy_Bin_Boundaries',... % three names of the data fields,
'SName','S(Phi,w)',...               % which are present in the hdf5 file
'ErrName','Err');
this=class(this,'speData');
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
    else
      error('speData:wrong_Constructor_arg','second argument has to be either sting or structure with spe data');
    end
else
    error('speData:wrong_Constructor_arg','spe data have the form: speData(file_name,[''load'';''bind''])');
end
end
%%
function this=bind_to_file(this,fullfileName)
% the function checks if the file exists, and reads its header;
% as the file esists now, it can be accessed later without unnecessary
% checks
fullfileName=strtrim(fullfileName);

if(~exist(fullfileName,'file'))
    error('speData:bind_to_file',' file %s does not exist',fullfileName);
end

[fileDir,fileName,fileExt]=fileparts(fullfileName);
this.fileDir =fileDir;
this.fileName=fileName;
this.fileExt =fileExt;
file_tag     =lower(this.fileExt);
switch(file_tag)
    case this.speFileExt;
        % despite the program asks to work with an spe file, a correspondent
        % hdf file may exist and we would better work with it
        hdf_file=fullfile(fileDir,[fileName this.hdfFileExt]);
        if(exist(hdf_file,'file')) % bind to hdf5 file instead;
            [this.nDetectors,this.en]=get_hdf5_header(hdf_file);
            this.fileExt=this.hdfFileExt;
        else
        [this.nDetectors,this.en]=get_spe_header(fullfileName);
        end
    case this.hdfFileExt;
        [this.nDetectors,this.en]=get_hdf5_header(fullfileName);
    otherwise
        error('speData:bind_to_file',' unrecognized extension %s in the file %s',...
           this.fileExt,this.fileName);
end
end
%%
function  this=load_data_from_file(this,fileName)
  this = bind_to_file(this,fileName);
  this = loadData(this);
end
%%
function this=build_spe_from_data(this,file,data)
% Writes ASCII .spe file
%
% data has following fields:
%   data.S          [ne x ndet] array of signal values
%   data.ERR        [ne x ndet] array of error values (st. dev.)
%   data.en         Column vector of energy bin boundaries
%
%   filename        Name of file excluding path; empty if problem
%   filepath        Path to file including terminating file separator; empty if problem
%

% T.G.Perring   13/6/07

null_data = -1.0e30;    % conventional NaN in spe files

% If no input parameter given, return
if ~exist('file','var')||~exist('data','var')
    error('Check arguments to put_spe')
end

% Check input arguments
if ~isstruct(data) ||...
        ~isfield(data,'S')   || isempty(data.S) ||...
        ~isfield(data,'ERR') || isempty(data.ERR) ||...
        ~isfield(data,'en')  || isempty(data.en)
    error('Check arguments (data format) to write into spe file')
end

size_S=size(data.S); size_ERR=size(data.ERR); size_en=size(data.en);
if length(size_S)~=2 || length(size_ERR)~=2|| length(size_en)~=2 ...
        || ~all(size_S==size_ERR) || min(size_en)~=1 || max(size_en)~=size_S(1)+1
    error('Check arguments (data sizes) to write into spe file')
end

% Remove blanks from beginning and end of filename
file_tmp=strtrim(file);

% Get file name and path (incl. final separator)
[path,name,ext]=fileparts(file_tmp);
if(~strcmp(ext,this.hdfFileExt)&&~strcmp(ext,this.speFileExt))
    ext=this.speFileExt;      % default writing is to ascii spe file but we can change it later
end

% Prepare data for Fortran routine
index=~isfinite(data.S)|~isfinite(data.ERR);
if sum(index(:)>0)
    data.S(index)=null_data;
    data.ERR(index)=0;
end

this.data_loaded=true; % boolean to check if the spe data are loaded to memory
this.nDetectors =size(data.S);
this.nEnergyBins=size(data.en);
this.fileDir    = path;
this.fileName   = name;
this.fileExt    = ext;

end
