---
title: Schröder-Bernstein via Eilenberg-Mazur in Haskell
---

## Some Set Theory

Given finite sets $A$ and $B$, we know how to compare their sizes by looking at their
cardinalities. We can say that $A$ is at least as large as $B$ if $|A| \leq |B|$ or $A$ and $B$ are
of the same size if $|A| = |B|$. Obviously, if $|A|\leq |B|$ and $|B|\leq |A|$ then $|A| = |B|$.
One can also do this for infinite sets by developing a theory of infinite cardinalities.

However, there is a way to compare sets without referring to their cardinalities which works for both finite and infinite sets. Let $A$ and $B$ be not necessarily finite sets. We will say that $A$
is at least as large as $B$ if there is an injective function from $A$ into $B$ and denote this by
$A\lesssim B$. If there is a bijection between $A$ and $B$ we will say that $A$ and $B$ are of the same size and denote it by $A\approx B$.

With the notations we introduced we can state the Schröder-Bernstein theorem as follows:

> If $A\lesssim B$ and $B\lesssim A$ then $A\approx B$.

Let us look at a simple application. We will show that $\mathbb{R}+\mathbb{Q}\approx\mathbb{R}$
where $+$ denotes disjoint union. Clearly $\mathbb{R}\lesssim\mathbb{R}+\mathbb{Q}$ because
we can view $\mathbb{R}$ as a subset of $\mathbb{R}+\mathbb{Q}$. On the other hand the function
from $\mathbb{R}+\mathbb{Q}$ to $\mathbb{R}$ sending $r\in\mathbb{R}$ to $e^r$ and $q\in\mathbb{Q}$
to $-e^q$ is injective as the function $x\mapsto e^x$ is an injective function whose image is contained in $\mathbb{R}^{>0}$.

