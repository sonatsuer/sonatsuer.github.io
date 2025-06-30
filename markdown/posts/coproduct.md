---
title: Coproducts of Magmas, Semigroups and Monoids
---

$\newcommand{\CC}{\mathcal{C}}$
$\newcommand{\ras}[1]{\kern-1.5ex\xrightarrow{\ \ \smash{#1}\ \ }\phantom{}\kern-1.5ex}$
$\newcommand{\ua}[1]{\bigg\uparrow\raise.5ex\rlap{\scriptstyle#1}}$
$\newcommand{\da}[1]{{\LARGE\nearrow}\rlap{\scriptstyle#1}}$

## TL;DR

While working on a personal project I needed to combine two writer monads
whose monoids were completely unrelated. A natural way of solving this problem
is to construct the coproduct of the monoids. Long story short, I ended up pushing a
small [fix](https://github.com/diagrams/monoid-extras/pull/61) to the [monoid-extras](https://hackage.haskell.org/package/monoid-extras)
package. This is a post explaining a few points about specification and
implementation of coproducts in varieties of algebras in general and monoids/semigroups
in particular. Turned out to be my biggest [déformation professionnelle](https://fr.wikipedia.org/wiki/D%C3%A9formation_professionnelle) so far. You can skip to [Implementing Coproducts](#implementing-coproducts) if you are not
interested in the theory. All the code is in this [gist](https://gist.github.com/sonatsuer/8165e7d32e8a1a91779da92fe4cd205a).

## Specifying Coproducts

We will start with the definition of coproducts. A coproduct is like smashing two burritos
into each other. Just kidding. Let $\CC$ be a category and let $O_1$ and $O_2$ be
two objects in $\CC$. The coproduct of of $O_1$ and $O_2$ consists of the following:

- A carrier object in $\CC$ denoted by $O_1\coprod O_2$,
- two morphisms in $\CC$ denoted by $\iota_i\colon O_i\to O_1\coprod O_2$ for $i=1,2$,
- for each object $T$ in $\CC$ a function $[\cdot,\cdot]\colon \CC(O_1,T)\times\CC(O_2,T)\to \CC(O_1\coprod O_2,T)$ such that the following poorly drawn diagrams commute for $i=1,2$:

$$
\begin{array}{c}
    &                       & T              \newline
    &       \da{f_i}        & \ua{[f_1,f_2]} \newline
O_i & \ras{\;\;\iota_i\;\;} & O_1\coprod O_2 \newline
\end{array}
$$

Moreover, $[f_1,f_2]$ is the unique morphism making both of the above diagrams commute. Actually, copdruct
is an initial object in the category whose objects are triples $(f_1,O,f_2)$ where $f_i\colon O_i\to O$ and
morphisms are morphisms of the ambient category which commute with the morphisms in the triple. By the usual
drill coproducts are unique if they exist, etc.

Also, note the emphasis on the ambient category. It will be important later.

## Interlude: Varieties of Algebras

The basic ideas we will use are valid for all varieties of algebras. So let us start from there.
Roughly speaking, a variety of algebras (or an equational class) is a class that can be axiomatized by universal equations
--sometimes called identities-- only. Typical examples include magmas, semigroups, monoids, groups, rings, etc. A typical
non-example is the class of fields. Note that this is an easy but nontrivial fact since having a non-equational standard
axiomatization does not automatically mean that there is no equational axiomatization.

To make the notion of axiomatization precise we need to define the notion of a language. These can be done in a more
fancy way using $F$-algebras where $F$ is an endofunctor (or even better, a monad) but I will stick to old school universal
algebra to keep things more accessible.

**Definition.** A language is a set of symbols $L$ together with a function ${\rm arity}\colon L\to\mathbb{N}$. We usually
omit ${\rm arity}$ and assume it is clear from the context. Languages are purely syntactic objects. The semantic
counterpart of a language $L$ is called an $L$-algebra and it consists of a carrier set $A$ and an interpretation
function
$$
I_s\colon A^{{\rm arity}(s)} \to A
$$
for each symbol $s$ in $L$. If the underlying $I$ is clear usually denote $I_s$ by $s$. Note that we allow $0$ as an arity here.
They correspond to functions from $A^0$ (the set with a unique element) to $A$, so they represent constants.

A few examples are in order. Let $L=\emptyset$. Then the $L$-algebras are just sets. If $L=\{c\}$ where $c$ is a constant symbol
then $L$-algebras are sets with a distinguished element. If $L=\{*\}$ where $*$ has arity $2$ then the $L$-algebras are
magmas.

Note that the class of $L$-algebras for a fixed $L$ comes equipped with a notion of a homomorphism which turns it into category.
A morphism $\varphi$ between $L$-algebras is, by definition, a function that preserves the interpretation of symbols:
$$
\varphi (f(a_1,\ldots,a_r)) = f(\varphi(a_1),\ldots,\varphi(a_r))
$$
for any $f$ in $L$ with $r={\rm arity}(f)$.

Once we have a language $L$, we can talk about terms of $L$. A term of $L$ is a finite tree of symbols from $L$ such that
if a node has symbol $s$ then it has an ordered list of child nodes of size ${\rm arity}(s)$. In practice we do not draw
the actual tree but refer to it as the parsing tree of a string with respect to an unambiguous grammar.

Note that without constant symbols we do not have any terms because finite trees have leaves and leaves can only have constant
symbols as they have no children. Also, every constant symbol is a tree consisting of a single leaf. For a more interesting
example consider $L=\{*, a, b\}$ where $*$ is binary and $a$, $b$ are nullary symbols. Then these are all terms of $L$:
$$
a,\, b,\, a* b,\, b* a,\, a*(a* b) ,\, (a* a)* b ,\, (a* b)*(a* b) ,\,
a*(a*(a*(a*(a*(a* a))))) ,\,
((((((a* a)* a)* a)* a)* a)* a)
$$

Term algebras are interesting for us because, first, they are $L$-algebras where we interpret a symbols as one of the constructors
of a tree. Actually, the term algebra of a language $L$ is the initial algebra of the category of $L$-algebras. Second, they
correspond to certain well behaved data types, namely trees. Note also that any interpretation $I$ of $L$ can be extended uniquely
to a function $\tilde{I}$ on terms of $L$ by induction.

**Definition.** Let $L$ be a language. Expand $L$ to $L[X]$ by adding a new set of constant symbols $X=\{x_0,x_1,\ldots\}$. An
equation in $L$ is a pair of $L[X]$-terms. Let $A$ be an $L$ algebra with interpretation $I$. We say that an equation $(t_1,t_2)$
holds in $A$ if for **any** interpretation $\tilde{I}$ of $L[X]$ in $A$ which is an extension of $I$, we have $\tilde{I}(t_1) = \tilde{I}(t_2)$. Given a set of equations $E$ in $L$, an $(L,E)$-algebra is an $L$-algebra in which all equations in $E$ hold. A set
of equations in a fixed language is called an equational theory. A class consisting of $L$-algebras satisfying equations in a fixed equational theory is called an equational class or a variety of algebras. Phew...

Again, a few examples are in order. We will use a more suggestive notation for equations: $t_1=t_2$ as opposed to $(t_1,t_2)$. Let $L=\{*\}$ where $*$ is binary. Let $S=\{ x_0*(x_1* x_2) = (x_0* x_1)* x_2\}$. Since this equation must
hold under all interpretations what we are doing is essentially universal quantification. So $(L,S)$-algebras are
precisely the semigroups where the underlying operation is the interpretation of $*$. We can add more axioms. For instance we
can have $CS=S\cup\{x_0* x_1 = x_1* x_0\}$. Then the $(L,CS)$-algebras are precisely the commutative semigroups.

Just like $L$-algebras, $(L,E)$-algebras form a category. Moreover, that category also have an initial object. The construction
is somewhat straightforward but it does not lend itself to an implementation in a straightforward way. Actually, in some cases,
there is simply no implementation due to decidability issues. We will come to that later.

Given a language $L$ and an $L$-algebra $A$, call a binary relation $\equiv$ on $A$ compatible if for any $f$ in $L$ of arity $r$
$$
a_1\equiv a_1',\ldots, a_r\equiv a_r' \;\text{ implies }\; f(a_1,\ldots,a_r)\equiv f(a_1',\ldots,a_r')
$$
for all $a_1,\ldots,a_r,a_1',\ldots,a_r'$ in $A$. A compatible equivalence relation is called a congruence. Here are a few
important observations about congruence relations. If $A$ is an $L$-algebra and $\equiv$ is a congruence on $A$ the the quotient
set $A/\equiv$ is also an $L$-algebra in a canonical way. To interpret a symbol $f$ in $A/\equiv$, pick representatives from the
equivalence classes of the arguments of $f$, use the interpretation of $f$ in $A$ to get an element in $A$ and finally take the equivalence class of that element. This is a well defined operation. The canonical map from $A$ to $A/\equiv$ sending an element
to its equivalence class is an $L$-algebra morphism. Actually, this gives a quotient in the category theoretic sense but we will
not need that fact.

Now we can construct initial algebras of equational theories. Given a language $L$ and a set of equations $E$ in $L$ let us first
construct the term algebra $T$ of $L$. Let $I$ be the interpretation of $L$ in $T$. On $T$, consider the following relation:
$$
R = \{(\tilde{I}(t_1), \tilde{I}(t_2))\, |\, t_1=t_2\in E,\,\tilde{I}\text{ any interpretation extending }I\}.
$$
Let $\mathbb{C}_R$ be the set of congruence relations on $T$ extending $R$. First of all $\mathbb{C}_R$ is not empty because
the relation in which everything is related to everything is in $\mathbb{C}_R$. Moreover $\mathbb{C}_R$ is closed under arbitrary intersections. This is tedious to prove but otherwise easy. Therefore $\mathbb{C}_R$ has a minimum element $\bigcap\mathbb{C}_R$
which is the smallest congruence extending R. Let us denote this congruence by $\equiv_E$. One can show that $T/\equiv_E$ is the
initial object of the category of $(L,E)$-algebras.

These ideas, even though very abstract, give us a strategy to actually implement an $(L,E)$-algebra. We can start with an initial
object in the category of $L$-algebras which we know to be possible because they are just term algebras. Then we divide by the
congruence generated by $E$ as described before. At this stage, if $\equiv_E$ is decidable then we have an implementation in the
form of a [setoid](https://ncatlab.org/nlab/show/setoid). In principle equivalence can be
undecidable. However in certain practical cases one can use tools like the Knuth-Bendix algorithm or invent an ad-hoc normal form
for terms to decide equality.

Here is a trivial example. Let $L=\{a,b\}$ where both $a$ and $b$ are nullary. First let $E$ be empty. The term algebra $T$
for $L$ is simply $\{a,b\}$ as there is no way to combine constants. Also eqaulity extends $E$ and is trivially a congruence.
Thus $\equiv_E$ is equality and $T/\equiv_E$ is $T$. There is nothing to force $a$ to be equal to $b$ and hence $a$ is not equal
to $b$ in the initial object. On the contrary if we had $E=\{a=b\}$ then $T$ would have a single element. Examples with actual function symbols are usually difficult.


## Constructing Coproducts for Varieties of Algebras

It is not difficult to prove that every variety of algebras is cocomplete. [Here](https://ncatlab.org/nlab/show/cocompleteness+of+varieties+of+algebras) is a proof. In particular
every variety has coproducts. But instead of citing a theorem we will sketch a self contained
construction which is suitable for extracting an implementation.

We will start with a model theoretic idea due to Abraham robinson which has applications beyond equational theories. Given
an $(L,E)$-algebra $A$, construct the language $L[A]$ where each element of $A$ corresponds to a new constant symbol. Now also
extend $E$ to $E[A]$ by adjoining all the equalities that hold in $A$. So, for instance, if $E$ is the theory of semigroups, then
$E[A]$ encodes the entire multiplication table for $A$. Sometimes $E[A]$ is called the (equational) diagram of $A$. Here comes
the interesting part. Let $B$ be an $(L[A], E[A])$-algebra. Then we can define a map from $A$ to $B$ by sending $a$ to the interpretation of the constant symbol $a$. This is a morphism of $L$-algebras. Conversely, if $B$ is any $L$-algebra with a
morphism $\varphi\colon A\to B$, then we can turn $B$ into an $(L[A], E[A])$-algebra by interpreting the symbol corresponding to
$a$ as $\varphi(a)$. Since $L[A]$-morhisms preserve the interpretations of constants in $A$, this gives us a characterization
of the category $L$-algebras with a morphism from $A$ (the co-slice category over $A$ if you will) as the category of
$(L[A], E[A])$-algebras. This is the novelty of Robinson's idea: algebras enriched with constants can encode morphisms.

Back to the original problem. Let $L$ be a signature and let $E$ be set of equations in $L$. Consider
two $(L,E)$-algebras $O_1$ and $O_2$. We want to construct $O_1\coprod O_2$. For simplicity we will assume that $O_1$
and $O_2$ have disjoint domains --if not, we can replace one of them by an isomorphic copy. Let $L[O_1,O_2]$ be $(L[O_1])[O_2]$
and let $E[O_1,O_2]$ be $(E[O_1])[O_2]$. Then the initial object of the category of $(L[O_1,O_2], E[O_1,O_2])$-algebras is the coproduct
of $O_1$ and $O_2$. Tadaa! I will leave the details to the reader.

## Implementing Coproducts

Finally, enter Haskell. Let us implement coproducts for a few concrete varieties of algebras.

### Magmas

Recall that a magma is just a set with a binary operation. Let $L=\{*\}$ where $*$ is binary operation symbol. Let $A$ be a magma. Since magmas do not have any properties $E[A]=\emptyset$. This means that $\equiv_{E[A]}$
is equality and the term algebra for the language $L[A]$ consists of binary trees with elements from $A$ at its leaves. To summarize,
free magmas are precisely the binary trees. There is even a Haskell [package](https://hackage.haskell.org/package/magma) for this.

Now let $A$ and $B$ be magmas. To construct $A\coprod B$, we start with the term algebra of $L[A,B]$.  Now
the term algebra for $L[A, B]$ is easy as it is just a tree. The implementation is straightforward.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
import qualified Data.Magma as M

newtype MagmaTermAlgebra a = MagmaTermAlgebra (M.BinaryTree a)
  deriving (Eq)
  deriving newtype (M.Magma)

newtype MagmaCoproduct a b = MagmaCoproduct (MagmaTermAlgebra (Either a b))
  deriving newtype (M.Magma)

magmaL :: a -> MagmaCoproduct a b
magmaL = MagmaCoproduct . MagmaTermAlgebra . M.Leaf . Left

magmaR :: b -> MagmaCoproduct a b
magmaR = MagmaCoproduct . MagmaTermAlgebra . M.Leaf . Right

-- Assuming f and g are magma morphisms
magmaCopairing :: (M.Magma c) =>
  (a -> c) -> (b -> c) -> (MagmaCoproduct a b -> c)
magmaCopairing f g (MagmaCoproduct (MagmaTermAlgebra t)) =
  M.foldMap (either f g) t
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Things become interesting when we want to talk about equality. We need to take the quotient by the smallest congruence which contains all equations coming from $A$ and $B$, namely the diagrams of $A$ and $B$. Since magmas do not have defining identities, there are
no other equations. This means that the following equalities hold in the coproduct disregarding the newtype noise:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
M.Node (Left a1) (Left a1) == M.Leaf (a1 M.<> a2)
M.Node (Right b1) (Right b2) == M.Leaf (b1 M.<> b2)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These equations determine the equivalence relation we are looking for. They also gives us a rewriting system: we can replace
terms like the ones on the left hand side with their counterparts on the right hand side which are called reduced. Note that
we can do it iteratively until all subterms are reduced. Here I mean this algorithm halts because each iteration produces a simpler
tree. The advantage of this form is that two terms are equal if and only if they are equal in the sense of the carrier tree.

So let's implement this. We need an auxiliary function since the tree catamorphism is not strong enough here. We need to be able
to do recursion on the branching shape, too.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
levelTwoCatamorphism ::
  (a -> b) ->
  (a -> a -> b) ->
  (a -> b -> b) ->
  (b -> a -> b) ->
  (b -> b -> b) ->
  M.BinaryTree a -> b
levelTwoCatamorphism leaf leaf_leaf left_node node_leaf node_node = go
  where
    go = \case
      M.Leaf a ->
        leaf a
      M.Node (M.Leaf l) (M.Leaf r) ->
        leaf_leaf l r
      M.Node (M.Leaf l) nr@(M.Node _ _) ->
        left_node l (go nr)
      M.Node nl@(M.Node _ _) (M.Leaf r) ->
        node_leaf (go nl) r
      M.Node nl@(M.Node _ _) nr@(M.Node _ _) ->
        node_node (go nl) (go nr)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

With the help of this function we can define the equality on a coproduct of magmas. Here is the implementation.
Obviously there is room for optimization here but I will not go into that here.


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
magmaCoproductNormalize ::
  (M.Magma a, M.Magma b) =>  MagmaCoproduct a b -> MagmaCoproduct a b
magmaCoproductNormalize (MagmaCoproduct (MagmaTermAlgebra t)) =
  MagmaCoproduct . MagmaTermAlgebra . normalize $ t
  where
    normalize = until normalized stepNormalize

    stepNormalizeInner l r = case (l, r) of
      (Left ll, Left rl) ->
        M.Leaf . Left $ ll M.<> rl
      (Right lr, Right rr) ->
        M.Leaf . Right $ lr M.<> rr
      (Left ll, Right rr) ->
        M.Node (M.Leaf (Left ll)) (M.Leaf (Right rr))
      (Right lr, Left ll) ->
        M.Node (M.Leaf (Right lr)) (M.Leaf (Left ll))
    stepNormalize = levelTwoCatamorphism M.Leaf stepNormalizeInner (const id) const M.Node

    innerNormalized l r = case (l, r) of
      (Left _, Left _) -> False
      (Right _, Right _) -> False
      _ -> True
    normalized = levelTwoCatamorphism (const True) innerNormalized (const id) const (&&)

instance (Eq a, Eq b, M.Magma a, M.Magma b) => Eq (MagmaCoproduct a b) where
  t1 == t2 = magmaCoproductNormalize t1 == magmaCoproductNormalize t2
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is one way of implementing coproducts. Equality is computed through normalization. The magma instance
on the coproduct is free.

A different approach is to define a different carrier data structure which does not have a
trivial magma instance but equality works automatically because only the terms in normal form are constructible.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
data Symm t1 t2 = SymmLR t1 t2 | SymmRL t2 t1
  deriving Eq

data SizeOne a b = OneL a | OneR b
  deriving Eq
data SizeAtLeastTwo a b
  = ExactlyTwo (Symm a b)
  | OnePlus (Symm (SizeOne a b) (SizeAtLeastTwo a b))
  | AtLeastTwosCombined (SizeAtLeastTwo a b) (SizeAtLeastTwo a b)
  deriving Eq

data ExactCoproductCarrier a b
  = One (SizeOne a b)
  | AtLeastTwo (SizeAtLeastTwo a b)
  deriving Eq

instance (M.Magma a, M.Magma b) => M.Magma (ExactCoproductCarrier a b) where
  x <> y = case (x, y) of
    (One t1, One t2) ->
      case (t1, t2) of
        (OneL a1, OneL a2) ->
          One $ OneL $ a1 M.<> a2
        (OneL a1, OneR b2) ->
          AtLeastTwo $ ExactlyTwo $ SymmLR a1 b2
        (OneR b1, OneL a2) ->
          AtLeastTwo $ ExactlyTwo $ SymmRL b1 a2
        (OneR b1, OneR b2) ->
          One $ OneR $ b1 M.<> b2
    (One t1, AtLeastTwo t2) ->
      AtLeastTwo $ OnePlus $ SymmLR t1 t2
    (AtLeastTwo t1, One t2) ->
      AtLeastTwo $ OnePlus $ SymmRL t1 t2
    (AtLeastTwo t1, AtLeastTwo t2) ->
      AtLeastTwo $ AtLeastTwosCombined t1 t2

magmaLExact :: a -> ExactCoproductCarrier a b
magmaLExact = One . OneL

magmaRExact :: b -> ExactCoproductCarrier a b
magmaRExact = One . OneR

copairingExact :: M.Magma c => (a -> c) -> (b -> c) -> ExactCoproductCarrier a b -> c
copairingExact f g = go
  where
    go = \ case
      One (OneL a) ->
        f a
      One (OneR b) ->
        g b
      AtLeastTwo (ExactlyTwo (SymmLR a b)) ->
        f a M.<> g b
      AtLeastTwo (ExactlyTwo (SymmRL b a)) ->
        g b M.<> f a
      AtLeastTwo (OnePlus (SymmLR t1 t2)) ->
        go (One t1) M.<> go (AtLeastTwo t2)
      AtLeastTwo (OnePlus (SymmRL t1 t2)) ->
        go (AtLeastTwo t1) M.<> go (One t2)
      AtLeastTwo (AtLeastTwosCombined t1 t2) ->
        go (AtLeastTwo t1) M.<> go (AtLeastTwo t2)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Semigroups

Let us move to semigroups. The associativity axiom essentially says that there is no need for brackets
when forming terms. This means that we can use nonempty lists to represent terms instead of binary trees.
Actually, nonempty lists act as a normal form for free monoids. When we form the coproduct of two semigroups
we can simplify two consecutive elements coming from the same semigroup. Again, lets start with the term algebra
and define equality through normalization.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
newtype SemigroupTermalgebra a = SemigroupTermalgebra (NonEmpty a)
  deriving Eq
  deriving newtype Semigroup

newtype SemigroupCoproduct a b = SemigroupCoproduct (SemigroupTermalgebra (Either a b))
  deriving newtype Semigroup

semigroupL :: a -> SemigroupCoproduct a b
semigroupL =  SemigroupCoproduct . SemigroupTermalgebra . singleton . Left

semigroupR :: b -> SemigroupCoproduct a b
semigroupR = SemigroupCoproduct . SemigroupTermalgebra . singleton . Right

semigroupCopairing :: Semigroup c => (a -> c) -> (b -> c) -> SemigroupCoproduct a b -> c
semigroupCopairing f g (SemigroupCoproduct (SemigroupTermalgebra t)) =
  foldMap1 (either f g) t

semigroupCoproductNormalize ::
  (Semigroup a, Semigroup b) => SemigroupCoproduct a b -> SemigroupCoproduct a b
semigroupCoproductNormalize (SemigroupCoproduct (SemigroupTermalgebra t)) =
  SemigroupCoproduct . SemigroupTermalgebra . normalize $ t
  where
    -- note that we can normalize a term in a single pass
    normalize = \case
      Left e1 :| Left e2 : es ->
        normalize (Left (e1 <> e2) :| es)
      Right e1 :| Right e2 : es ->
        normalize (Right (e1 <> e2) :| es)
      e1 :| es1 -> case es1 of
        e2 : es2 -> (e1 :| []) <> normalize (e2 :| es2)
        [] -> e1 :| []


instance (Eq a, Eq b, Semigroup a, Semigroup b) => Eq (SemigroupCoproduct a b) where
  t1 == t2 = semigroupCoproductNormalize t1 == semigroupCoproductNormalize t2
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

And again it is possible to define a data type which allows only normalized terms to be constructed. So we
need to define an algebraic data type which represents nonempty alternating lists.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
data LeftHead a b = SingleLeft a | LeftHeadCons a (RightHead a b)
  deriving Eq
data RightHead a b = SingleRight b | RightHeadCons b (LeftHead a b)
  deriving Eq
data Alternating a b
  = HeadOnLeft (LeftHead a b)
  | HeadOnRight (RightHead a b)
  deriving Eq

instance (Semigroup a, Semigroup b) => Semigroup (Alternating a b) where
  x <> y = case (x, y) of
    (HeadOnLeft (SingleLeft a1), HeadOnLeft (SingleLeft a2)) ->
      HeadOnLeft $ SingleLeft $ a1 <> a2
    (HeadOnLeft (SingleLeft a1), HeadOnLeft (LeftHeadCons a2 rest)) ->
      HeadOnLeft $ LeftHeadCons (a1 <> a2) rest
    (HeadOnLeft (SingleLeft a1), HeadOnRight r) ->
      HeadOnLeft $ LeftHeadCons a1 r
    (HeadOnRight (SingleRight b1), HeadOnRight (SingleRight b2)) ->
      HeadOnRight $ SingleRight $ b1 <> b2
    (HeadOnRight (SingleRight b1), HeadOnRight (RightHeadCons b2 rest)) ->
      HeadOnRight $ RightHeadCons (b1 <> b2) rest
    (HeadOnRight (SingleRight b1), HeadOnLeft l) ->
      HeadOnRight $ RightHeadCons b1 l
    (HeadOnLeft (LeftHeadCons a rest), other) ->
      HeadOnLeft (SingleLeft a) <> (HeadOnRight rest <> other)
    (HeadOnRight (RightHeadCons b rest), other) ->
      HeadOnRight (SingleRight b) <> (HeadOnLeft rest <> other)

alternatingL :: a -> Alternating a b
alternatingL = HeadOnLeft . SingleLeft

alternatingR :: b -> Alternating a b
alternatingR = HeadOnRight . SingleRight

alternatingCopairing :: Semigroup c => (a -> c) -> (b -> c) -> Alternating a b -> c
alternatingCopairing f g = go
  where
    go = \case
      HeadOnLeft (SingleLeft a) ->
        f a
      HeadOnLeft (LeftHeadCons a rest) ->
        f a <> go (HeadOnRight rest)
      HeadOnRight (SingleRight b) ->
        g b
      HeadOnRight (RightHeadCons b rest) ->
        g b <> go (HeadOnLeft rest)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Monoids

The case of monoids turns out to be slightly tricky due to the constant symbol. Again, by associativity, we can
use lists to represent term algebras for monoids. The empty list serves as the identity element. So far, so good.
However, when we form the coproduct of two monoids we hit a small detail. The normal form is _not_ just an alternating
(possibly empty) list because we need to remove the occurrences of the identity element. This also affects the
normalization algorithm. Since simplifying consecutive elements coming from the same monoid, we may create new
occurrences of the identity element. Thus, normalization cannot be done in a single pass. Also, we cannot easily
define a data type which allows only normalized terms to be constructed because we would need refinement types
to talk about non-identity elements.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
newtype MonoidTermAlgebra a = MonoidTermAlgebra [a]
  deriving Eq
  deriving newtype (Semigroup, Monoid)

newtype MonoidCoproduct a b = MonoidCoproduct (MonoidTermAlgebra (Either a b))
  deriving newtype (Semigroup, Monoid)

monoidL :: a -> MonoidCoproduct a b
monoidL = MonoidCoproduct . MonoidTermAlgebra . (:[]) . Left

monoidR :: b -> MonoidCoproduct a b
monoidR = MonoidCoproduct . MonoidTermAlgebra . (:[]) . Right

monoidCopairing :: (Monoid c) => (a -> c) -> (b -> c) -> MonoidCoproduct a b -> c
monoidCopairing f g (MonoidCoproduct (MonoidTermAlgebra t)) =
  foldMap (either f g) t

-- Note the extra Eq contrained which were not needed for semigroups
monoidCoproductNormalize ::
  (Eq a, Monoid a, Eq b, Monoid b) => MonoidCoproduct a b -> MonoidCoproduct a b
monoidCoproductNormalize (MonoidCoproduct (MonoidTermAlgebra t)) =
  MonoidCoproduct . MonoidTermAlgebra . normalize $ t
  where
    normalize = until (all nonIdentity) normalizeStep . combineNeighbors
    combineNeighbors = \case
      (Left e1:Left e2 : es) -> combineNeighbors (Left (e1 <> e2) : es)
      (Right e1:Right e2:es) -> combineNeighbors (Right (e1 <> e2) : es)
      []  -> []
      (e:es) -> e : combineNeighbors es
    normalizeStep = combineNeighbors . filter nonIdentity
    nonIdentity e = e /= Left mempty && e /= Right mempty

instance (Eq a, Monoid a, Eq b, Monoid b) => Eq (MonoidCoproduct a b) where
  t1 == t2 = monoidCoproductNormalize t1 == monoidCoproductNormalize t2
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
