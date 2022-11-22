function obj = set_dist_functions_(obj,val)
% set values of distribution functions array from input data
if isa(val,'pdf_table')
    [npnt,x,f,A,Acum,m] = process_pdf_array(val);
elseif iscell(val)
    [npnt,x,f,A,Acum,m] = process_cellarray_of_df(val);
else
    error('HERBERT:pdf_table_array:invalid_argument', ...
        'set.dist_functions method accepts only array of pdf functions or cellarray of pdf function data. You provided %s', ...
        class(val))
end
obj.npnt_ = npnt;
obj.x_ = x;
obj.f_ = f;
obj.A_ = A;
obj.Acum_ = Acum;
obj.m_ = m;


function [npnt,x,f,A,Acum,m] = process_pdf_array(pdf)
% set array of pdf functions
if ~all(arrayfun(@(x)(x.filled),pdf(:)))
    error('HERBERT:pdf_table_array:invalid_argument', ...
        'Not all contributed pdf_table objects are filled - cannot make a table array')
end
npdf = numel(pdf);
npnt = arrayfun(@(x)(numel(x.f)),pdf);
nend = cumsum(npnt(:));
nbeg = nend - npnt(:) + 1;

x = NaN(nend(end),1);
f = NaN(nend(end),1);
A = NaN(nend(end),1);
Acum = NaN(nend(end),1);
m = NaN(nend(end),1);
for i=1:npdf
    x(nbeg(i):nend(i)) = pdf(i).x;
    f(nbeg(i):nend(i)) = pdf(i).f;
    A(nbeg(i):nend(i)) = pdf(i).A;
    Acum(nbeg(i):nend(i)) = A(nbeg(i):nend(i)) + (i-1);
    m(nbeg(i):nend(i)-1) = pdf(i).m;
end

function  [npnt,x,f,A,Acum,m] = process_cellarray_of_df(celldata)
if numel(celldata) ~= 3
    error('HERBERT:pdf_table_array:invalid_argument', ...
        'input array of distribution functions should contain 3 elements')
end
x = celldata{1};
f = celldata{2};
if numel(x) ~= numel(f)
    error('HERBERT:pdf_table_array:invalid_argument', ...
        '1-st element of input cellarray (x) contains %d elements and 2-nd (f) -- %d elements.\nThey should be equal', ...
        numel(x),numel(f));
end
npnt = celldata{3};
nend = cumsum(npnt(:));
npdf = numel(npnt);
if nend(end) ~= numel(f)
    error('HERBERT:pdf_table_array:invalid_argument', ...
        ['3-rd element of input cellarray (nptn) describes %d df-s with %d elements in total.',...
        'Actual number of elements in distribution is different: %d'],...
        npdf,nend(end),numel(f));
end
nbeg = nend - npnt(:) + 1;

A = cell(npdf,1);
Acum = cell(npdf,1);
m = cell(npdf,1);
tr_pdf = pdf_table;
tr_pdf.do_check_combo_arg = false;
for i=1:npdf

    tr_pdf.x = x(nbeg(i):nend(i));
    tr_pdf.f = f(nbeg(i):nend(i));

    tr_pdf = tr_pdf.check_combo_arg();

    A{i} = tr_pdf.A';
    Acum{i} = tr_pdf.A' + (i-1);
    m{i} = tr_pdf.m';
end
A = [A{:}]';
Acum= [Acum{:}]';
m = [m{:}]';
