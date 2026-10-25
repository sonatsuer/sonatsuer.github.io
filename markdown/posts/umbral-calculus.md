---
title: Free Theorems for Umbral Calculus
---

## TL;DR

Modern [umbral calculus](https://en.wikipedia.org/wiki/Umbral_calculus) is a branch of algebraic combinatorics created by [Gian-Carlo Rota](https://en.wikipedia.org/wiki/Gian-Carlo_Rota) by demystifying a dubious 19th century symbolic method used to prove identities. I defined a simple language to express umbral calculations and some standard assumption of umbral calculus became free theorems in the sense of Wadler. Proofs of the free theorems use ideas like Kripke relations and are not difficult. I will not go into the details here. The proofs are formalized in Lean mostly as an auto-formalization experiment. I also implemented the language in Haskell in the form of a library. Lean code, Haskell code and a detailed write up can all be found in [this repo](https://github.com/sonatsuer/umbral-calculus).

## A Taste of Umbral Calculus

So what is this dubious method? Let's see an example. Recall that the Bernoulli numbers
$B_n$ are defined by
$$
\frac{t}{e^t - 1} = \sum_{n \geq 0} B_n \frac{t^n}{n!} .
$$
It is a classical theorem, due to Euler, that
$$
\sum_{i=0}^{n} \binom{n}{i} B_i B_{n-i} = -n B_{n-1} - (n-1) B_n \tag{1}
$$
holds for $n \geq 1$. Let's prove it. Write $f(t) = t/(e^t - 1)$. Differentiating gives
$$
f'(t) =
\frac{e^t - 1 - te^t}{(e^t - 1)^2} =
\frac{1}{t} \left( \frac{t(e^t - 1)}{(e^t - 1)^2} - \frac{e^t t^2}{(e^t - 1)^2} \right) =
\frac{1}{t}\bigl(f(t) - e^t f(t)^2\bigr) ,
$$
which is equivalent to $t f'(t) = f(t) - f(t)^2 e^t$. To get rid of the last $e^t$, we
observe that $f(t)^2(e^t - 1) = t f(t)$, which yields
$$
f(t)^2 = f(t) - t f(t) - t f'(t) . \tag{2}
$$
The coefficients of $t^n/n!$ in $f$, in $tf$ and in $tf'$ are $B_n$, $n B_{n-1}$
and $n B_n$. So the coefficient of $t^n/n!$ on the right of (2) is
$B_n - nB_{n-1} - nB_n$, which is the right side of (1). It remains to show that the
coefficient of $t^n/n!$ in $f(t)^2$ is the left side of (1).

Here comes the magic. The symbolic method, which goes back to Blissard, pretends
that the index of $B_n$ is an exponent. We write $B^n$ for $B_n$, compute with $B$
as if it were a number, and turn the exponents back into indices at the end. In
this notation
$$
f(t) = 
\sum_{n \geq 0} B_n \frac{t^n}{n!} =
\sum_{n \geq 0} B^n \frac{t^n}{n!} =
\sum_{n \geq 0} \frac{(Bt)^n}{n!} = e^{Bt} .
$$

If we push this "trick" further we get into trouble. We get
$f(t)^2 = e^{Bt}e^{Bt} = e^{2Bt}$, whose coefficients are $2^n B^n$, that is,
$2^n B_n$. These are the wrong numbers. Apparently we need more magic. So we
*invent* another symbol $B'$, which behaves like $B$ but is not $B$. More precisely,
$B^i B'^j$ stands for $B_i B_j$. Note that $'$ disappears after turning the
exponents to indices. Then $f(t)^2 = e^{Bt}e^{B't} = e^{(B+B')t}$, and the
coefficient of $t^n/n!$ is
$$
(B + B')^n = \sum_{i=0}^{n} \binom{n}{i} B^i B'^{n-i} .
$$
After turning the exponents into indices, this is
$\sum_{i} \binom{n}{i} B_i B_{n-i}$, the left side of (1). Done.

It worked. There are other cases where this kind of shenanigans can give you valid identities. So at least as a method of dicovery it seems to be useful. But still, this is not rigorous at all!

## Algebra To the Rescue

Rota and Taylor made the method rigorous with a deceptively simple definition.

An *umbral calculus* consists of a commutative ring $k$, a set $\mathcal{A}$ of
symbols called *umbrae*, and a $k$-linear map
$\operatorname{E} : k[\mathcal{A}] \to k$, the *evaluation*, such that

- $\operatorname{E}[1] = 1$;
- (uncorrelation) for distinct umbrae $\alpha, \beta, \dots, \gamma$ and exponents
  $i, j, \dots, l$,
  $$
  \operatorname{E}[\alpha^i \beta^j \cdots \gamma^l]
    = \operatorname{E}[\alpha^i]\, \operatorname{E}[\beta^j] \cdots \operatorname{E}[\gamma^l] .
  $$

The *moments* of an umbra $\alpha$ are $a_n = \operatorname{E}[\alpha^n]$. Two umbrae
are *similar*, written $\alpha \equiv \beta$, if they have the same moments.

Uncorrelation only applies to *distinct* umbrae. For instance
$\operatorname{E}[\alpha^2] = a_2$, which is in general not
$\operatorname{E}[\alpha]^2 = a_1^2$. This is exactly the difference between $B$ and
$B'$ above.

To use exponential generating functions, assume that $k$ contains $\mathbb{Q}$ and
extend $\operatorname{E}$ to power series coefficientwise:
$$
\operatorname{E}\Bigl[\sum_{n \geq 0} p_n t^n\Bigr] = \sum_{n \geq 0} \operatorname{E}[p_n]\, t^n .
$$
For a polynomial $p \in k[\mathcal{A}]$ write $e^{pt} = \sum_{n} p^n t^n / n!$. Since
$k[\mathcal{A}]$ is a commutative $\mathbb{Q}$-algebra, $e^{(p+q)t} = e^{pt} e^{qt}$.

A *Bernoulli umbra* is an umbra $\iota$ with $\operatorname{E}[\iota^n] = B_n$ for all
$n$, that is, with $\operatorname{E}[e^{\iota t}] = f(t)$. Now take a second umbra
$\iota' \equiv \iota$, distinct from $\iota$. Then
\begin{align}
f(t)^2 &= \operatorname{E}[e^{\iota t}]\, \operatorname{E}[e^{\iota' t}] \newline
       &= \operatorname{E}[e^{\iota t} e^{\iota' t}] \newline
       &= \operatorname{E}[e^{(\iota + \iota') t}] .
\end{align}
The first equality holds because $\iota'$ has the moments of $\iota$. The second is
uncorrelation, applied coefficientwise. Comparing the coefficients of $t^n/n!$,
$$
\operatorname{E}[(\iota + \iota')^n]
  = \sum_{i=0}^{n} \binom{n}{i} \operatorname{E}[\iota^i]\, \operatorname{E}[\iota'^{\,n-i}]
  = \sum_{i=0}^{n} \binom{n}{i} B_i B_{n-i} .
$$
So $B'$ is not magic. It is a second umbra, similar to $\iota$ but distinct from it.

The first equality used a general rule of umbral calculus.

> **Substitution principle.** If $\alpha \equiv \beta$, then $\alpha$ may be replaced
> by $\beta$ in any umbral expression without changing its value, provided $\beta$
> does not already occur in it.

Is this principle sound? In this proof it is easy to check by hand. In general the question 
is not even well posed. The principle talks about *any umbral expression*. What does that 
even mean?

## Free Theorems

The idea is to define a small programming language whose programs are natural umbral
expressions. Then the substitution principle should hold for every program of the
right type, just because of its type. In other words, it should be a free theorem.

**The language.** It is a fragment of System F with a few additions. Its types are
$$
\tau ::= X \mid \tau \to \tau \mid \tau \times \tau \mid \mathsf{N} \mid \mathsf{T}\tau \mid \forall X.\, \tau ,
$$
with quantifiers only in front and ranging over quantifier-free types. Here
$\mathsf{N}$ is the type of natural numbers and $\mathsf{T}$ is the allocation monad.
The terms are those of System F, together with pairs and projections, $0$,
$\mathrm{succ}$, an iterator
$\mathrm{iter}_\tau : \mathsf{N} \to (\tau \to \tau) \to \tau \to \tau$, and the
monadic operations $\mathrm{return}$ and $\mathrm{bind}$. We write
$x \leftarrow M;\ N$ for $\mathrm{bind}\, M\, (\lambda x.\, N)$.

Ok so how do we do umbral calculations in this language? We simply encode the algebraic definition of Rota and Taylor as a type consisting of the operations of an umbral calculus. Then we pass it to any function doing the actual computation. So an umbral context or *dictionary* has all the necessary ring operations and the following functions:
$$
\mathrm{const} : K \to A, \qquad \mathrm{inj} : U \to A, \qquad
\operatorname{E} : A \to K, \qquad \mathsf{mk} : (\mathsf{N} \to K) \to \mathsf{T}\,U .
$$
The last one allocates a fresh umbra with the given moments. Instead of writing the humgous type out we we will abbreviate it as $\mathsf{Umbral}(K, U, A)$. 
So, for instance, an umbral expression acting on $m$ umbrae is a closed term of type
$$
\forall K\,U\,A.\ \mathsf{Umbral}(K, U, A) \to U \to \dots \to U \to \mathsf{T}\,K .
$$
Here are more concrete examples. Fresh copy of an umbra is a term of the language:
$\mathrm{new}\, u = \mathsf{mk}\,(i \mapsto \operatorname{E}[u^i])$ because we have 
iteration. Note that the umbra $\iota'$ of the proof above is $\mathrm{new}\,\iota$. Rota and Taylor's auxiliary umbrae are all made this way. For instance, the dot product $n.\alpha$ is, by construction,
$$
\mathrm{dot}_{\mathrm{c}}\, n\, u = \alpha_1 \leftarrow \mathrm{new}\, u;\ \dots;\
  \alpha_n \leftarrow \mathrm{new}\, u;\ \mathrm{return}\,(\alpha_1 + \dots + \alpha_n) .
$$

**Sketch of the semantics.** There is a natural Kripke-style semantics for this langauge. Define a *world* to be a finite set of names, each with a moment
sequence. A morphism of worlds is an injective renaming
of names that preserves moments. Define the denotation of types as functors from worlds to sets. A computation at $w$ allocates a block $\Delta$ of fresh names and returns a value in the extended world $w \oplus \Delta$:
$$
(\mathsf{T} F)(w) = \{(\Delta, s) : \Delta \text{ a world},\ s \in F(w \oplus \Delta)\} .
$$
This defines a monad on the category of functors from worlds to sets.

Now comes the relational part. We want to relate two computations possibly running in different worlds. Define a *world relation* $\varphi : w_1 \nrightarrow w_2$ to be a $k$-algebra homomorphism $\varphi : k[\text{names of }w_1] \to k[\text{names of }w_2]$ that preserves the evaluation.

The *logical relation* $\langle\!\langle \tau \rangle\!\rangle_\varphi$ at a type
$\tau$ is defined by induction on $\tau$.

- At $K$ and $\mathsf{N}$ it is equality.
- At $U$ it relates names $x$ and $y$ with $\varphi(x) = y$.
- At $A$ it relates polynomials $p$ and $q$ with $\varphi(p) = q$.
- At a product it is componentwise.
- At a function type it relates functions that send related arguments to related
  results, in every later pair of worlds.
- At $\mathsf{T}\tau$ it relates $(\Delta_1, s_1)$ and $(\Delta_2, s_2)$ if there is a
  world relation $\psi : \Delta_1 \nrightarrow \Delta_2$ between the allocated blocks
  such that $s_1$ and $s_2$ are related at $\varphi \otimes \psi$.

The [write-up](https://github.com/sonatsuer/umbral-calculus/blob/main/docs/umbral-free-theorems.pdf)
has the precise definitions. The main result is the following.

> **Theorem (Abstraction Theorem with Allocation).** Let $\varphi : w_1 \nrightarrow w_2$
> be a world relation, and let the dictionaries and the environments be related at
> $\varphi$. Then for every term $t$ of type $\tau$, its denotations at $w_1$ and at
> $w_2$ are related by $\langle\!\langle \tau \rangle\!\rangle_\varphi$.

So what did we achieve? A few things, but most importantly the substitution principle
holds. Let $t$ be an expression in one umbra, and take for $\varphi$ the renaming that
swaps two similar names $\alpha$ and $\beta$. The runs of $t$ at $\alpha$ and at
$\beta$ are related at $\mathsf{T}\,K$. The relation at $K$ is equality, so the two
runs return the same value, however much $t$ allocates.

## Some Haskell Code

My original motivation was to express the substitution principle as a free theorem and it is done. We can also write actual umbral programs in the language because, after all, it is a programming language. So I embedded it in Haskell, added a few auxiliary general purpose functions, implemented different backends for numerical, symbolic and probabilistic computations. The embedding essentially consists of a single record:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
-- | A dictionary of the umbral operations, with allocation in the monad @m@.
data Umbral m k u a = Umbral
  { -- | a scalar is a constant polynomial
    scalar :: k -> a,
    -- | an umbra is a polynomial
    inj :: u -> a,
    -- | the evaluation
    eval :: a -> k,
    -- | a fresh umbra with the given moments; the zeroth entry is never used
    mk :: (Natural -> k) -> m u
  }
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In any umbral calculation, this record is passed as an input. I also defined a custom ring class. So, for instance, the evaluation map has the following signature:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
forall m k u a. (Ring k, Ring a) => Umbral m k u a -> u -> k
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This of course is not usable in this abstract form. We need a model of umbral calculus in which we can actually do the computations. The library comes with four models: a numeric one where you can compute number sequences, the same over the integers modulo $n$, a symbolic model where you can compute polynomial families like Hermite or Touchard polynomials and a probabilistic one in which the umbrae are random variables and the evaluation is the expectation. There is a module called [showcase](https://github.com/sonatsuer/umbral-calculus/blob/main/haskell/src/Umbral/Showcase.hs) in the repo with examples. In this post I will give one example computing [A001187](https://oeis.org/A001187), the sequence of the number of connected labeled graphs on n nodes.

We need the _moment model_ of umbral calculus for numerical sequences. Here is a rough description.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
type Assign name c = name -> Natural -> c

momentModel 
  :: (Ring c) 
  => Assign name c 
  -> Umbral Fresh c (Name name c) (Poly (Name name c) c)
momentModel rho =
  Umbral
    { scalar = constant,
      inj = var,
      eval = evaluate moments,
      mk = \f -> do
        i <- fresh
        return $ New i (memoSeq f)
    }
  where
    moments (Old n) = rho n
    moments (New _ f) = f
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here the `Assign`{.haskell} type defines a context of named umbra through their moments expressed as functions from naturals to the scalars. The moment model starts from an assignment and creates an umbral context in which the umbrae are variables in a polynomial ring over c. The monad `Fresh`{.haskell} is for allocating fresh umbrae. It is a `newtype`{.haskell} over the state monad. Evaluation is simple polynomial evaluation.

### Connected graphs: the mathematics

A labeled graph on $n$ vertices splits uniquely into its connected components. Let
$g_n = 2^{\binom{n}{2}}$ be the number of labeled graphs on $n$ vertices, and $c_n$ the
number of connected ones. The exponential formula says that
$$
\sum_{n \geq 0} g_n \frac{t^n}{n!} = \exp\Bigl(\sum_{n \geq 1} c_n \frac{t^n}{n!}\Bigr) .
$$
The reason is that a labeled graph is the same thing as a set partition of its
vertices, given by its components, together with a connected graph on each block. See
[the exponential formula](https://en.wikipedia.org/wiki/Exponential_formula).
So $c_n$ is the coefficient of $t^n/n!$ in the logarithm of the exponential
generating function $G(t)$ of $g$. In probabilistic language, the $c_n$ are the
*cumulants* of the sequence $g$.

Umbral calculus computes cumulants with two auxiliary umbrae.

- The *singleton umbra* $\chi$ has $\operatorname{E}[\chi] = 1$ and
  $\operatorname{E}[\chi^n] = 0$ for $n \geq 2$. No random variable has these moments.
- The *composition* of two umbrae $\beta$ and $\alpha$ is a fresh umbra $\delta$ with
  moments
  $$
  \operatorname{E}[\delta^m] = \sum_{j \leq m} \operatorname{E}[(\beta)_j]\, B_{m,j}(a) ,
  $$
  where $a$ is the moment sequence of $\alpha$, $(x)_j = x(x-1)\cdots(x-j+1)$ is the
  falling factorial, and the *partial Bell polynomial* $B_{m,j}(a)$ is the sum, over
  the partitions of $\{1, \dots, m\}$ into $j$ blocks, of the product of
  $a_{\text{size}}$ over the blocks. In generating functions,
  $$
  \operatorname{E}\bigl[e^{\delta t}\bigr]
    = \sum_{j \geq 0} \operatorname{E}[(\beta)_j] \frac{(A(t) - 1)^j}{j!} ,
  $$
  where $A(t)$ is the exponential generating function of $a$. In the language,
  $\beta.\alpha$ is the term of type $\mathsf{T}\,U$ that allocates $\delta$.

Let $\gamma$ be an umbra with moments $g_n$, and let $\delta$ be the composition of
$\chi$ and $\gamma$. This is the *cumulant umbra* of Di Nardo and Senato, written
$\chi.\gamma$. To see why it works, look at the factorial moments of $\chi$.
The falling factorial $(x)_j$ has no constant term for $j \geq 1$, so
$\operatorname{E}[(\chi)_j]$ is the coefficient of $x$ in $(x)_j$, which is
$(-1)^{j-1}(j-1)!$. Hence
$$
\operatorname{E}\bigl[e^{\delta t}\bigr]
  = 1 + \sum_{j \geq 1} (-1)^{j-1} \frac{(G(t) - 1)^j}{j}
  = 1 + \log G(t) .
$$
So the moments of $\delta$ are the numbers $c_n$ we want.

### Connected graphs: the code

This almost directly translates to Haskell.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
-- | The umbra γ with E[γⁿ] = 2^C(n,2), the number of labelled graphs on n points.
graphs :: (Ring k) => Umbral m k u a -> m u
graphs d = mk d $ \n -> fromInt 2 .^ ((n * n - n) `div` 2)

-- | γ ← graphs; χ.γ
connectedGraphsTerm :: (Monad m, Ring k, Ring a) => Umbral m k u a -> m u
connectedGraphsTerm d = graphs d >>= cumulant d
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The auxiliary umbrae also have direct translations.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
-- | The singleton umbra χ, with moments (0, 1, 0, 0, …).
singleton :: (Ring k) => Umbral m k u a -> m u
singleton d = mk d singletonMoments

-- | The cumulant umbra χ.α: c ← χ; c.α
cumulant :: (Monad m, Ring k, Ring a) => Umbral m k u a -> u -> m u
cumulant d u = do
  c <- singleton d
  compose d c u

-- | The composition β.α, as a fresh umbra.
compose :: (Ring k, Ring a) => Umbral m k u a -> u -> u -> m u
compose d b x = mk d (composeMoments d b x)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here `composeMoments`{.haskell} computes $\sum_j \operatorname{E}[(\beta)_j]\, B_{m,j}(a)$.
It gets the factorial moments by evaluating falling factorials of `inj d b`{.haskell},
and the partial Bell polynomials from a memoized table built by their recurrence.
Nothing in these terms mentions a model. They only use the dictionary `d`{.haskell}.

To run the term we pick the moment model. The function `closedMoments`{.haskell}
runs a term that takes no umbra and returns the moment sequence of the umbra it
returns:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
>>> S.take 8 (closedMoments connectedGraphsTerm) :: [Integer]
[1,1,1,4,38,728,26704,1866256]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These are the first terms of [A001187](https://oeis.org/A001187) (the zeroth entry is $\operatorname{E}[1] = 1$).

Ok so we *can* compute [A001187](https://oeis.org/A001187) but should we do it? Unfortunately, this implementation is not very fast. With my laptop, in GHCi, computing $c_{160}$ with `connectedGraphsTerm`{.haskell} took about $12.6$ seconds. The library also has `connected`{.haskell} in `Umbral.Sequences`{.haskell}, which uses the recursive moment–cumulant formula
$\kappa_n = a_n - \sum_{k < n} \binom{n-1}{k-1} \kappa_k a_{n-k}$. It computes
$c_{160}$ in about $0.09$ seconds, the same as the classical recurrence for connected
graphs.