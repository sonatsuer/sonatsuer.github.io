---
layout: post
title: An Invitation to Functional Programming (For Mathematicians)
categories:
- evangelism
---

(This post is based on two talks I gave at the mathematics departments of Bilkent University and METU.)

# Functional Programming

Here is the definition of functional programing in Wikipedia:
> In computer science, functional programming is a programming paradigm that treats computation as the evaluation of mathematical functions and avoids changing-state and mutable data.

This should be very appealing to mathematicians. The reason is that choosing pure --i.e. mathematical-- functions as a foundation means that programs are *algebraic* objects. Computation is literally simplification of algebraic expressions.

This paradigm is very intuitive from the point of view of a mathematician. For instance, we can use *substituition of equals for equals principle*, a principle we learn in primary school, as a way to reason bout programs. This is also very useful from the point of view of a programmer. It even has a fancy name in computer science. It is called *referential transparency*.

However, somewhat surprisingly, functional programming is considered difficult by a lot of programmers. Personally, I think programmers find it difficult because first they need to *unlearn* an entire paradigm which they have been using for years. This is where the mathematicians have the advantage. A mathematician only needs to *learn* the specifics of a programming language based on ideas with which he/she is already familiar. Learning is gnerally easier than unlearning.

In this post, I will try to lure you, my dear mathematician, into functional programming.

# Enter Haskell

We will work out an example of the *programs are algebraic objects* approach in detail. For that we will use Haskell, an industrial strength pure functional language, named after the mathematician and logician Haskell Curry. This will not be a crash course in Haskell. Instead, I will explain the syntax as we go.

Like the vast majority of programming languages, Haskell has data structures. One of the most common data structures in Haskell is the  list structure. Here is the definition: given a type `a`, (like integers, floating point numbers, strings, etc.) we define `[a]` by *structural recursion* as follows:
- `[]` is a list, it is called the empty list;
-	if `x` is an element of type `a` and `xs` is a list of elements of type `a` then `x : xs` is also list.

For instance
```
1 : (2 : (3 : [])) = 1 : 2 : 3 : []
```
is a list of integers. Haskell allows us to express this list as `[1, 2, 3]`.

Note that here `:` is a actually *binary operation* and a list actually a *term*. Now let us define a simple function on lists.

Let `xs` and `ys` be two lists (over the same type). We define the concatenation `xs++ys` of `xs` and `ys` by recursion on the structure of `xs` as follows:

```
[]++ys = ys    and    (x : xs') ++ ys = x : (xs' ++ ys).
```

Let us compute an example:
```
[1,2]++[3,4] = (1 : (2 : [] )) ++ (3 : (4 : []))
             = 1 : (( 2 : []) ++ (3 : (4 : []))
             = 1 : (2 : ([] ++ (3 : (4 : [])))
             = 1 : (2 : (3 : (4 : [])))
             = [1,2,3,4]
```
Note the simialarity between this calculation and the calculations you do in algebra.

# Our First Program in Haskell

Suppose that we want to devise a function --that is to say, write a program-- which produces the reverse of a list. Here is the obvious solution. Given a list `xs` let us define `naiveReverse` as follows:
```
naiveReverse [] = []
naiveReverse (x : xs) = naiveReverse xs ++ [x]
```
This looks like a (recursive) mathematical definition but it is actually valid Haskell code. As an exercise you may want to show that `naiveReverse [1,2,3] = [3,2,1]`.

Our program solves the problem of inveting a list, however we call it the naive reverse for a reason. It is not very efficient. First, note that the computation of `xs ++ ys` requires length of `xs` many applications of `:` operation. This causes the computtaion to `naiveReverse xs` to require \\(\frac{1}{2}n(n-1)\\) applications of the operation `:` where \\(n\\) is the length of `xs`.

We can easily prove this by induction on \\(n\\). Base case is trivial. Suppose the statement holds for \\(n\\). Let `xs` be of length \\(n\\). Then, for any `x` we have
\\[
{\rm naiveReverse}\, (x : xs) = {\rm naiveReverse}\, xs ++ [x].
\\]
As `naiveReverse xs` and `xs` has the same length, namely \\(n\\), computation of `++` takes \\(n\\) applications of the `:` operation. On the other hand, by induction hypothesis, `naiveReverse xs` requires \\(\frac{1}{2}n(n-1)\\) applications. Adding these two yields \\(\frac{1}{2}n(n+1)\\), which is what we want.

So the complexity of `naiveReverse` is quadratic as a function of the input length because `++` is expensive. There is a very similar situation in mathematics with an elegant solution: multiplication is expensive, however one can use logarithms to turn multiplication into addition, do the additon and come back with exponentiaiton. This is why logarithm tables were used before computers.

We will use the same trick to optimize `naiveReverse`, that is, we will change the underlying monoid using a homomorphism.

# Algebra Refresher
Recall that a monoid is a triple \\((M, \cdot, 1_M)\\) where \\(\cdot\\) is a binary associative operation on \\(M\\) and \\(1_M\\) is the identity element of \\(\cdot\\).

Here are a few examples:
\begin{enumerate}
	\onslide<2->{\item For any set $S$, the set of self maps of $S$, denoted by ${\rm End}(S)$ is a monoid under composition. The identity is the identity function.}
	\onslide<3->{\item For any set $S$, the set of finite sequences with elements from $S$ form a monoid under concatenation. The identity is the empty list. (Actually this is called the free monoid generated by $S$.)}
\end{enumerate}
\end{frame}

