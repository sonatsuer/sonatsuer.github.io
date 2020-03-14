---
title: Curry-Howard Correspondence From Scratch (Part 2 of 2)
---

## Simply Typed Lambda Calculus

In the first post we constructed a formal theory of propositions but left the
notion of *naming a specific element* from a function set vague. Now we are going to fix that.

Our central notion will be that of a *lambda term*. As we want to define a formal theory we will
not define what a lambda term is and focus on how to construct new lambda terms from old ones. Intuitively
though, we will think of lambda terms as function prototypes.

First we need variables. We will assume that we have an infinite set of variables and denote
variables by lower case letters from the Latin alphabet. Each variable will also be a lambda term.
Other than that, there will be two ways to construct a lambda term. First, if $M$ and $N$ are
lambda terms then so is $MN$. We will think of $MN$ as $M$ applied to $N$. Second,
if $x$ is a variable and $M$ is a lambda term than so is $\lambda x.M$. Intuitively
$\lambda x.M$ will mean $x\mapsto M(x)$. This will be clearer when we start using lambda terms.

Let us look at a few examples. The following are all lambda terms constructed using variables only:
$$
  x,\; xy,\; xx,\; x(yz),\; (xy)z,\; (xx)x,\; (xy)(x(yz)).
$$
Of course we can also use $\lambda$:
$$
  \lambda x.x,\; \lambda y. y,\; \lambda x. y,\; \lambda y. (\lambda x. (yx))),\;
  (\lambda x. (xy))(\lambda y. x).
$$
To reduce the number of brackets we will give application higher priority than $\lambda$.
So, for instance, the expression $\lambda x. yz$ will stand for $\lambda x. (yz)$ rather than
$(\lambda x. y)z$.

Now let us define when two lambda terms are equal. Since we think of $\lambda x.M$ as a function
mapping $x$ to $M$, we see $\lambda x.x$ as some kind of identity function. However, under
this interpretation, there should not be a difference between $\lambda x.x$ and $\lambda y.y$.
More generally there should not be a difference between $x\mapsto M(x)$ and $y\mapsto M(y)$.
Therefore we want
$$
  \lambda x. x  = \lambda y. y = \lambda z. z = \ldots
$$
Maybe slightly more interestingly, we also want
\begin{align}
\lambda z. ((\lambda x.x)(\lambda y.yz))   &=
\lambda u. ((\lambda x.x)(\lambda y.yu))\newline &=
\lambda z. ((\lambda x.x)(\lambda u.uz))\newline &=
\lambda z. ((\lambda z.z)(\lambda u.uz))\newline &=
\ldots
\end{align}

We will call this *harmless renaming of variables* $\alpha$-equivalence. One can define $\alpha$-equivalence
formally but it is slightly messy. Therefore we will not do it here and instead adopt a convention: In a $\lambda$
term, each $\lambda$ will use a different variable. So, for instance, we will avoid using the last lambda term
in the list above since $\lambda z$ appears twice in it.

Now comes the more interesting properties of equality. We define
$$
  (\lambda x. M)N = M[x:= N].
$$
Here $M$ is a lambda term and $ M[x:= N]$ stands for the lambda term obtained from $M$ by replacing each
occurrence of $x$ by $N$. For instance
$$
  (\lambda x. x) N = x[x := N] = N.
$$
So $\lambda x. x$ does behave like identity. Here is another example:
\begin{align}
(\lambda y. (\lambda x. yx))(\lambda z. z)  &= (\lambda x. yx)[y:=\lambda z. z] \newline
&= \lambda x. ((\lambda z.z)x) \newline
&= \lambda x. (z[z:=x]) \newline
&= \lambda x. x.
\end{align}

Finally, let us express the functions $C$ and $E$ we defined in the previous post as lambda terms. By definition
$C_x(y)=x$ so $C_x = \lambda y. x$. If we view $C_x$  as a function of $x$ then we get
$$
  C = \lambda x. (\lambda y. x).
$$
Again by definition we have $E_x(f) = f(x)$ so $E_x = \lambda f. f x$. Therefore
$$
  E = \lambda x. (\lambda f. f x).
