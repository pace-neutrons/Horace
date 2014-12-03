function src = sources_init (varargin)
% Initialise the src structure for use with put_sqw if pix source(s) not from sqw data structure
%
%   >> src = sources_init (S)
%   >> src = sources_init (S, sparse_fmt, nfiles, npix, npix_nz, pix_nz, pix)
%
% Input:
% ------
%   S           Array of sqwfile information structures, one per open file
%
% *OR*
%
% Cell arrays all with same size, one element per data source containing:
%
%   S           sqwfile object for an open file (=[] if not file data source)
%   sparse_fmt  true if sparse format object or file; false otherwise
%   nfiles      number of contributing spe files in the data source
%   npix        npix array    (=[] if not stored in memory)
%   npix_nz     npix_nz array (=[] if not stored in memory, or non-sparse format)
%   pix_nz      pix_nz array  (=[] if not stored in memory, or non-sparse format)
%   pix         pix array     (=[] if not stored in memory)
%
%
% Output:
% -------
%   src         Array of structures, one per data source, with the following fields
%                   S           sqwfile object for an open file (=[] if not file data source)
%                   sparse_fmt  true if sparse format object or file; false otherwise
%                   nfiles      number of contributing spe files in the data source
%                   npix        npix array    (=[] if not stored in memory)
%                   npix_nz     npix_nz array (=[] if not stored in memory, or non-sparse format)
%                   pix_nz      pix_nz array  (=[] if not stored in memory, or non-sparse format)
%                   pix         pix array     (=[] if not stored in memory)
%
%
% This function is not very general or robust - it simply puts the creation of a src
% structure in one location to make maintenance of data io functions simpler. Only
% limited checks are performed on the input


% Original author: T.G.Perring
%
% $Revision: 909 $ ($Date: 2014-09-12 18:20:05 +0100 (Fri, 12 Sep 2014) $)


if nargin==1
    if isstruct(varargin{1}) && all(strcmp(fieldnames(varargin{1}(1)),fieldnames(sqwfile)))
        % Input is an array of sqwfile structures, assumed to be for open files
        S=varargin{1};
        sparse_fmt=cell(size(S));
        nfiles=cell(size(S));
        for i=1:numel(S)
            sparse_fmt{i}=S(i).info.sparse;
            nfiles{i}=S(i).info.nfiles;
        end
        src=struct('S',num2cell(S),'sparse_fmt',sparse_fmt,'nfiles',nfiles,...
            'npix',[],'npix_nz',[],'pix_nz',[],'pix',[]);
    else
        error('Invalid input')
    end
    
elseif nargin==7
    for i=1:numel(varargin)
        if ~iscell(varargin{i});
            error('Invalid input')
        end
    end
    src=struct('S',varargin{1},'sparse_fmt',varargin{2},'nfiles',varargin{3},...
        'npix',varargin{4},'npix_nz',varargin{5},'pix_nz',varargin{6},'pix',varargin{7});
end
