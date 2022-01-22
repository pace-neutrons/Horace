function [wpdf, wcdf] = IX_dataset_1d(obj)
% Produce IX_dataset_1d objects from the probability distribution function
%
%   >> [wpdf, wcdf] = IX_dataset_1d(obj)
%
% Input:
% ------
%   obj         <a href="matlab:help('pdf_table');">pdf_table</a> object that contains the probability distribution
%
% Output:
% -------
%   wpdf        Probability distribution function as an IX_dataset_1d object
%              (See <a href="matlab:help('IX_dataset_1d');">IX_dataset_1d</a> for details)
%
%   wcdf        Cumulative probability distribution as an IX_dataset_1d object
%              (See <a href="matlab:help('IX_dataset_1d');">IX_dataset_1d</a> for details)


if ~isscalar(obj)
    error('HERBERT:pdf_table:invalid_argument',...
        'Method only takes a scalar object')
end
if ~obj.filled
    error('HERBERT:pdf_table:uninitialised',...
        'The probability distribution function is not initialised')
end

wpdf = IX_dataset_1d (obj.x_, obj.f_, zeros(size(obj.f_)),...
    'Probability distribution function','Random variable','Function value');

wcdf = IX_dataset_1d (obj.x_, obj.A_, zeros(size(obj.A_)),...
    'Cumulative distribution function','Random variable','Function value');

end
