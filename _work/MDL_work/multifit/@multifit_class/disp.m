function outstr = disp(obj)
% prints the multifit class structure in an easy to read format
%
% outstr = disp(obj)
%
% Input:
%   obj   a multifit object
%
% To see the fields of the multifit object, use:
%   >> struct(obj)

outstr = sprintf('<a href="matlab:doc multifit_class">multifit</a> object with %d datasets\n',numel(obj.data));

if nargout==0
    disp(outstr);
end
