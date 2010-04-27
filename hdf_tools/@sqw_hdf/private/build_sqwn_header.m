function header=build_sqwn_header(varargin)
% the function builds the header for sqw-n structure
% usage:
% header=build_sqwn_header()
%        builds default sqwn structure with fields described below;
% or
% header=build_sqwn_header(title,nfiles,head)
% where: 
% title  --  the titile of sqw(n) file we are building
% nfiles --  number of single sqw (spe) files contributing into the file
% head   -- the structure, with fields described below. The values of these
%           fields will be coped into the header
% or 
% header=build_sqwn_header(filename)
% where filename is the name of new sqw file;
%
% function defains the structure of default sqwn header 
%   main_headertitle      Title of sqw data structure
%   main_headernfiles     Number of spe files that contribute
%   data.title      Title of sqw data structure
%   data.alatt      Lattice parameters for data field (Ang^-1)
%   data.angdeg     Lattice angles for data field (degrees)
%   data.uoffset    Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
%   data.u_to_rlu   Matrix (4x4) of projection axes in hkle representation
%                      u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   data.ulen       Length of projection axes vectors in Ang^-1 or meV [row vector]
%   data.ulabel     Labels of the projection axes [1x4 cell array of character strings]
%   data.iax        Index of integration axes into the projection axes  [row vector]
%                  Always in increasing numerical order
%                       e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
%   data.iint       Integration range along each of the integration axes. [iint(2,length(iax))]
%                       e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
%   data.pax        Index of plot axes into the projection axes  [row vector]
%                  Always in increasing numerical order
%                       e.g. if data is 3D, data.pax=[1,2,4] means u1, u2, u4 axes are x,y,z in any plotting
%                                       2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
%   data.p          Call array containing bin boundaries along the plot axes [column vectors]
%                       i.e. row cell array {data.p{1}, data.p{2} ...} (for as many axes as length of data.pax)
%   data.dax        Index into data.pax of the axes for display purposes. For example we may have 
%
%   data.urange     True range of the data along each axis [urange(2,4)]

header0 = build_default_sqwn_struct();
if nargin==0 % biild default sqwn header
   header=header0;
elseif nargin==1
   header=header0;   
   [filepath,filename]=fileparts(varargin{1});
   header.filename=filename;
   header.filepath=filepath;
elseif nargin==3
    header.main_header_title =varargin{1};
    header.main_header_nfiles=varargin{2};
%
    head  = varargin{3};
    if ~isstruct(head)
       error('HORACE:hdf_tools','build_sqwn_header: third parameter of the function has to be spe structure with proper fields')
    end
    fields_requested = fieldnames(header0);
    for i=1:numel(fields_requested)
        if ~isfield(head,fields_requested{i})
            if isfield(header,fields_requested{i})
                continue;
            end
            error('HORACE:hdf_tools','build_sqwn_header: field %s has to be present in the input structure (third argument)',fields_requested{i})
        end
        header.(fields_requested{i}) = head.(fields_requested{i});
    end
else
    help build_sqwn_header
    error('HORACE:hdf_tools','build_sqwn_header: called with wrong number of arguments')
end
%---------------------------------------------------------------------
function header=build_default_sqwn_struct()
    ndim=4;                     % maximal header length
    header.main_header_title  = 'default sqwn file header';
    header.main_header_nfiles = 1;
    header.filename           = 'undefined sqwn file';
    header.filepath           = 'located somewhere';  
    header.alatt              = [2*pi, 2*pi, 2*pi];
    header.angdeg             = [90,90,90];
    header.efix =100;            %      Fixed energy (ei or ef depending on emode)
    header.emode=1;             %    Emode=1 direct geometry, =2 indirect geometry
    header.cu=[1;0;0];        %    First vector defining scattering plane (r.l.u.)
    header.cv=[0;1;0];         %    Second vector defining scattering plane (r.l.u.)
    header.psi=0;        %    Orientation angle (rad)
    header.omega=0;      %    --|
    header.dpsi=0;       %      |  Crystal misorientation description (rad)
    header.gl  =0;       %      |  (See notes elsewhere e.g. Tobyfit manual
    header.gs = 0;       %    --|
    header.en =zeros(200,1);       %    Energy bin boundaries (meV) [column vector]        
    header.uoffset            = zeros(4,1);
    header.u_to_rlu           = eye(4);
    header.ulen               = [1,1,1,1];
    header.ulabel             = {'\zeta','\xi','\eta','E'};
    header.iax                = zeros(1,ndim);
    header.iint               = zeros(2,size(header.iax,2));
    header.pax                = 1:ndim;
    header.p                  = repmat({[1:100]'},1,ndim);
    header.urange             = zeros(2,ndim);     %    True range of the data along each axis [urange(2,4)]
    header.urange(2,:)        = 1;
        
    
    
