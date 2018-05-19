---
layout: post
title: Kolmogorov Complexity (Part 1 of 2)
categories:
- kolmogorov-complexity
---

# A Mandatory Example

Consider the following two binary strings:
\begin{align}
&\texttt{0101010101010101010101010101010},\newline
&\texttt{1100100100001111110110101010001}.
\end{align}

Which one do you think is easier to remember? Most people would say that the first one, because
there is an obvious and simple rule/method to generate it. So, instead of remembering the string,
we can remember the rule. One can also say that the first string is sşmple while the second one is
complex. Kolmogorov complexity is based on this idea.

Let us semi-formalize it. First let us fix a Turing complete programming language. I will not define what a programming
language *is* or *should be* and, frankly, be somewhat vague about it. Hence the prefix *semi* in front of
*formalize*. Though I will make a few assumptions. Our programs in pur programming language will be strings
from from a fixed alphabet \\(\mathcal{L}\\), say, containing ASCII or UTF-8. I will also assume that each program
accepts strings from \\(\mathcal{L}\\) as input and produce strings from \\(\mathcal{L}\\) as output. So,
in particular, we can give a program to another program as input or a program may produce a program. For ease
of reading, I will use \\(\texttt{this font}\\) when writing a string from \\(\mathcal{L}\\).

One technical assumtion which will be important later is that our program will use decimal representation
for natural numbers. Actually pretty much any positional system would do, but for the sake of definiteness
I will stick with decimal.

When I write a program, I will use some sort of pseudocode hoping that there is no ambiguity. Also I will
not exclude partial programs which corresponds do partial functions. For insance
\begin{align}
&\texttt{accept x as input}\newline
&\texttt{while 1 == 1}\newline
&\;\;\;\texttt{do nothing}\newline
&\texttt{return x}
\end{align}
is a valid program even though it does not produce any result as it is always stuck in the while loop.

Now we can define the Kolmogorov complexity of a string from \\(\mathcal{L}\\): Let \\(\sigma\\) be a string
from \\(\mathcal{L}\\). The Kolmgorov complexity of \\(\sigma\\) is the length of the shortest program which
generates \\(\sigma\\) on any input. It is denoted by \\(K(\sigma)\\).

# How canonical is this definition?

The definition seems very intuitive, especially after the mandatory example. However, there is something fishy here.
We made several arbitrary choices yet we called \\(K(\sigma)\\) *the* Kolmogorov complexity of \\(\sigma\\). It should
be clear that it is easier to generate certain strings in some langugaes than others. Indeed, the second string in our
example is just the first few digits of the binary expansion of \\(\pi\\) so it can be easier to generate in a language
designed for numerical computations.

Actually, for any string \\(\sigma\\), we can very well imagine a programming language which has \\(\sigma\\) as a built-in
constant. Thus the Kolmogorov complexity of a single string seems to very heavily depend on our language of choice. So what
happens if we change our programming language? Does this mean that our notion is arbitrary?

Fortunately, no. Let us consider two notions of complexity \\(K_1\\), \\(K_2\\) corresponding
to two different programming languages \\(L_1\\) and \\(L_2\\), respectively. Since \\(L_1\\) is Turing complete, we can write a
*compiler* for \\(L_2\\) in \\(L_1\\). In other words, \\(L_1\\) can simulate \\(L_2\\). Let \\(\sigma\\) be a string and
let \\(n=K_2(\sigma)\\). Then there is a program \\(p\\) in the language \\(L_2\\) which witnesses the fact that \\(n=K_2(\sigma)\\).
That is, \\(p\\) has length \\(n\\) and \\(p\\) generates \\(\sigma\\). Now consider the (description of a) program in \\(L_1\\):
Simulate \\(p\\). The length of this program will be \\(n + c\\) for some \\(c\\) becuse the program contains the string \\(p\\) and
\\(p\\) has length \\(n\\). The part corresponding to \\(c\\) is the part that simulates \\(L_2\\) and it does not depend on \\(\sigma\\).
By construction, "Simulate \\(p\\)" generates \\(\sigma\\), thus
\\[
  K_1(\sigma)\leq n + c = K_2(\sigma) + c.
\\]
We proved that there is a constant \\(c\\) such that \\(K_1(\sigma)\leq K_2(\sigma) + c\\) for all \\(\sigma\\). By stmmetry,
there is a \\(c'\\) such that \\(K_2(\sigma)\leq K_1(\sigma) + c'\\) for all \\(\sigma\\). Combining these two we obtain
\\[
  |K_1(\sigma) - K_2(\sigma)| < {\rm max}\\{c, c'\\}.
\\]
This shows that if we consider an infinite family of strings and consider the asymptotic behaviour of Kolmogorov complexity
on that family, then the programming language we choose does not matter. Obviously, this does not imply that this asymptotic
behaviour is easy to determine.

From now on we will stick with a fixed but not explicitely determined choice of language and denote the complexity function
given by that language \\(K\\).

# Berry Paradox


# An Incomputability Result


