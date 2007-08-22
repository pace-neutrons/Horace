function output = convert_to_libisis(input)
% Converts Horace data to data compatable for Libisis.
%
% syntax:
%   output = convert_to_libisis(input)
%
% input:
%--------
%       input:      Any Horace dataset or standard matlab class
%
% Output:
%--------
%       output:     Corresponding libisis compatable dataset or class
%
% Description:
%--------------
%
%       This will convert the input into a corresponding libisis class. If
%       the input is a standard matlab class (double, string etc.), then the
%       output will be the same as the input. If the input is a Horace 
%       dataset, then it will be converted into the corresponding libisis
%       dataset.
%
% Examples:
%
%   >> IXTdataset_1d = convert_to_libisis(d1d)
%   >> number = convert_to_libisis(number)
%   >> IXTdataset_2d = convert_to_libisis(d2d)

output = input;
