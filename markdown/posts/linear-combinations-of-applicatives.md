---
title: Linear Combinations of Applicatives
---
$\newcommand{\ras}[1]{\kern-1.5ex\xrightarrow{\ \ \smash{#1}\ \ }\phantom{}\kern-1.5ex}$
$\newcommand{\dar}[1]{\bigg\downarrow\raise.5ex{\rlap{\scriptstyle#1}}}$

## Motivation

In Haskell, we very rarely write `Functor`{.haskell} instances. The reason is that
on a given type constructor of the appropriate kind, there is at most one
`Functor`{.haskell} instance and it can be derived automatically. There is no
analog of this for `Applicatives`{.haskell}. A lot of functors support many
`Applicative`{.haskell} instances. A well known example is the list type with its
standard and zippy `Applicative`{.haskell} instances. This raises a natural question:
What are some natural ways to construct `Applicative`{.haskell} functors?

Of course this question is/was tackled by many people, for instance by Ross Peterson
in a [paper](https://www.researchgate.net/publication/262327811_Constructing_Applicative_Functors), Edward Kmett
in a Comonoad Reader [post](http://ekmett.github.io/reader/2012/abstracting-with-applicatives/index.html) and more recently by
Iceland Jack in a Reddit [post](https://www.reddit.com/r/haskell/comments/wyg656/comment/im75b4k/?context=3).
Here I will give yet another method to construct Applicatives.

If you want to skip the mathematics, you can directly jump to the Either-ish examples section.
This is where Haskell code starts. The code in that section and more --a small test suite and a
few more examples-- are available as a [gist](https://gist.github.com/sonatsuer/f535501fbc1c793a1ecde83d4ded149e).

## The Construction

From now on I will assume some familiarity with lax monoidal functors. The relation
to Haskell's `Applicative`{.haskell} class is explained, for instance,
[here](http://blog.ezyang.com/2012/08/applicative-functors/)

We will be working in the category of sets, so no domain theory will be necessary.
Let $\mathcal{M}=(M,\cdot,1)$ be a monoid. Consider a family of lax monoidal functors
$\{F_m\}_{m\in M}$. We wil identify each element $m\in M$ with the constant functor $x\mapsto\{m\}$.
Now let us define:
$$
F(x) = \sum_{m\in M} m\times F_m(x).
$$
We want to turn $F$ into a lax monoidal functor from sets to sets where the monoidal
structure is $\times$. We need a unit, that is an element
$$
\epsilon \in F(1)
$$
and a multiplication, that is a family of natural transformations
$$
\odot \colon F(x)\times F(y) \to F(x\times y)
$$
indexed by sets $x$ and $y$ satisfying certain compatibility conditions. I will
not reproduce the conditions here, you can have a look at this nLab [entry](https://ncatlab.org/nlab/show/monoidal+functor).

Let $\epsilon_n$ be the unit of $F_n$ and let $\odot_n$ be the multiplication of $F_n$. It is easy to
define a unit for $F$: Let $\epsilon = (1, \epsilon_1)$. Multiplication is a little bit more
tricky. Let $a\in F(x)$ and $b\in F(y)$. We want to define $a\odot b$. Since $F$ is a sum,
there are $m,n\in M$, $a_m\in F_m(x)$ and $b_n\in F_n(y)$ such that $a = (m, a_m)$ and $b = (n, b_n)$.
First let us choose the summand in which $a\odot b$ will fall. A very natural candidate is
$(m\cdot n)\times F_{m\cdot n}(x\times y)$. So  $a\odot b$ will be of the form
$(m\cdot n, c_{m\cdot n})$ for some $c_{m\cdot n}\in F_{m\cdot n}(x\times y)$. One way of doing that
is to push $a_m$ into $F_{m\cdot n}(x)$, $b_n$ into $F_{m\cdot n}(y)$ and then
combine them by $\odot_{m\cdot n}$. Let us give names to the functions we use to push the elements:
$$
L(m, n)\in {\rm Hom}(F_m, F_{m\cdot n}),\;\;\; R(m, n)\in (F_n, F_{m\cdot n})
$$
Here ${\rm Hom}$ is in the category of lax monoidal functors with monoidal natural transformations.
Then we can write down a formula for $\odot$ as follows:
$$
(m, a_m) \odot (n, b_n) = (m\cdot n, L(m, n)(a_m) \odot_{m\cdot n} R(m, n)(b_n))
$$

Of course we cannot choose $L$ and $R$ arbitrarily. It turns out that they need to satisfy
the equations $L(a, 1) = {\rm Id}$ and $R(1, a) = {\rm Id}$. Moreover the following diagrams
should commute:

$$
\begin{array}{c}
F_a & \ras{\;\;\;L(a,b)\;\;\;} & F_{a\cdot b} \newline
\dar{L(a, b\cdot c)} & & \dar{L(a\cdot b, c)} \newline
F_{a\cdot(b\cdot c)} & \ras{\;\;{\rm Id}\;\;} & F_{(a\cdot b)\cdot c} \newline
\end{array}
\kern5em
\begin{array}{c}
F_b & \ras{\;\;\;R(a,b)\;\;\;} & F_{a\cdot b} \newline
\dar{L(b, c)} & & \dar{L(a\cdot b, c)} \newline
F_{b\cdot c} & \ras{\;\;R(a, b\cdot c)\;\;} & F_{a\cdot b\cdot c} \newline
\end{array}
\kern5em
\begin{array}{c}
F_c & \ras{\;\;\;R(a,b)\;\;\;} & F_{b\cdot c} \newline
\dar{R(a\cdot b, c)} & & \dar{R(a, b\cdot c)} \newline
F_{(a\cdot b)\cdot c} & \ras{\;\;{\rm Id}\;\;} & F_{a\cdot (b\cdot c)} \newline
\end{array}
$$

Nice and symmetric. It looks like a categorified version of a bi-action. I will leave it
to you to find a *"It's just a blah in the category of blöh."* kind of characterization.

## Examples

I will not give an implementation of the general construction as it talks about arbitrary
type level monoids. It can be done for *some* monoids but frankly I think it is not worth the
trouble. Instead, I will give several implementations corresponding to special cases.

### List-ish Examples

Let us begin with an easy example. Consider the monoid
$\mathcal{N}_\infty = (\mathbb{N}\cup\{\infty\}, \min, \infty)$. Let
$$
\mathcal{Z}(x) = \sum_{n\in \mathcal{N}_\infty} m\times V_m(x)
$$
where $V_n(x)$ is the functor of vectors of length $n$. We view each $V_n$ as lax
monoidal functor where $\odot$ is given by 'zipping' and the unit is given by replicating.
If we define
$$
L(m,n) = R(n,m) \in {\rm Hom}(F_m, F_{\min\{m,\, n\}})
$$
by truncating then all the conditions we mentioned in the last chapter are satisfied.
The lax monoidal structure we get on $F$ is the zippy version.

One can also obtained the lax monoidal structure induced by the list monad in a similar
way. Consider the multiplicative monoid $\mathcal{N}_*=(\mathbb{N}\cup\{\infty\}, *, 1)$. Let $V_n$
be as in the previous example. Define
$$
\mathcal{L}(x) = \sum_{n\in \mathcal{N}_*} m\times V_m(x)
$$
Note that $Z$ and $L$ are isomorphic as functors but we will endow $\mathcal{L}$ with a
different lax monoidal structure. We need to define the maps $L$ and $R$. First suppose
$m$ and $n$ are finite. Define
$$
L(m, n)(v) = nv_1\smallfrown nv_2 \smallfrown\cdots\smallfrown n v_m
$$
and
$$
R(m, n)(v) = mv
$$
where $v_i$ denotes the $i$-th component of a vector, $\smallfrown$ denotes vector concatenation
and $nv$ denotes $n$ copies of $v$ concatenated. So, for instance,
$$
L(3,2)(v_1, v_2, v_3) = (v_1,v_1,v_2,v_2,v_3,v_3)
\;\;\text{ and }\;\;
R(3,4)(v_1,v_2) = (v_1,v_2,v_1,v_2,v_1,v_2)
$$

I leave the case of infinite vectors as ~~an exercise~~ a fun puzzle.

I think a remark on implementations is in order. It might be tempting to model these
functors as dependent sums --which Haskell supports to an extent-- then implement the general
construction and transfer it to regular lists. However, this is not really possible
because the list type in Haskell is *not* isomorphic to a dependent sum of fixed-length
vectors. On the dependent sum  type we can implement the `isFinite`{.haskell} predicate
simply by pattern matching. On the other hand, for lists, this would practically mean
solving the halting problem.

### Either-ish Examples

So let us move to more practical examples. First let us reduce the dependent sum
to a regular sum. Suppose the family $\{F_m\}_{m\in M}$ contains only finitely many functors,
say, $G_1,\ldots,G_k$. Then we can group the duplicated functors to obtain the following equivalent form:
$$
F(x) = \sum_{i=1}^k M_k\times G_k(x)
$$
where $M_k = \{m\in M | F_m = G_k\}$. Note that if $G_1,\ldots, G_k$ are distinct then
$M = \bigsqcup_{i=1}^k M_i$. This looks much more manageable.

For the sake of simplicity we will assume that $k=2$. So $M=M_1\sqcup M_2$ and
$$
F(x) = M_1\times G_1 + M_2\times G_2
$$
To simplify things even further we will also assume that there are $\eta_{12}\colon G_1\to G_2$
and $\eta_{21}\colon G_2\to G_1$ and the functions $L(m,n)$ and $R(m,n)$ only take identity and
these natural transformations as values. After these assumptions we can start writing code.

First let us recall the lax monoidal interface to `Applicative`{.haskell} functors. We will be
writing sample computations with this interface.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
unit :: Applicative f => f ()
unit = pure ()

(**) :: Applicative f => f a -> f b -> f (a, b)
(**) = liftA2 (,)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Since we will be working with only two functors we can define a usual sum type to represent
the functor $F$ and implement $\odot$ in this case:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
data Carrier m1 g1 m2 g2 x = L m1 (g1 x) | R m2 (g2 x)
  deriving (Eq, Show, Functor)

type (~>) f g = forall a. f a -> g a

transferBinary :: Iso' a b -> (a -> a -> a) -> b -> b -> b
transferBinary i o a1 a2 = view i $ review i a1 `o` review i a2

alignFunctors ::
  (Applicative g1, Applicative g2, Semigroup m
  ) =>
  Iso' m (Either m1 m2) ->
  (g1 ~> g2) ->
  (g2 ~> g1) ->
  (x -> y -> z) ->
  Carrier m1 g1 m2 g2 x -> Carrier m1 g1 m2 g2 y -> Carrier m1 g1 m2 g2 z
alignFunctors i eta12 eta21 o c1 c2 =
  case (c1, c2) of
    (L a1 fx, L a2 fy) ->
      case Left a1 `tro` Left a2 of
        Left a -> L a (liftA2 o fx fy)
        Right b -> R b (liftA2 o (eta12 fx) (eta12 fy))
    (L a1 fx, R b2 gy) ->
      case Left a1 `tro` Right b2 of
        Left a -> L a (liftA2 o fx (eta21 gy))
        Right b -> R b (liftA2 o (eta12 fx) gy)
    (R b1 gx, L a2 fy) ->
      case Right b1 `tro` Left a2 of
        Left a -> L a (liftA2 o (eta21 gx) fy)
        Right b -> R b (liftA2 o gx (eta12 fy))
    (R b1 gx, R b2 gy) ->
      case Right b1 `tro` Right b2 of
        Left a -> L a (liftA2 o (eta21 gx) (eta21 gy))
        Right b -> R b (liftA2 o gx gy)
  where
    tro = transferBinary i (<>)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Our first concrete example is a homemade validation `Applicative`{.haskell}.The
validation requires a semigroup to accumulate failure cases. We can complete that
to a monoid by adding a new element as an identity. Then the old elements and the new
element form a decomposition of the monoid into a disjoint union. In this way we can
define the usual [validation](https://hackage.haskell.org/package/validation) `Applicative`{.haskell} as a special case of the construction.
Here is the code:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
data AddUnit m = AddUnit_OldElement m | AddUnit_NewUnit

addUnitIso :: Iso' (AddUnit m) (Either m ())
addUnitIso = iso fromAddUnit toAddUnit
  where
    fromAddUnit = \case
      AddUnit_OldElement m -> Left m
      AddUnit_NewUnit -> Right ()
    toAddUnit = \case
      Left m -> AddUnit_OldElement m
      Right () -> AddUnit_NewUnit

instance Semigroup m => Semigroup (AddUnit m) where
  (AddUnit_OldElement x) <> (AddUnit_OldElement y) = AddUnit_OldElement (x <> y)
  AddUnit_NewUnit <> y = y
  x <> AddUnit_NewUnit = x

instance Semigroup m => Monoid (AddUnit m) where
  mempty = AddUnit_NewUnit

data ClassicalValidation m a = Failure m | Success a
  deriving(Eq, Show, Functor)

classicalValidationIso ::
  Iso' (Carrier m (Const ()) () Identity a) (ClassicalValidation m a)
classicalValidationIso = iso toClassical fromClassical
  where
    toClassical = \case
      L m _ -> Failure m
      R _ (Identity a) -> Success a
    fromClassical = \case
      Failure m -> L m (Const ())
      Success a -> R () (Identity a)

type NaturalIso f g = forall x. Iso' (f x) (g x)

transferBinarfyF :: NaturalIso f g -> (f a -> f b -> f c) -> g a -> g b -> g c
transferBinarfyF i o a1 a2 =  view i $ review i a1 `o` review i a2

instance Semigroup m => Applicative (ClassicalValidation m) where
  pure = Success
  liftA2 o x y =
    let co = alignFunctors addUnitIso undefined (pure . runIdentity) o
     in transferBinarfyF classicalValidationIso co x y

-- >>> unit :: ClassicalValidation String ()
-- Success ()

-- >>> Success 'a' ** Success 'b'
-- Success ('a','b')

-- >>> Success 'a' ** Failure "e"
-- Failure "e"

-- >>> Failure "e" ** Success 'b'
-- Failure "e"

-- >>> Failure "e1" ** Failure "e2"
-- Failure "e1e2"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let us address a few things quickly. First, there is an `undefined`{.haskell}
in the `Applicative`{.haskell} instance definition. The reason is that we never need to
go from `g1`{.haskell} to `g2`{.haskell} so undefined is never called. To see why
it is the case look at the multiplication of `AddUnit m`{.haskell}. In that monoid, multiplication
of any element with an old element (from both sides) is again an old element. In algebra we
say that the old elements form a two sided ideal.

Second, the point of this implementation is illustrating a point. If you really need an implementation
the best way is to inline/specialize the `alignFunctors`{.haskell} and eliminate the
`undefined`{.haskell}.

Now we will construct a potentially useful applicative. The idea is that if you decompose
a monoid into disjoint sets, the set containing the unit is a partial monoid. The converse
is also true. If you have a partial monoid then you can turn that into a monoid by adding
a new absorbing element. Here is an implementation with a sample partial monoid.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
class PartialMonoid pm where
  pu :: pm
  pop :: pm -> pm -> Maybe pm

data UpToThree = Zero | One | Two
  deriving (Eq, Show, Enum, Bounded)

instance PartialMonoid UpToThree where
  pu = Zero
  a1 `pop` a2 =
    let n = fromEnum a1 + fromEnum a2
     in if n > 2 then Nothing else Just $ toEnum n

data AddAbsorbing m = AddAbsorbing_OldElement m | AddAbsorbing_NewAbsorbing

addAbsorbingIso :: Iso' (AddAbsorbing m) (Either m ())
addAbsorbingIso = iso fromAddAbsorbing toAddAbsorbing
  where
    fromAddAbsorbing = \case
      AddAbsorbing_OldElement m -> Left m
      AddAbsorbing_NewAbsorbing -> Right ()
    toAddAbsorbing = \case
      Left m -> AddAbsorbing_OldElement m
      Right () -> AddAbsorbing_NewAbsorbing

instance PartialMonoid m => Semigroup (AddAbsorbing m) where
  (AddAbsorbing_OldElement x) <> (AddAbsorbing_OldElement y) =
    maybe AddAbsorbing_NewAbsorbing AddAbsorbing_OldElement (x `pop` y)
  AddAbsorbing_NewAbsorbing <> _ = AddAbsorbing_NewAbsorbing
  _ <> AddAbsorbing_NewAbsorbing = AddAbsorbing_NewAbsorbing

instance PartialMonoid m => Monoid (AddAbsorbing m) where
  mempty = AddAbsorbing_OldElement pu
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This gives us all we need to define an applicative where less than perfect
success cases can accumulate and deteriorate into an error. Probably it is well known
to a lot of people but I had never seen it before.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
data Overflow pm a = Contained pm a | Overflown
  deriving (Eq, Show, Functor)

overflowIso ::
  Iso' (Carrier pm Identity () (Const ()) a) (Overflow pm a)
overflowIso = iso toOverflow fromOverflow
  where
    toOverflow = \case
      L pm (Identity a) -> Contained pm a
      R _ _ -> Overflown
    fromOverflow = \case
      Contained pm a -> L pm (Identity a)
      Overflown -> R () (Const ())

instance PartialMonoid pm => Applicative (Overflow pm) where
  pure = Contained pu
  liftA2 o x y =
    let co = alignFunctors addAbsorbingIso (pure . runIdentity) undefined o
     in transferBinarfyF overflowIso co x y

-- >>> unit :: Overflow UpToThree ()
-- Contained Zero ()

-- >>> Contained One 'a' ** Contained One 'b'
-- Contained Two ('a','b')

-- >>> Contained One 'a' ** Contained Two 'b'
-- Overflown

-- >>> Contained One 'a' ** Overflown
-- Overflown

-- >>> Overflown ** Contained One 'a'
-- Overflown
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Again we have an `undefined`{.haskel} in the definition but this time in the
opposite direction. This time the reason is the ideal consisting of the absorbing element.

The machinery --even the version with only two functors and one lax monoidal morphism-- is
stronger than the examples above illustrate. For instance we can create an applicative which
supports overflow style failure and validation style error accumulation.
[Here](https://gist.github.com/sonatsuer/f535501fbc1c793a1ecde83d4ded149e#file-applicativeexperiments-linearcombinations-hs-L275)
is an implementation. We can even define ~~utterly useless~~ exotic variants of validation
and overflow. We can even construct an example where both lax monoidal morphisms are needed
and they are *not* inverse to each other. These are all implemented in the
[gist](https://gist.github.com/sonatsuer/f535501fbc1c793a1ecde83d4ded149e).
