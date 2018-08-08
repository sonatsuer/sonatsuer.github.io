---
layout: post
title: Monoid Homomorphisms (Part 2 of 2)
categories:
- higher-algebra
---
# Applicatives As Monoid Homomorphisms
In the last post I mentioned that a monoidal structure is actually a categorification of the notion of a monoid. In accordance with the main theme of these posts, we should ask the following question: What is a homomorphism between monoidal structures?

Let us take two monoidal categories \\(\mathcal{C}\\) and \\(\mathcal{D}\\). The naive definition of a homomorphism of monoidal structures from \\(\mathcal{C}\\) to \\(\mathcal{D}\\) is a functor \\(F:\mathcal{C}\to\mathcal{D}\\) satisfying \\(F(1)=1\\) and \\(F(a\otimes b) = F(a)\otimes F(b)\\). The problem here is that two things are *very rarely* equal. In a categorical concept, the relevant concept is isomorphism. However, even isomorphism can be a too strong requirement. Existence of a morphism is often enough to obtain a useful concept. Here is the weakened version of a monoidal homomorphism, also know as a lax monoidal functor: a functor \\(F:\mathcal{C}\to\mathcal{D}\\) is called a lax monoidal functor if there are a morphism \\(\epsilon : 1 \to F(1)\\) and a natural transformation \\(\mu_{x,y}: F(a)\otimes F(b) \to F(a\otimes b)\\), of course, with respect to some coherence conditions. You may have a look at [nLab](https://ncatlab.org/nlab/show/monoidal+functor) for the full definition. One can also define co-lax monoidal functors by reversing the arrows.

I will give one obscure and one famous example from Haskell. The obscure example is the *Decisive* typeclass that I have seen only once. Decisive functors are co-lax monoidal (endo)functors with respect to the sum. The other is, as you can guess from the title of this subsection, the Applicative typecalss. I will not go into the details as it is well documented, say, in [Typeclassopedia](https://wiki.haskell.org/Typeclassopedia#Alternative_formulation).

So what? The api given by directly translating the definition is awkward as opposed the standard api which lets you do things like
```haskell
curriedFunctionWithManyInputs <$> a <*> b <*> c <*> d <*> e <*> f <*> g
```

What did we gain here? The point is that your relationship with code is not limited to *typing* it. Occasionally, you find yourself reasoning about code or even imagining code, possibly in an imaginary language! To know that applicative functors are actually homomorphisms offers the kind of wisdom you need when you are not necessarily in front of a keyboard. For instance, we have monad transformers but we do not have applicative transformers because the composition of applicative functors is already applicative, drum roll here, because composition of structure preserving maps is again structure preserving.

# Homomorphisms of Applicatives
> Day convolution is just the categorification of the notion of a convolution on a free \\(R\\)-algebra on a monoid where \\(R\\) is a commutative unital ring, what's the problem?

Well, at this point, I could vomit my *déformation professionnelle* in your general direction to explain what that means... But I won't, at least not in this post. I will only say that there is a general way of viewing lax monoidal functors as monoid objects in a monoidal category where Day convolution gives the underlying monoidal structure. I will also practice something I do not usually preach: I will work with an implementation of Day convolution in Haskell instead of working with the specification.

I will borrow the definitions/implementations from [Data.Functor.Day](https://hackage.haskell.org/package/contravariant-0.6.1/docs/Data-Functor-Day.html) with minor modifications.
```haskell
type (~>) f g = forall x . f x -> g x

data Day f g x = forall a b . Day (f a) (g b) (a -> b -> x)

-- The identity is the identity functor
-- This corresponds to the 'multiplication' of the monoidal structure.
dap :: Applicative f => Day f f ~> f
dap (Day fa fb op) = liftA2 op fa fb

-- These functions are used to map over components.
trans1 :: (f ~> g) -> Day f h ~> Day g h
trans1 fg (Day fb hc op) = Day (fg fb) hc op

trans2 :: (g ~> h) -> Day f g ~> Day f h
trans2 gh (Day fb gc op) = Day fb (gh gc) op

transBoth :: (f1 ~> f2) -> (g1 ~> g2) -> Day f1 g1 ~> Day f2 g2
transBoth morph1 morph22 = trans1 morph1 . trans2 morph2
```

Now suppose `f` and `g` are two applicative functors (viewed as monoid objects) and
```haskell
morph :: f ~> g
```
is a homomorpism from `f` to `g`. Then we must have
```haskell
  dap $ transBoth morph morph $ Day fa fb op
= morph $ dap $ Day fa fb op
```
Simplifying yields
```haskell
  liftA2 op (morph fa) (morph fb)
= morph $ liftA2 op fa fb
```
Since this holds for any `op`, it also holds for `(,)`. So we get the even simpler form
```haskell
  liftA2 (,) (morph fa) (morph fb)
= morph $ liftA2 (,) fa fb
```
Note that we can actually recover the previous equation by mapping `uncurry op` to both sides. So we can use the last equation together with
```haskell
morph . pure = pure
```
to define applicative-viewed-as-a-monoid homomorphisms. This is a little bit disappointing because we just reinvented the notion of a monoidal natural transformation. On the other hand we learned that monoidal natural transformations can be seen as monoid object morphisms. This is a neat fact and it allows us, for instance, to transfer homomorphism related concepts to applicative functors. Cayley representation is one of them. Have a look at *Notions of Computation as Monoids* by Rivas and Jaskelioff for details.

Let us look at a few concrete examples. Let `f` be `Maybe` and `g` be `[]`. Consider `maybeToList` from the first part. I claim that `maybetoList` is an applicative homomorphism. Clearly
```haskell
maybeToList $ pure x = maybeToList $ Just x = [x] = pure x
```
We also need to verify the following equality:
```haskell
  liftA2 (,) (maybeToList fa) (maybeToList fb)
= maybeToList $ liftA2 (,) fa fb
```
where `fa :: Maybe a` and `fb :: Maybe b`. If at least one of `fa` or `fb` is `Nothing` then both sides are `[]`. If `fa = Just x` and `fb = Just y` then both sides are equal to `[(x, y)]`. This finishes our little proof.

Actually something more general is going on here. Recall that `maybetoList` is also a monad homomorphism and our applicatives are induced by monad instances. So it is very natural to conjecture that all monad homomorphisms are also applicative homomorphisms with respect to the induced applicative structures. So let us prove this conjecture.

Let `m` and `n` be monads and let `morh :: m ~> n` be a monad homomorphism. Then `morph . pure = pure` as `return = pure`. The other equality we need to prove turns into the following one
```haskell
  liftM2 (,) (morph ma) (morph mb)
= morph $ liftM2 (,) ma mb
```
as `liftA2 = liftM2`. We know that
```haskell
liftM2 f mx my = mx >>= (\x -> (my >>= \y -> return $ f x y))
```
Since `morph` is a monad homomorphism we have
```haskell
morph (x >>= f) = morph x >>= morph . f
```
Now combining these two we get
```haskell
  morph $ liftM2 (,) ma mb
= morph $ ma >>= (\a -> (mb >>= \b -> return (a, b)))
= morph ma >>= morph . (\a -> (mb >>= \b -> return (a, b)))
= morph ma >>= (\a -> morph (mb >>= \b -> return (a, b)))
= morph ma >>= (\a -> (morph mb >>= morph . (\b -> return (a, b))))
= morph ma >>= (\a -> (morph mb >>= \b -> morph $ return (a, b)))
= morph ma >>= (\a -> (morph mb >>= \b -> morph . return $ (a, b)))
= morph ma >>= (\a -> (morph mb >>= \b -> return (a, b)))
= liftM2 (,) (morph ma) (morph mb)
```
which proves that `morph` is also an applicative homomorphism.

We may also conjecture that any applicative homomorphism between monads is also a monad homomorphism but it is not true! Recall from the first part that `listToMaybe` is not a monad homomorphism. We will now show that it is actually an applicative homomorphism. The only nontrivial equation to check is the following:
```haskell
  liftA2 (,) (listToMaybe fa) (listToMaybe fb)
= listToMaybe $ liftA2 (,) fa fb
```
where `fa :: [a]` and `fb :: [b]`. If at least one of `fa` or `fb` is `[]` then both sides are `Nothing`. If `fa = x : xs` and `fb = y : ys` then both sides are equal to `Just (x, y)`.

Of course there are other examples of applicative homomorphisms, for instance `retractAp`, `hoistAp t` and `runAp t` from [Control.Applicative.Free](http://hackage.haskell.org/package/free-5.1/docs/Control-Applicative-Free.html), though they are called monoidal natural transformations in the documentation.

# One More Examples of an Applicative Homomorphism

Note that in `hoistAp t` and `runAp t` there is no restriction on `t` other than being a natural transformation. This may look odd, but really it is not because `Ap` is the free part of a free-forgetful adjunction and if you are on the *forgotten* side of it, any natural transformation is a morphism as there is no structure to preserve. In general, though, such effortless theorems are rare. If you want to prove something you need to assume something. I want to give an example which depends on an algebraic assumption.

I will use the `Validation` typeclass from [Data.Validation](http://hackage.haskell.org/package/validation-1/docs/Data-Validation.html). Let me copy the relevant parts of the library here.
```haskell
data Validation err a
  = Failure err
  | Success a

instance Semigroup err => Applicative (Validation err a) where
  pure = Success
  Failure e1 <*> Failure e2 = Failure (e1 <> e2)
  Failure e <*> Success _ = Failure e
  Success _ <*> Failure e = Failure e
  Success f <*> Success x = Success (f x)
```

As you can see, this is very much like `Either` but the errors are accumulated using the semigroup structure as opposed to `Either` which only keeps the first error. One nice thing about the `Validation` is that its applicative instance is almost never induced by a monad instance.

Now suppose that you want to change the error type you want from, say, `err1` to `err2` using a function `convert :: err1 -> err2`. We can implement this easily by
```haskell
changeErr :: (err1 -> err2) -> Validation err1 a -> Validation err2 a
changeErr convert (Failure e) = Failure $ convert e
changeErr _ (Success x) = Success x
```
Now comes the interesting question: When is `changeErr` an applicative homomorphism? Obviously
```haskell
changeErr convert $ pure x = Success x = pure x
```
So we need to check
```haskell
  liftA2 (,) (changeErr convert $ fa) (changeErr convert $ fb)
= changeErr convert $ liftA2 (,) fa fb
```
where `fa :: Validation err1 a` and `fb :: Validation err2 b`. The proof is going to be a little boring because I will look at all four possible cases.
```haskell
  liftA2 (,) (changeErr convert $ Success x) (changeErr convert $ Success y)
= liftA2 (,) (Success x) (Success y)
= Success (x, y)
= changeErr convert $ Success (x, y)
= changeErr convert $ liftA2 (,) (Success x) (Success y)

  liftA2 (,) (changeErr convert $ Failure e1) (changeErr convert $ Success y)
= liftA2 (,) (Failure $ convert e1) (Success y)
= Failure $ convert e1
= changeErr convert $ Failure e1
= changeErr convert $ liftA2 (,) (Failure e1) (Success y)

  liftA2 (,) (changeErr convert $ Success x) (changeErr convert $ Failure e2)
= liftA2 (,) (Success x) (Failure $ convert e2)
= Failure $ convert e2
= changeErr convert $ Failure e2
= changeErr convert $ liftA2 (Success x) (Failure e2)
```

These equations hold without any assumption on `convert`. However, the final case reveals something:
```haskell
  liftA2 (,) (changeErr convert $ Failure e1) (changeErr convert $ Failure e2)
= liftA2 (,) (Failure $ convert e1) (Failure $ convert e2)
= Failure $ convert e1 <> convert e2

  changeErr convert $ liftA2 (,) (Failure e1) (Failure e2)
= changeErr convert $ Failure $ e1 <> e2
= Failure $ convert $ e1 <> e2
```
This shows that `changeErr convert` is an applicative homomorphism if and only if `convert` is a semigroup homomorphism. So, if `convert` is a semigroup homomorphism, then ew have
```haskell
  changeErr convert $ f <$> v1 <*> v2 <*> v3 <*> v4 <*> ... <*> vn
= f <$> changeErr convert v1
    <*> changeErr convert v2
    <*> changeErr convert v3
    <*> changeErr convert v4
    ...
    <*> changeErr convert vn

```
where `f` is a curried function with n many inputs. Therefore we can choose the more efficient one by comparing the costs of converting an error from `err1` to `err2`, accumulating errors in `err1` and accumulating errors in `err2`.

By the way, one can also find algebraic assumptions like this in the wild, too. The `Action` instance of `Endo a` on `a` from [Data.Monoid.Action](http://hackage.haskell.org/package/monoid-extras-0.5/docs/Data-Monoid-Action.html) is an example.

# The Take-Home Message

The take-home message should be compact (and I am tired) so I will be brief: If you are going to work with objects with structure, do not neglect the structure preserving maps between them!