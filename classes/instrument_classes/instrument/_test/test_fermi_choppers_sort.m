function test_sort_mod_and_chopper
% Test that sorting of moderator and chopper objects is working properly

% Check Fermi chopper sorting
% -------------------------------
c1=IX_fermi_chopper(10,150,0.049,1.3,1.2,50);
c2a=IX_fermi_chopper(10,250,0.049,1.3,1.2,100);
c2b=IX_fermi_chopper(10,250,0.049,1.3,1.2,120);
c3=IX_fermi_chopper(10,350,0.049,1.3,1.2,300);
c4=IX_fermi_chopper(10,450,0.049,1.3,1.2,400);
c5=IX_fermi_chopper(10,550,0.049,1.3,1.2,350);


% Check sort
% ------------
carr1=[c5,c3,c2b,c1,c2a,c4];

bigtic
[csort1,ix]=sortObj(carr1);
if ~isequal(ix,[4,5,3,2,6,1]) || ~isequal(carr1(ix),csort1)
    error('Fermi chopper sort not working')
end
bigtoc

bigtic
[csort1,ix]=gensort(carr1);
if ~isequal(ix,[4,5,3,2,6,1]) || ~isequal(carr1(ix),csort1)
    error('Fermi chopper sort not working')
end
bigtoc


% Check sort with repetitions
% ----------------------------
carr2=[c5,c1,c2b,c1,c2b,c4];

bigtic
[csort2,ix]=sortObj(carr2);
bigtoc
if ~isequal(ix,[2,4,3,5,6,1]) || ~isequal(carr2(ix),csort2)
    error('Fermi chopper sort not working')
end

bigtic
[csort2,ix]=gensort(carr2);
bigtoc
if ~isequal(ix,[2,4,3,5,6,1]) || ~isequal(carr2(ix),csort2)
    error('Fermi chopper sort not working')
end



% Now do a really big sort
% ------------------------
nchop = 100;
carr3 = repmat(c1,nchop,1);
ei = 100+100*rand(nchop,1);
for i=1:nchop
    carr3(i).energy=ei(i);
end


bigtic
[csort3_ref,ix_ref]=sortObj(carr3);
bigtoc


bigtic
[csort3c,ix]=gensort(carr3);
bigtoc
if ~isequal(ix,ix_ref) || ~isequal(csort3c,csort3_ref)
    error('Fermi chopper sort not working')
end


bigtic
[csort3d,ix]=gensort(carr3,'resolve');  % resolves objects before sorting
bigtoc
if ~isequal(ix,ix_ref) || ~isequal(csort3d,csort3_ref)
    error('Fermi chopper sort not working')
end


% Make an array of lots of repeats to test unique
% -----------------------------------------------
carr4 = [repmat(c1,1,5),repmat(c2a,1,10),repmat(c3,1,15),repmat(c4,1,8)];
ind = randperm(numel(carr4));
carr4 = carr4(ind);

cunique4_ref = [c1,c2a,c3,c4];

% uniqueObjIndep
bigtic
[cunique4a,m4a,n4a]=uniqueObj(carr4);
bigtoc
if ~isequal(cunique4a,cunique4_ref)
    error('Fermi chopper sort not working')
end


% General method
bigtic
[cunique4b,m4b,n4b]=genunique(carr4,'resolve');
bigtoc
if ~isequal(cunique4b,cunique4_ref)
    error('Fermi chopper sort not working')
end


% Unique on identical array
% -------------------------
% Avoid just using pointers in repmat
nch = 100;
csame = repmat(IX_fermi_chopper,1,nch);
for i=1:nch
    csame(i) = IX_fermi_chopper(10,150,0.049,1.3,1.2,50);
end

bigtic
cu = uniqueObj(csame);
bigtoc
if ~isequal(cu,csame(1))
    error('Fermi chopper sort not working')
end

bigtic
cu2 = genunique(csame);
bigtoc
if ~isequal(cu2,csame(1))
    error('Fermi chopper sort not working')
end





