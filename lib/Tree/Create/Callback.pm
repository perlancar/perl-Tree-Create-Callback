package Tree::Create::Callback;

# DATE
# VERSION

use Exporter qw(import);
our @EXPORT_OK = qw(create_tree_using_callback);

sub create_tree_using_callback {
    my $callback = shift;

    # create the root node
    my $level = 0;
    my ($root, $num_children) = $callback->(undef, $level, 0);
    my @parents       = ($root);
    my @nums_children = ($num_children);
    while (@parents) {
        $level++;
        my @new_parents;
        my @new_nums_children;
        for my $i (0..$#parents) {
            my $node;
            my @children;
            for my $j (0..$nums_children[$i]-1) {
                ($node, $num_children) = $callback->($parents[$i], $level, $j);
                if ($node) {
                    # connect child to parent
                    $node->parent($parents[$i]);

                    push @children, $node;
                    push @new_parents, $node;
                    push @new_nums_children, $num_children;
                }
            }
            # connect parent to its children
            $parents[$i]->children(\@children);
        }
        @parents = @new_parents;
        @nums_children = @new_nums_children;
    }
    $root;
}

1;
# ABSTRACT: Create tree object by using a callback

=head1 SYNOPSIS

 use Tree::Create::Callback qw(create_tree_using_callback);
 use Tree::Object::Hash; # for nodes

 # create a tree of height 4 containing 1 + 2 + 4 + 8 nodes
 my $tree = create_tree_using_callback(
     sub {
         my ($parent, $level, $seniority) = @_;
         # we should return ($node, $num_children)
         return (Tree::Object::Hash->new, $level >= 3 ? 0:2);
     }
 );


=head1 DESCRIPTION

Building a tree manually can be tedious: you have to connect the parent and
the children nodes together:

 my $root = My::TreeNode->new(...);
 my $child1 = My::TreeNode->new(...);
 my $child2 = My::TreeNode->new(...);

 $root->children([$child1, $child2]);
 $child1->parent($root);
 $child2->parent($root);

 my $grandchild1 = My::Class->new(...);
 ...

This module provides a convenience function to build a tree of objects in a
single command. You supply a callback to create node and the function will
connect the parent and children nodes for you.

The callback is called with these arguments:

 ($parent, $level, $sibling_order)

where C<$parent> is the parent node object (or undef if creating the root node,
which is the first time the callback is called), C<$level> indicates the current
depth of the tree (starting from 0 for the root node, then 1 for the root's
children, then 2 for their children, and so on). You can use this argument to
know where to stop creating nodes. C<$seniority> indicates the position of the
node against its sibling (0 means the node is the first child of its parent, 1
means the second, and so on). You can use this argument to perhaps customize the
node according to its sibling order.

The callback should return a list:

 ($node, $num_children)

where C<$node> is the created node object (the object can be of any class but it
must respond to C<parent> and C<children>, see L<Role::TinyCommons::Tree::Node>
for more details on the requirement), C<$num_children> is an integer that
specifies the number of children that this node should have (0 means this node
is to be a leaf node). The children will be created when the function calls the
callback again later for each child node.


=head1 FUNCTIONS

=head2 create_tree_using_callback($cb) => obj


=head1 SEE ALSO

Other C<Tree::Create::*> modules, e.g. L<Tree::Create::Size>.

Other ways to create tree: L<Tree::FromStruct>, L<Tree::FromText>,
L<Tree::FromTextLines>.
