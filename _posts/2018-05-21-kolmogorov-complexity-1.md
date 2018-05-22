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
we can remember the rule. One can also say that the first string is simple while the second one is
complex. Kolmogorov complexity is a quantified version of this intuitive notion.

Let us semi-formalize it. First let us fix a Turing complete programming language. I will not define what a programming
language *is* or *should be* and, frankly, be somewhat vague about it. Hence the prefix *semi* in front of
*formalize*. Though I will make a few assumptions. Programs in our programming language will be strings
from from a fixed alphabet \\(\mathcal{L}\\), say, containing ASCII or UTF-8. I will also assume that each program
accepts strings from \\(\mathcal{L}\\) as input and produce strings from \\(\mathcal{L}\\) as output. So,
in particular, we can give a program to another program as input or a program may produce a program. For ease
of reading, I will use \\(\texttt{this font}\\) when writing a string from \\(\mathcal{L}\\).

One technical assumtion which will be important later is that our programs will use decimal representation
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

Even worse, for any string \\(\sigma\\), we can very well imagine a programming language which has \\(\sigma\\) as a built-in
constant. Thus the Kolmogorov complexity of a single string seems to very heavily depend on our language of choice. So
does this mean that our definition of \\(K\\) is arbitrary? What happens if we change our programming language?

