% Compare SQWs. Fails if different.
%   ignore_latt: ingore lattice parameters 
%   (these have been refined since ILL data analysis)
function compare(l, r, ignore_latt)
    if isstring(l)
        disp(['Loading ' l '...']);
        l = read_sqw(l);
    end
    if isstring(r)
        disp(['Loading ' r '...']);
        r = read_sqw(r);
    end
    disp('Loading done.');

    %% compare detector params
    assert(all(l.detpar.group==r.detpar.group));
    assert(all(l.detpar.x2==r.detpar.x2));
    assert(all(l.detpar.phi==r.detpar.phi));
    assert(all(l.detpar.azim==r.detpar.azim));
    assert(all(l.detpar.width==r.detpar.width));
    assert(all(l.detpar.height==r.detpar.height));
    disp('PARs equal');

    %% compare headers
    assert(all(l.header.efix==r.header.efix));
    assert(all(l.header.emode==r.header.emode));
    if ~ignore_latt
        assert(all(l.header.alatt==r.header.alatt));
    end
    assert(all(l.header.angdeg==r.header.angdeg));
    assert(all(l.header.cu==r.header.cu));
    assert(all(l.header.cv==r.header.cv));
    assert(all(l.header.psi==r.header.psi));
    assert(all(l.header.omega==r.header.omega));
    assert(all(l.header.dpsi==r.header.dpsi));
    assert(all(l.header.gl==r.header.gl));
    assert(all(l.header.gs==r.header.gs));
    assert(all(l.header.en==r.header.en));
    assert(all(l.header.uoffset==r.header.uoffset));
    assert(all(l.header.ulen==r.header.ulen));
    assert(all(l.header.ulabel{1}==r.header.ulabel{1}));
    assert(all(l.header.ulabel{2}==r.header.ulabel{2}));
    assert(all(l.header.ulabel{3}==r.header.ulabel{3}));
    disp('(relevant parts) of headers equal');
    
    %% helper functions for fuzzy comparison
    % checks if
    %   abs(x_i - y_i) <= tol*max(abs(x_i),abs(y_i))
    %
    eqtol = @(x,y,tol) max(abs([x(:) y(:)])')*tol;
    eqrellist = @(x,y,tol) (abs(x(:)-y(:))' <= eqtol(x,y,tol));
    eqrel = @(x,y,tol) all(eqrellist(x,y,tol));

    %% compare data
    % (given tolerances are optimal!)
    if ~ignore_latt
        assert(all(l.data.alatt==r.data.alatt));
    end
    assert(all(l.data.angdeg==r.data.angdeg));
    assert(all(l.data.uoffset==r.data.uoffset));
    if ~ignore_latt
        assert(all(l.data.u_to_rlu(:)==r.data.u_to_rlu(:)));
    end
    assert(all(l.data.ulen==r.data.ulen));
    assert(all(l.data.ulabel{1}==r.data.ulabel{1}));
    assert(all(l.data.ulabel{2}==r.data.ulabel{2}));
    assert(all(l.data.ulabel{3}==r.data.ulabel{3}));
    assert(all(l.data.iax==r.data.iax));
    assert(all(l.data.iint(:)==r.data.iint(:)));
    assert(all(l.data.pax==r.data.pax));
    assert(all(l.data.dax==r.data.dax));

    assert(all(l.data.urange(:,1)==r.data.urange(:,1)));
    assert(all(l.data.urange(:,2)==r.data.urange(:,2)));
    assert(all(l.data.urange(:,3)==r.data.urange(:,3)));
    assert(all(l.data.urange(:,4)==r.data.urange(:,4)));

    assert(numel(l.data.p)==numel(r.data.p));
    for k=1:numel(l.data.p)
        assert(all(l.data.p{k}==r.data.p{k}));
    end

    assert(all(l.data.s(:)==r.data.s(:)));
    assert(all(l.data.e(:)==r.data.e(:)));
    assert(all(l.data.npix(:)==r.data.npix(:)));

    assert(all(size(l.data.pix)==size(r.data.pix)));
    bounds = 0:1000000:numel(l.data.pix);
    bounds = [bounds numel(l.data.pix)];
    disp('Data except pixels equal');
    h = waitbar(0,'Comparing pixel data...') ;
    for k=1:(numel(bounds)-1)
        idx = (bounds(k)+1):bounds(k+1);
        try
            assert(all(l.data.pix(idx)==r.data.pix(idx)));
        catch exception
            e = -10;
            while true
                try
                    assert(eqrel(l.data.pix(idx), r.data.pix(idx), 10^e));
                catch e2
                    e = e+1;
                    continue;
                end
                
                colprintf([1,0.5,0], ['Fuzzy with e=' num2str(e) '\n']);
                break;
            end
            
            e = find(~(l.data.pix(idx)==r.data.pix(idx)));
            disp('Diffs:');
            t=l.data.pix(idx);
            u=r.data.pix(idx);
            disp([t(e) u(e)]);
        end
        waitbar(k/numel(bounds));
        drawnow;
    end
    close(h);
    drawnow;

    disp('Data are equal!');
end
