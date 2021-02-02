###################
Support and updates
###################


Support
=======

If you are having problems then your first port of call should be this wiki -- we have listed and described every function that is included in the Horace package. See :ref:`here <List_of_functions:List of functions>` for details.

In addition the Matlab function files each have detailed notes describing how the function works and what it does. To see these notes type

::

   >> help function_name


in the Matlab command window, where function_name is the name of the function you want help with. For example, type >> help gen_sqw for help on the function to generate the sqw data files. Alternatively, if the function you want help for is a method for an object class and there are other object classes which have methods with the same name, then you can get help for the particular class by typing

::

   >> help class_name/function_name


For example, the plot command is defined for several different Horace data classes, and produces different types of plot for each. To get help for the plot method specifically for objects of class d2d, type >> help d2d/plot

If you want to display the output in the Matlab help window rather than the Matlab command window, use the doc command rather than the help command:

::

   >> doc function_name


::

   >> doc class_name/function_name


If all else fails, or you find a bug in the code, then please email `Horace Help <mailto:HoraceHelp@stfc.ac.uk>`__, and one of the Horace development team will get back to you.


Updates
=======

Horace will be updated periodically as bug fixes are applied and new functionality is added. This online manual will be relevant only to the latest official release. You are strongly urged to keep your copy of Horace up to date. To this end, when you download Horace you will be asked to supply a valid email address. You will then be emailed when major new releases become available. Support will not be provided for out-of-date versions of Horace!!