Let us consider two notions of complexity \\(K_1\\), \\(K_2\\) corresponding
to two different programming languages \\(L_1\\) and \\(L_2\\), respectively. Since \\(L_1\\) is Turing complete, we can write a
*compiler* for \\(L_2\\) in \\(L_1\\). In other words, \\(L_1\\) can simulate \\(L_2\\). Let \\(\sigma\\) be a string and
let \\(n=K_2(\sigma)\\). Then there is a program \\(p\\) in the language \\(L_2\\) which witnesses the fact that \\(n=K_2(\sigma)\\).
That is, \\(p\\) has length \\(n\\) and \\(p\\) generates \\(\sigma\\). Now consider the following (description of a) program in \\(L_1\\):
Simulate \\(p\\). The length of this program will be \\(n + c\\) for some \\(c\\) becuse the program contains the string \\(p\\) and
\\(p\\) has length \\(n\\). The part corresponding to \\(c\\) is the part that simulates \\(L_2\\) and it does not depend on \\(\sigma\\).
By construction, "Simulate \\(p\\)" generates \\(\sigma\\), thus
\\[
  K_1(\sigma)\leq n + c = K_2(\sigma) + c.
\\]
We proved that there is a constant \\(c\\) such that \\(K_1(\sigma)\leq K_2(\sigma) + c\\) for all \\(\sigma\\). By symmetry,
there is a \\(c'\\) such that \\(K_2(\sigma)\leq K_1(\sigma) + c'\\) for all \\(\sigma\\). Combining these two we obtain
\\[
  |K_1(\sigma) - K_2(\sigma)| < {\rm max}\\{c, c'\\}.
\\]
This shows that if we consider an infinite family of strings and consider the asymptotic behaviour of Kolmogorov complexity
on that family, then the programming language we choose does not matter. Obviously, this does not imply that this asymptotic
behaviour is easy to determine.

From now on we will stick with a fixed but not explicitely determined choice of language and denote the complexity function
given by that language by \\(K\\).

At this point I would compute the Kolmogorov complexity of some concrete strings (or infinite families of strings) but it is tricky.
We can always give an upper bound for Kolmogorov complexity by explicitly constructing a program and measuring its length
but the tricky part is to show that no shorter program generates the same string. Actually, the problem is so difficult that
there is no general solution. To put it more concretely, the function  \\(K\\) is not computable. The aim of this post is to
give a proof of this result.

# Berry Paradox

Before moving on to the actual proof, let us see the underlying idea of the proof in a linguistic context. Let us consider the following
description of a number:

\begin{align}
&\texttt{the least natural number that cannot be}\newline
&\texttt{described in English by less than 88 characters}
\end{align}

Let \\(n\\) be the natural number defined by this description. But this description itself has only 87 characters, counting
spaces and digits, so \\(n\\) has a description with only 87 characters. Contradiction! This argument is known as the Berry
paradox. I will not go into a linguistic or philosophical debate here, there is already a substantial body of literature on the topic.

Now note that if we start with the following description, we cannot really say much about the number it describes,
nevertheless, we do not end up with a paradox either:

\begin{align}
&\texttt{the least natural number that cannot be}\newline
&\texttt{described in English by less than 75 characters}
\end{align}

Thus the number in the description is not arbitrary. Here is a natural question: What values of \\(n\\) give rise to the Berry paradox?
To answer that question we will make the number \\(n\\) a parameter. For a natural number \\(n\\) let \\(\ulcorner n \urcorner\\) be the
decimal expression of \\(n\\) as a string. So, for instance \\(\ulcorner 234 \urcorner = \texttt{234}\\), \\(\ulcorner 0 \urcorner = \texttt{0}\\),
etc. Now define \\(\Delta(n)\\) be

\begin{align}
&\texttt{the least natural number that cannot be}\newline
&\texttt{described in English by less than $\ulcorner n \urcorner$ characters}
\end{align}

Clearly a positive natural number \\(n\\) gives rise to the Berry paradox if \\(\ell(\Delta(n)) < n\\) where \\(\ell(\sigma)\\)
denotes the length of \\(\sigma\\). Note that
\\[
  \ell(\Delta(n)) = 85 + \ell(\ulcorner n \urcorner) = 85 + 1 + \lfloor \log_{10} n \rfloor.
\\]
because \\(\ell(\ulcorner n \urcorner)\\) is simply the number of digits of \\(n\\). So the inequality we should solve is
\\[
  86 + \lfloor \log_{10} n  \rfloor < n.
\\]
We can of course find the exact solution set of this inequality but what is more interesting is that we can immediately tell
that there are solutions. The reason is that the left hand side grows logartihmically and the right hand side grows linearly and hence
the right hand side should dominate the left hand side for all sufficiently large values of \\(n\\). Even better, if we change the
phrasing of the condition or express it in a different language such as  french, we would need to solve the equation \\(c + \lfloor \log_{10} n  \rfloor < n\\) for some constant \\(c\\) and, by the same argument, we would have a solution. Thus the Berry paradox is about exploiting the fact that our measure
of complexity can be referred to in a not so complex way. Note that if we were to use the unary system instead of decimal, that is if we expressed \\(n\\) as \\(n\\)-many \\(\texttt{1}\\)'s, then we would have \\(\ell(\Delta(n))=c + n\\) for some \\(n\\) and the Berry paradox would not come up.

# An Incomputability Result
Here is the theorem we: There is no computer program which takes \\(\sigma\\) as input and produces \\(\ulcorner K(\sigma) \urcorner\\)
as output. For the proof, we will mimic the Berry paradox.

Suppose that there *is* such a program \\(p\\). We will obtain a contradiction. Consider the following program:
\begin{align}
&\texttt{accept n as input}\newline
&\texttt{if n does not represent a natural number then halt}\newline
&\texttt{set x to be the first string in alphabetical order}\newline
&\texttt{while the Kolmogorov complexity of x is less than n}\newline
&\;\;\;\texttt{replace x by the next string in alphabetical order}\newline
&\texttt{return x}
\end{align}

Note that we use \\(p\\) to check the condition in the while loop. Also note that the while loop is never stuck because
there is no bound on the Kolmogorov complexity. So this program produces a string of complexity grater than \\(n\\) if its
input is \\(\ulcorner n \urcorner\\).

Now for each \\(n\\) we can construct a program \\(\tau_n\\) as follows:

\begin{align}
&\texttt{accept u as input}\newline
&\texttt{set x to be the first string in alphabetical order}\newline
&\texttt{while the Kolmogorov complexity of x is less than $\ulcorner n\urcorner$}\newline
&\;\;\;\texttt{replace x by the next string in alphabetical order}\newline
&\texttt{return x}
\end{align}

Clearly \\(\tau_n\\) ignores the input and behaves like \\(\tau\\) with input \\(\ulcorner n\urcorner\\). Moreover
\\(\ell(\tau_n) = \lfloor\log_{10}(n)\rfloor + c\\) for some constant \\(c\\). Thus, for a sufficiently large \\(k\\) we have \\(\ell(\tau_k) < k\\).

Let \\(\omega\\) be the string produced by \\(\\tau\\) on an input \\(\ulcorner k \urcorner\\) satisfying \\(\ell(\tau_k) < k\\). Here comes the finishing blow: By the construction of \\(\tau\\), we have \\(K(\omega)\geq k\\). On the other hand \\(\tau_k\\) also produces \\(\omega\\) (on any input) therefore we must have \\(K(\omega)\leq \ell(\tau_k)\\). But these two inequalities imply that \\(k \leq \ell(\tau_k)\\). Contradiction!

Let us summarize what we did: We defined a not exctly canonical notion of complexity which is impossible to compute in practice. So what can we even do with it? Well, mathematical logic of course! This will be the topic of the forthcoming post on Kolmogorov complexity.


