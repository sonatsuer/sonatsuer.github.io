
---
title: Leaking Implementation Details (For Mathematicians)
...

## Motivation

You are in your office, trying to teach how to evaluate $\int \sin^2(x)\cos^3(x)dx$ to a pre-med
student. Suddenly you hear someone scream: _"Implementation details are leaking!"_
The pre-med and you look at each other with puzzled eyes. Then you hear it again:
_"It is everywhere! It even got into the specs!"_ This time you recognize the voice. It is your computer
scientist friend from across the hallway. You put your hand on the shoulder of the pre-med and say
_"You are right kiddo. You will be a real doctor, you don't need any of these..."_ and leave the room
to help your friend. However, there is a small problem. Being a mathematician, you do not know
what it means to leak implementation details.

So you call me and I tell you this:

## Examples from mathematics

Let's begin with a somewhat strange question:

> Is $e$ a subset of $\pi$?

Our gut feeling tells us that this is absurd and one shouldn't ask such questions even though it is formally valid in a
foundational theory in which all objects are sets, such as ZFC. There is one context, however, in which this question may come up.
If you are teaching an introductory course in real analysis and you are constructing real numbers as left Dedekind cuts
then, since the order on $\mathbb{R}$ is given by inclusion, you may ask whether $e$ is a subset of $\pi$ as a sanity check.
After this course, your students should of course forget about how the reals are constructed and refer to $\mathbb{R}$ as
a complete ordered field.

This practice is very common in programming, too. For a programmer, Dedekind reals are an implementation and the
axioms of the complete ordered fields form an API, that is an _application program interface_ together with a specification.
We interact with reals only through these axioms. So the fact that inclusion is the order relation on Dedekind reals is an
implementation detail, and if you use this fact while doing real analysis then you are leaking an implementation detail.

This particular example seems very intuitive but there are more subtle cases. Thinking in terms of an API and a specification
instead of a fixed implementation, also known as abstract thinking, can be tricky especially when the problem at hand is
presented in terms of a concrete implementation. To illustrate the point, I will talk about two problems.

Here is the first one:

> Is there an embedding of $(\mathbb{R}, \leq)$ into $(\wp(\mathbb{N}), \subseteq )$, where $\wp$ stands for power set?

The answer is yes and the proof is easy, though I have seen students as well as professional mathematicians being surprised
by this fact. I believe the reason is that $\wp(\mathbb{N})$ has a discrete _feeling_ to it as $\mathbb{N}$ is discretely
ordered. So one expects that it cannot contain a copy of $\mathbb{R}$. However $\wp$ does not use the order structure on
$\mathbb{N}$ and $\wp(\mathbb{N})$ is isomorphic to $\wp(A)$ for any countably infinite set $A$. In that regard,
choice of $\mathbb{N}$ is an implementation detail and the source of confusion seems to be the fact that it is leaking
at a pedagogical level. If the answer is still not clear after this discussion, just use Dedekind cuts with $\wp(\mathbb{Q})$.

The second question is a little famous:

> Given two dice $A$ and $B$ with arbitrary natural numbers on their faces, we say that $A$ beats $B$ if, when rolled together,
> $A$ is more likely to be higher than $B$. Can we have three dice $A$, $B$ and $C$ such that $A$ beats $B$, $B$ beats $C$
> and $C$ beats $A$?

The answer to this question, which is much more counterintuitive, is also yes. Actually here is an example:
$$
A\colon 2,2,4,4,9,9;\;\; B\colon 1,1,6,6,8,8;\;\; C\colon 3,3,5,5,7,7.
$$
More than once I have seen people claiming that this is impossible by arguing that the expected values would violate transitivity
of the order relation on reals. The problem with this argument, other than being false, is that expected value is meaningful for
_numbers_ as it involves an average. However, when you look at the statement of the problem you see that only the order on natural
numbers is used so one could formulate the question with any infinite linearly ordered set. So using structure other than the order
is leaking implementation details.

The moral of the story is that putting your problem behind an abstract API may clarify it. Mathematicians do it
intuitively. Programmers, on the other hand, usually approach the problem much more methodically. So let's see a toy example
from programming.

## Interfaces and Haskell: Smart constructors

I will use the programming language Haskell trying to explain the relevant syntax. Haskell programs are organized as trees of modules.
Each module implements some functionality. Modules can access their child modules modules to import functionality exported by them.
On the other hand a module does not necessarily export everything it implements. In other words, each module can define its API. This is one of
the standard ways of encapsulating implementation details. Let's look at a concrete example.

