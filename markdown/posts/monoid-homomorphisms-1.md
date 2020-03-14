---
title: Monoid Homomorphisms (1 of 2)
---

## Abstract Algebra and Programming

Haskell community in particular and the functional programming community in general adopted a lot of useful algebraic structures, such as semigroups,monoids, (linear) orders, monads, categories etc. However, in the vast majority of the cases, this adoption has been at the level of of individual objects as opposed to adopting the category they form. People talk about monoids, however you do not hear many programmers talking about the *category* of monoids, for instance. Similarly, you do not see many type class instances which use an assumption that a certain map is actually a morphism in some category. One notable exception is Kmett's monad homomorphism library, which treats monads as a category.

From an ex-mathematicians point of view, most functional programmers learning category theory seem to have blind spot there. There is this whole genre of categories where objects are *sets with extra structure* and morphisms are *structure preserving functions*. For the working programmer, a category usually consists of types and functions you can define between them. The extra structure part is completely lost. A function is merely a way to get from type a to type b. It is not seen as a means to carry or translate structure.

This is not a big loss, of course, because most of the time the category at at hand *does* consist of types in a programming language and functions you can define between them. However, I think, the *morphisms preserve structure* approach has its use cases.

## Monoids

Let's look at a concrete example. A monoid is a triple $(M, \star, 1_M)$ where $M$ is a set, $\star$ is a binary operation on $M$ and $1_M$ is an element of $M$ subject to the following conditions, called the monoid axioms:

- $\star$ is associative, i.e. $x\star(y\star z) = (x\star y) \star z$ for all $x,y,z\in M$,
- $1_M$ is the identity of the operation $\star$, i.e. $1_M\star x = x = x\star 1_M$ for all $x\in M$.

So monoids are sets with extra structure. Now let us define what it means for a function to preserve this structure. A monoid homomorphism from a monoid $(M,\star, 1_M)$ to $(N, \ast, 1_N)$ is a function $\varphi : M\to N$ which satisfies

- $\varphi(1_M) = 1_N$ and
- $\varphi(x \star y) = \varphi(x) \ast \varphi (y)$.

Note that the definition of monoid homomorphism does not depend on the monoid axioms but only on the operations needed to define a monoid.

Here are two monoids: $(\mathbb{R}, +, 0)$ and $(\mathbb{R}^{>0}, \cdot, 1)$. And here are two famous monoid homomorphisms: $\log:\mathbb{R}^{>0}\to\mathbb{R}$ and $\exp:\mathbb{R}\to\mathbb{R}^{>0}$, which happen to be inverse to each other.

Now comes the interesting part. Suppose we need to multiply two large numbers, say $x$ and $y$. The obvious thing is to use a computer or a calculator. But there is also an outdated alternative: logarithm tables. We simply look up the logarithms of $x$ and $y$, add the results, and using the logarithm table (and the fact that $\log$ is monotone increasing) compute the exponential. More symbolically, we use the following identity:
$$
  x\cdot y = \exp ( \log(x) + \log(y)).
$$
Let us go over what we did here. We took a *computation* in $\mathbb{R}^{>0}$, namely $x\cdot y$, and pushed it to $\mathbb{R}$ using $\log$. This made the computation easier as addition is easier than multiplication. Then we pushed the result back in $\mathbb{R}^{>0}$ where we needed it. This idea is very common in mathematics. For instance, Hughes' difference lists also use monoid homomorphisms. In that case the role of $\log$ is played by the Cayley representation map. I actually wrote about it [here](invitation.html).

## Categorification

> A monad is just a monoid in the category of endofunctors, what's the problem?

