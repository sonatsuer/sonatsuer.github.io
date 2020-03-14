---
title: An Invitation to Functional Programming (For Mathematicians)
---

_This post is based on two talks I gave at the mathematics departments of Bilkent University and METU._

## Functional Programming

Here is the definition of functional programing in Wikipedia:

> In computer science, functional programming is a programming paradigm that treats computation as the evaluation of mathematical functions and avoids changing-state and mutable data.

This should be very appealing to mathematicians. The reason is that choosing pure --i.e. mathematical-- functions as a foundation means that programs are *algebraic* objects. Computation is literally simplification of algebraic expressions.

This paradigm is very intuitive from the point of view of a mathematician. For instance, we can use *substitution of equals for equals principle*, a principle we learn in primary school, as a way to reason bout programs. This is also very useful from the point of view of a programmer. It even has a fancy name in computer science. It is called *referential transparency*.

However, somewhat surprisingly, functional programming is considered difficult by a lot of programmers. Personally, I think programmers find it difficult because to be productive in a purely functional language, first they need to *unlearn* an entire paradigm which they have been using for years. This is where the mathematicians have the advantage. A mathematician only needs to *learn* the specifics of a programming language based on ideas with which he/she is already familiar. Learning is generally easier than unlearning.

In this post, I will try to lure you, my dear mathematician, into functional programming.

## Enter Haskell

We will work out an example of the *programs are algebraic objects* approach in detail. For that we will use Haskell, an industrial strength pure functional language, named after the mathematician and logician Haskell Curry. This will not be a crash course in Haskell. Instead, I will explain the syntax as we go.

Like the vast majority of programming languages, Haskell has data structures. One of the most common data structures in Haskell is the  list structure. Here is the definition: given a type `a`{.haskell}, (like integers, floating point numbers, strings, etc.) we define `[a]`{.haskell} by *structural recursion* as follows:

- `[]`{.haskell} is a list, it is called the empty list;
- if `x`{.haskell} is an element of type `a`{.haskell} and `xs`{.haskell} is a list of elements of type `a`{.haskell} then `x : xs`{.haskell} is also list.

For instance

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
1 : (2 : (3 : [])) = 1 : 2 : 3 : []
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

is a list of integers. Haskell allows us to express this list as `[1, 2, 3]`{.haskell}.

Note that here `:`{.haskell} is a actually *binary operation* and a list actually a *term*. Now let us define a simple function on lists.

Let `xs`{.haskell} and `ys`{.haskell} be two lists (over the same type). We define the concatenation `xs++ys`{.haskell} of `xs`{.haskell} and
`ys`{.haskell} by recursion on the structure of `xs`{.haskell} as follows:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
[]++ys = ys    and    (x : xs') ++ ys = x : (xs' ++ ys).
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


