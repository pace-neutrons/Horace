function det = get_hor_format(par_data,file_name)
% function transforms data obtained as par data array into Horace srtucture
% and vise versa.
%
% Usage:
%>> det = get_hor_format(par_data,file_name)
% Input:
% par_array
%-- either:
%              6xNd array of angular detector parameters where Nd is number
%              of detectors. In this case function returns horace structure
%              described below
%-- or:
%              horace structure with the fields, described below
%              in this case the function returns 6xNd array of data
%              described below. file_name is not then used.
%
%
% file_name -- the name of the file whrer these data were read from
% azimuthal_inverted  -- if data were obtained from ascii file, the sign of the azimuthal angle has to be changed to have correct coordinate system
%                        in binary file data already have correct sighn. Define this parameter to true if no data inversion is necessary
%Output:
% det       -- the structure, with detector parameters information, which
%              used in Horace data format
%Parameters definitons:
% Detector's array has to have the following columns:
%  par(1,:)   -- sample-to-detector distance
%  par(2,:)   -- 2-theta (polar angle)
%  par(3,:)   -- azimutal angle
%  par(4,:)   -- detector width
%  par(5,:)   -- detector height
%  par(6,:)   -- detector ID (number)
%
% The array is projected to Horace structure with fields:
% det.group <- par(6,:)
% det.x2   <-  par(1,:)
% det.phi  <-  par(2,:)
% det.azim <- par(3,:)   %  sign change now occurs directly in the asccii
%                           loader
% det.width<-  par(4,:)
% det.height<- par(5,:)
% [filepath,filename]=fileparts(file_name);
% det.filename<- filename;
% det.filepath<- filepath;
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)
%
hor_fields={'group','x2','phi','azim','width','height'};
array_colN=[6,1,2,3,4,5];

if ~exist('file_name','var')
    file_name = '';
end
if isstruct(par_data)
    det = convert_structure_to_array(par_data,hor_fields,array_colN);
else
    det = convert_array_to_structure(par_data,hor_fields,array_colN,file_name);
end

function det=convert_array_to_structure(par_data,hor_fields,array_colN,file_name)
% convert horace detector information array into horace structure
%
[path,name,ext]=fileparts(file_name);
det.filename   =[name,ext];
if isempty(path)
    path='.';
end
det.filepath = [path,filesep];

size_par  = size(par_data);
if(size_par(1)~=6)
    error('GET_HOR_FORMAT:invalid_file_format',' proper par array has to have 6 column but this one has %d',size_par(1));
end

for i=1:numel(hor_fields)
    field = hor_fields{i};
    ind   = array_colN(i);
    det.(field) = par_data(ind,:);
end
%det.azim  = par_data(3,:); % no sign change is necessary as it occurs in ASCII par file reader

function  det = convert_structure_to_array(par_data,hor_fields,array_colN)
% convert horace detector information structure detector information array
%
ndet = numel(par_data.phi);
det=zeros(6,ndet);

for i=1:numel(hor_fields)
    field = hor_fields{i};
    ind   = array_colN(i);
    det(ind,:) = par_data.(field);
end
