####################################
Converting from Horace 3 to Horace 4
####################################

Horace 4 has been a major rewrite and refactoring effort on the code
from Horace 3. This document outlines the breaking changes between
versions as well as describing a fast way to convert existing scripts
from Horace 3 to Horace 4.

Projections
-----------

In Horace 4, projections have been expanded and reworked to be
generalised for other shapes of cuts (e.g. spherical, cylindrical). As
a result, the old-style projections, e.g.:

.. code-block:: matlab

   proj1 = struct('u', [1 0 0], 'v', [0 1 0]);
   proj2 = projaxes([1 0 0], [0 1 0]);
   proj3 = ortho_proj([1 0 0], [0 1 0]);

   proj4.u = [1 0 0];
   proj4.v = [0 1 0];

have been deprecated and a warning will be issued if they are
used. For old-style projections the conversion is as simple as
replacing the ``struct``, ``projaxes`` or ``ortho_proj`` with ``line_proj``
(c.f. :ref:`projections
<manual/Cutting_data_of_interest_from_SQW_files_and_objects:Projection in more details>`).

.. code-block:: matlab

   proj1 = line_proj([1 0 0], [0 1 0]);
   proj2 = line_proj([1 0 0], [0 1 0]);
   proj3 = line_proj([1 0 0], [0 1 0]);
   proj4 = line_proj([1 0 0], [0 1 0]);

Symmetrisation
--------------

The function ``sqw.symmetrise_sqw`` has been significantly rewritten
to generalise it and allow rotational symmetry reduction. As part of
this rewrite, it now takes ``Symop`` s as arguments rather than a pair
of vectors.

To update e.g.:

.. code-block:: matlab

   symmetrised = win.symmetrise_sqw([1 0 0], [0 1 0], [1 1 1]);

it simply becomes:

