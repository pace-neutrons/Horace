function [xvals,xpix,xvar,xdevsqr]=coordinates_calc_(w,xlist)
% Get the average values of one or more coordinates in each bin of an sqw object
%
%   >> xvals = coordinates_calc (w, xlist)
%
% Input:
% ------
%   w       sqw object
%   xlist   One or more coordinate names (string or cell array of strings)
%           Valid names are:
%               'd1','d2',...       Display axes (for as many dimensions as
%                                  the sqw object has)
%               'h', 'k', 'l'       r.l.u.
%               'E'                 energy transfer
%               'Q'                 |Q|
%
%           e.g. valid values for xlist include:
%               'E'
%               {'h'}
%               {'d1','d2'}
%               {'d3','E','Q','k'}
%
% Output:
% -------
%   ok      true if all OK; false if invalid coordinate name given
%
%   mess    empty if all OK, error message otherwise
%
%   xvals   Cell array of xvalues corresponding to the names in xlist, with
%          the size of each entry being that of the signal array.
%           If input was a single name as a character string, then xvals is
%          a numeric array; if a single name in a cell array, then xvals is
%          a cell array with one element.
%
%   xpix    Cell array of corresponding values for each pixel (column vectors)
%
%   xvar    Variance of xvalues in each bin (array size equal to that of
%          the signal array)
%
%   xdevsqr Cell array of corresponding squared-deviation for each pixel
%          (column vectors)


% Original author: T.G.Perring
%

% Get list of coordinates to average
% ------------------------------------
ax_name = {'d1','d2','d3','d4'};
xname=[ax_name(:);{'h';'k';'l';'E';'Q'}];


if ~iscellstr(xlist)
    cell_output=false;
    xlist={xlist};  % make a cell array for convenience
else
    cell_output=true;
end
ind = ismember(xname,xlist);
if ~any(ind)
    error('HORACE:sqw:invalid_argument', ...
        'Input parameter must be one or group of parameters from list %s\n. It is: %s',...
        disp2str(xname),disp2str(xlist))
end

% Check consistency of coordinate name(s) with dimensions of sqw object
nd=dimensions(w);
is_dax = ismember(ax_name,xlist);     % start of a bunch of names associated with plot axes
if any(is_dax)
    dax_num = find(is_dax);    
    if max(dax_num)>nd
        invalid = dax_num>nd;
        error('HORACE:sqw:invalid_argument', ...    
        'Some coordinate names %s request axes numbers higher then the dimensionality of sqw object (=%d)',...
        disp2str(ax_name(dax_num(invalid))),nd);
    end
end



% Evaluate required averages
% ---------------------------
% (Evaluate only those requested - keeps calculations down on what could be a long function call)

% Convenient structure of logicals with fields matching the valid coordinate names
ind=cell2struct(num2cell(ind),xname,1);

xpix=cell(1,numel(xlist));

header_ave=w.header_average();   % get average header
npixtot=w.pix.num_pixels;
if ind.h||ind.k||ind.l||ind.Q
    % Matrix and translation to convert from pixel coords to hkl
    uhkl=header_ave.u_to_rlu(1:3,1:3)*w.pix.q_coordinates+repmat(header_ave.uoffset(1:3),[1,npixtot]);
    if ind.Q
        % Get |Q|
        B=bmatrix(header_ave.alatt, header_ave.angdeg);
        qcryst=B*uhkl;
        Q=sqrt(sum(qcryst.^2,1));
    end
    if ind.h, xpix{ind.h}=uhkl(1,:)'; end   % column vector
    if ind.k, xpix{ind.k}=uhkl(2,:)'; end   % column vector
    if ind.l, xpix{ind.l}=uhkl(3,:)'; end   % column vector
    if ind.Q, xpix{ind.Q}=Q'; end       % column vector
    clear uhkl      % clear possibly large array
end

if ind.d1||ind.d2||ind.d3||ind.d4
    % Matrix and translation to convert from pixel coords to projection coordinates
    u_to_rlu = w.data.proj.u_to_rlu;
    U=(u_to_rlu(1:3,1:3))\header_ave.u_to_rlu(1:3,1:3);
    T=(u_to_rlu (1:3,1:3))\(w.data.proj.offset(1:3)'-header_ave.uoffset(1:3));
    uproj=U*w.pix.q_coordinates-repmat(T,[1,npixtot]);        % pixel Q coordinates now in projection axes
    uproj=[uproj;w.pix.dE+header_ave.uoffset(4)];    % now append energy data

    % Get display axes
    pax=w.data.pax;
    dax=w.data.dax;
    if ind.d1, xpix{ind.d1}=uproj(pax(dax(1)),:)'; end  % column vector
    if ind.d2, xpix{ind.d2}=uproj(pax(dax(2)),:)'; end  % column vector
    if ind.d3, xpix{ind.d3}=uproj(pax(dax(3)),:)'; end  % column vector
    if ind.d4, xpix{ind.d4}=uproj(pax(dax(4)),:)'; end  % column vector
    clear uproj     % clear possibly large array
end

if ind.E
    xpix{ind.E}=w.pix.dE'+header_ave.uoffset(4);
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
