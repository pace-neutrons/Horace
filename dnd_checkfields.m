function [ndim_out, mess] = dnd_checkfields (din)
% Check if the fields in a structure are correct for an nD datastructure (n=0,1,2,3,4)
% and check that the contents have the correct type and consistent sizes etc.
%
% If the argument is 0,1,2,3 or 4, then create a default empty structure
%
% Syntax:
%   >> [ndim, mess] = dnd_checkfields (din)
%
% Input:
% -------
%   din     Input structure.
%
% Output:
% -------
%   ndim    Number of dimensions (0,1,2,3,4). If an error, then returned as empty.
%
%   mess    Error message if isempty(ndim). If ~isempty(ndim), mess = ''
%
%
% The correct fields for a valid n-dimensional data structure are:
%
%   din.file  File from which (h,k,l,e) data was read [Character string]
%   din.grid  Type of grid ('orthogonal-grid') [Character string]
%   din.title Title contained in the file from which (h,k,l,e) data was read [Character string]
%   din.a     Lattice parameters (Angstroms)
%   din.b           "
%   din.c           "
%   din.alpha Lattice angles (degrees)
%   din.beta        "
%   din.gamma       "
%   din.u     Matrix (4x4) of projection axes in original 4D representation
%              u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   din.ulen  Length of vectors in Ang^-1 or meV [row vector]
%   din.label Labels of the projection axes [1x4 cell array of character strings]
%   din.p0    Offset of origin of projection [ph; pk; pl; pen] [column vector]
%   din.pax   Index of plot axes in the matrix din.u  [row vector]
%               e.g. if data is 3D, din.pax=[2,4,1] means u2, u4, u1 axes are x,y,z in any plotting
%                               2D, din.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
%   din.iax   Index of integration axes in the matrix din.u
%               e.g. if data is 2D, din.iax=[3,1] means summation has been performed along u3 and u1 axes
%   din.uint  Integration range along each of the integration axes. Dimensions are uint(2,length(iax))
%               e.g. in 2D case above, is the matrix vector [u3_lo, u1_lo; u3_hi, u1_hi]
%   din.p1    Column vector of bin boundaries along first plot axis
%   din.p2    Column vector of bin boundaries along second plot axis
%     :       (for as many plot axes as given by length of din.pax)
%   din.s     Cumulative signal.  [size(din.s)=(length(din.p1)-1, length(din.p2)-1, ...)]
%   din.e     Cumulative variance [size(din.e)=(length(din.p1)-1, length(din.p2)-1, ...)]
%   din.n     Number of contributing pixels [size(din.n)=(length(din.p1)-1, length(din.p2)-1, ...)]
%             If 0D, 1D, 2D, 3D, din.n is a double; if 4D, din.n is int16

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

first_names = {'file';'grid';'title';'a';'b';'c';'alpha';'beta';'gamma';'u';'ulen';'label';'p0';'pax';'iax';'uint'};
last_names  = {'s';'e';'n'};
d0d_names = [first_names;last_names];
d1d_names = [first_names;{'p1'};last_names];
d2d_names = [first_names;{'p1';'p2';};last_names];
d3d_names = [first_names;{'p1';'p2';'p3'};last_names];
d4d_names = [first_names;{'p1';'p2';'p3';'p4'};last_names];

