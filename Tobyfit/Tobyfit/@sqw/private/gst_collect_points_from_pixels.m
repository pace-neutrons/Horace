function wout = gst_collect_points_from_pixels(win,ppp,pnt_win,pnt_pix,SQE)
% All points that belong to a single sqw object pixel, say
% win(i).data.pix(:,j), can be accessed via:
%   npix = arrayfun(@(x)(size(x.data.pix,2)),win);
%   cumpix = cat(2,0,cumsum(npix));
%   pix_ij = 1+cumpix(i)+(j-1)*(1:ppp);
% And we can verify that this is correct by checking pnt_win and pnt_pix
%   all( pnt_win(pix_ij) == i)
%   all( pnt_pix(pix_ij) == j)

% Initialise output arguments
% ---------------------------
wout = win;

nwin = numel(win);
nPx = arrayfun( @(x)(size( x.data.pix, 2)), win);
tPx = sum(nPx);
tPt = tPx*ppp;
% Verify inputs:
if numel(pnt_win)~=tPt || numel(pnt_pix)~=tPt
    error('Point sqw-object index and per-sqw-object pixel index must have %d elements for %d total pixels and %d points per pixel',tPt,tPx,pts_per_pixel)
end
nSQE = numel(SQE);
if size(SQE,2) ~= nSQE
    if size(SQE,1)==nSQE
        SQE = permute(SQE,[2,1]);
    else
        fprintf('S(Q,E) is expected to be a row vector, but is ')
        fprintf('%d ',size(SQE))
        fprintf('instead. Forcing reshape to row vector.')
        SQE = permute(SQE(:),[2,1]);
    end
end

spanwin = cat(2,0,cumsum(nPx*ppp));
k = 0:ppp-1;
for i=1:nwin
    for j=1:nPx(i)
        ijk = spanwin(i) + j + k*nPx(i);
        
        if ~all(pnt_win(ijk)==i) || ~all(pnt_pix(ijk)==j)
            error('Something has gone wrong indexing points for pixel %d of win(%d)',j,i)
        end
        
        s = SQE(ijk);
        wout(i).data.pix(8,j) = sum(s)/ppp;
        wout(i).data.pix(9,j) = abs(sum(s.^2)-sum(s)^2)/ppp^2;
    end
    wout(i) = recompute_bin_data(wout(i));
end
