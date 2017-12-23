function test_docify_system_1 (manual)
% Test the production of docified m-files
%
%   >> test_docify
%   >> test_docify (manual)
%
%   manual = true   pauses to allow use of text comparison file at key points
%          = false  skips this test (for use as part of uatomated testing procedure)
%                   In this case, only catastrophic failure causes an error.
%
% At the moment, do not have automatic comparison of input and output files, but
% instead need to use a text comparison program e.g. Examdiff Pro. To avoid this
% test failing as part of the automated tests, give argument manual as true
% Must watch the manual output to the command window too, as the comparison
% of folder contents may not reveal a failure.

% T.G.Perring

if nargin==0
    manual = false;
else
    manual = logical(manual);
end

% Initialise
rootpath = fileparts(mfilename('fullpath'));
mkgpath('meta_docs',fullfile(rootpath,'test_docify_system_1_files','docify_files'));   % define a global path

source_undocified = fullfile(rootpath,'test_docify_system_1_files','source_undocified');
source_docified = fullfile(rootpath,'test_docify_system_1_files','source_docified');

% Copy test files to temporary folder
tmpfolder = fullfile(tempdir,'test_docify');
try rmdir(tmpfolder,'s'), catch, end   % delete, if already present and if can
copyfile(source_undocified,tmpfolder,'f')


%% Docify and test
% Use ExamDiff pro at the moment to test until get a recursive test program written

if manual
    disp('--------------------------------------------------------------------------------------------')
    docify (tmpfolder,'-recursive','-list',3,'-all')
    disp(' ')
    disp('Compare the following folders with a text comparison program: they should be identical')
    disp(source_docified)
    disp(tmpfolder)
    pause
    disp(' ')
else
    docify (tmpfolder,'-recursive','-list',0,'-all')
end


%% Repeat docify to see that there is no change
% Use ExamDiff pro at the moment to test until get a recursive test program written

if manual
    disp('--------------------------------------------------------------------------------------------')
    docify (tmpfolder,'-recursive','-list',3,'-all')
    disp(' ')
    disp('Compare the following folders with a text comparison program: they should be identical')
    disp(source_docified)
    disp(tmpfolder)
else
    docify (tmpfolder,'-recursive','-list',0,'-all')
end