.. code-block:: matlab

   symmetrised = win.symmetrise_sqw(SymopReflection([1 0 0], [0 1 0], [1 1 1]);

.. note::

   The ``SymopReflection`` can also be constructed earlier and reused:

   .. code-block:: matlab

      sym = SymopReflection([1 0 0], [0 1 0], [1 1 1]);
      symmetrised = win.symmetrise_sqw(sym);

Passing a pair of vectors will still be accepted and be internally
transformed into the correct ``Symop``, however, it is still best to
switch.

Spaghetti Plot
--------------

``qwidth`` in ``spaghetti_plot`` arguments now correctly refers to a full-width of the perpendicular
bins. This means that to achieve the same results in Horace 4 as Horace 3, a user-specified
``qwidth`` should be twice as large. Default ``qwidths`` have been updated to reflect this change.

Crystal Alignment
-----------------

Crystal alignment in Horace 4 has changed slightly in that only one
object is returned from the realignment functions. This object
contains all the data necessary for the realignment.

.. note::

   The subsequent procedure is identical to the Horace 3 procedure for using
   ``rlu_corrections``, however the object is not a plain matrix.

To convert files, it is simply a case of removing the use of the extra
arguments, e.g.:

.. code-block:: matlab

   [rlu_corr,alatt,angdeg] = refine_crystal(rlu0, alatt, angdeg, bp,'fix_angdeg','fix_alatt_ratio');

becomes:

.. code-block:: matlab

   rlu_corr = refine_crystal(rlu0, alatt, angdeg, bp,'fix_angdeg','fix_alatt_ratio');

And simply pass ``rlu_corr`` to all operations as normal.


Multifit
--------

As of Horace 4, the deprecated legacy multifit syntax (i.e. all in one
line):

.. code-block:: matlab

   [wfit, fitdata] = multifit_sqw(my_new_cut, @sr122_xsec, pars, pfree, pbind, 'list', 1);

has been fully removed. This means that trying to use this syntax will
result in an error. The modern syntax uses an object-based form which
looks like:

.. code-block:: matlab

   kk = multifit(my_new_cut);
   kk = kk.set_fun(@sr122_xsec);
   kk = kk.set_pin(pars);
   kk = kk.set_free(pfree);
   kk = kk.set_bind(pbind);
   kk = kk.set_options('listing', 1);
   [wfit, fitdata] = kk.fit();

While this would be a lot of effort to translate manually, thankfully,
Horace 4.0 comes with a function (``mf_leg_to_new``) to translate the
legacy tyle to the new format:

.. code-block:: matlab

   mf_leg_to_new("[wfit, fitdata] = multifit_sqw(my_new_cut, @sr122_xsec, pars, pfree, pbind, 'list', 1)")

   ans =

      kk = multifit(my_new_cut);
      kk = kk.set_fun(@sr122_xsec);
      kk = kk.set_pin(pars);
      kk = kk.set_free(pfree);
      kk = kk.set_bind(pbind);
      kk = kk.set_options('listing', 1);
      [wfit, fitdata] = kk.fit();

ready to be put into your code.

.. warning::

   The reason for not translating files directly is that this function
   is provided in a *caveat emptor* state and the parameters should
   be double checked to ensure they are what you expect. Any erroneous
   parameters should be reported to the developers at `Horace Help
   <mailto:HoraceHelp@stfc.ac.uk>`__

Deprecated Functions
--------------------

.. note::

   All deprecation warning IDs in horace are of the form
   ``HORACE:function:deprecated``. A complete list is below [1]_

The table below lists functions have been deprecated and their Horace 4 equivalent.

+--------------------------+--------------------+
|Old                       |New                 |
+--------------------------+--------------------+
|``projaxes``              |``line_proj``       |
+--------------------------+--------------------+
|``refine_crystal_dnd``    |``refine_crystal``  |
+--------------------------+--------------------+
|``refine_crystal_horace`` |``refine_crystal``  |
+--------------------------+--------------------+
|``refine_crystal_sqw``    |``refine_crystal``  |
+--------------------------+--------------------+
|``fake_sqw``              |``dummy_sqw``       |
+--------------------------+--------------------+
|``fake_data``             |``dummy_sqw``       |
+--------------------------+--------------------+
|``cut_sqw_sym``           |``cut``             |
+--------------------------+--------------------+
|``cut_sym``               |``cut``             |
+--------------------------+--------------------+
|``signal``                |``coordinates_calc``|
+--------------------------+--------------------+
|``symop``                 |``Symop.create``    |
+--------------------------+--------------------+
|``axes_block``            |``line_axes``       |
+--------------------------+--------------------+
|``ortho_axes``            |``line_axes``       |
+--------------------------+--------------------+
|``projaxes``              |``line_proj``       |
+--------------------------+--------------------+
|``ortho_proj``            |``line_proj``       |
+--------------------------+--------------------+
|``herbert_config``        |``hor_config``      |
+--------------------------+--------------------+

.. [1] Deprecated warnings are as follows:

   - ``HORACE:tobyfit:deprecated``
   - ``HORACE:refine_crystal:deprecated``
   - ``HORACE:fake_sqw:deprecated``
   - ``HORACE:cut_sym:deprecated``
   - ``HORACE:cut_sqw_sym:deprecated``
   - ``HORACE:signal:deprecated``
   - ``HORACE:symop:deprecated``
   - ``HORACE:axes_block:deprecated``
   - ``HORACE:ortho_axes:deprecated``
   - ``HORACE:ortho_proj:deprecated``
   - ``HORACE:projaxes:deprecated``
   - ``HORACE:spher_axes:deprecated``
   - ``HORACE:spher_proj:deprecated``
   - ``HORACE:serializable:deprecated``
   - ``HORACE:write_spe_to_sqw:deprecated``
   - ``HORACE:horace_cut_nan_inf:deprecated``
   - ``HORACE:horace_info_level:deprecated``


  To disable all deprecation warnings use the following:

  .. code-block:: matlab

     warns = [
     "HORACE:tobyfit:deprecated"
     "HORACE:refine_crystal:deprecated"
     "HORACE:fake_sqw:deprecated"
     "HORACE:cut_sym:deprecated"
     "HORACE:cut_sqw_sym:deprecated"
     "HORACE:signal:deprecated"
     "HORACE:symop:deprecated"
     "HORACE:axes_block:deprecated"
     "HORACE:ortho_axes:deprecated"
     "HORACE:ortho_proj:deprecated"
     "HORACE:projaxes:deprecated"
     "HORACE:spher_axes:deprecated"
     "HORACE:spher_proj:deprecated"
     "HORACE:serializable:deprecated"
     "HORACE:write_spe_to_sqw:deprecated"
     "HORACE:horace_cut_nan_inf:deprecated"
     "HORACE:horace_info_level:deprecated"
     ];
     for i = 1:numel(warns)
        warning('off', warns(i));
     end