A monoid homomorphism from \\((M, \cdot, 1_M)\\) to \\((N, \circ, 1_N)\\) is a function \\(\varphi : M \to N\\) such that
\begin{frame}
\frametitle{Algebra refresher: Cayley representation theorem}
\begin{theorem}{\bfseries Cayley} A monoid with underlying set $S$ can be embedded in ${\rm End}(S)$.
\pause
\begin{proof}
One can easily check that $\mathcal{C}(s)=\lambda_s$ where $\lambda_s(x)= s * x$ is such an embedding.
\end{proof}
\end{theorem}
\vspace*{1em}
\pause

Note that if a function $f$ is in the image of $\mathcal{C}$ then one can recover the element it came from by applying $f$ to the identity of the monoid.

\end{frame}

\begin{frame}
\frametitle{Pushing the problem to ${\rm End}([a])$}
In ${\rm End}([a])$, the monoidal operation, namely function composition, is very cheap. To be more precise, it requires constant time because the composition of two functions is left untouched untill someone tries to apply it to a value.
\vspace*{1em}
\pause

However, the notion of reverting only makes sense in $[a]$ and not in ${\rm End}([a])$. So we need to embed only the concatenation part of the problem into ${\rm End}([a])$.
\vspace*{1em}
\pause

The inverse of $xs$ is given by $f\, xs\, []$ where $f$ is defined by
\[
f\, [] = id
\;\;\;\text{ and }\;\;\;\;
f\, (x : xs) = f\, xs \circ \mathcal{C}([x]).
\]
\end{frame}

\begin{frame}[fragile]
\frametitle{Haskell Implementation}
\begin{verbatim}
type End s = s -> s

singleton :: a -> End [a]
singleton x = f where f y = x : y

cayleyReverse :: [a] -> End [a]
cayleyReverse [] = id
cayleyReverse (x : xs) = cayleyReverse xs . singleton x

naiveReverse :: [a] -> [a]
naiveReverse [] = []
naiveReverse (x : xs) = naiveReverse xs ++ [x]

betterReverse :: [a] -> [a]
betterReverse xs = cayleyReverse xs []
\end{verbatim}
\end{frame}


\section{Sketch of a Vast Generalization}
\begin{frame}
\frametitle{Monoid Objects in a Category}
We will port our method to different domains using category theory.

\pause
First, we need to translate our notions to category theory. Effectively, this means expressing \emph{everything} in terms of functions and their compositions.

We need
\begin{itemize}
	\onslide<3->{\item Elements (using terminal objects)}
	\onslide<4->{\item Products (expressing Cartesian product as a categorical limit)}
	\onslide<5->{\item Monoids (using the ``associativity'' of Cartesian products)}
\end{itemize}

\onslide<6->{
Now a monoid is a set $M$ together with two functions $*\colon M\times M\to M$ and $e\colon 1\to M$ satisfying the associativity and identitiy rules.
}
\vspace{1em}

\onslide<7->{
The associativity rule of a monoid $M$ can be expressed by saying that the two functions
\[
*\, \circ \, (id \times\,*)
\;\;\;\text{ and }\;\;\;
*\,\circ \, (*\times id) \circ \alpha
\]
from $M\times(M\times M)$ to $M$ are equal. (Here $\alpha (x,(y, z)) = ((x,y),z))$.)
}

\onslide<8->{
\vspace{1em}
Exercise: Express the identity rule.}
\end{frame}

\begin{frame}
\frametitle{Monoid Objects in a Monoidal Category}
This is where the hand-waving starts. For actual definition you may use Wikipedia.
\vspace{1em}

\pause
First, let us forget about sets and functions and work with an arbitrary category. This means that we work with abstract objects and abstract ``maps'' between them. The composition $f \circ g$ is defined only when the codomain of $g$ coincides with the domain of $f$. The only assumption about this abstract composition is associativty.
\vspace{1em}

\pause
Let us also forget about Cartesians product and work with an arbitrary monoidal structure. This means that we have a binary construction on our objects with a function like $\alpha$ --and a little bit more.
\vspace{1em}

\pause
It turns out that the notion of a monoid can be expressed in any category with a monoidal structure. If your category is the category of sets and functions between them and the monoidal structure is the Cartesian product then you recover the original notion.
\vspace{1em}

\end{frame}

\begin{frame}
\frametitle{Examples: Applicatives, Monads and Arrows}
But is this generalization useful?
\pause You bet! Here are some examples.
\begin{itemize}
	\onslide<2->{\item Let $Hask$ be the category of types in Haskell with functions definable in Haskell and pairing (or product) as the monoidal structure. (From a strict point of view, this is not true but good enough to snatch ideas from category theory.) Then for any $a$, $[a]$ and $End\, a$ are monoids.}
	\onslide<3->{\item Consider endofunctors of $Hask$ with composition as the monoidal structure. Then the monoids are called the monads. The Cayley representation in this context is acalled the codensity monad transformation for historical reasons.}
	\onslide<4->{\item In the category of endofunctors of $Hask$ with Day convolution as the monoidal structure the monoids are called the applicatives.}
	\onslide<5->{\item In the category of profunctors with profunctor tensor as the monoidal structure the monoids are called the weak arrows.
	\item \ldots}
\end{itemize}
\end{frame}

\begin{frame}
\frametitle{Tip of the iceberg}
This was just one idea and its generalizations. Here is an incomplete list of other relevant pure mathematical notions, each of which could be the topic of a different talk:
\begin{itemize}
	\item Free constructions (free monads, free applicatives, etc.)
	\onslide<2->{\item Categorical duality (comonds, cofree constructions etc.)}
	\onslide<3->{\item Functors (adjointness and representability)}
	\onslide<4->{\item Categories as databases (AQL and functorial migration)}
	\onslide<5->{\item Curry-Howard correspondence
	\item \ldots}
\end{itemize}
\onslide<5->{A lot of exciting things are happenning here!}
\end{frame}

# Final Remarks
There is nothing more practical than a good theory.

In theory, there is no difference between theory and practise. In practise, there is.