$$

What we defined so far is called the *untyped lambda calculus*. Even though it gives us a formal theory of
functions, it is not enough for our purposes as we also need function sets. To be able to talk about some
sort of function sets, we will introduce the notion of *type* into our theory.

The definition of a type is going to be very simple: if $\alpha$ and  $\beta$ are types then so is
$\alpha\to\beta$. Note that, formally speaking, there is no difference between types and propositions we defined in the
previous post. On the other hand, while a proposition has the connotation of a judgement, a type will be
more like function sets.

Now we will define our typing relation between lambda terms and types. If a lambda term $M$ is related to the type
$\tau$ then we will say that $M$ is of type $\tau$ and denote it by $M\colon\tau$. We will call
a statement like $M\colon\tau$ a type assignment. A context will simply be a set of type assignments. Our typing system
will consist of rules, which given a context, allows us to derive type assignments. If a context $\Gamma$ allows us
to derive an assignment $M\colon\tau$ we will denote it by $\Gamma\vdash M\colon\tau$. Note that we are overloading
the symbol $\vdash$ here.

Here is the first rule. Let $\Gamma$ be a context, then
$$
  \Gamma,x\colon\tau\vdash x\colon\tau\
$$
So, if the type of variable $x$ is $\tau$ in a given context, then we can derive the assignment $x\colon\tau$
in that context. Let us call this the rule $A^\to$.

Here is the second rule:
$$
  \text{if }\;\,
  \Gamma\vdash N:\sigma\;\,
  \text{ and }\;\,\
  \Gamma\vdash M:\sigma\to\tau\;\;
  \text{ then }\;\;\Gamma\vdash MN:\tau.
$$
So if $M$ is a function which maps objects of type $\alpha$ to objects of type $\beta$ and
$N$ is of type $\alpha$ then $M$ applied to $N$ should be of type $\beta$. Let us call this
the rule $B^\to$.

Finally,
$$
  \text{if }\;\;\;
  \Gamma,x:\tau\vdash M:\sigma \;\;\;
  \text{ then }\;\;\;
  \Gamma\vdash \lambda x. M:\tau\to\sigma.
$$
If $x$ is of type $\tau$ then any lambda term starting with $\lambda x.$ should be a function
from $\tau$ to somewhere. As $M$ is of type $\sigma$, obviously we should have $\lambda x. M:\tau\to\sigma$.
Let us call this the rule $C^\to$.

The system we constructed with rules $A^\to$, $B^\to$ and $C^\to$ is called the simply typed
lambda calculus in the style of Church and sometimes denoted by $\lambda^\to$. At this point you might
want to compare ${\rm IP}(\to)$ and $\lambda^\to$, especially the rules $A$, $B$, $C$
and $A^\to$, $B^\to$, $C^\to$.

Now we can give a precise definition of naming a specific element from a function set. Let $A$ be a function
set as we used in the previous post. Formally, we can view $A$ as a type, say $\tau$. If there is a
lambda term $M$ such that $\vdash M\colon\tau$ then we say that one can name a specific function from
$A$, namely $M$.

As an example consider the lambda term $\lambda x.(\lambda f.f x)$. Recall that it corresponds to
$x\mapsto E_x$. Let $\Gamma=\{x:\alpha,\,f:\alpha\to\beta\}$. Then, by the rule $A^\to$, we
get
$$
  \Gamma\vdash x\colon\alpha \;\;
  \text{ and }\;\;
  \Gamma\vdash f\colon\alpha\to\beta.
$$
And from these, together with rule $B^\to$ we obtain $\Gamma\vdash f x: \beta$. Finally, applying
the rule $C^\to$ twice we derive
$$
  \vdash \lambda x. (\lambda f. f x) : \alpha\to((\alpha\to\beta)\to\beta).
$$

## Finally, The Curry-Howard Correspondence
We need one final definition before we can express the Curry-Howard correspondence between ${\rm IP}(\to)$ and
$\lambda^\to$ formally.

Let $\Gamma$ be a context. Define
$$
  |\Gamma| =\{\tau \colon \text{ there is a variable $x$ such that } x : \tau\in\Gamma\}.
