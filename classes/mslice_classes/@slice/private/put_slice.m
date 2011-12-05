function [ok,mess,filename,filepath]=put_slice(data,file)
% Writes ASCII slice file
%   >> [ok,mess,filename,filepath]=put_slice(data,file)
%
% The format of the file is described in get_slice. Must make sure get_slice and put_slice are consistent.
%
% Output:
% -------
%   ok              True if all OK, false otherwise
%   mess            Error message; empty if ok=true
%   filename        Name of file excluding path; empty if problem
%   filepath        Path to file including terminating file separator; empty if problem

% T.G.Perring   15 August 2009

null_data = -1e30;    % conventional NaN in spe files

ok=true;
mess='';

% If no input parameter given, return
if ~exist('file','var')||~exist('data','var')
    error('Check arguments to put_slice')
end

% Remove blanks from beginning and end of filename
file_tmp=strtrim(file);

% Get file name and path (incl. final separator)
[path,name,ext]=fileparts(file_tmp);
filename=[name,ext];
filepath=[path,filesep];

% Get header fields
nx=size(data.xbounds,2)-1;
ny=size(data.ybounds,2)-1;
xorig=0.5*(data.xbounds(1)+data.xbounds(2));
yorig=0.5*(data.ybounds(1)+data.ybounds(2));
dx=data.xbounds(2)-data.xbounds(1);
dy=data.ybounds(2)-data.ybounds(1);
header=[nx;ny;xorig;yorig;dx;dy];

% Make bins with zero data go to null_data
data.c(data.npixels==0)=null_data;

% Make labels to go as footer in the file
labels=put_struct_to_labels(data,'except',{'xbounds','ybounds','x','y','c','e','npixels','pixels','SliceFile','SliceDir'});

% Write to file
try
    footer=char(labels)';
    line_len=size(footer,1);    % maximum string length
    footer=footer(:)';          % make a string
    ierr = put_slice_mex (file_tmp,header,data.x',data.y',data.c',data.e',data.npixels',data.pixels',footer,line_len);
    if round(ierr)~=0
        error(['Error writing slice data to ',file_tmp])
        filename='';
        filepath='';
    end
catch
    try     % matlab write
        disp(['Matlab writing of .slc file : ' file_tmp]);
        [ok,mess]=put_slice_matlab(header,data,labels,file_tmp);
        if ~ok
            error(mess)
            filename='';
            filepath='';
        end
    catch
        ok=false;
        mess=['Error writing cut data to ',file_tmp]';
        filename='';
        filepath='';
    end
end
