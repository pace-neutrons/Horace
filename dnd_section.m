function dout = dnd_section (din, varargin)
% Takes a section out of a dataset structure
%
% Syntax:
%   >> dout = section (din, [ax_1_lo, ax_1_hi], [ax_2_lo, ax_2_hi], ...)
%
% Input:
% ------
%   din                 Dataset structure.
%                       Type >> help dnd_checkfields for a full description of the fields
%
%   [ax_1_lo, ax_1_hi]  Lower and upper limits for the first axis.
%                       To retain the limits of the input structure, type the scalar '0'
%
%   [ax_2_lo, ax_2_hi]  Lower and upper limits for the second axis
%
%           :           [For as many dimensions as there are of the input dataset structure]
%                       
%
% Output:
% -------
%   dout                Output dataset structure.
%
%
% Example: if input dataset is 3D, to alter the limits of the first and third axes:
%   >> dout = section (din, [1.9,2.1], 0, [-0.55,-0.45])
%                                                           

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

% Dimension of input data structure
ndim=length(din.pax);

% Check input parameters
if nargin==1    % trivial case - no sectioning, so return
    dout = din;
    return
end
if nargin==2 & iscell(varargin{1}) % interpret as having been passed a varargin (as cell array is not a valid type to be passed to section)
    args = varargin{1};
else
    args = varargin;
end

nargs= length(args);
if nargs~=ndim
    error ('ERROR - Check number of arguments to cut_data')
end

% Initialise output argument
dout = din;

% Get section parameters and axis arrays:
ilo = zeros(1,ndim);
ihi = zeros(1,ndim);
for i=1:ndim
    if ~isa_size(args{i},'row','double') | ~(length(args{i})==1 | length(args{i})==2)
        error (['ERROR: Limits parameter for axis ',num2str(i),' must be zero or a pair of numbers'])
    elseif length(args{i})==1
        if args{i}==0
            ilo(i) = 1;
            ihi(i) = size(din.s,i);
        else
            error (['ERROR: Limits parameter for axis ',num2str(i),' must be zero or a pair of numbers'])
        end
    elseif length(args{i})==2
        pvals_name = ['p', num2str(i)];         % name of field containing bin boundaries for the plot axis to be integrated over
        pvals = din.(pvals_name);               % values of bin boundaries (use dynamic field names facility of Matlab)
        pcent = 0.5*(pvals(2:end)+pvals(1:end-1));          % values of bin centres
        lis=find(pcent>=args{i}(1) & pcent<=args{i}(2));    % index of bins whose centres lie in the sectioning range
        if length(lis)~=0
            ilo(i) = lis(1);
            ihi(i) = lis(end);
            dout.(pvals_name) = pvals(lis(1):lis(end)+1);
        else
            if args{i}(1)>args{i}(2)
                error (['ERROR: Lower limit larger than upper limit for axis ',num2str(i)])
            else
                error (['ERROR: No data along axis ',num2str(i),' in the range [',num2str(args{i}(1)),',',num2str(args{i}(2)),']'])
            end
        end
    end
end

% Get data arrays:
% [Inelegant that each case of ndim is considered; would like to have a function independent of ndim.
%  Could do this with eval, but are there any eficiency penatlies ?]
if ndim==1
    dout.s = din.s(ilo(1):ihi(1));
    dout.e = din.e(ilo(1):ihi(1));
    dout.n = din.n(ilo(1):ihi(1));
elseif ndim==2
    dout.s = din.s(ilo(1):ihi(1),ilo(2):ihi(2));
    dout.e = din.e(ilo(1):ihi(1),ilo(2):ihi(2));
    dout.n = din.n(ilo(1):ihi(1),ilo(2):ihi(2));
elseif ndim==3
    dout.s = din.s(ilo(1):ihi(1),ilo(2):ihi(2),ilo(3):ihi(3));
    dout.e = din.e(ilo(1):ihi(1),ilo(2):ihi(2),ilo(3):ihi(3));
    dout.n = din.n(ilo(1):ihi(1),ilo(2):ihi(2),ilo(3):ihi(3));
elseif ndim==4
    dout.s = din.s(ilo(1):ihi(1),ilo(2):ihi(2),ilo(3):ihi(3),ilo(4):ihi(4));
    dout.e = din.e(ilo(1):ihi(1),ilo(2):ihi(2),ilo(3):ihi(3),ilo(4):ihi(4));
    dout.n = din.n(ilo(1):ihi(1),ilo(2):ihi(2),ilo(3):ihi(3),ilo(4):ihi(4));
else
    error('ERROR: Logic flaw in function ''section''')
end
    
    