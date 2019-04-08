function varargout = mtimesx_horace(varargin)
% mtimesx does a matrix multiply of two inputs (single, double, or sparse)
%******************************************************************************
%
%  MATLAB (R) is a trademark of The Mathworks (R) Corporation
%
%  Function:    mtimesx
%  Filename:    mtimesx.m
%  Programmer:  James Tursa
%  Version:     1.10
%  Date:        December 08, 2009
%  Copyright:   (c) 2009 by James Tursa, All Rights Reserved
%
% -------------------------------------------------------------------------
% Modified for Horace workfolw in September 2017;
% Horace revision:
%
 $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)
%
% -------------------------------------------------------------------------
%
%
%  This code uses the BSD License:
%
%  Redistribution and use in source and binary forms, with or without
%  modification, are permitted provided that the following conditions are
%  met:
%
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
%
%  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%  POSSIBILITY OF SUCH DAMAGE.
%
%--
%
% mtimesx is a fast general purpose matrix and scalar multiply routine that utilizes
% BLAS calls and custom code to perform the calculations. mtimesx also has extended
% support for n-Dimensional (nD, n > 2) arrays, treating these as arrays of 2D matrices
% for the purposes of matrix operations.
%
% "Doesn't MATLAB already do this?"  For 2D matrices, yes, it does. However, MATLAB does
% not always implement the most efficient algorithms for memory access, and MATLAB does not
% always take full advantage of symmetric cases. The mtimesx 'SPEED' mode attempts to do
% both of these to the fullest extent possible. For nD matrices, MATLAB does not have
% direct support for this. One is forced to write loops to accomplish the same thing that
% mtimesx can do faster.
%
% The usage is as follows (arguments in brackets [ ] are optional):
%
% Syntax
%
%  M = mtimesx( [mode] )
%  C = mtimesx(A [,transa] ,B [,transb] [,mode])
%
% Description
%
%  mtimesx performs the matrix calculation op(A) * op(B), where:
%     A = A single or double or sparse scalar, matrix, or array.
%     B = A single or double or sparse scalar, matrix, or array.
%     transa = A character indicating a pre-operation on A:
%     transb = A character indicating a pre-operation on B:
%              The pre-operation can be any of:
%              'N' or 'n' = No operation (the default if trans_ is missing)
%              'T' or 't' = Transpose
%              'C' or 'c' = Conjugate Transpose
%              'G' or 'g' = Conjugate (no transpose)
%     mode = 'MATLAB' or 'SPEED' (sets mode for current and future calculations,
%                                 case insensitive, optional)
%     M is a string indicating the current calculation mode, before setting the new one.
%     C is the result of the matrix multiply operation.
%
% Examples:
%
%  C = mtimesx(A,B)         % performs the calculation C = A * B
%  C = mtimesx(A,'T',B)     % performs the calculation C = A.' * B
%  C = mtimesx(A,B,'G')     % performs the calculation C = A * conj(B)
%  C = mtimesx(A,'C',B,'C') % performs the calculation C = A' * B'
%
% mtimesx has two modes:
%
% 'MATLAB' mode: This mode attempts to reproduce the MATLAB intrinsic function mtimes
% results exactly. When there was a choice between faster code that did not match the
% MATLAB intrinsic mtimes function results exactly vs slower code that did match the
% MATLAB intrinsic mtimes function results exactly, the choice was made to use the
% slower code. Speed improvements were only made in cases that did not cause a mismatch.
% Caveat: I have only tested on a PC with later versions of MATLAB. But MATLAB may use
% different algorithms for mtimes in earlier versions or on other machines that I was
% unable to test, so even this mode may not match the MATLAB intrinsic mtimes function
% exactly in some cases. This is the default mode when mtimesx is first loaded and
% executed (i.e., the first time you use mtimesx in your MATLAB session and the first
% time you use mtimesx after clearing it). You can set this mode for all future
% calculations with the command mtimesx('MATLAB') (case insensitive).
%
% 'SPEED' mode: This mode attempts to reproduce the MATLAB intrinsic function mtimes
% results closely, but not necessarily exactly. When there was a choice between faster
% code that did not exactly match the MATLAB intrinsic mtimes function vs slower code
% that did match the MATLAB intrinsic mtimes function, the choice was made to use the
% faster code. Speed improvements were made in all cases that I could identify, even
% if they caused a slight mismatch with the MATLAB intrinsic mtimes results.
% NOTE: The mismatches are the results of doing calculations in a different order and
% are not indicative of being less accurate. You can set this mode for all future
% calculations with the command mtimesx('SPEED') (case insensitive).
%
% Note: You cannot combine double sparse and single inputs, since MATLAB does not
% support a single sparse result. You also cannot combine sparse inputs with full
% nD (n > 2) inputs, since MATLAB does not support a sparse nD result. The only
% exception is a sparse scalar times an nD full array. In that special case,
% mtimesx will treat the sparse scalar as a full scalar and return a full nD result.
%
% Note: The 'N', 'T', and 'C' have the same meanings as the direct inputs to the BLAS
% routines. The 'G' input has no direct BLAS counterpart, but was relatively easy to
% implement in mtimesx and saves time (as opposed to computing conj(A) or conj(B)
% explicitly before calling mtimesx).
%
% mtimesx supports nD inputs. For these cases, the first two dimensions specify the
% matrix multiply involved. The remaining dimensions are duplicated and specify the
% number of individual matrix multiplies to perform for the result. i.e., mtimesx
% treats these cases as arrays of 2D matrices and performs the operation on the
% associated parings. For example:
%
%     If A is (2,3,4,5) and B is (3,6,4,5), then
%     mtimesx(A,B) would result in C(2,6,4,5)
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
% The first two dimensions must conform using the standard matrix multiply rules
% taking the transa and transb pre-operations into account, and dimensions 3:end
% must match exactly or be singleton (equal to 1). If a dimension is singleton
% then it is virtually expanded to the required size (i.e., equivalent to a
% repmat operation to get it to a conforming size but without the actual data
% copy). For example:
%
%     If A is (2,3,4,5) and B is (3,6,1,5), then
%     mtimesx(A,B) would result in C(2,6,4,5)
%     where C(:,:,i,j) = A(:,:,i,j) * B(:,:,1,j), i=1:4, j=1:5
%
%     which would be equivalent to the MATLAB m-code:
%     C = zeros(2,6,4,5);
%     for m=1:4
%         for n=1:5
%             C(:,:,m,n) = A(:,:,m,n) * B(:,:,1,n);
%         end
%     end
%
% When a transpose (or conjugate transpose) is involved, the first two dimensions
% are transposed in the multiply as you would expect. For example:
%
%     If A is (3,2,4,5) and B is (3,6,4,5), then
%     mtimesx(A,'C',B,'G') would result in C(2,6,4,5)
%     where C(:,:,i,j) = A(:,:,i,j)' * conj( B(:,:,i,j) ), i=1:4, j=1:5
%
%     which would be equivalent to the MATLAB m-code:
%     C = zeros(2,6,4,5);
%     for m=1:4
%         for n=1:5
%             C(:,:,m,n) = A(:,:,m,n)' * conj( B(:,:,m,n) );
%         end
%     end
%
%     If A is a scalar (1,1) and B is (3,6,4,5), then
%     mtimesx(A,'G',B,'C') would result in C(6,3,4,5)
%     where C(:,:,i,j) = conj(A) * B(:,:,i,j)', i=1:4, j=1:5
%
%     which would be equivalent to the MATLAB m-code:
%     C = zeros(6,3,4,5);
%     for m=1:4
%         for n=1:5
%             C(:,:,m,n) = conj(A) * B(:,:,m,n)';
%         end
%     end
%
% ---------------------------------------------------------------------------------------------------------------------------------
%
% The BLAS routines used are DDOT, DGEMV, DGEMM, DSYRK, and DSYR2K for double
% variables, and SDOT, SGEMV, SGEMM, SSYRK, and SSYR2K for single variables.
% These routines are (description taken from www.netlib.org):
%
% DDOT and SDOT:
%
% *     forms the dot product of two vectors.
%
% DGEMV and SGEMV:
%
% *  DGEMV  performs one of the matrix-vector operations
% *
% *     y := alpha*A*x + beta*y,   or   y := alpha*A'*x + beta*y,
% *
% *  where alpha and beta are scalars, x and y are vectors and A is an
% *  m by n matrix.
%
% DGEMM and SGEMM:
%
% *  DGEMM  performs one of the matrix-matrix operations
% *
% *     C := alpha*op( A )*op( B ) + beta*C,
% *
% *  where  op( X ) is one of
% *
% *     op( X ) = X   or   op( X ) = X',
% *
% *  alpha and beta are scalars, and A, B and C are matrices, with op( A )
% *  an m by k matrix,  op( B )  a  k by n matrix and  C an m by n matrix.
%
% DSYRK and SSYRK:
%
% *  DSYRK  performs one of the symmetric rank k operations
% *
% *     C := alpha*A*A' + beta*C,
% *
% *  or
% *
% *     C := alpha*A'*A + beta*C,
% *
% *  where  alpha and beta  are scalars, C is an  n by n  symmetric matrix
% *  and  A  is an  n by k  matrix in the first case and a  k by n  matrix
% *  in the second case.
%
% DSYR2K and SSYR2K:
%
% *  DSYR2K  performs one of the symmetric rank 2k operations
% *
% *     C := alpha*A*B' + alpha*B*A' + beta*C,
% *
% *  or
% *
% *     C := alpha*A'*B + alpha*B'*A + beta*C,
% *
% *  where  alpha and beta  are scalars, C is an  n by n  symmetric matrix
% *   and  A and B  are  n by k  matrices  in the  first  case  and  k by n
% *  matrices in the second case.
%
% Double sparse matrix operations are supported, but not always directly.
% For (matrix) * (scalar) operations, custom code is used to produce a result
% that minimizes memory access times. All other operations, such as
% (matrix) * (vector) or (matrix) * (matrix), or any operation involving a transpose
% or conjugate transpose, are obtained with calls back to the MATLAB intrinsic
% mtimes function. Thus for most non-scalar sparse operations, mtimesx is
% simply a thin wrapper around the intrinsic MATLAB function and you will see
% no speed improvement.
%
% ---------------------------------------------------------------------------------------------------------------------------------
%
% Examples:
%
%  C = mtimesx(A,B)                 % performs the calculation C = A * B
%  C = mtimesx(A,'T',B,'speed')     % performs the calculation C = A.' * B
%                                   % using a fast algorithm that may not
%                                   % match MATLAB results exactly
%  mtimesx('matlab')                % sets calculation mode to match MATLAB
%  C = mtimesx(A,B,'g')             % performs the calculation C = A * conj(B)
%  C = mtimesx(A,'c',B,'C')         % performs the calculation C = A' * B'
%
% ---------------------------------------------------------------------------------------------------------------------------------