ndim_out=[];
mess='';
%--------------------------------------------------------------------------------------------------
if isstruct(din)
    names = fieldnames(din);
    % Check that field names are valid and that they are in the right order to create a class
    if length(names)==length(d0d_names) && min(strcmp(d0d_names,names))
        ndim=0;
    elseif length(names)==length(d1d_names) && min(strcmp(d1d_names,names))
        ndim=1;
    elseif length(names)==length(d2d_names) && min(strcmp(d2d_names,names))
        ndim=2;
    elseif length(names)==length(d3d_names) && min(strcmp(d3d_names,names))
        ndim=3;
    elseif length(names)==length(d4d_names) && min(strcmp(d4d_names,names))
        ndim=4;
    else
        mess = 'ERROR: Input structure does not have correct fields for an nD dataset'; return
    end
    % check the contents of each of the fields is valid:
    % This should give an exhaustive check of the consistency of the fields, but at present does not
    % do all checks e.g. doesnt check that elements of ulen are all +ve, are consistent with lattice parameters
    % and matrix u etc. The mutual consistency will be assured by the functions that generate these
    % but using the 'get' and 'set' routines may upset that consistency.
    if ~((ischar(din.file)&&isempty(din.file))||isa_size(din.file,'row','char'))
        mess='ERROR: field ''file'' must be a character string'; return
    end
    if ~isa_size(din.grid,'row','char') || ~strcmp(din.grid,'orthogonal-grid') 
        mess='ERROR: field ''grid'' must be a ''orthogonal-grid'''; return
    end
    if ~isa_size(din.a,[1,1],'double'); mess='ERROR: field ''a'' must be a single number'; return; end
    if ~isa_size(din.b,[1,1],'double'); mess='ERROR: field ''b'' must be a single number'; return; end
    if ~isa_size(din.c,[1,1],'double'); mess='ERROR: field ''c'' must be a single number'; return; end
    if ~isa_size(din.alpha,[1,1],'double'); mess='ERROR: field ''alpha'' must be a single number'; return; end
    if ~isa_size(din.beta, [1,1],'double'); mess='ERROR: field ''beta'' must be a single number'; return; end
    if ~isa_size(din.gamma,[1,1],'double'); mess='ERROR: field ''gamma'' must be a single number'; return; end
    if ~isa_size(din.gamma,[1,1],'double'); mess='ERROR: field ''gamma'' must be a single number'; return; end
    if ~isa_size(din.u,[4,4],'double'); mess='ERROR: field ''u'' must be a 4x4 matrix of numbers'; return; end
    if ~isa_size(din.ulen,[1,4],'double'); mess='ERROR: field ''ulen'' must be a row vector of 4 numbers'; return; end
    if ~isa_size(din.label,[1,4],'cellstr'); mess='ERROR: field ''label'' must be a (row) cell array of 4 strings'; return; end
    if ~isa_size(din.p0,[4,1],'double'); mess='ERROR: field ''p0'' must be a column vector of 4 numbers'; return; end
    if ndim==0
        if ~isempty(din.pax) || ~isa_size(din.iax,[1,4],'double') || ~isequal(sort(din.iax),[1,2,3,4])
            mess='ERROR: Check the fields ''iax'' and ''pax'''; return;
        end
        if ~isa_size(din.uint,[2,4],'double'); mess='ERROR: field ''uint'' must be 2x4 matrix of reals'; return; end
    elseif ndim==4
        if ~isempty(din.iax) || ~isa_size(din.pax,[1,4],'double') || ~isequal(sort(din.pax),[1,2,3,4])
            mess='ERROR: Check the fields ''iax'' and ''pax'''; return;
        end
        if ~isempty(din.uint); mess='ERROR: field ''uint'' must be empty'; return; end
    else
        if ~isa_size(din.pax,[1,ndim],'double') || ~isa_size(din.iax,[1,4-ndim],'double') ||...
                ~isequal(sort([din.pax,din.iax]),[1,2,3,4])
            mess='ERROR: Check the fields ''iax'' and ''pax'''; return;
        end
        if ~isa_size(din.uint,[2,4-ndim],'double'); mess='ERROR: field ''uint'' must be 2x',num2str(4-ndim),' matrix of reals'; return; end
    end
    if ndim==0
        data_size = [1,1];  % size that data arrays must have if to be zero-dimensional
    end
    if ndim>=1
        if ~isa_size(din.p1,'column','double'); mess='ERROR: field ''p1'' must be a column vector of at least 2 numbers'; return; end
        n1 = length(din.p1)-1;
        data_size = [n1,1]; % size that data arrays must have if to be one-dimensional
    end
    if ndim>=2
        if ~isa_size(din.p2,'column','double'); mess='ERROR: field ''p2'' must be a column vector of at least 2 numbers'; return; end
        n2 = length(din.p2)-1;
        data_size = [n1,n2]; % size that data arrays must have if to be two-dimensional
    end
    if ndim>=3
        if ~isa_size(din.p3,'column','double'); mess='ERROR: field ''p3'' must be a column vector of at least 2 numbers'; return; end
        n3 = length(din.p3)-1;
        data_size = [n1,n2,n3]; % size that data arrays must have if to be three-dimensional
    end
    if ndim>=4
        if ~isa_size(din.p4,'column','double'); mess='ERROR: field ''p4'' must be a column vector of at least 2 numbers'; return; end
        n4 = length(din.p4)-1;
        data_size = [n1,n2,n3,n4]; % size that data arrays must have if to be four-dimensional
    end
    if ~isa_size(din.s,data_size,'double'); mess='ERROR: field ''s'' must have size that matches axis coordinates'; return; end
    if ~isa_size(din.e,data_size,'double'); mess='ERROR: field ''e'' must have size that matches axis coordinates'; return; end
    if length(find(din.e<0))>0; mess='ERROR: field ''e'' must not have negative elements (holds variances)'; return; end
    if ~isa_size(din.n,data_size,'numeric'); mess='ERROR: field ''n'' must have size that matches axis coordinates'; return; end
    if ndim==4
        if ~isa(din.n,'int16'); mess='ERROR: field ''n'' must have type int16 (data is 4-dimensional)'; return; end
        if length(find(din.n<int16(0)))>0; mess='ERROR: field ''n'' must not have negative elements'; return; end
    else
        if ~isa(din.n,'double'); mess='ERROR: field ''n'' must have type double'; return; end
        if length(find(din.n<0))>0; mess='ERROR: field ''n'' must not have negative elements'; return; end
    end
    ndim_out = ndim;
else
    mess = 'ERROR: Input is not a structure'; return
end
