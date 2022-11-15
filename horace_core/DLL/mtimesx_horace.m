function varargout = mtimesx_horace(varargin)
% mtimesx_horace does a matrix multiply of two inputs (single, double)
%
% This is a highly simplified and reduced implementation of the mtimesx function
% developed by James Tursa, available at:
%  https://uk.mathworks.com/matlabcentral/fileexchange/25977-mtimesx-fast-matrix-multiply-with-multi-dimensional-support
%
% Syntax
%  C = mtimesx_horace(A, B [, use_mex])
%
% Description:
%
%  mtimesx_horace performs the matrix calculation A*B, where:
%   A       = A single or double scalar, matrix, or array.
%   B       = A single or double scalar, matrix, or array.
%   use_mex = boolean override of configuration to force use of mex implementation
%   C is the result of the matrix multiply operation.
%
%  If the `use_mex` flag in the `hor_config' configuration is FALSE, or the
%  `use_mex` argument is FALSE this operation is performed in MATLAB.
%  Otherwise the operation is performed using an optimized mex implenation
%  using the a number of threads taken from the 'hor_config.num_threads' configuration.
%
% Examples:
%
%  C = mtimesx_horace(A, B)         % performs the calculation C = A * B
%  C = mtimesx_horace(A, B, false)  % performs the calculation C = A * B in
%  MATLAB
%
% mtimesx_horace supports nD inputs. For these cases, the first two dimensions
% specify the matrix multiply involved. The remaining dimensions are duplicated and
% specify the number of individual matrix multiplies to perform for the result.
% i.e., mtimesx_horace treats these cases as arrays of 2D matrices and performs
% the operation on the associated parings. For example:
%
%     If A is (2,3,4,5) and B is (3,6,4,5), then
%     mtimesx_horace(A,B) would result in C(2,6,4,5)
%     where C(:,:,i,j) = A(:,:,i,j) * B(:,:,i,j), i=1:4, j=1:5
%
%     which would be equivalent to the MATLAB m-code:
%     C = zeros(2,6,4,5);
%     for m=1:4
%         for n=1:5
%             C(:,:,m,n) = A(:,:,m,n) * B(:,:,m,n);
%         end
%     end
%
% The first two dimensions must conform using the standard matrix multiply rules,
% and dimensions 3:end must match exactly or be singleton (equal to 1).
% If a dimension is singleton then it is virtually expanded to the required
% size (i.e., equivalent to a repmat operation to get it to a conforming size
% but without the actual data copy). For example:
%
%     If A is (2,3,4,5) and B is (3,6,1,5), then
%     mtimesx_horace(A,B) would result in C(2,6,4,5)
%     where C(:,:,i,j) = A(:,:,i,j) * B(:,:,1,j), i=1:4, j=1:5
%
%     which would be equivalent to the MATLAB m-code:
%     C = zeros(2,6,4,5);
%     for m=1:4
%         for n=1:5
%             C(:,:,m,n) = A(:,:,m,n) * B(:,:,1,n);
%         end
%     end

hc = hor_config;
par = parallel_config;
use_mex = hc.use_mex;
n_threads = par.threads;

if  numel(varargin) > 2 && isa(varargin{end},'logical')
    use_mex = varargin{end};
    argi = varargin(1:end-1);
else
    argi = varargin;
end

if numel(argi) ~= 2
    error('mtimesx_horace:runtime_error', 'Invalid arguments');
end

if use_mex
    try
        % Call the mex routine .
        [varargout{1:nargout}] = mtimesx_mex(argi{:}, n_threads);
    catch ERR
        use_mex = false;
        if hc.force_mex_if_use_mex
            rethrow(ERR);
        else
            warning('mtimesx_horace:runtime_error',...
                'Error %s running mtimes_mex C-code. trying Matlab',...
                ERR.message);
            use_mex = false;
        end
    end
end

if ~use_mex
    [varargout{1:nargout}] = mtimesx_matlab(argi{:});
end

end

function varargout = mtimesx_matlab(varargin)

A = varargin{1};
B = varargin{2};

if numel(A) == 1 || numel(B) == 1
    varargout{1} = A*B;
    return;
end

sza = size(A);
szb = size(B);
sz = [sza(1),szb(2)];
if numel(sza) > 2 || numel(szb) >2
    A_size = sza(1)*sza(2);
    B_size = szb(1)*szb(2);

    a_tail_size = prod(sza)/A_size;
    b_tail_size = prod(szb)/B_size;


    if ~(a_tail_size == b_tail_size || min([a_tail_size,b_tail_size]) == 1)
        error('MTIMESX_MATLAB:invalid_argument',...
            ['different A and B sizes supported only if numel(size(B))<=2)',...
            ' or A and B dimensions in higher than 2 range are equal']);
    end
    tail_size =  max([a_tail_size,b_tail_size]);

    rez = zeros(sz(1),sz(2),tail_size);
    if a_tail_size > 1
        A = reshape(A,sza(1),sza(2),tail_size);
    else
        A = reshape(repmat(A,1,tail_size),[sz,tail_size]);
    end
    if b_tail_size > 1
        B = reshape(B,szb(1),szb(2),tail_size);
    else
        B = reshape(repmat(B,1,tail_size),[sz,tail_size]);
    end
else
    tail_size = 1;
    a_tail_size = 1;
    b_tail_size = 1;
end

if tail_size > 1
    Mk0 = szb(1);
    Mi = sza(1);
    Mj = szb(2);
    for i=1:Mi
        for j=1:Mj
            for k=1:Mk0
                rez(i,j,:) = rez(i,j,:) + A(i,k,:).*B(k,j,:);
            end
        end
    end

    if a_tail_size > b_tail_size
        sza(1) = sz(1);
        sza(2) = sz(2);
        varargout{1} = reshape(rez,sza);
    else
        szb(1) = sz(1);
        szb(2) = sz(2);
        varargout{1} = reshape(rez,szb);
    end
else
    varargout{1} = A*B;
end

end