The problem is that the monoidal structure on the endofunctor category is not specified. Joking aside, it has been almost 10 years since Dan Piponi wrote a blog post titled [From Monoids to Monads](http://blog.sigfpe.com/2008/11/from-monoids-to-monads.html). So I will not explain how the notion of monad is a categorified version of the notion of a monoid. However, mostly to fix notation, I will explain what the notion of the category of monoid objects in an arbitrary monoidal category is.

Let us start with usual monoids in the category of sets. The first step is to express everything using functions in the point-free style. The binary operation on a monoid is already a function. But how do we talk about the identity element? The idea is to view the identity as a *nullary* operation, that is, a function from the zeroth cartesian power of the monoid to itself. The zeroth power of a set is a set with a single element, also known as a singleton. So a nullary operation on a set $X$ is simply a function from a singleton to $X$, which is obviously determined by the unique element in its image. This means that we can identify nullary operations on $X$ with elements of $X$.

Now let us rephrase the definition of a monoid without referring to elements. Fix a singleton $1$. A monoid is a triple $(M, \star, 1_M)$ where $\star$ and $1_M$ are binary and nullary operations, respectively, on $M$ where the following diagrams commute:


$\newcommand{\ra}[1]{\kern-1.5ex\xrightarrow{\ \ #1\ \ }\phantom{}\kern-1.5ex}$
$\newcommand{\ras}[1]{\kern-1.5ex\xrightarrow{\ \ \smash{#1}\ \ }\phantom{}\kern-1.5ex}$
$\newcommand{\da}[1]{\bigg\downarrow\raise.5ex\rlap{\scriptstyle#1}}$
$\newcommand{\id}{\textrm{id}}$

$$
\begin{array}{c}
1 \times M & \ras{1_M \times \id} & M \times M \newline
\da{\id} & & \da{\star} \newline
1 \times M & \ras{\;\;\lambda\;\;} & M, \newline
\end{array}
\;\;\;\;\;\;\;\;\;
\begin{array}{c}
M \times 1 & \ras{1_M \times \id} & M \times M \newline
\da{\id} & & \da{\star} \newline
M \times 1 & \ras{\;\;\rho\;\;} & M \newline
\end{array}
$$

and

$$
\begin{array}{c}
(M \times M) \times M & \ras{\alpha}\;\;\;\; M \times (M\times M)\;\;\;\; \ras{\star} & M \times M \newline
\da{\star} & & \da{\star} \newline
M \times M & \ras{\;\;\;\;\;\;\;\;\;\;\;\;\;\;\star\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;} & M. \newline
\end{array}
$$

Here $\lambda$ and $\rho$ are projections and $\alpha((x,y), z) = (x,(y,z))$. A function $\varphi:M\to N$ is a monoid homomorphism from $(M,\star,1_M)$ to $(N,\ast, 1_N)$ if the following diagrams commute:

$$
\begin{array}{c}
1 & \ras{1_M} & M \newline
\da{\id} & & \da{\varphi} \newline
1 & \ras{1_N} & N, \newline
\end{array}
\;\;\;\;\;\;\;\;\;
\begin{array}{c}
M \times M & \ras{\varphi \times \varphi} & N \times N \newline
\da{\star} & & \da{\ast} \newline
M & \ras{\varphi} & N. \newline
\end{array}
$$

This formulation tells us that in any category with finite products we can talk about monoids and monoid homomorphisms. For instance if we replace the category of sets by topological spaces (with continuous maps) we obtain the notion of a topological monoid. We will do something better, though. We will isolate the properties of category theoretic product we needed in the definitions above. This will give us a notion of an abstract product which will yield the notion a  monoidal category.

Let $C$ be an arbitrary category. Let $\otimes$ be our abstract product on $C$.We want to be able replace every occurrence of $\times$ above by $\otimes$. First of all we should have

$$
\otimes : C \times C \to C
$$

because a product takes two objects and produces one. We also need $f\otimes g$ where $f\times g$ is a functor from $C\times C$ to itself. So let us take $\otimes$ to be a functor. What else? We need analogues of $1$, $\lambda$, $\rho$ and $\alpha$.

In the case of cartesian product, $1$ is the zeroth power of any object. This is essentially saying that our tensor should have a two sided identity, *up to isomorphism*. Now looking at the diagrams above, we see that, $\lambda$ and $\rho$ exactly do that. Finally, we need a family of isomorphism

$$
  \alpha_{a,b,c} : (a\otimes b)\otimes c\to a\otimes(b\otimes c)
$$

natural in $a$, $b$ and $c$.

It may seem that this is enough, however we also need some coherence conditions. Here is the problem. Obviously

$$
  ( a \times (b \times (c \times d))
  \;\;\text{ and }\;\;
  (((a \times b) \times c) \times d
$$

are isomorphic, naturally in $a$, $b$, $c$ and $d$, but if we want to construct an actual isomorphism using $\alpha$ we have, a priori, two choices:

$$
\alpha_{a\times b, c, d} \circ \alpha_{a,b,c\times d}
$$

and

$$
(\id_a \times \alpha_{b,c,d}) \circ \alpha_{a, b\times c, d} \circ (\alpha_{a,b,c}\times \id_z)
$$

It happens that these are the same isomorphism but there is nothing guaranteeing that the same will hold for an arbitrary $\otimes$. We want our isomorphisms to be unique provided that they are constructed from $\alpha$, $\lambda$ and $\rho$. It turns out that this can be achieved by assuming two simple laws, the so called pentagon law --this is actually what we just wrote-- and the so called triangle law --a coherence condition regarding the identity. For details, you may have a look at [nLab](https://ncatlab.org/nlab/show/monoidal+category). So a monoidal category is a category with a product satisfying the pentagon and the triangle laws.

Now if you stop for a second and squint at the screen, you may realize that a monoidal structure is a monoid where operations are defined *up to isomorphism*. So the notion of a monoidal category is also a categorification of the notion of a monoid, though in a entirely different direction. But then what is the correct notion of homomorphism here? We'll see that when we come to applicative functors.

## Monad Homomorphisms

$\newcommand{\end}[1]{\textrm{End}(#1)}$
Given a category $C$, let $\end{C}$ be the category of functors from $C$ to itself where the morphisms are given by natural transformations. Functor composition gives a natural monoidal structure on $\end{C}$ and the monoidal objects in this category are called, you guessed it, monads.

Now let's look at monad homomorphisms. Here, I will switch to Haskell notation. Whether I can or should switch to Haskell like that is the subject of an entirely different [discussion](http://math.andrej.com/2016/08/06/hask-is-not-a-category/).

Let us specialize the definition of a homomorphism to our case. Let `m`{.haskell} and `n`{.haskell} be monads. A monad homomorphism is a natural transformation `morph :: forall a. m a -> n a`{.haskell} satisfying the following properties:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
morph . return = return
morph . join = join . (morph . fmap morph)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The second law is equivalent o

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
morph (x >>= f) = morph x >>= morph . f
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if you are used to thinking in terms of `>>=`{.haskell}.

For a list of examples you may have a look at [this](https://gist.github.com/ekmett/48f1b578cadeeaeee7a309ec6933d7ec) gist which has cute homomorphisms like `readOnly`{.haskell} which is not in [Control.Monad.Morph](http://hackage.haskell.org/package/mmorph-1.1.2/docs/Control-Monad-Morph.html).

So what is the merit of knowing that, say `lift`, is a monad homomorphism? Well, when you think about it, we use `lift`{.haskell} when we are in the wrong monad. That is, we use `lift`{.haskell} to get from type a to type b just as I mentioned in the beginning. Indeed, if you have only one monadic value, this is all you can do with `lift`{.haskell}. The fact that `lift`{.haskell} is a homomorphism becomes useful when we want to lift many values. For instance we have

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
forM_ xs (lift . f) = lift (forM_ xs f)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

and

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
mapM_ (lift . f) xs = lift (mapM_ f xs)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

And since lifting has a cost, the forms on the right hand side are usually more efficient.

I would like to finish this part by giving an example of a natural transformation which is not a monad homomorphism. Let `listToMaybe`{.haskell} be defined by `foldr (const . Just) Nothing`{.haskell}. Then `listToMaybe`{.haskell} is not a monad homomorphism. Indeed,

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
  listToMaybe (join [[], [1]])
= listToMaybe [1]
= Just 1
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

but

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
  join $ listToMaybe $ listToMaybe <$> [[], [1]]
= join $ listToMaybe [Nothing, Just 1]
= join (Just Nothing)
= Nothing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

On the other hand, `maybeToList`{.haskell} defined by `foldr (:) []`{.haskell} *is* a monad homomorphism.
