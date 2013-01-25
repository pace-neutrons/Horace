function varargout = change_crystal(varargin)
% Change the crystal lattice and orientation of an sqw object or array of objects
%
% Most commonly:
%   >> wout = change_crystal (w, rlu_corr)              % change lattice parameters and orientation
%
% OR
%   >> wout = change_crystal (w, alatt)                 % change just length of lattice vectors
%   >> wout = change_crystal (w, alatt, angdeg)         % change all lattice parameters
%   >> wout = change_crystal (w, alatt, angdeg, rotmat) % change lattice parameters and orientation
%   >> wout = change_crystal (w, alatt, angdeg, u, v)   % change lattice parameters and redefine u, v
%
%
% Input:
% -----
%   w           Input sqw object
%
%   rlu_corr    Matrix to convert notional rlu in the current crystal lattice to
%              the rlu in the the new crystal lattice together with any re-orientation
%              of the crystal. The matrix is defined by the matrix:
%                       qhkl(i) = rlu_corr(i,j) * qhkl_0(j)
%               This matrix can be obtained from refining the lattice and
%              orientation with the function refine_crystal (type
%              >> help refine_crystal  for more details).
% *OR*
%   alatt       New lattice parameters [a,b,c] (Angstroms)
%   angdeg      New lattice angles [alf,bet,gam] (degrees)
%   rotmat      Rotation matrix that relates crystal Cartesian coordinate frame of the new
%              lattice as a rotation of the current crystal frame. Orthonormal coordinates
%              in the two frames are related by 
%                   v_new(i)= rotmat(i,j)*v_current(j)
%   u, v        Redefine the two vectors that were used to determine the scattering plane
%              These are the vectors at whatever misorientation angles dpsi, gl, gs (which
%              cannot be changed).
%
% Output:
% -------
%   wout        Output sqw object with changed crystal lattice parameters and orientation
%
% NOTE
%  The input data set(s) can be reset to their original orientation by inverting the
%  input data e.g.
%    - call with inv(rlu_corr)
%    - call with the original alatt, angdeg, u and v

% Original author: T.G.Perring
%
% $Revision: 601 $ ($Date: 2012-02-08 14:46:10 +0000 (Wed, 08 Feb 2012) $)


% This routine is also used to change the crystal in sqw files, for which the syntax is
%   >> change_crystal(filename,...)
% and the output overwrites the input file.


% If data source is a filename, then must ensure that matches sqw type
% Recall this function is used by d0d, d1d,... as a gateway routine, so if data_source is structure
% it may require non sqw type data to be read. 
[data_source, args, source_is_file, sqw_type, ndims, source_arg_is_filename, mess] = parse_data_source (varargin{:});
if ~isempty(mess)
    error(mess)
end
if source_arg_is_filename
    if ~all(sqw_type)
        error('Data file(s) not (all) sqw type i.e. does(do) not contain pixel information')
    end
    if nargout>0
        error('Cannot have output for data source being file(s)')
    end
end

if source_is_file
    for i=1:numel(data_source)
        [h.main_header,h.header,h.detpar,h.data,mess,position,npixtot,type]=get_sqw (data_source(i).filename,'-hverbatim');
        [h.header,h.data]=change_crystal_alter_fields(h.header,h.data,args{:});

        fout=fopen(data_source(i).filename,'r+');    % open for reading and writing
        if fout<0, error(['Unable to open file ',outfile,' to change crystal information.']), end
        frewind(fout)   % get to beginning of file (may not be necessary
        [mess,position,npixtot,type] = put_sqw (fout,h.main_header,h.header,h.detpar,h.data,'-h');
        if fopen(fout), fclose(fout); end
        if ~isempty(mess), error(['Error writing to file ',data_source(i).filename,' - check not corrupted: ',mess]), end
    end
    
else
    varargout{1}=data_source;
    for i=1:numel(data_source)
        [varargout{1}(i).header,varargout{1}(i).data,ok,mess]=change_crystal_alter_fields(data_source(i).header,data_source(i).data,args{:});
        if ~ok, error(mess), end
    end
    
end
