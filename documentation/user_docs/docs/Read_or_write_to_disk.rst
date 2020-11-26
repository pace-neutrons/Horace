#####################
Read or write to disk
#####################

read_horace, read_sqw, read_dnd
===============================

There are three functions that can be used to read sqw or d1d,d2d,...d4d data from a binary file that was written using ``save``.

::

   filename='C:\\mprogs\\myfile.dat';
   w_read=read_horace(filename);


This is the most general function, and the one that is recommended for general use. In the example shown here ``w_read`` will contain an sqw object or d1d,d2d,...d4d object depending on the contents of the file. (Here the example data file has deliberately been chosen to have an ambiguous extension. Normally you would save an object to a file with the conventional extension for the object in question: .sqw, .d1d, .d2d, .d3d, .d4d.)

::

   filename='C:\\mprogs\\myfile.sqw';
   w_read=read_sqw(filename);


In the example shown here ``w_read`` is an sqw object, since the data in ``myfile.sqw`` originated from a cut created using cut_sqw with option '-pix'.

::

   filename='C:\\mprogs\\myfile.d1d';
   w_read=read_sqw(filename);


In the example shown here ``w_read`` is an d1d object, since the data in ``myfile.d1d`` originated from a cut created using cut_sqw with option '-nopix'.

save
====

Function that applies to all dimensionalities and types of datasets.

::

   filename='C:\\mprogs\\myfile.dat';
   save(w_in,filename);


This function writes the n-dimensional dataset ``w_in`` (sqw type or d1d etc type) to a file specified by the string ``filename``.

save_xye
========

Save data in an sqw or dnd dataset to an ascii file.

::

   filename='C:\\mprogs\\my_ascii_file.txt';
   save_xye(w_in,filename);


The format of the ascii file for an n-dimensional dataset is n columns of co-ordinates along each of the axes, plus one column of signal and another column of error (variance).


head_horace, head_sqw, head_dnd
===============================

These functions return a Matlab structure containing with the header information in an sqw or dnd file.

::

   filename='C:\\mprogs\\myfile.sqw'
   h=head_horace(filename)
   hfull=head_horace(filename,'-full')


The header information is read from a binary file containing an sqw object or dnd object.

::

   filename='C:\\mprogs\\myfile.sqw'
   h=head_sqw(filename)
   hfull=head_sqw(filename,'-full')


The header information is read from a binary file containing an sqw object.

::

   filename='C:\\mprogs\\myfile.sqw'
   h=head_dnd(filename)


The header information is read from a binary file containing a dnd object. If the file contains an sqw object, then the header information that is returned is that if there was an implicit conversion of the sqw onject to a dnd object.
