function [ok,mess,xvals,xpix,xvar,xdevsqr]=coordinates_calc(w,xlist)
% Get average values of one or more coordinates for the pixels in each bin of an sqw object
%
% Syntax:
%   >> xvals = coordinates_calc (w, xlist)
%
% Input:
% ------
%   w       sqw object
%   xlist   One or more valid coordinate names (string or cell array of strings)
%           Valid names are:
%               'd1','d2',...       Display axes (for as many dimensions as sqw object has)
%               'h', 'k', 'l'       r.l.u.
%               'E'                 energy transfer
%               'Q'                 |Q|
%
%           E.g. valid xlist include: 'E'  {'d1','d2'}  {'d3','E','Q','k'}, {'h'}
%
% Output:
% -------
%   ok      true if all OK; false if invalid coordinate name given
%
%   mess    empty if all OK, error message otherwise
%
%   xvals   Cell array of xvalues corresponding to the names in xlist, with size
%          of each entry being that of the signal array.
%           If input was a single name as a character string, then xvals is a numeric array; if
%          a single name in a cell array, then xvals is a cell array with one element.
%
%   xpix    Cell array of corresponding values for each pixel (column vectors)
%
%   xvar    Variance of xvalues, size equal to that of the signal array.
%
%   xdevsqr Cell array of corresponding squared-deviation for each pixel (column vectors)

% T.G.Perring 9 August 2009


% Get list of coordinates to average
% ------------------------------------
xname={'d1','d2','d3','d4','h','k','l','E','Q'};
ind=zeros(size(xname));

if ~iscellstr(xlist)
    cell_output=false;
    xlist={xlist};  % make a cell array for convenience
else
    cell_output=true;
end

for i=1:numel(xlist)
    tmp=find(strcmpi(xlist{i},xname),1);
    if ~isempty(tmp)
        ind(tmp)=i;
    else
        xvals=[]; xpix=[]; xvar=[]; xdevsqr=[]; ok=false; mess=['Unrecognised coordinate name: ''',xlist{i},'''']; return
    end
end

% Check consistency of coordinate name(s) with dimensions of sqw object
nd=dimensions(w);
noff=1;     % start of a bunch of names associated with plot axes
if any(logical(ind(noff+nd:noff+3)))
    xvals=[]; xpix=[]; xvar=[]; xdevsqr=[]; ok=false; mess=['Coordinate name incompatible with dimensionality of sqw object (=',num2str(nd),')']; return
end

% Can inly perform operation for sqw-type object
if ~is_sqw_type(w)
    xvals=[]; xpix=[]; xvar=[]; xdevsqr=[]; ok=false; mess='Function only has meaning for an sqw-type object, not a dnd-type sqw object'; return
end


% Evaluate required averages
% ---------------------------
% (Evaluate only those requested - keeps calculations down on what could be a long function call)

present=cell2struct(num2cell(logical(ind)),xname,2);  % convenient structure of logicals with fields matching the valid coordinate names
ind=cell2struct(num2cell(ind),xname,2);

xpix=cell(1,numel(xlist));

header_ave=header_average(w.header);   % get average header
npixtot=size(w.data.pix,2);
if present.h||present.k||present.l||present.Q
    % Matrix and translation to convert from pixel coords to hkl
    uhkl=header_ave.u_to_rlu(1:3,1:3)*w.data.pix(1:3,:)+repmat(header_ave.uoffset(1:3),[1,npixtot]);
    if present.Q
        % Get |Q|
        B=bmatrix(header_ave.alatt, header_ave.angdeg);     % B matrix of Busing and Levy
        qcryst=B*uhkl;
        Q=sqrt(sum(qcryst.^2,1));
    end
    if present.h, xpix{ind.h}=uhkl(1,:)'; end   % column vector
    if present.k, xpix{ind.k}=uhkl(2,:)'; end   % column vector
    if present.l, xpix{ind.l}=uhkl(3,:)'; end   % column vector
    if present.Q, xpix{ind.Q}=Q'; end       % column vector
    clear uhkl      % clear possibly large array
end

if present.d1||present.d2||present.d3||present.d4
    % Matrix and translation to convert from pixel coords to projection coordinates
    U=inv(w.data.u_to_rlu(1:3,1:3))*header_ave.u_to_rlu(1:3,1:3);
    T=inv(w.data.u_to_rlu(1:3,1:3))*(w.data.uoffset(1:3)-header_ave.uoffset(1:3));
    uproj=U*w.data.pix(1:3,:)-repmat(T,[1,npixtot]);        % pixel Q coordinates now in projection axes
    uproj=[uproj;w.data.pix(4,:)+header_ave.uoffset(4)];   % now append energy data

    % Get display axes
    pax=w.data.pax;
    dax=w.data.dax;
    if present.d1, xpix{ind.d1}=uproj(pax(dax(1)),:)'; end   % column vector
    if present.d2, xpix{ind.d2}=uproj(pax(dax(2)),:)'; end   % column vector
    if present.d3, xpix{ind.d3}=uproj(pax(dax(3)),:)'; end   % column vector
    if present.d4, xpix{ind.d4}=uproj(pax(dax(4)),:)'; end   % column vector
    clear uproj     % clear possibly large array
end

if present.E
    xpix{ind.E}=w.data.pix(4,:)'+header_ave.uoffset(4);
end

% Compute average, and spread if 
[xvals,xvar,xdevsqr]=average_bin_data(w,xpix);

% Convert output to arrays if input was not a cell array
if ~cell_output
    xvals=xvals{1};
    xvar=xvar{1};
    xpix=xpix{1};
    xdevsqr=xdevsqr{1};
end

ok=true;
mess='';