To appreciate the power of Schröder-Bernstein, you might look for a direct proof of
$\mathbb{R}+\mathbb{Q}\approx\mathbb{R}$. But keep in mind that Schröder-Bernstein is not a
theorem of intuitionistic set theory. For instance it fails in the effective topos. Actually,
due to a recent result by Pradic and Brown [it implies the excluded middle principle](https://arxiv.org/pdf/1904.09193.pdf).
On te other hand it is a theorem of ZF, namely classical set theory without the axiom of choice.

So how can we implement it in Haskell if it is not constructive? Well, the implementation will
not be total in some cases but we will still be able to derive some interesting bijections between
types from injections.

## Eilenberg-Mazur Swindle

We haven't talked about a proof yet. There are several proofs using several different
ideas: Knaster-Tarski fixed point theorem, König's bipartite graph argument, Cantor's use of
industrial strength cardinal arithmetic, etc. We will use a form of the [Eilenberg-Mazur
swindle](https://en.wikipedia.org/wiki/Eilenberg%E2%80%93Mazur_swindle).

Suppose $X\lesssim Y$ and $Y\lesssim X$. Let $A$ be the complement of the image of $Y$ in $X$.
Then we have $X\approx A + Y$. Similarly we have $Y\approx B + X$ where $B$ is the complement of
the image of $X$ in $Y$. Now this gives us, by iteration, these
$$
X \approx A + Y \approx A + (B + X) \approx A + (B + (A + Y)) \approx A + (B + (A + (B + X)))\approx \ldots
$$
If you pay attention to actual bijections, you can even write this as an infinite
alternating sum plus some residual set $C$ which is not covered by any step of this process:
$$
X \approx A + B + A + B + \cdots + C.
$$
Similarly we have
$$
Y \approx B + A + B + A + \cdots + C.
$$
Note that the initial summands are different. Now we have
\begin{align}
X & \approx A + B + A + B + \cdots + C \newline
  & \approx (A + B) + (A + B) + \cdots + C \newline
  & \approx (B + A) + (B + A) + \cdots + C \newline
  & \approx B + A + B + A + \cdots + C \newline
  & \approx Y
\end{align}
Of course I pushed some details under the rug and there are a few details to be checked but nevertheless, this is a proof of the Schröder-Bernstein theorem via Eilenberg-Mazur.

## Haskell Implementation

I will put code snippets together with explanations in the post. If you want to play with the
code, it is available as a [gist]().

First of all, the notions of disjoint union and being in bijection already exist in Haskell
but with different names. So let us first rename them so they look more like mathematical
notation:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
type a + b = Either a b
type a ≈ b = Iso' a b
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here `Iso'`{.haskell} is from the lens package. Next we will define an infinite alternating
sum as a recursive data type relying on the laziness of Haskell.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
data AlternatingSum a b
  = FirstSummand a
  | RemainingSummands (AlternatingSum b a)
  deriving
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Our infinite sum type is related to our binary sum as expected:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
leftmostDecomposition :: AlternatingSum a b ≈ (a + AlternatingSum b a)
leftmostDecomposition = iso toDecomposed fromDecomposed
  where
    toDecomposed = \case
      FirstSummand a -> Left a
      RemainingSummands alt -> Right alt
    fromDecomposed = either FirstSummand RemainingSummands
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By using this decomposition twice we can obtain the grouping into binary sums in the proof above:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
associated :: (a + (b + c)) ≈ ((a + b) + c)
associated = iso toLeftBracket fromLeftBracket
  where
    toLeftBracket = either (Left . Left) (either (Left . Right) Right)
    fromLeftBracket = either (fmap Left) (Right . Right)

selfSimilarDecomposition :: AlternatingSum a b ≈ ((a + b) + AlternatingSum a b)
selfSimilarDecomposition =
  leftmostDecomposition . seconding leftmostDecomposition . associated
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

At this point we have everything we need to perform the infinite swap of te binary sums. One
might think --I certainly did-- that the following implementation works:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
infiniteSwapped :: AlternatingSum a b ≈ AlternatingSum b a
infiniteSwapped =
  selfSimilarDecomposition .
  bimapping swapped infiniteSwapped .
  from selfSimilarDecomposition
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

But it turns out that this is not lazy enough and it hangs. So we will use the following
function which is enough for our purpose:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
infiniteSwap :: forall a b. AlternatingSum a b -> AlternatingSum b a
infiniteSwap =
  view (from selfSimilarDecomposition) .
  bimap (view swapped) infiniteSwap .
  view selfSimilarDecomposition
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

And here is a translation of the Eilenberg-Mazur argument into Haskell:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
schroderBernsteinExplicitSum :: forall a b x y.
  x ≈ (a + y) -> y ≈ (b + x) -> x ≈ y
schroderBernsteinExplicitSum xToAplusY yToBplusX = iso xToY yToX
  where
    xToY = contractToY . infiniteSwap . expandFromX
    yToX = contractToX . infiniteSwap . expandFromY

    expandFromX :: x -> AlternatingSum a b
    expandFromX x = case x ^. xToAplusY of
      Left a -> FirstSummand a
      Right y -> RemainingSummands $ expandFromY y

    expandFromY :: y -> AlternatingSum b a
    expandFromY y = case y ^. yToBplusX of
      Left b -> FirstSummand b
      Right x -> RemainingSummands $ expandFromX x

    contractToY :: AlternatingSum b a -> y
    contractToY = \case
      FirstSummand b -> Left b ^. re yToBplusX
      RemainingSummands alt -> Right (contractToX alt) ^. re yToBplusX

    contractToX :: AlternatingSum a b -> x
    contractToX = \case
      FirstSummand a -> Left a ^. re xToAplusY
      RemainingSummands alt ->Right (contractToY alt) ^. re xToAplusY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is good, but we will make it better. In set theory, the propositions $X\lesssim Y$
and $\exists B. Y\approx B + X$ are equivalent. But the latter is just the existential characterization of a simple prism. So the question here is can we implement Schröder-Bernstein
using prisms without explicitly mentioning the complement? The answer is yes.

Let us first define a poor man's existential prism.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
data ExistentialPrism s a = forall c. ExistentialPrism (s ≈ (c + a))
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now we can generalize `schroderBernsteinExplicitSum`{.haskell} to implicit sums, namely existential
prisms, in a straightforward way:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
schroderBernsteinExistentialPrism ::
  ExistentialPrism x y -> ExistentialPrism y x -> x ≈ y
schroderBernsteinExistentialPrism (ExistentialPrism iso1) (ExistentialPrism iso2) =
  schroderBernsteinExplicitSum iso1 iso2
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We can turn every simple prism into a simple existential prism as follows:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
toExistential :: Prism' s a -> ExistentialPrism s a
toExistential p = ExistentialPrism (iso fromS toS)
  where
    fromS = matching p
    toS = either id (review p)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Something may look fishy here. Note that the complement we chose here is `s`{.haskell} but it
should be a refinement of `s`{.haskell} where the refining predicate says "not in the image of
`review p`{.haskell}". But it is OK because, in effect, this function is acting like a smart
constructor. We are not accessing arbitrary elements of `s`{.haskell}.

Now we have everything we need to implement Schröder-Bernstein for prisms but before that we will
define one more type synonym to mimic the mathematical notation. The functions after the
synonym are not needed to prove the Schröder-Bernstein theorem but they motivate the choice
of notation.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
type a ≲ b = Prism' b a

reflexivity :: a ≲ a
reflexivity = prism' id Just

transitivity :: a ≲ b -> b ≲ c -> a ≲ c
transitivity p1 p2 = p2 . p1
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Finally, Schröder-Bernstein for prisms, which, in the light of the last two functions, could
as well be called `antisymmetry`{.haskell}:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
schroderBernstein :: y ≲ x -> x ≲ y -> x ≈ y
schroderBernstein p1 p2 =
  schroderBernsteinExistentialPrism (toExistential p1) (toExistential p2)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Examples

Let's look at a few examples. Unfortunately this part is going to be slightly anticlimactic.
First a few prisms.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
ex1 :: Prism' Natural Natural
ex1 = prism' create mbRecover
  where
    create = (+1)
    mbRecover n = if n > 0 then Just (n - 1) else Nothing

ex2 :: Prism' Natural Natural
ex2 = reflexivity

ex3 :: Prism' Natural (Natural + Natural)
ex3 = prism' create mbRecover
  where
    create = \case
      Left n -> 2 * n
      Right n -> 2 * n + 1
    mbRecover n = Just $
      if even n then Left (n `div` 2) else Right ((n - 1) `div` 2)

ex4 :: Prism' Natural (Natural + Natural)
ex4 = prism' create mbRecover
  where
    create = \case
      Left n -> 3 * n
      Right n -> 3 * n + 1
    mbRecover n
      | n `mod` 3 == 0
        = Just $ Left $ n `div` 3
      | n `mod` 3 == 1
        = Just $ Right $ (n - 1) `div` 3
      | otherwise
        = Nothing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We also need a function to display the graphs of functions.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
graphOf :: (a -> b) -> [a] -> [(a, b)]
graphOf f as = [ (a, f a) | a <- as]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here are a few examples presented as doctests.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
-- >>> graphOf (view $ schroderBernstein ex1 ex1) [0..9]
-- [(0,1),(1,0),(2,3),(3,2),(4,5),(5,4),(6,7),(7,6),(8,9),(9,8)]

-- >>> graphOf (view $ schroderBernstein ex1 ex2) [0..9]
-- [(0,0),(1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9)]

-- >>> graphOf (view $ schroderBernstein ex3 _Right) [0..20]
-- [(0,Left 0),(1,Right 0),(2,Left 1),(3,Right 1),(4,Left 2),(5,Right 2),(6,Left 3),(7,Right 3),(8,Left 4),(9,Right 4),(10,Left 5),(11,Right 5),(12,Left 6),(13,Right 6),(14,Left 7),(15,Right 7),(16,Left 8),(17,Right 8),(18,Left 9),(19,Right 9),(20,Left 10)]

-- >>> graphOf (view $ schroderBernstein ex4 _Right) [0..20]
-- [(0,Left 0),(1,Right 0),(2,Right 2),(3,Left 1),(4,Right 1),(5,Right 5),(6,Left 2),(7,Right 7),(8,Right 8),(9,Left 3),(10,Right 3),(11,Right 11),(12,Left 4),(13,Right 4),(14,Right 14),(15,Left 5),(16,Right 16),(17,Right 17),(18,Left 6),(19,Right 6),(20,Right 20)]

-- >>> graphOf (view $ schroderBernstein _Right ex3) (concatMap (\x -> [Left x, Right x]) [0..9])
-- [(Left 0,0),(Right 0,1),(Left 1,2),(Right 1,3),(Left 2,4),(Right 2,5),(Left 3,6),(Right 3,7),(Left 4,8),(Right 4,9),(Left 5,10),(Right 5,11),(Left 6,12),(Right 6,13),(Left 7,14),(Right 7,15),(Left 8,16),(Right 8,17),(Left 9,18),(Right 9,19)]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Note that we did not try all possible combinations. For instance `schroderBernstein ex2 ex1`{.haskell} hangs.
As we mentioned in the very beginning, `schroderBernstein p1 p2`{.haskell} is going to be partial
for some prisms `p1`{.haskell} and `p2`{.haskell}. As an exercise you can characterize the prism
pairs which give total functions.

That's it? Well, kind of it is. This was mostly a nerd-snipe without a concrete application in mind.
Though it is possible to view  `schroderBernstein`{.haskell} as a solution to a matching problem.
First let us make a small observation. Suppose we have injective functions $f\colon A\to B$ and
$g\colon B\to A$. Then, by Schröder-Bernstein there is a bijection $\sigma\colon A\to B$. By going over the construction, it is easy to see that for any $(a,b)\in A\times B$ in the graph of $\sigma$,
either $f(a) = b$ or $g(b) = a$. So if we interpret $f$ and $g$ as preferred match functions, then
the Schröder-Bernstein theorem says that it is possible match everyone from $A$ with everyone from
$B$ in such a way that in each couple, at least one side achieves preferred match.
