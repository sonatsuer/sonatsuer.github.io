---
title: Making Prisms out of Predicates with Liquid Haskell
---
## TL;DR

An attempt to fix a few unlawful isos turns into a modest showcase of some undocumented features
of Liquid Haskell and a low-key rant about how undocumented they are.

## Unlawful Isos in the Lens Library

Consider the iso [`non`](https://hackage.haskell.org/package/lens-5.2.3/docs/Control-Lens-Iso.html#v:non) from the lens library in Haskell:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
non :: Eq a => a -> Iso' (Maybe a) a
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

One immediately sees that this cannot be lawful as the number of inhabitants for `a`{.haskell} and `Maybe a`{.haskell} are different for a finite type `a`{.haskell}. We can also write down an explicit counterexample to the isomorphism laws:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
nonzero :: Iso' (Maybe Int) Int
nonzero = non 0

-- >>> Just 0 ^. nonzero . from nonzero
-- Nothing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The result should have been `Just 0`{.haskell}.

The documentation says that `non x`{.haskell} is actually an isomorphism between `Maybe a`{.haskell} and `a`{.haskell} sans `v`{.haskell}. There is a similar remark about [`anon`](https://hackage.haskell.org/package/lens-5.2.3/docs/Control-Lens-Iso.html#v:anon) saying that it is not lawful.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
anon :: a -> (a -> Bool) -> Iso' (Maybe a) a
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Can we fix the situation? Or at least can we improve it? It turns out that the answer is yes.
First let us to make two observations:

- each predicate defines a _refinement type_,
- compared to isomorphisms, prisms are more appropriate to express the relation between a type and a refinement of it.

As an example, our `nonzero`{.haskell} should be a prism from integers to nonzero integers. So how do we implement it? There are at least two methods.

## Refinements via Smart Constructors

We can model refinements as `newtype`s and do something like this:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
newtype Nonzero = Nonzero Int

homemadeNonzero :: Prism' Int Nonzero
homemadeNonzero = prism' create mbRecover
  where
    create (Nonzero n) = n
    mbRecover n = if n == 0 then Nothing else Just (Nonzero n)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This works but it is ad-hoc and not really extensible. Luckily there is a Haskell library called [Refined](https://hackage.haskell.org/package/refined) which is based on this approach and it comes with all sorts of auxiliary functions. With that library we can do this:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
{-# LANGUAGE DataKinds #-}
module PredicatePlay where

import Relude
import qualified Refined as R
import Control.Lens

storeBoughtNonzero :: Prism' Int (R.Refined (R.Not (R.EqualTo 0)) Int)
storeBoughtNonzero = prism' create mbRecover
  where
    create = R.unrefine
    mbRecover = rightToMaybe . R.refine
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By using the `Predicate`{.haskell} typeclass provided by the library we can define a polymorphic prism which works for all predicates.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
predicatePrism :: R.Predicate p x => Prism' x (R.Refined p x)
predicatePrism = prism' create mbRecover
  where
    create = R.unrefine
    mbRecover = rightToMaybe . R.refine
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Jolly good! Now let's do it again but this time in [Liquid Haskell!](https://ucsd-progsys.github.io/liquidhaskell/)

## Liquid Haskell

It is very easy to define refinement types in Liquid Haskell so we can use the definition of the nonzero prism almost verbatim.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
{-@ type Nonzero = { v:Int | v /= 0 } @-}

{-@ liquidNonzero :: Prism' Int Nonzero @-}
liquidNonzero :: Prism' Int Int
liquidNonzero = prism' create mbRecover
  where
    create n = n
    mbRecover n = if n == 0 then Nothing else Just n
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

However, if we want to use this prism we get into problems immediately. For instance

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
{-@ nonzeroPreview :: Int -> Maybe Nonzero @-}
nonzeroPreview :: Int -> Maybe Int
nonzeroPreview = preview liquidNonzero
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

is rejected by Liquid Haskell because Liquid Haskell has no way of knowing what the `preview`{.haskell} function does. So we need to explain it to Liquid Haskell. The problem is that `preview`{.haskell} is polymorphic and we cannot force it to be monomorphic by adding a Liquid Haskell signature. The
solution relies on the notion of [abstract refinement](https://ranjitjhala.github.io/static/abstract_refinement_types.pdf) which is an under documented feature of Liquid Haskell.
Abstract refinements basically allow us to quantify over predicates. So the following signature solves our problem:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
{-@ preview :: forall <p :: a -> Bool>.
               MonadReader s m => Getting (First a) s a<p> -> m (Maybe a<p>) @-}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here `p` denotes a predicate on `a` which is just a Boolean valued function on `a`. The
syntax `a<p>` denotes `a` refined by `p`. So we basically say that for any predicate `p`,
if you _get_ a value from a getter for a type refined by a predicate `p`, then the value you get
also satisfies the predicate `p`.

We can do a similar thing for `review`{.haskell}:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
{-@ review :: forall <p :: b -> Bool>.
              MonadReader b<p> m => AReview t b<p> -> m t @-}

{-@ nonzeroReview :: Nonzero -> Int @-}
nonzeroReview :: Int -> Int
nonzeroReview = review liquidNonzero
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After this definition the following code is rightfully rejected by Liquid Haskell:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
notOk :: Int
notOk = nonzeroReview 0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

and this one is accepted:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
ok :: Int
ok = nonzeroReview 1
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is nice, but very monomorphic. Ideally we want something like the `predicatePrism`{.haskell}
function from the previous section. In `predicatePrism`{.haskell} we use the typeclass mechanism
to pass a predicate to the function which means that we still need to define each instance for this typeclass by hand. In Liquid Haskell, we can use a generic predicate and solve the problem in
one place by using another under documented feature, namely [bounded refinements](https://arxiv.org/abs/1507.00385). Essentially, what we want to do is to give a Liquid Haskell type to the function

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
mkPreviewFromPredicate :: (a -> Bool) -> a -> Maybe a
mkPreviewFromPredicate pred a = if pred a then Just a else Nothing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The problem is that value level predicates and type level predicates are distinct objects and we
need to relate them somehow. The solution is already present in the bounded refinements paper I
linked above. The idea is to use a *witness* bound.

Let `p :: a -> Bool`{.haskell} be a predicate in the sense of Liquid Haskell. A witness for `p`{.haskell} is a family of predicates on `Bool`{.haskell} parametrized by `a`{.haskell}, that is
a Liquid Haskell type level function `w :: a -> Bool -> Bool`, which satisfies the following
property:

> for an `x`{.haskell} of type `a`{.haskell} and boolean value `b`{.haskell}, if `b`{.haskell}
> and `w x b` hold then `p x` holds.

Let us abbreviate this to `bound Witness p w` following the paper. Now something like this
should work:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
mkPreviewFromPredicate :: forall <p :: a -> Bool, w :: a -> Bool -> Bool>
                          { bound Witness p w }
                          (x:a -> Bool<w x>) -> a -> Maybe a<p>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Note that the `x:a -> Bool<w x>`{.haskell} captures `pred`{.haskell} using `w`{.haskell}
at value `x`{.haskell} and by the definition of the `Witness`{.haskell} bound we --and
more importantly the underlying SMT solver-- can infer that `x`{.haskell} must satisfy the
Liquid Haskell predicate `p`{.haskell}. Nice!

Well, not really. Because this is not valid Liquid Haskell. Actually Liquid Haskell does not
have first class refined predicates. What we can do is to translate the `Witness`{.haskell}
bound to a subtyping judgement which Liquid Haskell supports, but doesn't mention in documents.
I found about it while reading the actual source code. So here is the final version:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
{-@ mkPreviewFromPredicate ::
      forall <p :: a -> Bool, w :: a -> Bool -> Bool>.
      {y :: a, b :: {v:Bool<w y> | v} |- {v:a | v == y} <: a<p>}
      (x:a -> Bool<w x>) -> a -> Maybe a<p> @-}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are two new symbols here. First one is `|-`{.haskell} (or in LaTeX $\vdash$). This
is the entailment symbol. Basically it means that in the environment expressed on the
left-hand-side the conclusion on the right-hand-side holds. For its precise meaning in
this context you can refer to the bounded predicates paper.

The other symbol is `<:`{.haskell} which stands for subtyping. Note that `{v:a | v == y} <: a<p>`{.haskell} is an indirect way of saying that `y`{.haskell} satisfies `p`{.haskell}. So this is
basically an encoding trick.

Now we can use `mkPreviewFromPredicate`{.haskell} to define prisms directly from predicates:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
{-@ liquidNonzero2 :: Prism' Int Nonzero @-}
liquidNonzero2 :: Prism' Int Int
liquidNonzero2 = prism' id $ mkPreviewFromPredicate (/=0)

{-@ type Positive = { v:Int | v > 0 } @-}
{-@ liquidPositive :: Prism' Int Positive @-}
liquidPositive :: Prism' Int Int
liquidPositive = prism' id $ mkPreviewFromPredicate (>0)

-- etc...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Whew...

## Conclusion

Of course the problem of 'fixing' unlawful isos is a pet peeve. However, it turned out to be
a good opportunity to learn a few things.

The [Refined](https://hackage.haskell.org/package/refined) library seems useful if you do not need to carry out type-level proofs. The library
does provide some proof combinators like [Not](https://hackage.haskell.org/package/refined-0.8.1/docs/Refined.html#t:Not),
[And](https://hackage.haskell.org/package/refined-0.8.1/docs/Refined.html#t:And) etc.
However it seems propositions like _even if and only if not odd_ are out of scope.

Liquid Haskell turned out to be much more painful then I thought it would be. I am not talking
about the need to provide signatures for `review`{.haskell} and `preview`{.haskell}. This is something you expect with preexisting library code as in the case of, say, [vectors](https://github.com/ucsd-progsys/liquidhaskell/blob/develop/liquid-vector/src/Data/Vector_LHAssumptions.hs). I am
talking about lack of documentation. When I started writing this post I was not aware of
abstract refinements or bounded refinements even though I had gone over the [official tutorial](https://ucsd-progsys.github.io/intro-refinement-types/120/) which claims to be complete.
Also error messages generated by liquid haskell were less than satisfactory. Here is an example:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
{-@ myMap :: forall <p :: b -> Bool>. (f: a -> b<p>) -> [a] -> [{v:b | p v}] @-}
myMap :: (a -> b) -> [a] -> [b]
myMap f [] = []
myMap f (x:xs) = f x : myMap f xs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is rejected by the following error message:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
 -- /home/sonat/Documents/haskell/liquid/nix-liquid/src/Experiment.hs:51:14: Error: Bad Type Specification
-- Experiment.myMap :: (a -> {VV : b | true}) -> [a] -> [{VV : b | p VV}]
--     Sort Error in Refinement: {VV : b_a4On | p VV}
--     The sort (Pred  b_a4On) is not a function with at least 1 arguments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

I see three obvious problems in this message: The notion of sort is not defined in the official
documentation, the message is expressed in terms of names generated by Liquid Haskell and
there is no indication about the location of the problem. By the way, the correct signature is
as follows:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
{-@ myMap :: forall <p :: b -> Bool>. (f: a -> b<p>) -> [a] -> [b<p>] @-}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is another example. Not even line numbers are present. I have no idea what 17, 20 and 21 stand for.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
-- :1:1-1:1: Error
--   Constraint with free vars
--   17
--   [p]
--   Try using the --prune-unsorted flag
-- :1:1-1:1: Error
--   Constraint with free vars
--   20
--   [p]
--   Try using the --prune-unsorted flag
-- :1:1-1:1: Error
--   Constraint with free vars
--   21
--   [p]
--   Try using the --prune-unsorted flag
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Overall, Liquid Haskell feels more academic than practical, especially if you try to do
something slightly original compared to the standard examples. My conclusion is that Liquid Haskell is a strong tool with great potential but developer experience leaves much to be desired, pushing
the developer towards cargo cult programming.
