function [data, mess] = get_header(fid, data_in)
% Reads a header structure out from either a binary .spe, file, binary .sqe file
% or a binary orthogonal grid file.
%
% Syntax:
%   >> [data, mess] = get_header(fid, data_in)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   data_in     [optional] Data structure to which the grid data
%              fields below will be added.
%
% Output:
% -------
%   data        Structure containing fields read from file (details below)
%   mess        Error message; blank if no errors, non-blank otherwise
%
% Fields read for all of 'spe', sqe' or 'orthogonal-grid' data:
%
%   data.grid   Type of grid ('spe' or 'orthogonal-grid') [Character string]
%   data.title  Title contained in the file from which (h,k,l,e) data was read [Character string]
%   data.a      Lattice parameters (Angstroms)
%   data.b           "
%   data.c           "
%   data.alpha  Lattice angles (degrees)
%   data.beta        "
%   data.gamma       "
%   data.u      Matrix (4x4) of projection axes in original 4D representation
%               u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   data.ulen   Length of vectors in Ang^-1 or meV [row vector]
%   data.label  Labels of the projection axes [1x4 cell array of charater strings]
%
% If reading a binary spe or sqe file:
%   data.nfiles Number of spe files in the binary file
%   data.urange Range along each of the axes: [u1_lo, u2_lo, u3_lo, u4_lo; u1_hi, u2_hi, u3_hi, u4_hi]
%   data.ebin   Energy bin width of first, minimum and last spe file: [ebin_first, ebin_min, ebin_max]
%
% If a 0D,1D,2D,3D, or 4D data structure:
%
%   data.p0     Offset of origin of projection [ph; pk; pl; pen] [column vector]
%   data.pax    Index of plot axes in the matrix data.u  [row vector]
%               e.g. if data is 3D, data.pax=[2,4,1] means u2, u4, u1 axes are x,y,z in any plotting
%                               2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
%   data.iax    Index of integration axes in the matrix data.u
%               e.g. if data is 2D, data.iax=[3,1] means summation has been performed along u3 and u1 axes
%   data.uint   Integration range along each of the integration axes. Dimensions are uint(2,length(iax))
%               e.g. in 2D case above, is the matrix vector [u3_lo, u1_lo; u3_hi, u1_hi]

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

if nargin==2
    if isstruct(data_in)
        data = data_in;
    else
        mess = 'ERROR: Check the type of input argument data_in';
        return
    end
else
    data = [];
end

[n, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
[data.grid, count, ok, mess] = fread_catch(fid,[1,n],'*char'); if ~all(ok); return; end;

[n, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
[data.title, count, ok, mess] = fread_catch(fid,[1,n],'*char'); if ~all(ok); return; end;

[data.a, count, ok, mess] = fread_catch(fid,1,'float32'); if ~all(ok); return; end;
[data.b, count, ok, mess] = fread_catch(fid,1,'float32'); if ~all(ok); return; end;
[data.c, count, ok, mess] = fread_catch(fid,1,'float32'); if ~all(ok); return; end;
[data.alpha, count, ok, mess] = fread_catch(fid,1,'float32'); if ~all(ok); return; end;
[data.beta, count, ok, mess] = fread_catch(fid,1,'float32'); if ~all(ok); return; end;
[data.gamma, count, ok, mess] = fread_catch(fid,1,'float32'); if ~all(ok); return; end;
[data.u, count, ok, mess] = fread_catch(fid,[4,4],'float32'); if ~all(ok); return; end;
[data.ulen, count, ok, mess] = fread_catch(fid,[1,4],'float32'); if ~all(ok); return; end;

[n, count, ok, mess] = fread_catch(fid,2,'int32'); if ~all(ok); return; end;
[label, count, ok, mess] = fread_catch(fid,[n(1),n(2)],'*char'); if ~all(ok); return; end;
data.label=cellstr(label)';

if strcmp(data.grid,'spe')|strcmp(data.grid,'sqe'),
    [data.nfiles, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [data.urange, count, ok, mess] = fread_catch(fid,[2,4],'float32'); if ~all(ok); return; end;
    [data.ebin, count, ok, mess] = fread_catch(fid,[1,3],'float32'); if ~all(ok); return; end;
else
    [data.p0, count, ok, mess] = fread_catch(fid,[4,1],'int32'); if ~all(ok); return; end;
    [n, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    if n>0
        [data.pax, count, ok, mess] = fread_catch(fid,[1,n],'int32'); if ~all(ok); return; end;
    else
        data.pax=[];    % create empty index of plot axes
    end
    if n==4,
        data.iax=[];    % create empty index of integration array
        data.uint=[];
    else
        [n, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
        [data.iax, count, ok, mess] = fread_catch(fid,[1,n],'int32'); if ~all(ok); return; end;
        [data.uint, count, ok, mess] = fread_catch(fid,[2,n],'float32'); if ~all(ok); return; end;
    end
end