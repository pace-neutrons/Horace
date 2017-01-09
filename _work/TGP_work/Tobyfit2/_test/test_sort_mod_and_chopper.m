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
carr1=[c5,c3,c2b,c1,c2a,c4];

[csort1,ix]=sort(carr1);
if ~isequal(ix',[4,5,3,2,6,1]) || ~isequal(carr1(ix),csort1)
    error('Fermi chopper sort not working')
end

% Check unique
carr2=[c5,c2b,c3,c5,c2b,c1,c4,c2a,c4];

[csort2,ix,ib]=unique(carr2);
if ~isequal(ix',[6     8     5     3     9     4]) ||...
        ~isequal(ib',[6     3     4     6     3     1     5     2     5]) ||...
        ~isequal(carr2(ix),csort2) ||...
        ~isequal(carr2,csort2(ib))
    error('Fermi chopper unique not working')
end


% Check unique in reverse
carr2=[c5,c2b,c3,c5,c2b,c1,c4,c2a,c4];

[csort2,ix,ib]=unique(carr2,'first');
if ~isequal(ix',[6     8     2     3     7     1]) ||...
        ~isequal(ib',[6     3     4     6     3     1     5     2     5]) ||...
        ~isequal(carr2(ix),csort2) ||...
        ~isequal(carr2,csort2(ib))
    error('Fermi chopper unique not working')
end



% Check moderator sorting
% -------------------------------
m1=IX_moderator(10,32,'ikcarp',[11,0,0]);
m2=IX_moderator(10,32,'ikcarp',[22,0,0]);
m3=IX_moderator(10,32,'ikcarp_param',[33,0,0]);
m4=IX_moderator(10,32,'ikcarp',[44,0,0]);

% Check sort
marr1=[m2,m2,m1,m2,m4,m2,m3,m3,m4];

[msort1,ix]=sort(marr1);
if ~isequal(ix',[3     1     2     4     6     5     9     7     8]) ||...
        ~isequal(marr1(ix),msort1)
    error('Moderator sort not working')
end



% Check unique
marr2=[m2,m2,m1,m2,m4,m2,m3,m3,m4];

[msort2,ix,ib]=unique(marr2);
if ~isequal(ix',[3     6     9     8]) ||...
        ~isequal(ib',[2     2     1     2     3     2     4     4     3]) ||...
        ~isequal(marr2(ix),msort2)||...
        ~isequal(marr2,msort2(ib))
    error('Fermi chopper unique not working')
end


% Check unique in reverse
marr2=[m2,m2,m1,m2,m4,m2,m3,m3,m4];

[msort2,ix,ib]=unique(marr2,'first');
if ~isequal(ix',[3     1     5     7]) ||...
        ~isequal(ib',[2     2     1     2     3     2     4     4     3]) ||...
        ~isequal(marr2(ix),msort2)||...
        ~isequal(marr2,msort2(ib))
    error('Fermi chopper unique not working')
end


