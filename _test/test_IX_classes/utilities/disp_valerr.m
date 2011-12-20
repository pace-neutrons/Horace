function disp_valerr(d)
% Display structure with two scalar fields val and err
%
%   >> disp_valerr(d)

% Check input has right structure
if isstruct(d)
    fnames=fieldnames(d);
    if ~numel(fnames)==2 || ~isequal(fnames,{'val';'err'})
        error('Input argument must be a structure with two fields, ''val'' and ''err''')
    end
else
    error('Input argument must be a structure with two fields, ''val'' and ''err''')
end

% List to screen
for i=1:numel(d)
    disp([num2str(d(i).val),'   ',num2str(d(i).err)])
end