Suppose you need some sort of counter in your program that you can increase at will. One obvious solution would be to use
integers. However integers can take negative values or we can multiply integers, which are not really meaningful for a counter.
so using naked integers is not a good idea. Instead we will implement our counter in a module and use integers as the underlying
object but hide it from the users outside.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
module Counter
  ( initialCounter
  , increase
  , undo
  , getCount
  ) where

newtype Counter = MkCounter Int

initialCounter :: Counter
initialCounter = MkCounter 0

increase :: Counter -> Counter
increase (MkCounter n) = if n == maxBound then error "Overflow" else MkCounter (n + 1)

undo :: Counter -> Counter
undo (MkCounter n) = max 0 (n - 1)

getCount :: Counter -> Int
getCount (MkCounter n) = n
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let's talk about this piece of code. We define a module named `Counter`{.haskell} which defines a type named `Counter`{.haskell}.
The subtlety here is that `MkCounter`{.haskell} is _not_ exported. This means that even if we can talk about values of type
`Counter`{.haskell} outside this module, we cannot use pattern match to extract the integer inside, or put an arbitrary integer
in a `Counter`{.haskell}. Instead, we have to use `initialCounter`{.haskell} to construct a counter, `increase`{.haskell}
and `undo`{.haskell} to manipulate counters and `getCount`{.haskell} to access the value in the counter. Interacting with the
`Counter`{.haskell} type using only this api guarantees that the integer held by the counter is never negative.

Now is a good time to introduce some terminology. The constructor `initialCounter`{.haskell} is called a smart constructor. The property
of being nonnegative is called an invariant of the type. The functions `increase`{.haskell} and `undo`{.haskell} are said to preserve the
invariant. The idea is to expose a type through its smart constructors and invariant-preserving manipulators. One can find this idea
applied in, say, the containers like maps and sets where the underlying type is some kind of tree.

I should say at his point that I chose smart constructors because they are easy to explain. They come with certain [caveats](https://lexi-lambda.github.io/blog/2020/11/01/names-are-not-type-safety/) which I will
not go into in this post. So if you decide to make use this method take a look at the down sides. I omitted other methods like [existential types](https://en.wikibooks.org/wiki/Haskell/Existentially_quantified_types) which can hide everything about a type except for that it exists and [typeclasses](https://wiki.haskell.org/Typeclassopedia) which allow you to hide an entire class of structures behind an API. I also wrote this post from a theory-free point of view but there is deep and beautiful mathematics behind [information hiding](https://www.cs.bham.ac.uk/~udr/papers/logical-relations-and-parametricity.pdf) if you are interested.

## When to leak implementation details

After reading all these you might think that leaking implementation details should be avoided at all costs. Well, not really.
Look at these type signatures from the `Data.Set`{.haskell} library of Haskell:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
singleton :: a -> Set a
insert :: Ord a => a -> Set a -> Set a
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

They roughly correspond to the functions ${\rm singleton}(x) = \{x\}$ and ${\rm insert}(x, A) = \{x\}\cup A$. The first
signature looks okay but that `Ord a`{.haskell} in the second one looks odd. It is a typeclass constraint saying that this function requires
the type `a`{.haskell} have a linear order on it. It is there because the underlying tree structure has an invariant expressed in terms of
an order relation: at a branching point, all nodes on the left branch should be less then all nodes on the right branch. It is needed for
efficiency. With this invariant, for instance, membership can be decided in logarithmic time as opposed to linear time by employing a
divide and conquer type strategy. But this means we are letting an implementation detail leak through the API! Of course one can build a
library to represent sets without mentioning order relations but it would be unusable because it would be too slow. So yes, the implementation detail leaks but for a very good reason. It is a very common theme. The initial design of a system has clear cut abstraction boundaries but
optimization --or some other cross cutting concern-- breaches those boundaries.

We have similar practices in mathematics, too. Sometimes we pick a representation of an object and work with it because it is easier due to some
extra structure of the particular representation. Here is a somewhat advanced example. Concrete categories, that is, categories with a faithful
functor into ${\rm Set}$ are sometimes easier to work with as element chasing arguments are available. But the standard API of category theory
has arrows but no elements. So sometimes we employ a big theorem like the [Freyd-Mitchell theorem](https://ncatlab.org/nlab/show/Freyd-Mitchell+embedding+theorem) which, in this case, essentially says that an abelian category can be viewed as full subcategory of an $R$-module category.
This allows us to use assumptions like "morphisms are functions" which are not compatible with the API of categories.
