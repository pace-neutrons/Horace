%% Set up for class creation
% Must have run herbert_init
% Need to run the cells below from the developer only area where aaa_copy is found

root_dir='T:\matlab\apps_devel\Herbert';

utilities_classes_dir=fullfile(root_dir,'utilities','classes');
classes_dir=fullfile(root_dir,'classes');

temp_classdefs=fullfile('templates','classdefs');
temp_methods=fullfile('templates','methods');
temp_ops=fullfile('templates','ops');

util_classdefs=fullfile(utilities_classes_dir,'classdefs');
util_methods=fullfile(utilities_classes_dir,'methods');
util_ops=fullfile(utilities_classes_dir,'ops');

%% Create sigvar
class_name='sigvar';

aaa_copy (temp_classdefs, utilities_classes_dir, class_name)
aaa_copy (temp_ops,       utilities_classes_dir, class_name)

aaa_copy (fullfile('templates','sigvar_specific','classdefs'), utilities_classes_dir, class_name)
aaa_copy (fullfile('templates','sigvar_specific','methods'  ), utilities_classes_dir, class_name)
aaa_copy (fullfile('templates','sigvar_specific','ops'      ), utilities_classes_dir, class_name)


%% Create testsigvar
class_name='testsigvar';

aaa_copy (temp_classdefs, utilities_classes_dir, class_name, 'test')
aaa_copy (temp_ops,       utilities_classes_dir, class_name, 'test', 'methods')


%% Update a class with the generic definitions
class_name='crap';

aaa_copy (temp_classdefs, classes_dir, class_name)
aaa_copy (temp_ops,       classes_dir, class_name)

%% Create a class with the generic definitions and examples
class_name='crap2';

aaa_copy (temp_classdefs, classes_dir, class_name, 'examples')
aaa_copy (temp_ops,       classes_dir, class_name, 'examples', 'methods')
