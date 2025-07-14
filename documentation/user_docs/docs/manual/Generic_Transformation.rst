#######################
Generic Transformations
#######################

The previous chapters describe how one may do various  
:doc:`unary </manual/Unary_operations>` or :doc:`binary operations </manual/Binary_operations>` over your data or can build your analytical model and :doc:`simulate it over whole *sqw* file </manual/Simulation>`. 
As whole `sqw` file can not be generally placed in memory, all these operations are 
based on special `PageOp` family of algorithms, which operate loading a page of data in memory
and applying various operations to these data. For :doc:`unary </manual/Unary_operations>` and :doc:`binary </manual/Binary_operations>` operations we wrote these transformations for users and the `sqw_eval` algorithm from :doc:`Simulation</manual/Simulation>` section 
give user a set of rules to white his own model in `hklE` coordinate system and apply it to whole `sqw` object.

Generic transformations are the set of algorithms, which gives user access to the body of `PageOp` algorithm to do whatever he wants with his ``sqw`` data. As this gives user the most powerful access to modifying ``sqw`` data, it requests from user most knowledge and efforts to do useful things with these data.

``sqw_op`` algorithm
====================

