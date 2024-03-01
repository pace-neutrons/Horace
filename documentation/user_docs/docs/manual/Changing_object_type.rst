####################
Changing object type
####################

sqw
===

Convert a ``dnd`` object into an n-dimensional ``sqw`` object


::

   wout_sqw = sqw(win_dnd)

.. warning::

   The pixel information has been lost in the conversion from an ``sqw`` to a
   ``dnd`` (see: :ref:`cut
   <manual/Cutting_data_of_interest_from_SQW_files_and_objects:cut>`, `dnd`_) and
   will not be recovered on converting back, leaving you with an invalid ``sqw``
   object for many operations.

dnd
===

Convert an n-dimensional ``sqw`` object into the equivalently dimensioned object
out of ``d0d``, ``d1d``, ``d2d``, ``d3d``, ``d4d`` object (i.e. throw away the
pixel information)

::

   wout_dnd = dnd(win_sqw) % Match the dimensionality of the sqw
   wout_d0d = d0d(win_sqw)
   wout_d1d = d1d(win_sqw)
   wout_d2d = d2d(win_sqw)
   wout_d3d = d3d(win_sqw)
   wout_d4d = d4d(win_sqw)
   
Alternatively:   

::

   woud_dnd = win_sqw.data % return the object with the dimensionality of sqw.

.. warning::

   It is not recommended to use e.g. ``d0d`` to extract the ``dnd`` from an
   ``sqw``. This should be done by getting the ``sqw`` object's ``data``
   property or by :ref:`cutting
   <manual/Cutting_data_of_interest_from_SQW_files_and_objects:cut>` with the
   ``'-nopix'`` option.
   



IX_datasets
===========

Convert an n-dimensional ``sqw`` / ``dnd`` object into the generic Herbert ``IX_dataset_nd``
object


::

   wout_IX = IX_dataset_1d(win_sqw)
   wout_IX = IX_dataset_2d(win_sqw)
   wout_IX = IX_dataset_3d(win_sqw)


.. warning::

   It is not possible to increase the dimensionality of a ``dnd`` object.
