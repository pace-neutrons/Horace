function is_diagonal = is_diagonal_matr(matr,varargin)
%IS_DIAGONAL_MATR Checks if the matrix contains only diagonal elements or
%may be converted to matrix containing only diagonal elements.
% 
% Useful in cases when one needs to check if UB-matrix describes orthogonal
% system or not
%
% Inputs:
% matr     -- square matrix to check
% Optional:
% AbsErr   -- absolute error to compare elements with. If abs(element) <
%             AbsErr, the element considered equal to 0
% Returns:
% is_diagonal -- true if matrix is diagonal and false othersise
% 
% NOTE: Degenerated matrix may be considered diagonal matrix too. 
% 
% USAGE: use to check if UB matrix describes orthogonal system.

if size(matr,1) ~= size(matr,2)
    error('HERBERT:is_diagonal_matr:invalid_argument', ...
        'The method is applicable to square matrices only. Size of input matrix is %s', ...
        disp2str(size(matr)));
end
if nargin<2
    AbsErr = 4*eps(class(matr));
else
    AbsErr = varargin{1};
    if AbsErr < 0
        error('HERBERT:is_diagonal_matr:invalid_argument', ...        
            'Absolute error, if provided, can not be negative. It is: %s', ...
            disp2str(AbsErr));
    end
end
[leading_elements,cidx] = max(abs(matr));
szm = size(matr);
lidx = sub2ind(szm,cidx,1:szm(2));
matr(lidx) = matr(lidx)-leading_elements;
is_diagonal = all(abs(matr(:))<AbsErr);

end