Let us compute an example:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
[1,2]++[3,4] = (1 : (2 : [] )) ++ (3 : (4 : []))
             = 1 : (( 2 : []) ++ (3 : (4 : []))
             = 1 : (2 : ([] ++ (3 : (4 : [])))
             = 1 : (2 : (3 : (4 : [])))
             = [1,2,3,4]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Note the similarity between this calculation and the calculations you do in algebra.

## Our First Program in Haskell

Suppose that we want to devise a function --that is to say, write a program-- which produces the reverse of a list. Here is the obvious solution. Given a list `xs`{.haskell} let us define `naiveReverse`{.haskell} as follows:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
naiveReverse [] = []
naiveReverse (x : xs) = naiveReverse xs ++ [x]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This looks like a (recursive) mathematical definition but it is actually valid Haskell code. As an exercise you may want to show that `naiveReverse [1,2,3] = [3,2,1]`{.haskell}.

Our program solves the problem of inverting a list, however we call it the naive reverse for a reason. It is not very efficient. First, note that the computation of `xs ++ ys`{.haskell} requires length of `xs`{.haskell} many applications of `:`{.haskell} operation. This causes the computation to `naiveReverse xs`{.haskell} to require $\frac{1}{2}n(n-1)$ applications of the operation `:`{.haskell} where $n$ is the length of `xs`{.haskell}.

We can easily prove this by induction on $n$. Base case is trivial. Suppose the statement holds for $n$. Let `xs`{.haskell} be of length $n$. Then, for any `x`{.haskell} we have
$$
{\rm naiveReverse}\, (x : xs) = {\rm naiveReverse}\, xs ++ [x].
$$
As `naiveReverse xs`{.haskell} and `xs`{.haskell} has the same length, namely $n$, computation of `++`{.haskell} takes $n$ applications of the `:`{.haskell} operation. On the other hand, by induction hypothesis, `naiveReverse xs`{.haskell} requires $\frac{1}{2}n(n-1)$ applications. Adding these two yields $\frac{1}{2}n(n+1)$, which is what we want.

So the complexity of `naiveReverse`{.haskell} is quadratic as a function of the input length because `++`{.haskell} is expensive. There is a very similar situation in mathematics with an elegant solution: multiplication is expensive, however one can use logarithms to turn multiplication into addition, do the addition and come back with exponentiation. This is why logarithm tables were used before computers.

We will use the same trick to optimize `naiveReverse`, that is, we will change the underlying monoid using a homomorphism.

## Algebra Refresher

Recall that a monoid is a triple $(M, \cdot, 1_M)$ where $\cdot$ is a binary associative operation on $M$ and $1_M$ is the identity element of $\cdot$.

Here are a few examples. For any set $S$, the set of self maps of $S$, denoted by ${\rm End}(S)$ is a monoid under composition. The identity is the identity function. For any set $S$, the set of finite sequences with elements from $S$ form a monoid under concatenation. The identity is the empty list. This is called the free monoid generated by $S$.

A monoid homomorphism from $(M, \cdot, 1_M)$ to $(N, \star, 1_N)$ is a function $\varphi : M \to N$ such that $\varphi(1_M) = 1_N$ and
$\varphi(x\cdot y) = \varphi(x)\star\varphi(y)$.

The Cayley representation theorem, which is taught in every every abstract algebra course, says that the map $\mathcal{C} : M\to {\rm End}(M)$ defined by $\varphi(m)(n) = m \cdot n $ is an injective monoid homomorphism, i.e. a monoid embedding. Note that if a function $f$ is in the image of $\mathcal{C}$ then one can recover the element it came from by applying $f$ to the identity of the monoid.

Using the Cayley representation theorem, we can push the problem of computing inverses to the monoid ${\rm End}([a])$. (Note how I mixed the Haskell notation and standard mathematical notation.) The advantage is that in ${\rm End}([a])$, the monoidal operation, namely function composition, is very cheap. To be more precise, it requires constant time because the composition of two functions is left untouched until someone tries to apply it to a value. However, the notion of reverting only makes sense in $[a]$ and not in ${\rm End}([a])$. So we need to embed only the concatenation part of the problem into ${\rm End}([a])$.

Here is the solution as valid Haskell code:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
type End s = s -> s

naiveReverse :: [a] -> [a]
naiveReverse [] = []
naiveReverse (x : xs) = naiveReverse xs ++ [x]

singleton :: a -> End [a]
singleton x = f where f y = x : y

cayleyReverse :: [a] -> End [a]
cayleyReverse [] = id
cayleyReverse (x : xs) = cayleyReverse xs . singleton x

betterReverse :: [a] -> [a]
betterReverse xs = cayleyReverse xs []
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



Note that `cayleyReverse`{.haskell} is obtained from `naiveReverse`{.haskell} in a mechanical way replacing `++`{.haskell} by `{.haskell}.`{.haskell} and `[x]`{.haskell} by `singleton x`{.haskell}.

## Final Remarks

This idea can be vastly generalized, if you know some category theory. Instead of monoids you can work with monoid objects in certain monoidal categories and transfer this optimization technique to different contexts. If you are interested in the details, you may have a look at *Notions of Computation as Monoids* by Exequiel Rivas and Mauro Jaskelioff.

In the beginning, I said that I will try to lure you into functional programming. And the picture I tried to draw can be summarized by the famous motto:

>There is nothing more practical than a good theory.

However, if you are really considering a career change like I did, there is another motto you should know about:

>In theory, there is no difference between theory and practice. In practice, there is.