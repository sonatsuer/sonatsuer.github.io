---
title: Two Characterizations of Natural Numbers
---

$\newcommand{\IN}{\mathbb{N}}$
$\newcommand{\ras}[1]{\kern-1.5ex\xrightarrow{\ \ \smash{#1}\ \ }\phantom{}\kern-1.5ex}$
$\newcommand{\ua}[1]{\bigg\uparrow\raise.5ex\rlap{\scriptstyle#1}}$

## Induction and Recursion

Recently I found lecture notes of an introductory set theory course I taught almost
10 years ago. Most of the content was pretty standard: axiom of choice, cardinal arithmetic,
transfinite induction etc. But one theorem was something you would not find proved in full
detail very often: equivalence of Dedekind's definition of natural numbers and the initial
algebra definition. So I decided to turn it into a blog post.

Let us start by setting the stage. Call a triple $\mathcal{A}=(A,f,a)$ an $\IN$-like structure if
$a\in A$ and $f\colon A\to A$. Note that we only specified the 'signature' of the structure,
we are not assuming anything else.

**Proof By Iduction (PI):** We will say that an $\IN$-like structure $\mathcal{A}=(A,f,a)$
_allows proof by induction_ if for every $B\subseteq A$ satisfying the properties

- $a\in B$,
- $b\in B$ implies $f(b)\in B$

we have $B=A$.

So, if you are familiar with the terminology, an $\IN$-like structure allows **PI** if
and only if it does not have any proper substructures. The obvious example is
$(\IN, n \mapsto n + 1, 0)$. But allowing **PI** is a weak property in the sense that there are
other models satisfying it. For instance $(\{0,1,\ldots,m\}, n \mapsto n + 1\;{\rm mod}\;m, 0)$. Dedekind's axioms for natural numbers is a strengthening of allowing **PI** to eliminate
finite examples like this one.

**Dedekind Axioms for Naturals (DA):** For an $\IN$-like structure $\mathcal{A}=(A,f,a)$ the
_Dedekind axioms_ are

- $\mathcal{A}$ allows **PI**,
- $f$ is injective,
- $a$ is not in the image of $f$.

As a small warm-up, let us prove that $f$ is actually a bijection between $A$ and $A\setminus\{a\}$.
Define
$$
B = \{b\in A | b = a \text{ or } b\in{\rm Im}(f)\}.
$$
It is enough to show that $B=A$. Clearly $a\in B$. Now suppose $b\in B$. Then, by definition,
$f(b)\in {\rm Im}(f)$. Hence $f(b)\in B$. So, by **PI**, we are done.

The second characterization of natural numbers relies on recursion.

**Definition by Recursion (DR):** We will say that an $\IN$-like structure $\mathcal{A}=(A, f, a)$ _allows
definition by recursion_ if for any $\IN$-like structure $\mathcal{B}=(B, g, b)$ there is a
unique function
$\varphi\colon A\to B$ such that

- $\varphi(a) = b$,
- $\varphi(f(x)) = g(\varphi(x))$ for any $x\in A$.

So, if you are familiar with the terminology, an $\IN$-like structure allows **DR** if
and only if it is an initial object in te category of $\IN$-like structures and the function
$\varphi$ is the corresponding catamorphism.

If you are not familiar with the terminology, here is a simple example. For the moment assume
that $\mathcal{N}=(\IN, n\mapsto n + 1, 0)$ allows **DR** --whatever you definition for $\IN$ is. Now consider $\mathcal{B}=(\IN, n\mapsto 2n, 1)$. The function $\varphi$ mentioned in the **DR**
property satisfies $\varphi(0) = 1$ and $\varphi(n + 1)=2\varphi(n)$. So $\varphi$ is the
function $n\mapsto 2^n$ defined by recursion.

In this post I will give  a proof of the following theorem: An $\IN$-like structure allows **DR**
if and only if it satisfies **DA**.

## From Dedekind Axioms to Definition by Recursion

Suppose $\mathcal{A}=(A,f,a)$ satisfies **DA** and $\mathcal{B}=(B,g,b)$ is an $\IN$-like
structure. Call a subset $R$ of $A\times B$ a candidate relation if

- $(a,b)\in R$,
- if $(x,y)\in R$ then $(f(x), g(y))\in R$.

Let $\Gamma$ be the set of all candidate relations. Since $A\times B$ itself is a candidate
relation $\Gamma$ is not empty. Now define $\gamma = \bigcap\Gamma$. Note that $\gamma$ is
a subset of every candidate relation. Now we will prove a series of claims about $\gamma$.

**First, $\gamma$ is a candidate relation.** Indeed, since $(a,b)$ is in every element of
$\Gamma$, it is in the intersection. Similarly, if $(x,y)$ is in $\gamma$ then $(x,y)$ is in
every element of $\Gamma$ but every element of $\Gamma$ is a candidate relation thus $(f(x), g(y))$
is in every element of $\Gamma$. So $(f(x), f(y))$ is in $\gamma$.

**Second, $\gamma$ is the graph of a function,** that is, for any $x\in A$ there is a unique
$y\in B$ such that $(x,y)\in\gamma$. Define
$$
U = \{u\in A| \text{there is a unique $b\in B$ such that } (u,b)\in\gamma\}.
$$
We will show that $U=A$ using the assumption that $\mathcal{A}$ allows **PI**.

Clearly $(a, b)\in\gamma$ as $\gamma$ is a candidate relation. Suppose there is a $b'\in B$
such that $b\neq b'$ and $(a,b')\in\gamma$. Let $\gamma'=\gamma\setminus\{(a, b')\}$.
then we have $(a,b)\in\gamma'$. Moreover, if $(x,y)$ is in $\gamma'$ then so is $(f(x), g(y))$
because $(f(x), g(y))\in\gamma$. Moreover $(f(x),g(y))\neq(a,b')$ as $a$ is not in the image of $f$ by **DA**. We just proved that $\gamma'$ is a candidate relation. Thus $\gamma\subseteq\gamma'$ as
$\gamma$ is the minimum candidate relation. But $\gamma'$ is obtained from $\gamma$ by removing an element. Contradiction. Therefore such a $b'$ cannot exist and hence we must have $a\in U$. This
finishes the base case of induction.

Now suppose $x\in U$. By the definition of $U$, there is a unique $y\in B$ such that
$(x,y)\in\gamma$. Since $\gamma$ is a candidate relation, we also know that $(f(x), g(y))\in\gamma$.
Now suppose there is a $b\in B$ such that $b\neq g(y)$ and $(f(x), b)\in\gamma$. Define $\gamma'=\gamma\setminus\{(f(x), b)\}$. Similar to the base case, we will prove that $\gamma'$ is
a candidate relation which, by the minimality of $\gamma$, will imply a contradiction. Note that
$(a,b)\in\gamma'$ as the element we removed cannot be $(a,b)$ because $a$ is not in the image
of $f$. Now suppose $(x',y')\in\gamma'$. We want to show that $(f(x'), g(y'))\in\gamma'$. We know
that $(f(x'), g(y'))\in\gamma$ because $\gamma$ is a candidate relation. So the only way that
$(f(x'), g(y'))\not\in\gamma'$ is that $(f(x'), g(y'))$ is the element we removed from $\gamma$,
namely $(f(x), b)$. But if $(f(x'), g(y')) = (f(x), b)$ then $x=x'$ because $f$ is injective.
This, in turn, would imply that both $(x,y)$ and $(x,y')$ are in $\gamma$. Since $x\in U$
we must have $y = y'$ and $g(y') = g(y)$. But this is not possible as, by assumption,
$b\neq g(y)$.

By slightly abusing notation, we will write $\gamma(a)$ when referring to the unique $b\in B$
such that $(a,b)\in\gamma$.

**Third, $\gamma$ satisfies the recursion equations,** that is, $\gamma(a)=b$ and $\gamma(f(x))=g(\gamma(x))$.
Let us translate what we know about $\gamma$ expressed in relational notation
to the functional notation. Since $(a,b)\in\gamma$ we have $\gamma(a)=b$. Also
for any $x\in A$ we have $(x, \gamma(x))\in\gamma$ by definition. Thus, since $\gamma$ is a
candidate relation, $(f(x), g(\gamma(x)))\in\gamma$ and that translates to
$\gamma(f(x))=g(\gamma(x))$.

This means that we can take $\varphi=\gamma$ in the statement of **DR** if we can show that
$\gamma$ is the unique such function. So let us do that.

**Fourth, $\gamma$ is the unique such function.** This is a simple application of **PI**.
Let $\gamma'\colon A\to B$ be another function satisfying equations in the statement of **DR**.
Define
$$
E = \{e\in A| \gamma(e) = \gamma'(e)\}
$$
By assumption $\gamma(a)= b =\gamma'(a)$. So $a\in E$. Suppose $x\in E$. Then
$$
\gamma(f(x))=g(\gamma(x))=g(\gamma'(x))=\gamma'(f(x)).
$$

Thus $f(x)\in A$. So by **PI** we are done.

## From Definition by Recursion to Dedekind Axioms

Now let us go in te opposite direction. Suppose $\mathcal{A}=(A,f,a)$ allows **DR**. Maybe somewhat
surprisingly, the difficult part is showing that $f$ is a bijection between $A$ and
$A\setminus\{a\}$. Proving that $\mathcal{A}$ allows **PI** is almost immediate.

To make the argument easier to read, let us introduce a few notions. Given $\IN$-like
structures $\mathcal{A}=(A,f,a)$ and $\mathcal{B}=(B,g,b)$, a homomorphism $\alpha$ from $\mathcal{A}$
to $\mathcal{B}$ is a function $\alpha\colon A\to B$ such that $\alpha(a)=b$ and $\alpha(f(x))=g(\alpha(x))$
for all $x\in A$. In this terminology, an $\IN$-like structure $\mathcal{A}$ allows **DR** if an only if
for any $\IN$-like structure $\mathcal{B}$ there is a unique homomorphism $\varphi\colon\mathcal{A}\to\mathcal{B}$.

It is an easy exercise to show that identity function is a homomorphism and composition of
two composable homomorphisms is again a homomorphism.

Now back to **PI**. Let $B\subseteq A$ be a subset containing $a$ and closed under $f$. This makes
$\mathcal{B}=(B,g, a)$ where $g = f\vert_B$ an $\IN$-like structure. So, by **DR**, there is
a unique homomorphism $\varphi\colon A\to B$. There is also a homomorphism $\iota\colon\mathcal{B}\to\mathcal{A}$
defined by inclusion: $\iota(x)=x$. Now $\iota\circ\varphi$ is a homomorphism from $\mathcal{A}$
to itself. But $\mathcal{A}$ allows **DR** so by uniqueness of homomorphisms we must have that $\iota\circ\varphi$
is the identity function. But then $\iota$ has to be surjective meaning that $B=A$.

For the rest, we will develop some rudimentary category theory. Let $\mathcal{C}$ be
a category and let $F\colon\mathcal{C}\to\mathcal{C}$ be a functor. An $F$-algebra
is a pair $(A,f)$ where $A$ is an object of $\mathcal{C}$ and $f\colon F(A)\to A$
is a morphism of $\mathcal{C}$. It may be difficult to see where the name 'algebra'
comes from at first sight so let us first clarify that. The idea is that we can view
$F$ as a way to define an abstract signature. In the case of polynomial functors they do
define signatures in the classical sense. The notion of an $\IN$-like structure is an
instance of this. Let us elaborate.

Consider the functor $S(X) = 1 + X$ from the category of sets to itself where 1 is a fixed
terminal object --a singleton-- and $+$ is the coproduct of sets, that is,
disjoint union. An $S$-algebra is a function from $f\colon 1 + A\to A$. Clearly $f$ is determined by
two functions $g=f\vert_1$ and $h=f\vert_A$. The domain of the function $g$ is a singleton so $g$
is determined by the unique element in its image. To summarize, an $S$-algebra structure on $A$
is determined by an element of $A$ and a function from $A$ to $A$. Bu this is precisely
what an $\IN$-like structure is determined by.

We can also define a notion of morphism between $F$-algebras. Let $(A, f)$ and $(B, g)$ be
$F$-algebras for some functor $F$. A function $\varphi\colon A\to B$ is called an $F$-algebra
morphism if the following diagram commutes:

$$
\begin{array}{c}
A & \ras{\;\;\;\varphi\;\;\;} & B \newline
\ua{f} & & \ua{g} \newline
F(A) & \ras{\;\;F(\varphi)\;\;} & F(B) \newline
\end{array}
$$

Clearly the following diagram commutes:

$$
\begin{array}{c}
A & \ras{\;\;\;{\rm id}\;\;\;} & a \newline
\ua{f} & & \ua{f} \newline
F(A) & \ras{\;\;F({\rm id})={\rm id}\;\;} & F(A) \newline
\end{array}
$$
Therefore ${\rm id}$ is a morphism from $(A, f)$ to itself. Moreover if the small squares
in the following diagram commute then the big rectangle commutes:
$$
\begin{array}{c}
A & \ras{\;\;\;\varphi\;\;\;} & B & \ras{\;\;\;\psi\;\;\;} & C\newline
\ua{f} & & \ua{g} & & \ua{h} \newline
F(A) & \ras{\;\;F(\varphi)\;\;} & F(B) & \ras{\;\;F(\psi)\;\;} & F(C) \newline
\end{array}
$$
Therefore composition of $F$-algebra morphisms is again an $F$-algebra morphism. We just
proved that $F$-algebras form a category. We define an initial $F$-algebra to be an initial
object in the category of $F$-algebras.

It is easy to see that $S$-algebra morphisms correspond to homomorphisms of $\IN$-like structures
and being an initial $S$-algebra corresponds to being an $\IN$-like structure which allows
definition be recursion.

Now comes a beautiful and surprisingly general theorem about initial algebras:

**Lambek's theorem:** Let $F$ be a functor and let $(A, f)$ be an initial
$F$-algebra. Then $f$ is an $F$-algebra isomorphism from $(F(A), F(f))$
to $(A, f)$.


_Proof:_ Let $\varphi$ be the unique morphism from $(A, f)$ to
$(F(A), F(f))$. Consider the following diagram:
$$
\begin{array}{c}
A & \ras{\;\;\;\varphi\;\;\;} & F(A) & \ras{\;\;\;f\;\;\;} & A\newline
\ua{f} & & \ua{F(f)} & & \ua{f} \newline
F(A) & \ras{\;\;F(\varphi)\;\;} & F(F(A)) & \ras{\;\;F(f)\;\;} & F(A) \newline
\end{array}
$$
The square on the left commutes by the definition of $\varphi$. The square on the
right commutes trivially. Therefore the big rectangle commutes. This means that
$f\circ\varphi$ is a morphism from  $(A,f)$ to itself so it must be ${\rm id}$
because an initial algebra has only one endomorphism. Now consider $\varphi\circ f$.
Using the fact that $F$ is a functor and the square on the left commutes we obtain:
$$
\varphi\circ f = F(f)\circ F(\varphi) = F(f\circ\varphi)=f({\rm id}) = {\rm id}.
$$
This proves that $f$ is an isomorphism whose inverse is $\varphi$. $\blacksquare$

Now let us see what this means for $S(X)=1 + X$. Let $\mathcal{A}=(A,f,a)$ be an
$\IN$-like structure which allows **DR**. Then the corresponding $S$-algebra is
$c_a+f\colon 1+A\to A$ where $c_a$ denotes te constant function with value $a$.
By assumption it is an initial $S$-algebra. By Lambek's theorem $c_a + f$ is
an isomorphism from $1 + A$ to $A$. In particular, as viewed as a
function, it is a bijection. The image of $c_a$ is $\{a\}$. Therefore $f$ must
be a bijection from $A$ to $A\setminus \{a\}$. This proves that $\mathcal{A}$
satisfies **DA**.
