---
title: Optics and Representable Functors
---

## A Few Simple Observations

I like the existential representations of optics because they are conceptually
illuminating and allow me to play with the definitions easily without worrying
about implementation details too much. This whole post is about such a playful act
about the interaction between optics and representable functors.

My notation in this section will be a mixture of classical mathematical notation,
Haskell syntax and optic names as used in, say the [lens library](https://hackage.haskell.org/package/lens). If it it too mathy for your taste you can skip this section and move
onto implementations in Haskell. Also there is a [gist](https://gist.github.com/sonatsuer/c8fad6612a67831b745217bcf59325f0) with all the code here plus some
extra examples.

Suppose $r_1$ and $r_2$ are sets --or types, if you prefer-- representing functors
$F$ and $G$, respectively. That is, $F(a)=a^{r_1}$ and $G(a)=a^{r_2}$. Let $\cong$ denote isomorphism.
Then we have the following constructions:

 __Isomorphism  from isomorphism:__ Suppose we have an ${\rm Iso'}\,r_1\, r_2 = r_1\cong r_2$. Then
$$
F(a) \cong a^{r_1} \cong a^{r_2} \cong G(a)
$$
This gives an ${\rm Iso'}\,F(a)\,G(a)$.

__Lens from prism:__ Suppose we have a ${\rm Prism'}\,r_1\, r_2 = \exists r. r_1 \cong r + r_2$. Then
$$
F(a) \cong a^{r_1} \cong \exists r.a^{r + r_2}\cong \exists b. a^r \times a^{r_2} \cong \exists r. a^r \times G (a)
$$
This gives a ${\rm Lens'}\,F(a)\,G(a)$.

__Grate from lens:__  Suppose we have a lens ${\rm Lens'}\,r_1\, r_2 = \exists r. r_1 \cong r\times r_2$.
$$
F(a) \cong a^{r_1} \cong \exists r. a^{r \times r_2} \cong \exists r. {a^{r_2}}^r \cong \exists r. G (a) ^r
$$
This gives a ${\rm Grate'}\,F(a)\,G(a)$.

Now let us implement these constructions in Haskell!

## Isomorphism from Isomorphism

This one is kind of free and it is not really about representable functor. Still, for the
sake of completeness, I will put it here:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
transportIso ::
  ( Rep.Representable f, Rep.Rep f ~ r1
  , Rep.Representable g, Rep.Rep g ~ r2
  ) =>
  Iso' r1 r2 -> Iso (f a) (f b) (g a) (g b)
transportIso givenIso = iso fromFa toFa
  where
    fromFa fa = Rep.tabulate $ Rep.index fa . view (re givenIso)
    toFa ga = Rep.tabulate $ Rep.index ga . view givenIso
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Lens from Prism

Creating a lens from a prism is not this straightforward but still easy.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
homemadeLensFromPrism ::
  ( Rep.Representable f, Rep.Rep f ~ r1
  , Rep.Representable g, Rep.Rep g ~ r2
  ) =>
  Prism' r1 r2 -> Lens' (f a) (g a)
homemadeLensFromPrism restriction = lens getter setter
  where
    getter fa =
      Rep.tabulate $ Rep.index fa . review restriction
    setter fa ga =
      Rep.tabulate $ \r1 ->
        case preview restriction r1 of
          Nothing -> Rep.index fa r1
          Just r2 -> Rep.index ga r2
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Note that here we obtain a simple lens. The reason is that a representable functor
is a homogeneous data structure meaning that all its contents are of the same type.
It is also worth mentioning that we can implement this function using the combinator
`outside`{.haskell} from the lens library. However `outside`{.haskell} expects a
representable profunctor and in a lot of useful cases one only has a representable functor.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
repIso :: (Rep.Representable f, Rep.Rep f ~ r) => Iso (f a) (f b) (r -> a) (r -> b)
repIso = iso Rep.index Rep.tabulate

mkLensFromPrism ::
  ( Rep.Representable f, Rep.Rep f ~ r1
  , Rep.Representable g, Rep.Rep g ~ r2
  ) =>
  Prism' r1 r2 -> Lens' (f a) (g a)
mkLensFromPrism pr = repIso . outside pr . from repIso
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now let us look a few simple examples. first of all, we can recover evaluation at a point
as a lens view. As a bonus we also obtain the ability to change the value at a point.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
wrappedInIdentity ::
  ( Rep.Representable f, Rep.Rep f ~ r, Eq r
  ) =>
  r -> Lens' (f a) (Identity a)
wrappedInIdentity r =
  mkLensFromPrism $ only r

atPosition ::
  ( Rep.Representable f, Rep.Rep f ~ r, Eq r
  ) =>
  r -> Lens' (f a) a
atPosition r = wrappedInIdentity r . coerced
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is theoretically fine but practically not that interesting. Before moving on to
more practical examples I want to introduce a combinator which turns injective functions
with small domains into prisms.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
mkPrismFromInjection ::
  (Ord a, Enum b, Bounded b
  ) =>
  (b -> a) -> Prism' a b
mkPrismFromInjection create = prism' create mbRecover
  where
    mbRecover a =
      Map.lookup a $
        Map.fromList [(create b, b) | b <- universe ]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now combining this with `mkLensFromPrism`{.haskell} we obtain the following combinator:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
restrictByPositionMapping ::
  ( Rep.Representable f, Rep.Rep f ~ r1
  , Rep.Representable g, Rep.Rep g ~ r2
  , Ord r1, Enum r2, Bounded r2
  ) =>
  g r1 -> Lens' (f a) (g a)
restrictByPositionMapping positionMapping =
  mkLensFromPrism $ mkPrismFromInjection $ Rep.index positionMapping
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To see these in action, we need representable functors. So here are two examples: `Triple`{.haskell}
and `WrappedStream`{.haskell}.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
data Triple a = Triple
  { _slot0 :: a
  , _slot1 :: a
  , _slot2 :: a
  } deriving (Functor, Show)

instance Distributive Triple where
  distribute wrappedTriple = Triple a1 a2 a3
    where
      a1 = _slot0 <$> wrappedTriple
      a2 = _slot1 <$> wrappedTriple
      a3 = _slot2 <$> wrappedTriple

data Slot = Slot0 | Slot1 | Slot2
  deriving (Eq, Enum, Bounded, Show)

instance Rep.Representable Triple where
  type Rep Triple = Slot
  tabulate f =
    Triple (f Slot0) (f Slot1) (f Slot2)
  index (Triple s0 s1 s2) = \case
    Slot0 -> s0
    Slot1 -> s1
    Slot2 -> s2

-- newtype is to mostly avoid orphan instance warnings
newtype WrappedStream a = WrappedStream { getStream :: Str.Stream a}
  deriving Functor

instance Show a => Show (WrappedStream a) where
  show =
    (<>" ...") . concatMap (<>", ") . fmap show . Str.take 20 . getStream

instance Distributive WrappedStream where
  distribute = WrappedStream . Str.distribute . fmap getStream

instance Rep.Representable WrappedStream where
  type Rep WrappedStream = Natural
  tabulate f = WrappedStream $
    Str.fromList [f n | n <- [0 ..]]
  index (WrappedStream str) n =
    Str.head $ Str.drop (fromIntegral n) str

example1 :: WrappedStream Int
example1 = WrappedStream $ Str.fromList [0 ..]

example2 :: WrappedStream Int
example2 = WrappedStream $ Str.fromList [100 ..]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

...and a few lenses on these types:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
firstThree :: Lens' (WrappedStream a) (Triple a)
firstThree = restrictByPositionMapping $ Triple 0 1 2

secondThree :: Lens' (WrappedStream a) (Triple a)
secondThree = restrictByPositionMapping $ Triple 3 4 5

evens :: Lens' (WrappedStream a) (WrappedStream a)
evens = mkLensFromPrism $ prism' create mbRecover
  where
    create n = 2 * n
    mbRecover n = if even n then Just (n `div` 2) else Nothing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Finally our combinators in actions:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
-- >>> example1
-- 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,  ...

-- >>> example1 ^. atPosition 5
-- 5

-- >>> example1 & atPosition 5 .~ 77
-- 0, 1, 2, 3, 4, 77, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,  ...

-- >>> example1 ^. firstThree
-- Triple {_slot0 = 0, _slot1 = 1, _slot2 = 2}

-- >>> example1 & atPosition 4 .~ 0 & view secondThree
-- Triple {_slot0 = 3, _slot1 = 0, _slot2 = 5}

-- >>> example1 & firstThree .~ Triple 100 101 102
-- 100, 101, 102, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,  ...

-- >>> example1 & firstThree . atPosition Slot2 .~ 999
-- 0, 1, 999, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,  ...

-- >>> example2
-- 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119,  ...

-- >>> example1 ^. evens
-- 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38,  ...

-- >>> example1 & evens .~ example2
-- 100, 1, 101, 3, 102, 5, 103, 7, 104, 9, 105, 11, 106, 13, 107, 15, 108, 17, 109, 19,  ...

-- >>> example2 & evens .~ example1
-- 0, 101, 1, 103, 2, 105, 3, 107, 4, 109, 5, 111, 6, 113, 7, 115, 8, 117, 9, 119,  ...

-- >>> example1 & evens . evens . evens .~ example2
-- 100, 1, 2, 3, 4, 5, 6, 7, 101, 9, 10, 11, 12, 13, 14, 15, 102, 17, 18, 19,  ...

-- >>> example1 & evens . firstThree .~ Triple 100 101 102
-- 100, 1, 101, 3, 102, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,  ...

-- >>> example1 & evens . secondThree . atPosition Slot2 .~ 1000
-- 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1000, 11, 12, 13, 14, 15, 16, 17, 18, 19,  ...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There is also an example of a [2D Menger sponge](https://en.wikipedia.org/wiki/Menger_sponge)
in the [gist](https://gist.github.com/sonatsuer/c8fad6612a67831b745217bcf59325f0#file-lensesonrepresentables-hs-L205) implemented using `mkLensFromPrism`{.haskell}.

## Grate from Lens

Grates are not popular optics. The lens library does not have them. So I will work
with a grate representation and derive their basic properties here. Historically, the
idea of a lens comes from profunctor optics. Grates are the optics [corresponding to closed
profunctors](https://r6research.livejournal.com/28050.html). Their existential representation
is given by this isomorphism:
$$
Grate'\,s\, a = \exists i. s \cong a^i.
$$
So grates are essentially representable functors where you are not allowed to mention the
representing object directly. The standard API we obtain after eliminating the
existential quantifier of grates is a little mysterious. I will be working with this API.
If you are curious you can have a look at [this](https://oleg.fi/gists/posts/2018-12-12-find-correct-laws.html#grate) discussion about the grate API and the corresponding
laws.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
newtype GrateRep s t a b = GrateRep { unGrateRep :: ((s -> a) -> b) -> t }

type GrateRep' s a = GrateRep s s a a
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To obtain some intuition about `GrateRep`.{.haskell} let us see what we can do with it.
First of all, as the existential representation suggests, every representable functor should
give rise to a grate. Here is the implementation.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
represented :: Rep.Representable f => GrateRep (f a) (f b) a b
represented = GrateRep $
  \faab -> Rep.tabulate (\r -> faab (`Rep.index` r))
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Actually more is true. The `Distributive`{.haskell} class is essentially a Haskell-98 way
of talking about representables without the representing object. So can we make a grate
out of a `Distributive`{.haskell} functor? Yes! One can also give a direct implementation but
I will introduce double continuation as an auxiliary type to decompose `GrateRep`{.haskell}
into meaningful pieces.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
newtype DoubleCont a b s = DoubleCont { unDoubleCont :: (s -> a) -> b }
  deriving Functor

distributed :: Distributive f => GrateRep (f a) (f b) a b
distributed = GrateRep $
  \faab -> ($ id) . unDoubleCont <$> distribute (DoubleCont faab)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Note the functor instance for `Doublecont`{.haskell} made it easier to implement the grate.

Ok so we have a grate, what can we do with it? To paraphrase: If you have a homogeneous
container with fixed shape, what can you do with it without referring to its shape? As a trivial
example, we can set all the values in te container to a fixed value. Or, more generally, we
can apply the same function to all values. Maybe more interestingly, if we have two containers
of the same shape we can zip them! None of these operations refer to the shape of the container,
and they all can be implemented using the grate API:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
zipWith0 :: GrateRep s t a b -> b -> t
zipWith0 (GrateRep sabt) b =
  sabt (const b)

zipWith1 :: GrateRep s t a b -> (a -> b) -> s -> t
zipWith1 (GrateRep sabt) ab s =
  sabt $ \sa -> ab (sa s)

zipWith2 :: GrateRep s t a b -> (a -> a -> b) -> s -> s -> t
zipWith2 (GrateRep sabt) o s1 s2 =
  sabt $ \sa -> o (sa s1) (sa s2)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

I hope these examples give some insight about grates. Now back to our original
goal: To obtain a grate from a lens. I will use functor (and contravariant) instances with
respect all variables in the double continuation. However, instead of defining different
newtypes around the double continuation function and define the corresponding instances
I will do it in a single function.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
modifyDoubleCont ::
  (s1 -> s2) ->
  (a2 -> a1) ->
  (b1 -> b2) ->
  ((s1 -> a1) -> b1) ->
  ((s2 -> a2) -> b2)
modifyDoubleCont mapS contramapA mapB  =
  (. (contramapA .)) . (mapB .) . (. (. mapS))
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The definition may look horrible if you are not used to this kind of functions but there is
a simple algorithm to derive it and you can discover it easily.

And now the function `grateFromLens`{.haskell}:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
grateFromLens ::
  ( Rep.Representable f, Rep.Rep f ~ r1
  , Rep.Representable g, Rep.Rep g ~ r2
  ) =>
  Lens' r1 r2 -> GrateRep (f a) (f b) (g a) (g b)
grateFromLens lns = GrateRep $ \fagaga ->
  Rep.tabulate $
    \r1 ->
      fagaga
        & modifyDoubleCont Rep.index Rep.tabulate Rep.index
        & modifyDoubleCont id (\r1a r2 -> r1a $ lns .~ r2 $ r1) (\r2a _ -> r2a $ r1 ^. lns )
        & ($ id)
        & ($ r1)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let us see this function in action:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
decompose3 :: Iso' Natural (Natural, Slot)
decompose3 = iso fromN toN
  where
    fromN n = (n `div` 3, remainderAsSlot $ n `mod` 3)
    toN (n, slot) =
      3 * n + slotAsRemainder slot
    slotAsRemainder = \case
      Slot0 -> 0
      Slot1 -> 1
      Slot2 -> 2
    remainderAsSlot n
      | n == 0    = Slot0
      | n == 1    = Slot1
      | otherwise = Slot2

divideBy3 :: Lens' Natural Natural
divideBy3 = decompose3 . _1

remainderBy3 :: Lens' Natural Slot
remainderBy3 = decompose3 . _2

divideBy3Grate :: GrateRep (WrappedStream a) (WrappedStream b) (WrappedStream a) (WrappedStream b)
divideBy3Grate = grateFromLens divideBy3

remainderBy3Grate :: GrateRep (WrappedStream a) (WrappedStream b) (Triple a) (Triple b)
remainderBy3Grate = grateFromLens remainderBy3

-- first three examples give you the usual zip.
-- >>> zipWith2 represented (+) example1 example2
-- 100, 102, 104, 106, 108, 110, 112, 114, 116, 118, 120, 122, 124, 126, 128, 130, 132, 134, 136, 138,  ...

-- >>> zipWith2 divideBy3Grate (zipWith2 represented (+)) example1 example2
-- 100, 102, 104, 106, 108, 110, 112, 114, 116, 118, 120, 122, 124, 126, 128, 130, 132, 134, 136, 138,  ...

-- >>> zipWith2 remainderBy3Grate (zipWith2 represented (+)) example1 example2
-- 100, 102, 104, 106, 108, 110, 112, 114, 116, 118, 120, 122, 124, 126, 128, 130, 132, 134, 136, 138,  ...

-- These are more interesting

liftWrapped2 ::
  (Str.Stream a -> Str.Stream a -> Str.Stream a) ->
  WrappedStream a -> WrappedStream a -> WrappedStream a
liftWrapped2 binaryOp w1 w2 = WrappedStream $ on binaryOp getStream w1 w2

-- >>> liftWrapped2 Str.interleave example1 example2
-- 0, 100, 1, 101, 2, 102, 3, 103, 4, 104, 5, 105, 6, 106, 7, 107, 8, 108, 9, 109,  ...

-- >>> zipWith2 divideBy3Grate (liftWrapped2 Str.interleave) example1 example2
-- 0, 1, 2, 100, 101, 102, 3, 4, 5, 103, 104, 105, 6, 7, 8, 106, 107, 108, 9, 10,  ...

pickAlternating :: Str.Stream a -> Str.Stream a -> Str.Stream a
pickAlternating str1 str2 = Str.zip3 str1 str2 (Str.fromList [0 :: Int ..]) <&>
  \(a, b, n) -> if even n then a else b

-- >>> liftWrapped2 pickAlternating example1 example2
-- 0, 101, 2, 103, 4, 105, 6, 107, 8, 109, 10, 111, 12, 113, 14, 115, 16, 117, 18, 119,  ...

-- >>> zipWith2 divideBy3Grate (liftWrapped2 pickAlternating) example1 example2
-- 0, 1, 2, 103, 104, 105, 6, 7, 8, 109, 110, 111, 12, 13, 14, 115, 116, 117, 18, 19,  ...

crissCross :: Str.Stream a -> Str.Stream a -> Str.Stream a
crissCross (Str.Cons _x1 (Str.Cons y1 rest1)) (Str.Cons x2 (Str.Cons _y2 rest2)) =
  y1 Str.<:> x2 Str.<:> crissCross rest1 rest2

-- >>> liftWrapped2 crissCross example1 example2
-- 1, 100, 3, 102, 5, 104, 7, 106, 9, 108, 11, 110, 13, 112, 15, 114, 17, 116, 19, 118,  ...

-- >>> zipWith2 divideBy3Grate (liftWrapped2 crissCross) example1 example2
-- 3, 4, 5, 100, 101, 102, 9, 10, 11, 106, 107, 108, 15, 16, 17, 112, 113, 114, 21, 22,  ...

shiftByEndo ::
  ( Rep.Representable f
  , Rep.Rep f ~ r
  ) =>
  Endo r -> (a -> a -> b) -> f a -> f a -> f b
shiftByEndo (Endo endo) binaryOp fa1 =
  zipWith2 represented binaryOp (Rep.tabulate $ Rep.index fa1 . endo)

swapNeightbors :: Endo Natural
swapNeightbors = Endo $ \n -> if even n then n + 1 else n - 1

-- >>> zipWith2 divideBy3Grate (shiftByEndo swapNeightbors (+)) example1 example2
-- 103, 105, 107, 103, 105, 107, 115, 117, 119, 115, 117, 119, 127, 129, 131, 127, 129, 131, 139, 141,  ...

-- >>> zipWith2 remainderBy3Grate (shiftByEndo (Endo id) (+)) example1 example2
-- 100, 102, 104, 106, 108, 110, 112, 114, 116, 118, 120, 122, 124, 126, 128, 130, 132, 134, 136, 138,  ...

-- >>> zipWith2 remainderBy3Grate (shiftByEndo (Endo $ const Slot0) (+)) example1 example2
-- 100, 101, 102, 106, 107, 108, 112, 113, 114, 118, 119, 120, 124, 125, 126, 130, 131, 132, 136, 137,  ...

-- >>> zipWith2 remainderBy3Grate (shiftByEndo (Endo $ const Slot1) (+)) example1 example2
-- 101, 102, 103, 107, 108, 109, 113, 114, 115, 119, 120, 121, 125, 126, 127, 131, 132, 133, 137, 138,  ...

rotateSlot :: Slot -> Slot
rotateSlot = \case
  Slot0 -> Slot1
  Slot1 -> Slot2
  Slot2 -> Slot0

-- >>> zipWith2 remainderBy3Grate (shiftByEndo (Endo rotateSlot) (+)) example1 example2
-- 101, 103, 102, 107, 109, 108, 113, 115, 114, 119, 121, 120, 125, 127, 126, 131, 133, 132, 137, 139,  ...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

I think this is enough.
