---
title: Curry-Howard Correspondence From Scratch (Part 1 of 2)
---

## Function Sets

Suppose we have two sets $X$ and $Y$. Can we name a function from $X$ to $Y$ without
using what $X$ or $Y$ is? Obviously if $Y$ is empty and $X$ is not empty then this is not possible
as there is no function from a nonempty set to the empty set. So let us suppose $X$ and $Y$ are nonempty
for the moment. Now there *are* functions from $X$ to $Y$. For instance, for every element $y\in Y$,
there is the constant function which takes the value $y$. Bu this does not count because the problem is to *name* a
particular function, not to prove the existence of such functions. It looks difficult. Actually, in a sense
which we will define later, the answer is that we cannot name such a function. Considering the fact that we do not
know anything about $X$  and $Y$ this is hardly surprising.

On the other hand, if we take $X=Y$ then it is possible to name such a function: the identity function. Since
the identity function maps each element to itself, we do not need to know anything about $X$. Frankly, this
does not seem like an interesting observation, either. However, as we consider more complex examples, the situation will
change dramatically.

Let us introduce some notation. For sets $X$ and $Y$, we will denote the set of functions from $X$ to $Y$
by $X\to Y$. In this notation $f \in X\to Y$ and $f \colon X \to Y$ have the same meaning. For instance,
if we denote the identity function on $X$ by $1_X$, then we have $1_X \in X\to X$.

Now let us consider the following question: Can we name a function from the set
$$
  X \to (Y \to X) ?
$$
What we need to find is a function, which, given an element of $X$, produces a function from $Y$ to $X$. After
a moments thought, it is easy to come up with the function $x\mapsto C_x$ where $C_x(y)=x$ for all $y\in Y$. In
other words, we can send $x$ to the constant function which only attains the value $x$.

In a similar way, one can easily see that
$$
  x\mapsto 1_Y \in X \to (Y \to Y).
$$
However, it seems that the problem has no solution for the sets
$$
  X \to (X \to Y) \;\;\;\text{ and }\;\;\; (X \to Y) \to Y
$$

We can consider even more complex examples. For instance
$$
  x\mapsto E_x \in X \to ((X \to Y ) \to Y).
$$
where $E_x$ is the ''evaluation at $x$'' function, that is $E_x(f) = f(x)$.
Yet the problem has no solution for the set
$$
  X \to ((Y \to X) \to Y).
$$

As an exercise, you might want to name an element from the set
$$
  (X \to (Y \to Z)) \to ((X \to Y) \to (X \to Z)).
$$

After seeing all these examples, we have a somewhat vague but very natural questions:
From which sets can we name specific elements? We will give a rather surprising answer to this question.

## Propositional Calculus with only Implication
After function sets, the title may remind you of the Monty Python Movie *And Now for Something Completely Different*
but bear with me. I promise this is going somewhere.

In this section we will develop a modest theory of propositions. We are not going to define *what* a proposition is,
but intuitively, we will think of propositions as judgments. The central notion in our theory will be that of proof,
or rather the "proves" relation which we will denote by $\vdash$. The proves relation will be a relation
between proposition sets, which we will call assumption sets, and propositions. If $\Gamma$ is a set of
propositions and $p$ is a proposition we will write $\Gamma\vdash p$ to denote $\Gamma$ proves $p$.

Now we will list the properties we want $\vdash$ to satisfy. These properties will be our deduction rules. For
ease of notation we will abbreviate $\Gamma\cup\{p\}$ as  $\Gamma,p$ and $\Gamma\cup\{p,q\}$ as $\Gamma,p,q$.
We will also write $\vdash p$ instead of $\emptyset\vdash p$.

Our first deduction rule is trivial: We can prove a proposition if it is among our assumptions. Formally,
$$
  \Gamma, p\vdash p.
$$
We will call this the rule $A$.

For the other deduction rules, we need to define how we can construct new propositions from old ones. There are
several ways to do it. We can use conjunctions, disjunctions, negations, implications etc. For the sake of this post, we
will only work with implication. If $p$ and $q$ are two propositions then we define a new proposition $p\to q$
and read it as "$p$ implies $q$". Obviously this is a completely formal definition.

Now we can introduce more deduction rules. The next rule is the famous *modus ponens* rule. It says
if one can prove $p$ and $p\to q$ from an assumption set $\Gamma$ then we can also prove $q$ from $\Gamma$.
More formally we have
$$
  \text{if }\;\;\;\Gamma\vdash p\;\;\;\text{ and }\;\;\;\Gamma\vdash p\to q
  \;\;\;\text{ then }\;\;\;\Gamma\vdash q.
$$
We will call this the rule $B$.

Our final rule is kind of a dual version of modus ponens. It says that if one can prove $q$ from $\Gamma$ together
with $p$ then using only $\Gamma$ one can prove $p\to q$. More formally
$$
  \text{if }\;\;\;\Gamma,p\vdash q\;\;\;\text{ then }\;\;\;\Gamma\vdash p\to q.
$$
We will call this the rule $C$.

Our propositional logic with the rules $A$, $B$ and $C$ is called the implicational fragment of the intuitionistic propositional
logic and sometimes denoted by ${\rm IP}(\to)$. So what can we deduce in ${\rm IP}(\to)$? Let us look at a few examples.

First of all, by $A$, we have $p\vdash p$. So, by $C$, we deduce $\vdash p\to p$. On the other hand we should not have
$\vdash p\to q$ because it is absurd to expect an arbitrary proposition to imply an arbitrary proposition. Actually
it is not difficult to prove that we cannot deduce $\vdash p\to q$ in ${\rm IP}(\to)$ but we will mostly rely on intuitive arguments.

Here is another example. By $A$, we have $p,q\vdash p$. By $C$, we deduce $p\vdash q\to p$. Using $C$ once more we obtain
$\vdash p\to (q\to p)$. If we start with $p,q\vdash q$ in the previous argument we obtain $\vdash p\to (q\to q)$.
On the other hand we should not be able to deduce $\vdash p \to (p\to q)$. Because assuming $p$ holds, we cannot
say that $p$ implies an arbitrary $y$.

Note that we have not used the rule $B$ yet. So let us look at an example involving that rule. Let
$$
  \Gamma=\{p,p\to q\}.
$$
First of all, by $A$, we have $\Gamma\vdash p$ and $\Gamma\vdash p\to q$. Thus, by $B$, we deduce $\Gamma\vdash q$.
Now using the rule $C$ twice we get
$$
  \vdash  p \to ((p \to q) \to q).
$$

As an exercise, prove that
$$
  \vdash
   (p \to (q \to r)) \to ((p \to q) \to (p \to r)).
$$

Now let us list the propositions we were able to prove with an empty assumption set:

\begin{align}
& p \to p, \newline
& p \to (q \to p), \newline
& p \to (q \to q), \newline
& p \to ((p \to q) \to q), \newline
& (p \to (q \to r)) \to ((p \to q) \to (p \to r)).
\end{align}

Let us also list all the function sets from which we were able to name specific elements:
\begin{align}
& X \to X, \newline
& X \to (Y \to X), \newline
& X \to (Y \to Y), \newline
& X \to ((X \to Y) \to Y), \newline
& (X \to (Y \to Z)) \to ((X \to Y) \to (X \to Z)).
\end{align}

Either we have a strange coincidence in our hands or we just observed a nontrivial relation between functions and
propositions. In the [next post](curry-howard-2.html), we will see that this is not a coincidence.