%[use_mex,num_omp_threads] = get(hor_config,'use_mex','threads');
[use_mex,n_threads] = config_store.instance().get_value('hor_config','use_mex','threads');




%if isempty(which('mtimesx_mex'))
%    root = fileparts(which('horace_init'));
%    cd(fullfile(root,'_LowLevelCode','cpp','mtimesx'));
%    mtimesx_build;
%end

if  numel(varargin) > 2 && isa(varargin{end},'logical')
    use_mex = varargin{end};
    argi = varargin(1:end-1);
else
    argi = varargin;
end


if use_mex && numel(argi) == 2
    try
        %\
        % Call the mex routine mtimesx.
        %/
        [varargout{1:nargout}] = mtimesx_mex(argi{:},n_threads);
    catch ERR
        use_mex = false;
        fm = get(hor_config,'force_mex_if_use_mex');
        if fm
            rethrow(ERR);
        else
            warning('mtimesx:runtime_error',...
                'Error %s running mtimes_mex C-code. trying Matlab',...
                ERR.message);
            set(hor_config,'use_mex',false);
        end
    end
end


if ~use_mex
    [varargout{1:nargout}] = mtimesx_matlab(argi{:});
end


function varargout = mtimesx_matlab(varargin)

if nargin < 2
    varargout{1} = 'NOMEX';
    return;
end
A = varargin{1};
np =2;
op = cell(2,1);
if is_string(varargin{np})
    [op{1},empty1] = get_op(varargin{np});
    np=3;
else
    op{1} = get_op('');
    np = 2;
    empty1 = true;
    empty2 = true;
end
B = varargin{np};
if nargin > np
    op{2} = get_op(varargin{np+1});
else
    op{2} = get_op('');
    empty2 = true;
end

op1 = op{1};
op2 = op{2};
if numel(A) == 1 || numel(B) == 1
    varargout{1} = op1(A)*op2(B);
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
    if empty1 && empty2
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
    else
        for i=1:tail_size
            rez(:,:,i) = op1(A(:,:,i))*op2(B(:,:,i));
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
    varargout{1} = op1(A)*op2(B);
end

function [op,empty] = get_op(code)
OI = upper(code);
empty = false;
switch OI
    case 'G'
        op = @(x)(conj(x));
    case 'T'
        op = @(x)(transpose(x));
    case 'C'
        op = @(x)(ctranspose(x));
    case 'N' % option used to test operators loop.
        op = @(x)(x);
    otherwise
        op = @(x)(x);
        empty = true;
end