$$
Note that $|\Gamma|$ consists of types/propositions. In other words, $|\Gamma|$ is an assumption set. is the set of variables
appearing in $\Gamma$.

Finally, I present you the Curry-Howard Correspondence for ${\rm IP}(\to)$ and $\lambda^\to$:

If $\Gamma\vdash M:\varphi$ then $|\Gamma|\vdash\varphi$. Conversely, if $|\Gamma|\vdash\varphi$ then
there is a lambda term $M$ such that $\Delta\vdash M:\varphi$ where $\Delta=\{x_\psi:\psi\;|\; \psi\in\Gamma\}$.
To paraphrase it as a slogan, if we view types as propositions, provable propositions are precisely the types of
lambda terms.

Even this modest version of the Curry-Howard correspondence is beautiful and surprising. One wonders if it is possible to
generalize it. Actually, there is a very natural direction of generalization. We know that ${\rm IP}(\to)$ is a restricted version
of a more general logic, namely the full intuitionistic propositional logic. So we can try to generalize the theorem
to different logics. However, it is not clear how to generalize $\lambda^\to$, especially if you have not seen lambda calculus
before. The idea is that $\lambda^\to$ is a programming language and in order to generalize the Curry-Howard correspondence, we need
to find/invent different programming languages with different type systems.

First, let us clarify what we mean by $\lambda^\to$ is a programming language. Let us fix a type $\tau$ and define
$\texttt{Nat}=(\tau\to\tau)\to(\tau\to\tau)$. As the name suggests, $\texttt{Nat}$ will be the set of natural
numbers. For lambda terms $M$ and $N$ let us make the following recursive definition: $M^0N = N$ and
$M^{n+1}N=M(M^nN)$. So $M^nN$ is $M$ applied to $N$, $n$-times. The Church encoding
of a natural number $n$ is
$$
  \ulcorner n \urcorner = \lambda s. (\lambda z. s^n z).
$$
As you can check easily, $\vdash \ulcorner n \urcorner : \texttt{Nat}$. We can also define basic operations on $\texttt{Nat}$.
For instance if
$$
  A_+ = \lambda x. (\lambda y. (\lambda s. (\lambda z. (xs)((ys)z))))
$$
then we have $\vdash A_+ : \texttt{Nat} \to (\texttt{Nat} \to \texttt{Nat})$ and for all natural number $m$ and $n$ the
equality $(A_+\ulcorner m \urcorner )\ulcorner n \urcorner =\ulcorner m + n \urcorner $ holds. Therefore we can interpret
$A_+$ as a program which adds numbers. As an exercise you might want to define a computer program which does multiplication.

One can even define booleans in $\lambda^\to$. Let ${\bf T}=\lambda y. (\lambda x . x)$ and ${\bf F}=\lambda y. (\lambda x . y)$.
If we interpret ${\bf T}$ as true and ${\bf F}$ as false then $(BP)Q$ acts like
$$
  {\bf if}\; B\; {\bf then}\; P \;{\bf else}\; Q
$$
if $B$ is ${\bf T}$ of ${\bf F}$. These may look like ad-hoc ideas but lambda terms (without their types) is actually a
universal way of writing programs. This is the topic of another post, though.

Now back to the original question (with a finer statement): Can we find/invent a different programming language whose typing rules
corresponds to a logic in such a way that proving a proposition/type in that logic corresponds to writing a program of that
proposition/type? The answer is amazingly yes!

For a very simple example, consider the *and* operation on propositions.
The type construction rule corresponding to logical *and* should be pairing, also known as the Cartesian product. Because, using the analogy
in the first post, naming an element from a set $X$ *and*  a set $Y$ is the same as naming an element from $X\times Y$.
In a similar fashion, *or* corresponds to sum types. One can also consider logics with quantifiers, modalities or linear logics etc. and they
all come with their corresponding programming languages. Moreover the properties of the type system viewed as a logic are reflected as
programming language features such as polymorphism, staging, resource awareness etc. So what we covered in these two posts is just the tip
of the iceberg.