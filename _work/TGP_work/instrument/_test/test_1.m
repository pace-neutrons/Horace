% Test and time sampling
n = 1e7;

x = [-5,0,5]';

disp('=== random area ===========')
bigtic
Asamp = rand(n,1);
bigtoc
disp(' ')

disp('=== Equivalent direct algorithm ===========')
bigtic
xsamp2 = rand_triangle([n,1]);
bigtoc
disp(' ')

samp2distr(xsamp2)
keep_figure

disp('=== Equivalent general class ===========')
myPDF = pdf_table(x,f);
bigtic
xsamp3 = myPDF.rand([n,1]);
bigtoc
disp(' ')

samp2distr(xsamp3)
keep_figure

disp('=== exponentiation ===========')
bigtic
v_exp = exp(Asamp);
bigtoc



